# Store icon refresh 1.0.1.0

This change only updates the PDF-to-Image visual identity and the Microsoft Store MSIX
package version from `1.0.0.0` to `1.0.1.0`, as required for an update.

- Replace `Square44x44Logo.png`, `Square150x150Logo.png` and `StoreLogo.png`.
- Keep the official Microsoft Store package name, publisher CN and Store ID unchanged.
- Keep the conversion core and native File Explorer shell extension unchanged.
- No changes to features, privacy behavior, dependencies, or minimum OS version.
- The semantic product version remains `0.9.0-beta.1` for this icon-only correction.
- The development MSIX lane remains unchanged; it may consume the updated shared icon assets when rebuilt.

Release process:
1. Review GitHub PR and wait for all build checks to pass.
2. Merge the PR to `main` after reviewing its diff.
3. Download the *main-branch* Microsoft Store MSIX artifact, check the version and icon assets.
4. Create a **new** Partner Center update submission (Store ID `9NRZMPGMQPS4`).
5. Upload the updated MSIX, finish validation, and submit for certification.
6. Test the signed Store-delivered update. The old public app remains available while the update is processed.

Never upload the development-only self-signed MSIX as the Store update.