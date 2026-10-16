#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <string>

// Test-only converter replacement: record argv, never render or modify PDFs.
int wmain(int argc, wchar_t** argv)
{
    wchar_t report[32768]{};
    if (!GetEnvironmentVariableW(L"WINPEBBLE_SHELL_TEST_REPORT", report, 32768)) return 2;
    std::wstring arguments;
    for (int i = 1; i < argc; ++i)
    {
        arguments += argv[i];
        arguments += L'\0';
    }
    HANDLE file = CreateFileW(report, GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS,
        FILE_ATTRIBUTE_NORMAL, nullptr);
    if (file == INVALID_HANDLE_VALUE) return 3;
    DWORD written = 0;
    const DWORD bytes = static_cast<DWORD>(arguments.size() * sizeof(wchar_t));
    const BOOL ok = WriteFile(file, arguments.data(), bytes, &written, nullptr);
    CloseHandle(file);
    return ok && written == bytes ? 0 : 4;
}
