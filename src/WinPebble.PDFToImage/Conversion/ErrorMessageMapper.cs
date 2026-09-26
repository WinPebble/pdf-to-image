using System.Runtime.InteropServices;

namespace WinPebble.PDFToImage.Conversion;

internal static class ErrorMessageMapper
{
    public static string ToUserMessage(Exception exception)
    {
        Exception ex = Unwrap(exception);

        return ex switch
        {
            FileNotFoundException =>
                "The PDF file could not be found.",

            UnauthorizedAccessException =>
                "WinPebble does not have permission to read the PDF or write to this folder.",

            PathTooLongException =>
                "The file path is too long for this operation.",

            IOException ioEx =>
                $"A file operation failed: {ioEx.Message}",

            COMException =>
                "Windows could not open or render this PDF. The file may be damaged, unsupported, or password-protected.",

            InvalidDataException dataEx =>
                dataEx.Message,

            _ =>
                $"Unexpected error: {ex.Message}"
        };
    }

    private static Exception Unwrap(Exception exception)
    {
        while (exception.InnerException is not null &&
               (exception is AggregateException ||
                exception is System.Reflection.TargetInvocationException))
        {
            exception = exception.InnerException;
        }

        return exception;
    }
}
