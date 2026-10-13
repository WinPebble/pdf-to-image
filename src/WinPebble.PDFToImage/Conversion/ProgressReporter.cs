namespace WinPebble.PDFToImage.Conversion;

internal interface IProgressReporter
{
    void FileStarted(string inputPath, int pageCount, OutputFormat format);
    void PageStarted(int pageNumber, int pageCount);
    void PageCompleted(int pageNumber, int pageCount, uint width, uint height, string outputPath);
    void FileCompleted(string inputPath);
}

internal sealed class ConsoleProgressReporter : IProgressReporter
{
    public void FileStarted(string inputPath, int pageCount, OutputFormat format)
    {
        Console.WriteLine();
        Console.WriteLine($"Input : {inputPath}");
        Console.WriteLine($"Pages : {pageCount}");
        Console.WriteLine($"Format: {format.ToString().ToUpperInvariant()}");
    }

    public void PageStarted(int pageNumber, int pageCount)
    {
        // Console remains concise; the window uses this callback to show liveness.
    }

    public void PageCompleted(
        int pageNumber,
        int pageCount,
        uint width,
        uint height,
        string outputPath)
    {
        Console.WriteLine($"  Page {pageNumber}/{pageCount}: {width}x{height}px -> {outputPath}");
    }

    public void FileCompleted(string inputPath)
    {
        Console.WriteLine("  Done.");
    }
}
