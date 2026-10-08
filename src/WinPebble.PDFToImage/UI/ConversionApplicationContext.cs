using System.Windows.Forms;
using WinPebble.PDFToImage.Cli;
using WinPebble.PDFToImage.Conversion;

namespace WinPebble.PDFToImage.UI;

// The Explorer-invoked process owns one short-lived UI thread and worker.
// There is no resident service, task-tray process or global window.
internal sealed class ConversionApplicationContext : ApplicationContext, IProgressReporter
{
    private readonly CliOptions _options;
    private readonly ProgressWindow _window;
    private readonly CancellationTokenSource _cancel = new();
    private readonly System.Windows.Forms.Timer _showDelay;
    private System.Windows.Forms.Timer? _successDelay;

    private int _currentFileIndex;
    private bool _completed;
    private bool _shuttingDown;

    public int ExitCode { get; private set; } = ExitCodes.Success;

    public ConversionApplicationContext(CliOptions options)
    {
        _options = options;
        _window = new ProgressWindow();
        _window.CancelRequested += () => _cancel.Cancel();
        _window.CloseRequested += CloseAndExit;

        // Marshal callbacks to a real HWND, even while the window is hidden.
        _ = _window.Handle;

        _showDelay = new System.Windows.Forms.Timer { Interval = 750 };
        _showDelay.Tick += (_, _) =>
        {
            _showDelay.Stop();
            if (!_completed && !_window.IsDisposed)
            {
                _window.Show();
            }
        };
        _showDelay.Start();

        _ = Task.Run(ProcessFilesAsync);
    }

    private async Task ProcessFilesAsync()
    {
        int succeeded = 0;
        int failed = 0;
        bool cancelled = false;
        string lastError = "";
        var converter = new PdfConverter(this);

        try
        {
            for (int i = 0; i < _options.InputFiles.Count; i++)
            {
                string inputPath = _options.InputFiles[i];
                Interlocked.Exchange(ref _currentFileIndex, i + 1);
                if (_cancel.IsCancellationRequested)
                {
                    cancelled = true;
                    break;
                }

                try
                {
                    await converter.ConvertAsync(inputPath, _options.Format, _cancel.Token);
                    succeeded++;
                }
                catch (OperationCanceledException) when (_cancel.IsCancellationRequested)
                {
                    cancelled = true;
                    break;
                }
                catch (Exception ex)
                {
                    failed++;
                    lastError = $"{Path.GetFileName(inputPath)}: {ErrorMessageMapper.ToUserMessage(ex)}";
                    string capturedInput = inputPath;
                    string capturedError = ErrorMessageMapper.ToUserMessage(ex);
                    Post(() => _window.RecordError(capturedInput, capturedError));
                }
            }
        }
        catch (Exception ex)
        {
            failed++;
            lastError = ErrorMessageMapper.ToUserMessage(ex);
        }

        int completedCount = succeeded;
        int failedCount = failed;
        bool wasCancelled = cancelled;
        string finalError = lastError;
        Post(() => Finish(completedCount, failedCount, wasCancelled, finalError));
    }

    private void Finish(int succeeded, int failed, bool cancelled, string lastError)
    {
        if (_shuttingDown) return;
        _completed = true;
        _showDelay.Stop();

        if (cancelled)
        {
            ExitCode = ExitCodes.Cancelled;
            if (!_window.Visible) _window.Show();
            _window.FinishCancelled(succeeded);
        }
        else if (failed > 0)
        {
            ExitCode = ExitCodes.ConversionFailed;
            if (!_window.Visible) _window.Show();
            _window.FinishWithErrors(succeeded, failed, lastError);
        }
        else if (_window.Visible)
        {
            ExitCode = ExitCodes.Success;
            _window.FinishSuccess(succeeded);
            _successDelay = new System.Windows.Forms.Timer { Interval = 1250 };
            _successDelay.Tick += (_, _) => CloseAndExit();
            _successDelay.Start();
        }
        else
        {
            // Fast conversions produce no distracting popup/flicker.
            CloseAndExit();
        }
    }

    private void CloseAndExit()
    {
        if (_shuttingDown) return;
        _shuttingDown = true;
        _showDelay.Stop();
        _successDelay?.Stop();
        _successDelay?.Dispose();
        _showDelay.Dispose();
        _window.AllowClose();
        _window.Close();
        _cancel.Dispose();
        ExitThread();
    }

    private void Post(Action uiAction)
    {
        try
        {
            if (_window.IsDisposed || !_window.IsHandleCreated) return;
            _window.BeginInvoke((MethodInvoker)(() =>
            {
                if (!_shuttingDown && !_window.IsDisposed) uiAction();
            }));
        }
        catch (InvalidOperationException)
        {
            // The UI is already closing.
        }
        catch (ObjectDisposedException)
        {
            // The UI is already closing.
        }
    }

    public void FileStarted(string inputPath, int pageCount, OutputFormat format)
    {
        int fileNumber = Volatile.Read(ref _currentFileIndex);
        int totalFiles = _options.InputFiles.Count;
        string formatName = format == OutputFormat.Png ? "PNG" : "JPG";
        Post(() => _window.StartFile(inputPath, pageCount, formatName, fileNumber, totalFiles));
    }

    public void PageStarted(int pageNumber, int pageCount) =>
        Post(() => _window.StartPage(pageNumber, pageCount));

    public void PageCompleted(int pageNumber, int pageCount, uint width, uint height, string outputPath) =>
        Post(() => _window.CompletePage(pageNumber, pageCount));

    public void FileCompleted(string inputPath) => Post(_window.CompleteFile);
}
