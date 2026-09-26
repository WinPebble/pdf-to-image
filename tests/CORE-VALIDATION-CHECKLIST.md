# Core validation checklist

After building the EXE, test these in order.

## Smoke
- [ ] A4 one-page -> PNG
- [ ] A4 one-page -> JPG
- [ ] output dimensions approximately 2480 x 3508 px
- [ ] PNG metadata 300 x 300 dpi
- [ ] JPG metadata 300 x 300 dpi
- [ ] JPG visual quality is good

## Output naming
- [ ] repeat PNG conversion -> `(2)` output, no overwrite
- [ ] repeat JPG conversion -> `(2)` output, no overwrite
- [ ] 3-page PDF -> dedicated PNG folder
- [ ] 3-page PDF -> dedicated JPG folder
- [ ] repeat multi-page conversion -> folder `(2)`

## File paths
- [ ] spaces in filename
- [ ] Vietnamese Unicode filename
- [ ] long-ish nested directory
- [ ] multiple PDFs in one command

## Failure behavior
- [ ] missing PDF gives understandable error
- [ ] non-PDF file rejected
- [ ] damaged PDF gives understandable error
- [ ] password-protected PDF gives understandable error
- [ ] no zero-byte final output left after failure

## Security / architecture
- [ ] no Poppler files
- [ ] conversion works offline
- [ ] original PDF unchanged
- [ ] no background process remains after conversion
