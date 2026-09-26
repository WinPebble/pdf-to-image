# WinPebble PDF to Image — Core v2 release gate

The following must pass before Explorer integration begins.

- [ ] PNG A4 2480 × 3508
- [ ] JPG A4 2480 × 3508
- [ ] PNG metadata ≈ 300 × 300 DPI
- [ ] JPG metadata ≈ 300 × 300 DPI
- [ ] source PDF hash unchanged
- [ ] single-page collision `(2)`
- [ ] landscape orientation
- [ ] A3 size
- [ ] Unicode/Vietnamese filename
- [ ] multi-page PNG output
- [ ] atomic final multi-page folder
- [ ] repeated multi-page folder `(2)`
- [ ] multiple PDFs in one invocation
- [ ] nested folder paths
- [ ] corrupt PDF fails cleanly
- [ ] password-protected PDF fails cleanly
- [ ] non-PDF fails cleanly
- [ ] no `.winpebble.tmp` artifacts
- [ ] no background process remains
