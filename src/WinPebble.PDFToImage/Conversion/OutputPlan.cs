namespace WinPebble.PDFToImage.Conversion;

internal sealed class OutputPlan : IDisposable
{
    public IReadOnlyList<string> WorkingPaths { get; }
    public IReadOnlyList<string> FinalPaths { get; }
    public string? StagingDirectory { get; }
    public string? FinalDirectory { get; }
    public bool IsMultiPage => StagingDirectory is not null;

    private bool _committed;

    private OutputPlan(
        IReadOnlyList<string> workingPaths,
        IReadOnlyList<string> finalPaths,
        string? stagingDirectory,
        string? finalDirectory)
    {
        WorkingPaths = workingPaths;
        FinalPaths = finalPaths;
        StagingDirectory = stagingDirectory;
        FinalDirectory = finalDirectory;
    }

    public static OutputPlan Create(
        string pdfPath,
        int pageCount,
        OutputFormat format)
    {
        if (pageCount < 1)
        {
            throw new ArgumentOutOfRangeException(nameof(pageCount));
        }

        string directory = Path.GetDirectoryName(pdfPath)
            ?? throw new InvalidOperationException("Could not determine the PDF directory.");

        string baseName = Path.GetFileNameWithoutExtension(pdfPath);
        string extension = format == OutputFormat.Png ? ".png" : ".jpg";

        if (pageCount == 1)
        {
            string finalPath = OutputNaming.GetUniqueFilePath(
                Path.Combine(directory, baseName + extension)
            );

            return new OutputPlan(
                new[] { finalPath },
                new[] { finalPath },
                stagingDirectory: null,
                finalDirectory: null
            );
        }

        string label = format == OutputFormat.Png ? "PNG" : "JPG";

        string finalDirectory = OutputNaming.GetUniqueDirectoryPath(
            Path.Combine(directory, $"{baseName} - {label}")
        );

        string stagingDirectory = Path.Combine(
            directory,
            $".{Path.GetFileName(finalDirectory)}.{Guid.NewGuid():N}.winpebble.tmp"
        );

        Directory.CreateDirectory(stagingDirectory);

        int digits = Math.Max(3, pageCount.ToString().Length);

        var workingPaths = new string[pageCount];
        var finalPaths = new string[pageCount];

        for (int i = 0; i < pageCount; i++)
        {
            string pageNumber = (i + 1).ToString($"D{digits}");
            string filename = $"{baseName}_page_{pageNumber}{extension}";

            workingPaths[i] = Path.Combine(stagingDirectory, filename);
            finalPaths[i] = Path.Combine(finalDirectory, filename);
        }

        return new OutputPlan(
            workingPaths,
            finalPaths,
            stagingDirectory,
            finalDirectory
        );
    }

    public void Commit()
    {
        if (_committed)
        {
            return;
        }

        if (!IsMultiPage)
        {
            _committed = true;
            return;
        }

        if (StagingDirectory is null || FinalDirectory is null)
        {
            throw new InvalidOperationException("Invalid multi-page output plan.");
        }

        if (Directory.Exists(FinalDirectory) || File.Exists(FinalDirectory))
        {
            throw new IOException(
                $"The final output path became unavailable: {FinalDirectory}"
            );
        }

        MoveDirectoryWithRetry(StagingDirectory, FinalDirectory);
        _committed = true;
    }

    private static void MoveDirectoryWithRetry(
        string sourceDirectory,
        string destinationDirectory)
    {
        // Newly written folders in Downloads/Documents can be touched briefly
        // by Defender, Search Indexer, thumbnail handlers, cloud sync, etc.
        // Treat sharing/access failures as transient for a short bounded window.
        const int maxAttempts = 12;

        Exception? lastException = null;

        for (int attempt = 1; attempt <= maxAttempts; attempt++)
        {
            try
            {
                Directory.Move(sourceDirectory, destinationDirectory);
                return;
            }
            catch (UnauthorizedAccessException ex) when (attempt < maxAttempts)
            {
                lastException = ex;
            }
            catch (IOException ex) when (attempt < maxAttempts)
            {
                lastException = ex;
            }

            // Progressive delay: 100, 150, 200 ... 650 ms.
            int delayMilliseconds = 50 + (attempt * 50);
            Thread.Sleep(delayMilliseconds);
        }

        throw new IOException(
            $"Could not finalize the output folder after {maxAttempts} attempts. " +
            "Windows or another process may be temporarily using the folder.",
            lastException
        );
    }

    public void Dispose()
    {
        if (_committed || StagingDirectory is null)
        {
            return;
        }

        TryDeleteDirectory(StagingDirectory);
    }

    private static void TryDeleteDirectory(string path)
    {
        try
        {
            if (Directory.Exists(path))
            {
                Directory.Delete(path, recursive: true);
            }
        }
        catch
        {
            // Best-effort cleanup only. The caller will still receive the real conversion error.
        }
    }
}
