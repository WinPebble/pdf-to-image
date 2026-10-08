using System.Windows.Forms;
using WinPebble.PDFToImage.Cli;
using WinPebble.PDFToImage.Conversion;
using WinPebble.PDFToImage.UI;

namespace WinPebble.PDFToImage;

internal static class Program
{
    [STAThread]
    public static int Main(string[] args)
    {
        Console.OutputEncoding = System.Text.Encoding.UTF8;

        // The native File Explorer command opts in to the lightweight window.
        // Direct CLI usage retains all existing text progress and exit codes.
        bool showProgressWindow = args.Any(a =>
            string.Equals(a, "--progress-ui", StringComparison.OrdinalIgnoreCase));
        string[] originalCliArgs = args.Where(a =>
            !string.Equals(a, "--progress-ui", StringComparison.OrdinalIgnoreCase)).ToArray();

        CliOptions? options = CliOptions.TryParse(originalCliArgs, out string? parseError);
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

        if (showProgressWindow)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            using var context = new ConversionApplicationContext(options);
            Application.Run(context);
            return context.ExitCode;
        }

        return RunConsoleAsync(options).GetAwaiter().GetResult();
    }

    private static async Task<int> RunConsoleAsync(CliOptions options)
    {
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
            Console.Error.WriteLine(failures == 1 ? "1 file failed." : $"{failures} files failed.");
            return ExitCodes.ConversionFailed;
        }

        return ExitCodes.Success;
    }
}
