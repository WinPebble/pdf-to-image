# Third-party notices

## NSIS

WinPebble PDF to Image uses NSIS (Nullsoft Scriptable Install System) as the installer builder for the SignPath-readiness path.

The NSIS project documents that its source, plug-ins, documentation, examples, headers and graphics are generally licensed under the zlib/libpng license, with separate licenses for some compression modules.

WinPebble's installer script explicitly uses the **zlib** compressor.

- NSIS project: https://nsis.sourceforge.io/
- NSIS license: https://nsis.sourceforge.io/Docs/AppendixI.html
- zlib license is OSI-approved.

NSIS is a build/installer component; WinPebble does not claim ownership of NSIS.

## Windows system APIs

PDF rendering uses Windows system APIs, including `Windows.Data.Pdf`. These are operating-system components and are not redistributed by WinPebble.
