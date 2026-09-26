namespace WinPebble.PDFToImage.Conversion;

internal interface IProgressReporter
{
    void FileStarted(string inputPath, int pageCount, OutputFormat format);
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

    public void PageCompleted(
        int pageNumber,
        int pageCount,
        uint width,
        uint height,
        string outputPath)
    {
        Console.WriteLine(
            $"  Page {pageNumber}/{pageCount}: {width}x{height}px -> {outputPath}"
        );
    }

    public void FileCompleted(string inputPath)
    {
        Console.WriteLine("  Done.");
    }
}
