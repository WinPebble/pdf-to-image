namespace WinPebble.PDFToImage.Conversion;

internal static class OutputNaming
{
    public static string GetUniqueFilePath(string path)
    {
        if (!File.Exists(path) && !Directory.Exists(path))
        {
            return path;
        }

        string directory = Path.GetDirectoryName(path)
            ?? throw new InvalidOperationException("Could not determine output directory.");

        string name = Path.GetFileNameWithoutExtension(path);
        string extension = Path.GetExtension(path);

        for (int number = 2; ; number++)
        {
            string candidate = Path.Combine(
                directory,
                $"{name} ({number}){extension}"
            );

            if (!File.Exists(candidate) && !Directory.Exists(candidate))
            {
                return candidate;
            }
        }
    }

    public static string GetUniqueDirectoryPath(string path)
    {
        if (!Directory.Exists(path) && !File.Exists(path))
        {
            return path;
        }

        for (int number = 2; ; number++)
        {
            string candidate = $"{path} ({number})";

            if (!Directory.Exists(candidate) && !File.Exists(candidate))
            {
                return candidate;
            }
        }
    }
}
