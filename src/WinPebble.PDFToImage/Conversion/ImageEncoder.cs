using Windows.Foundation;
using Windows.Graphics.Imaging;
using Windows.Storage;
using Windows.Storage.Streams;

namespace WinPebble.PDFToImage.Conversion;

internal static class ImageEncoder
{
    private const double OutputDpi = 300.0;

    public static async Task EncodeRenderedPngAsync(
        IRandomAccessStream renderedPngStream,
        string finalOutputPath,
        OutputFormat format)
    {
        renderedPngStream.Seek(0);

        BitmapDecoder decoder = await BitmapDecoder.CreateAsync(renderedPngStream);

        PixelDataProvider pixelProvider = await decoder.GetPixelDataAsync(
            BitmapPixelFormat.Bgra8,
            BitmapAlphaMode.Ignore,
            new BitmapTransform(),
            ExifOrientationMode.IgnoreExifOrientation,
            ColorManagementMode.ColorManageToSRgb
        );

        byte[] pixels = pixelProvider.DetachPixelData();

        string tempPath = CreateTemporaryOutputPath(finalOutputPath);

        try
        {
            using (File.Create(tempPath))
            {
                // Create an empty file first so StorageFile can open it.
            }

            StorageFile outputFile = await StorageFile.GetFileFromPathAsync(tempPath);

            using IRandomAccessStream outputStream =
                await outputFile.OpenAsync(FileAccessMode.ReadWrite);

            BitmapEncoder encoder;

            if (format == OutputFormat.Jpg)
            {
                var encoderOptions = new BitmapPropertySet
                {
                    {
                        "ImageQuality",
                        new BitmapTypedValue(1.0f, PropertyType.Single)
                    }
                };

                encoder = await BitmapEncoder.CreateAsync(
                    BitmapEncoder.JpegEncoderId,
                    outputStream,
                    encoderOptions
                );
            }
            else
            {
                encoder = await BitmapEncoder.CreateAsync(
                    BitmapEncoder.PngEncoderId,
                    outputStream
                );
            }

            encoder.SetPixelData(
                BitmapPixelFormat.Bgra8,
                BitmapAlphaMode.Ignore,
                decoder.PixelWidth,
                decoder.PixelHeight,
                OutputDpi,
                OutputDpi,
                pixels
            );

            await encoder.FlushAsync();

            // The final filename only appears after a complete successful encode.
            File.Move(tempPath, finalOutputPath);
        }
        catch
        {
            TryDelete(tempPath);
            throw;
        }
    }

    private static string CreateTemporaryOutputPath(string finalOutputPath)
    {
        string directory = Path.GetDirectoryName(finalOutputPath)
            ?? throw new InvalidOperationException("Could not determine output directory.");

        string name = Path.GetFileName(finalOutputPath);

        return Path.Combine(
            directory,
            $".{name}.{Guid.NewGuid():N}.winpebble.tmp"
        );
    }

    private static void TryDelete(string path)
    {
        try
        {
            if (File.Exists(path))
            {
                File.Delete(path);
            }
        }
        catch
        {
            // Best-effort cleanup only.
        }
    }
}
