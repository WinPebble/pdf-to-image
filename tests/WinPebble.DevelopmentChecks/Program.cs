using System.Reflection;
using System.Security.Cryptography;
using System.Windows.Forms;
using WinPebble.PDFToImage;
using WinPebble.PDFToImage.Conversion;
using WinPebble.PDFToImage.UI;

internal static class DevelopmentChecks
{
    [STAThread]
    private static int Main(string[] args)
    {
        string root = Path.GetFullPath(args[0]);
        string work = Path.Combine(root, "artifacts", "development-checks", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(work);
        int failed = 0;
        foreach (OutputFormat format in new[] { OutputFormat.Png, OutputFormat.Jpg })
        {
            foreach (string mode in new[] { "pre-cancel", "file-start", "single-after-encode", "collision", "multi-first", "multi-last", "locked-output", "readonly-output" })
            {
                try
                {
                    CheckCancellationAsync(root, work, format, mode).GetAwaiter().GetResult();
                    Console.WriteLine($"PASS: {format} / {mode}");
                }
                catch (Exception ex)
                {
                    failed++;
                    Console.Error.WriteLine($"FAIL: {format} / {mode}: {ex.Message}");
                }
            }
        }
        try { CheckWindowState(); Console.WriteLine("PASS: hidden WinForms progress state"); }
        catch (Exception ex) { failed++; Console.Error.WriteLine($"FAIL: window state: {ex.Message}"); }
        Console.WriteLine($"Checks: {17 - failed}/17 passed. Outputs: {work}");
        return failed == 0 ? 0 : 1;
    }

    private static async Task CheckCancellationAsync(string root, string work, OutputFormat format, string mode)
    {
        string folder = Path.Combine(work, format + "-" + mode);
        Directory.CreateDirectory(folder);
        bool multi = mode.StartsWith("multi-", StringComparison.Ordinal);
        string pdf = Path.Combine(folder, "Input.pdf");
        File.Copy(Path.Combine(root, "tests", multi ? "Hardening-MultiPage.pdf" : "Hardening-A4.pdf"), pdf);
        string before = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(pdf)));
        string extension = format == OutputFormat.Png ? ".png" : ".jpg";
        string final = Path.ChangeExtension(pdf, extension);
        bool blockedCleanup = mode is "locked-output" or "readonly-output";
        bool collision = mode == "collision" || blockedCleanup;
        if (collision) File.WriteAllText(final, "existing user output");
        using var cancel = new CancellationTokenSource();
        if (mode == "pre-cancel") cancel.Cancel();
        using var reporter = new CancellingReporter(cancel, mode);
        bool cancelled = false;
        try { await new PdfConverter(reporter).ConvertAsync(pdf, format, cancel.Token); }
        catch (OperationCanceledException) when (cancel.IsCancellationRequested) { cancelled = true; }
        Require(cancelled, "Conversion must report cancellation");
        Require(before == Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(pdf))), "Source PDF changed");
        Require(!reporter.Completed, "Cancelled file must not report successful completion");
        Require(!Directory.EnumerateFileSystemEntries(folder).Any(p => p.Contains(".winpebble.tmp", StringComparison.Ordinal)), "Staging/temp output remains");
        Require(!Directory.EnumerateDirectories(folder).Any(), "Cancelled multi-page final folder exists");
        string[] images = Directory.GetFiles(folder, "*" + extension);
        if (blockedCleanup)
        {
            Require(reporter.BlockedDeleteConfirmed, "Fixture must cause a real Windows deletion failure");
            Require(images.Length == 2, "Best-effort cleanup must leave only the blocked new image and existing output");
            Require(File.ReadAllText(final) == "existing user output", "Pre-existing output changed");
            Require(reporter.CreatedPath != final && File.Exists(reporter.CreatedPath), "Wrong output was targeted for cleanup");
            Require(reporter.CreatedHash == Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(reporter.CreatedPath!))), "Blocked new output changed");
        }
        else if (mode == "collision")
        {
            Require(images.Length == 1 && File.ReadAllText(final) == "existing user output", "Must preserve existing output and discard only new image");
        }
        else Require(images.Length == 0, "Cancelled file left a final image");
    }

    private static void CheckWindowState()
    {
        using var window = new ProgressWindow(); // Never shown; this is component state, not a device/UI acceptance test.
        window.StartFile("Example.pdf", 3, "PNG", 2, 4);
        window.CompletePage(1, 3);
        Require(Field<ProgressBar>(window, "_bar").Value == 33, "Current PDF progress should be 33%");
        Require(Field<Label>(window, "_batch").Text.Contains("File 2 of 4"), "Batch counter incorrect");
        window.StartFile("Next.pdf", 2, "JPG", 3, 4);
        Require(Field<ProgressBar>(window, "_bar").Value == 0, "Next PDF must reset percentage");
        window.FinishCancelled(2);
        Require(Field<Button>(window, "_action").Text == "Close", "Cancelled window must offer Close");
        Require(Field<Label>(window, "_page").Text.Contains("2"), "Completed count missing");
        window.AllowClose();
    }

    private static T Field<T>(object owner, string name) =>
        (T)owner.GetType().GetField(name, BindingFlags.Instance | BindingFlags.NonPublic)!.GetValue(owner)!;

    private static void Require(bool condition, string message)
    {
        if (!condition) throw new InvalidOperationException(message);
    }

    private sealed class CancellingReporter(CancellationTokenSource cancel, string mode) : IProgressReporter, IDisposable
    {
        private FileStream? _lockedOutput;
        public bool BlockedDeleteConfirmed { get; private set; }
        public string? CreatedPath { get; private set; }
        public string? CreatedHash { get; private set; }
        public bool Completed { get; private set; }
        public void FileStarted(string path, int pages, OutputFormat format) { if (mode == "file-start") cancel.Cancel(); }
        public void PageStarted(int page, int pages) { }
        public void PageCompleted(int page, int pages, uint width, uint height, string output)
        {
            if (mode is "locked-output" or "readonly-output")
            {
                CreatedPath = output;
                CreatedHash = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(output)));
                if (mode == "locked-output")
                    _lockedOutput = new FileStream(output, FileMode.Open, FileAccess.Read, FileShare.Read);
                else
                    File.SetAttributes(output, File.GetAttributes(output) | FileAttributes.ReadOnly);
                // Verify real OS failure rather than substituting a mock delete.
                try { File.Delete(output); }
                catch (IOException) when (mode == "locked-output") { BlockedDeleteConfirmed = true; }
                catch (UnauthorizedAccessException) when (mode == "readonly-output") { BlockedDeleteConfirmed = true; }
                if (!BlockedDeleteConfirmed) throw new InvalidOperationException("Deletion-blocking fixture failed");
                cancel.Cancel();
            }
            if (mode is "single-after-encode" or "collision" || mode == "multi-first" && page == 1 || mode == "multi-last" && page == pages)
                cancel.Cancel();
        }
        public void FileCompleted(string path) => Completed = true;
        public void Dispose()
        {
            _lockedOutput?.Dispose();
            if (mode == "readonly-output" && CreatedPath is not null && File.Exists(CreatedPath))
                File.SetAttributes(CreatedPath, File.GetAttributes(CreatedPath) & ~FileAttributes.ReadOnly);
        }
    }
}
