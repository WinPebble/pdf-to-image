using WinPebble.PDFToImage.Cli;
using WinPebble.PDFToImage.Conversion;

namespace WinPebble.PDFToImage;

internal static class Program
{
    public static async Task<int> Main(string[] args)
    {
        Console.OutputEncoding = System.Text.Encoding.UTF8;

        CliOptions? options = CliOptions.TryParse(args, out string? parseError);

        if (options is null)
        {
            if (!string.IsNullOrWhiteSpace(parseError))
            {
                Console.Error.WriteLine(parseError);
                Console.Error.WriteLine();
            }

            CliOptions.PrintUsage();
            return ExitCodes.InvalidArguments;
        }

        var converter = new PdfConverter(new ConsoleProgressReporter());

        int failures = 0;

        foreach (string input in options.InputFiles)
        {
            try
            {
                await converter.ConvertAsync(input, options.Format);
            }
            catch (Exception ex)
            {
                failures++;
                Console.Error.WriteLine();
                Console.Error.WriteLine($"FAILED: {input}");
                Console.Error.WriteLine(ErrorMessageMapper.ToUserMessage(ex));
            }
        }

        if (failures > 0)
        {
            Console.Error.WriteLine();
            Console.Error.WriteLine(
                failures == 1
                    ? "1 file failed."
                    : $"{failures} files failed."
            );

            return ExitCodes.ConversionFailed;
        }

        return ExitCodes.Success;
    }
}
