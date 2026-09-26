namespace WinPebble.PDFToImage.Cli;

internal sealed record CliOptions(OutputFormat Format, IReadOnlyList<string> InputFiles)
{
    public static CliOptions? TryParse(string[] args, out string? error)
    {
        error = null;

        if (args.Length == 0 ||
            args.Any(a => string.Equals(a, "--help", StringComparison.OrdinalIgnoreCase) ||
                          string.Equals(a, "-h", StringComparison.OrdinalIgnoreCase) ||
                          string.Equals(a, "/?", StringComparison.OrdinalIgnoreCase)))
        {
            return null;
        }

        OutputFormat? format = args[0].ToLowerInvariant() switch
        {
            "--png" => OutputFormat.Png,
            "--jpg" => OutputFormat.Jpg,
            "--jpeg" => OutputFormat.Jpg,
            _ => null
        };

        if (format is null)
        {
            error = "First argument must be --png or --jpg.";
            return null;
        }

        if (args.Length < 2)
        {
            error = "At least one PDF file is required.";
            return null;
        }

        var files = args
            .Skip(1)
            .Where(a => !string.IsNullOrWhiteSpace(a))
            .Select(Path.GetFullPath)
            .ToArray();

        if (files.Length == 0)
        {
            error = "At least one PDF file is required.";
            return null;
        }

        return new CliOptions(format.Value, files);
    }

    public static void PrintUsage()
    {
        Console.WriteLine("WinPebble PDF to Image — development core");
        Console.WriteLine();
        Console.WriteLine("Usage:");
        Console.WriteLine("  WinPebble.PDFToImage.exe --png <file.pdf> [more.pdf ...]");
        Console.WriteLine("  WinPebble.PDFToImage.exe --jpg <file.pdf> [more.pdf ...]");
        Console.WriteLine();
        Console.WriteLine("Current development target:");
        Console.WriteLine("  - Windows native PDF renderer (Windows.Data.Pdf)");
        Console.WriteLine("  - 300 DPI raster output");
        Console.WriteLine("  - PNG / JPG");
        Console.WriteLine("  - JPG encoder quality = 1.0");
        Console.WriteLine("  - 300 x 300 DPI metadata");
        Console.WriteLine("  - no Poppler");
    }
}
