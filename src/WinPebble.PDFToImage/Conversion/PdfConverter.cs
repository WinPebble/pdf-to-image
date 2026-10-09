using Windows.Data.Pdf;
using Windows.Graphics.Imaging;
using Windows.Storage;
using Windows.Storage.Streams;

namespace WinPebble.PDFToImage.Conversion;

internal sealed class PdfConverter
{
    private const double OutputDpi = 300.0;
    private const double WindowsDipDpi = 96.0;

    private readonly IProgressReporter _progress;

    public PdfConverter(IProgressReporter progress)
    {
        _progress = progress;
    }

    public async Task ConvertAsync(
        string inputPath,
        OutputFormat format,
        CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        string pdfPath = ValidateInputPath(inputPath);

        StorageFile inputFile = await StorageFile.GetFileFromPathAsync(pdfPath);
        cancellationToken.ThrowIfCancellationRequested();
        PdfDocument document = await PdfDocument.LoadFromFileAsync(inputFile);
        cancellationToken.ThrowIfCancellationRequested();

        int pageCount = checked((int)document.PageCount);
        if (pageCount < 1)
        {
            throw new InvalidDataException("The PDF contains no pages.");
        }

        _progress.FileStarted(pdfPath, pageCount, format);
        using OutputPlan plan = OutputPlan.Create(pdfPath, pageCount, format);

        for (int index = 0; index < pageCount; index++)
        {
            cancellationToken.ThrowIfCancellationRequested();
            _progress.PageStarted(index + 1, pageCount);

            using PdfPage page = document.GetPage((uint)index);
            (uint width, uint height) = GetOutputPixelSize(page);
            using var renderStream = new InMemoryRandomAccessStream();

            var white = new Windows.UI.Color { A = 255, R = 255, G = 255, B = 255 };
            var renderOptions = new PdfPageRenderOptions
            {
                DestinationWidth = width,
                DestinationHeight = height,
                BackgroundColor = white,
                // Preserve the current lossless intermediate rendering path.
                BitmapEncoderId = BitmapEncoder.PngEncoderId
            };

            // This Windows API does not take our CancellationToken. Cancel is
            // cooperative at page boundaries and between rendering/encoding.
            await page.RenderToStreamAsync(renderStream, renderOptions);
            cancellationToken.ThrowIfCancellationRequested();

            string workingPath = plan.WorkingPaths[index];
            await ImageEncoder.EncodeRenderedPngAsync(renderStream, workingPath, format);

            // For multi-page documents all images live in a hidden staging
            // directory until Commit. Cancel cleans that directory via Dispose.
            // For a single page, encoding already placed a complete image in
            // the final location, so remove only our newly generated output.
            if (cancellationToken.IsCancellationRequested)
            {
                if (!plan.IsMultiPage && File.Exists(workingPath))
                {
                    File.Delete(workingPath);
                }
                cancellationToken.ThrowIfCancellationRequested();
            }

            _progress.PageCompleted(
                index + 1, pageCount, width, height, plan.FinalPaths[index]);
        }

        // Do not publish a partly-rendered multi-page directory on cancel.
        cancellationToken.ThrowIfCancellationRequested();
        plan.Commit();
        _progress.FileCompleted(pdfPath);
    }

    private static string ValidateInputPath(string inputPath)
    {
        string fullPath = Path.GetFullPath(inputPath);
        if (!File.Exists(fullPath))
        {
            throw new FileNotFoundException("PDF file not found.", fullPath);
        }
        if (!string.Equals(Path.GetExtension(fullPath), ".pdf", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidDataException("Input file must have the .pdf extension.");
        }
        return fullPath;
    }

    private static (uint Width, uint Height) GetOutputPixelSize(PdfPage page)
    {
        double scale = OutputDpi / WindowsDipDpi;
        uint width = checked((uint)Math.Max(1, Math.Round(page.Size.Width * scale)));
        uint height = checked((uint)Math.Max(1, Math.Round(page.Size.Height * scale)));
        return (width, height);
    }
}
