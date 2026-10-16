# Store 1.0.2.0 release candidate

Historical preparation snapshot. Partner Center subsequently confirmed Submission 3 /
1.0.2.0 published on 2026-10-15. The next candidate is the [1.0.3.0 shared logo
update](../branding/SHARED_BRAND_ICON.md); statements below describe the earlier preparation stage.

Prepared 2026-10-13. Status: PREPARATION ONLY, not uploaded, certified or published. Main baseline: `cf9f7ad0180c26cc987f4d22251979d1f717e6d5` (PR #12). Documentation PR #13 is independent and is not merged by this task.

## Approved preparation scope

- Maintainer confirms the highest Partner Center package version, including pending submissions, is 1.0.1.0. Candidate package version: 1.0.2.0, x64.
- Use Windows 10 minimum 10.0.19041.0, matching the development manifest used for testing, and Windows 11. This admits Windows 10 2004+; earlier Windows 10 builds are outside this package's declared scope.
- The maintainer explicitly declined additional Windows 10 device testing. That is a documented scope/risk acceptance, not evidence of a PASS on every admitted Windows 10 build. Actual device evidence covers Windows 10 22H2 build 19045.7725 and Windows 11 build 26300.9457 for the hash-identified dev binary.
- Include existing merged Progress UI/Cancel and cleanup fixes. No changes to PDF rendering, encoding, output names, shell CLSIDs or conversion logic.
- Preserve exact Store name/publisher from [STORE_IDENTITY.md](STORE_IDENTITY.md). Full-dev and sparse identities remain separate. Candidate is unsigned for Store submission and contains no development certificate/private key.

## Version review

Only Store Package/Identity Version changes from 1.0.1.0 to 1.0.2.0. Build-MSIX-Store assertions/output filenames, the Store workflow artifact name/paths, BUILDING and submission guidance are synchronized.

C# ProductVersion/InformationalVersion remains 0.9.0-beta.1; assembly/file version remains 0.9.0.1. Native RC, NSIS metadata, sparse manifest and full-dev version/filenames are reviewed and deliberately unchanged. These version systems are distinct; changing them is unnecessary for a Store package update and would alter the already tested executable inputs. Do not describe the package version as its FileVersion. The beta-labelled product metadata remains visible in binaries; review that choice before submission if stable product branding is desired.

MaxVersionTested stays 10.0.26100.0; this metadata is not an exhaustive runtime compatibility claim. Target framework and trimming/self-contained build settings are unchanged.

## Validation and evidence gates

- Build the unsigned Store candidate with canonical Build-MSIX-Store.ps1; record source SHA/dirty state, OS/tools, MSIX/EXE/DLL hashes and actual results in a candidate validation record.
- Verify packed official identity, 1.0.2.0 x64, MinVersion 10.0.19041.0, required payload and absence of AppxSignature.p7x/certificate/private-key material.
- Run hardening against the candidate's actual staged executable and the 17-case conversion/cleanup regression. These do not install the official-identity package or test Store upgrade/delivery.
- CI build outputs are validation artifacts, not automatic publication. Candidate CI runs/hashes are separate from previous local dev package evidence.
- Official Store identity installation/upgrade lifecycle, WACK, display scaling/keyboard, exact timing and certain finalization races require separate execution or explicit disposition. No package install/removal, certificate trust change or Explorer restart is performed by preparation.
- Record the maintainer's decision to omit additional Windows 10 device tests separately from automated checks. Do not relabel omitted cases as passed.

## Submission handoff (requires separate approval)

1. Review the final candidate validation record and remaining limitations. Confirm no higher version has since entered Partner Center.
2. Review/merge the production preparation PR only when approved; identify the exact final SHA and artifact hash. Rebuilds need their own hashes.
3. In Partner Center, start an update for Store ID 9NRZMPGMQPS4, upload the approved unsigned Store MSIX, review supported OS/device availability, release notes, listing and submission options.
4. Submit for certification only after explicit maintainer approval. No self-signed dev CER is needed by Store users. Do not upload the development kit/MSIX instead of the official-identity candidate.
5. Wait for Microsoft's certification/publication outcome; no fixed availability date is promised. Verify the delivered version and upgrade path before declaring the update live.

## Draft release notes

- Adds a conversion progress window with current-PDF page count and percentage for File Explorer conversions.
- Adds cooperative cancellation while preserving completed outputs and original PDFs.
- Expands the proposed x64 package OS range to Windows 10 build 19041+ alongside Windows 11. Real-device checks were performed on Windows 10 22H2 and Windows 11; older admitted Windows 10 versions were not separately tested.
- Improves cancellation cleanup, including cases where output cannot be deleted due to file locks/access restrictions. Cleanup is best effort, so a blocked newly encoded image may remain.

These notes describe the candidate, not a currently published Store update.
