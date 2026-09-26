# SignPath Foundation readiness

## Already addressed

- [x] Public GitHub repository
- [x] MIT License
- [x] Full WinPebble-owned core source
- [x] Native Explorer integration source
- [x] Version-controlled build and packaging scripts
- [x] GitHub-hosted Windows CI build
- [x] Privacy statement
- [x] Code signing policy
- [x] Named SignPath roles for the current maintainer
- [x] Install/uninstall implementation documented
- [x] No telemetry/background service in the utility
- [x] NSIS Setup EXE release form
- [x] Product/version metadata aligned to `0.9.0-beta.1` / `0.9.0.1`
- [x] GitHub Actions builds and verifies the Setup EXE from `main`
- [x] CI-generated SHA-256
- [x] Development-certificate system change disclosed before installation
- [x] Development certificate removed during uninstall
- [x] Public `v0.9.0-beta.1` pre-release published
- [x] Release page includes Code signing policy and Privacy links

## Current public release

Release: `v0.9.0-beta.1`

https://github.com/WinPebble/pdf-to-image/releases/tag/v0.9.0-beta.1

Artifact:

```text
WinPebble-PDF-to-Image-Setup-0.9.0-beta.1-unsigned.exe
```

SHA-256:

```text
f0c13d6500dd1e8bacc0eedda56cd2663f2d6756b717ede6b63e96c67dd73872
```

Source/build commit:

```text
6ad99e83e4b13469a47a06883181bbecb3491587
```

## Required before application submission

- [ ] Confirm all current maintainers use GitHub multi-factor authentication
- [ ] Confirm the SignPath applicant will enable/use SignPath multi-factor authentication
- [ ] Review `SIGNPATH_APPLICATION_DRAFT.md`
- [ ] Submit the SignPath Foundation application

## After SignPath Foundation approval

- [ ] Configure the approved SignPath/GitHub integration
- [ ] Configure the trusted/verifiable GitHub build system
- [ ] Define artifact configuration and enforce product/version metadata restrictions
- [ ] Add production signing-request workflow
- [ ] Require manual approval for every production signing request
- [ ] Remove development certificate requirements from the production release path
- [ ] Validate signed installer with Smart App Control and Microsoft Defender enabled
- [ ] Publish the first production-signed release
