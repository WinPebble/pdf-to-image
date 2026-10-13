using System.Drawing;
using System.Windows.Forms;

namespace WinPebble.PDFToImage.UI;

internal sealed class ProgressWindow : Form
{
    private readonly Label _headline;
    private readonly Label _percentage;
    private readonly Label _file;
    private readonly Label _page;
    private readonly Label _batch;
    private readonly Label _detail;
    private readonly ProgressBar _bar;
    private readonly Button _action;

    private bool _finished;
    private bool _closingAllowed;
    private bool _cancelRequested;

    public event Action? CancelRequested;
    public event Action? CloseRequested;

    public ProgressWindow()
    {
        Text = "WinPebble PDF to Image";
        FormBorderStyle = FormBorderStyle.FixedDialog;
        StartPosition = FormStartPosition.CenterScreen;
        MaximizeBox = false;
        MinimizeBox = true;
        ShowInTaskbar = true;
        AutoScaleMode = AutoScaleMode.Dpi;
        ClientSize = new Size(488, 225);
        Font = new Font("Segoe UI", 9F);

        _headline = new Label
        {
            Location = new Point(18, 19), Size = new Size(373, 26),
            Font = new Font(Font, FontStyle.Bold), Text = "Preparing conversion..."
        };
        _percentage = new Label
        {
            Location = new Point(396, 19), Size = new Size(74, 26),
            Text = "0%", TextAlign = ContentAlignment.TopRight
        };
        _bar = new ProgressBar
        {
            Location = new Point(18, 53), Size = new Size(452, 16),
            Minimum = 0, Maximum = 100, Value = 0,
            Style = ProgressBarStyle.Continuous
        };
        _file = new Label
        {
            Location = new Point(18, 85), Size = new Size(452, 24),
            AutoEllipsis = true, Text = "Waiting for input..."
        };
        _page = new Label
        {
            Location = new Point(18, 111), Size = new Size(452, 22),
            Text = "Preparing pages..."
        };
        _batch = new Label
        {
            Location = new Point(18, 136), Size = new Size(452, 22),
            Text = "", ForeColor = SystemColors.GrayText
        };
        _detail = new Label
        {
            Location = new Point(18, 168), Size = new Size(344, 43),
            AutoEllipsis = true, ForeColor = SystemColors.GrayText,
            Text = "Processing locally. Your original PDF stays unchanged."
        };
        _action = new Button
        {
            Location = new Point(371, 177), Size = new Size(99, 30),
            Text = "Cancel", UseVisualStyleBackColor = true
        };
        _action.Click += (_, _) =>
        {
            if (_finished) CloseRequested?.Invoke();
            else RequestCancel();
        };

        Controls.AddRange(new Control[]
        {
            _headline, _percentage, _bar, _file, _page, _batch, _detail, _action
        });
    }

    public void StartFile(string path, int pageCount, string format, int fileNumber, int fileTotal)
    {
        _headline.Text = $"Converting to {format}...";
        _percentage.Text = "0%";
        _bar.Value = 0;
        _file.Text = Path.GetFileName(path);
        _page.Text = $"0 of {pageCount} pages complete";
        _batch.Text = $"File {fileNumber} of {fileTotal}  |  Progress for current PDF";
        if (!_cancelRequested)
        {
            _detail.Text = "Rendering pages locally. Large pages can take longer.";
        }
    }

    public void StartPage(int pageNumber, int pageCount)
    {
        if (!_cancelRequested)
        {
            _page.Text = $"Rendering page {pageNumber} of {pageCount}...";
        }
    }

    public void CompletePage(int pageNumber, int pageCount)
    {
        int percent = (int)((100L * pageNumber) / pageCount);
        _bar.Value = Math.Clamp(percent, 0, 100);
        _percentage.Text = $"{percent}%";
        if (!_cancelRequested)
        {
            _page.Text = $"{pageNumber} of {pageCount} pages complete";
        }
    }

    public void CompleteFile()
    {
        if (!_cancelRequested)
        {
            _page.Text = "Output saved successfully.";
        }
    }

    public void RecordError(string path, string message)
    {
        _detail.Text = $"{Path.GetFileName(path)}: {message}";
    }

    public void FinishSuccess(int succeeded)
    {
        _finished = true;
        _headline.Text = "Conversion completed";
        _page.Text = succeeded == 1 ? "1 PDF converted successfully." :
            $"{succeeded} PDFs converted successfully.";
        _detail.Text = "Your original PDF files are unchanged.";
        _action.Enabled = false;
    }

    public void FinishWithErrors(int succeeded, int failed, string lastError)
    {
        _finished = true;
        _headline.Text = "Finished with errors";
        _page.Text = $"{succeeded} succeeded, {failed} failed.";
        _detail.Text = lastError;
        _action.Text = "Close";
        _action.Enabled = true;
    }

    public void FinishCancelled(int succeeded)
    {
        _finished = true;
        _headline.Text = "Conversion cancelled";
        _page.Text = $"Completed files preserved: {succeeded}.";
        _detail.Text = "Incomplete multi-page output was discarded.";
        _action.Text = "Close";
        _action.Enabled = true;
    }

    private void RequestCancel()
    {
        if (_cancelRequested) return;
        _cancelRequested = true;
        _headline.Text = "Cancelling...";
        _detail.Text = "Waiting for the current rendering step to finish.";
        _action.Enabled = false;
        CancelRequested?.Invoke();
    }

    protected override void OnFormClosing(FormClosingEventArgs e)
    {
        if (!_closingAllowed)
        {
            e.Cancel = true;
            if (_finished) CloseRequested?.Invoke();
            else RequestCancel();
            return;
        }
        base.OnFormClosing(e);
    }

    public void AllowClose() => _closingAllowed = true;
}
