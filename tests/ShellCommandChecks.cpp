#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <shobjidl.h>
#include <shlobj.h>
#include <wrl.h>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

using Microsoft::WRL::ComPtr;

void Require(bool condition, const char* message)
{
    if (!condition) throw std::runtime_error(message);
}

ComPtr<IShellItemArray> Selection(const std::vector<std::wstring>& paths)
{
    std::vector<PIDLIST_ABSOLUTE> ids;
    for (const auto& path : paths)
    {
        PIDLIST_ABSOLUTE id = nullptr;
        Require(SUCCEEDED(SHParseDisplayName(path.c_str(), nullptr, &id, 0, nullptr)), "Parse shell path");
        ids.push_back(id);
    }
    std::vector<PCIDLIST_ABSOLUTE> constIds(ids.begin(), ids.end());
    ComPtr<IShellItemArray> items;
    const HRESULT hr = SHCreateShellItemArrayFromIDLists(static_cast<UINT>(ids.size()),
        constIds.data(), &items);
    for (auto id : ids) CoTaskMemFree(id);
    Require(SUCCEEDED(hr), "Create selection");
    return items;
}

std::wstring ShellPath(IShellItemArray* items, DWORD index)
{
    ComPtr<IShellItem> item;
    Require(SUCCEEDED(items->GetItemAt(index, &item)), "Get selected item");
    PWSTR path = nullptr;
    Require(SUCCEEDED(item->GetDisplayName(SIGDN_FILESYSPATH, &path)), "Read selected path");
    std::wstring result(path);
    CoTaskMemFree(path);
    return result;
}

int wmain(int argc, wchar_t** argv)
{
    if (argc != 2) return 2;
    const HRESULT init = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    if (FAILED(init)) return 2;
    HMODULE dll = nullptr;
    int result = 1;
    try
    {
        const std::wstring dllPath(argv[1]);
        const std::wstring directory = dllPath.substr(0, dllPath.find_last_of(L"\\/"));
        const std::wstring report = directory + L"\\arguments.bin";
        const std::wstring pdf = directory + L"\\Tài liệu & O'Brien (1).PDF";
        const std::wstring otherPdf = directory + L"\\Second PDF.pdf";
        const std::wstring text = directory + L"\\Other.txt";
        for (const auto& path : {pdf, otherPdf, text})
        {
            HANDLE file = CreateFileW(path.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_NEW,
                FILE_ATTRIBUTE_NORMAL, nullptr);
            Require(file != INVALID_HANDLE_VALUE, "Create test input");
            CloseHandle(file);
        }
        Require(SetEnvironmentVariableW(L"WINPEBBLE_SHELL_TEST_REPORT", report.c_str()) != FALSE,
            "Set recorder output");
        dll = LoadLibraryW(dllPath.c_str());
        Require(dll != nullptr, "Load shell DLL");
        using GetClass = HRESULT(STDAPICALLTYPE*)(REFCLSID, REFIID, void**);
        auto getClass = reinterpret_cast<GetClass>(GetProcAddress(dll, "DllGetClassObject"));
        Require(getClass != nullptr, "COM class export");
        const wchar_t* ids[] = {L"{5F0CDA3B-27EE-4AA4-96E4-2D38A09F83B1}",
            L"{83008B83-8E5E-45E2-8B6B-CB7F5B386D9C}"};
        for (int mode = 0; mode < 2; ++mode)
        {
            CLSID id{};
            Require(SUCCEEDED(CLSIDFromString(ids[mode], &id)), "Parse command CLSID");
            ComPtr<IClassFactory> factory;
            Require(SUCCEEDED(getClass(id, IID_PPV_ARGS(&factory))), "Get command factory");
            ComPtr<IExplorerCommand> command;
            Require(SUCCEEDED(factory->CreateInstance(nullptr, IID_PPV_ARGS(&command))), "Create command");
            Require(command->GetIcon(nullptr, nullptr) == E_POINTER, "Null icon output rejected");
            PWSTR icon = nullptr;
            Require(SUCCEEDED(command->GetIcon(nullptr, &icon)) && icon != nullptr, "Get menu icon");
            const bool iconCorrect = std::wstring(icon) == directory + L"\\WinPebble.PDFToImage.exe,0";
            CoTaskMemFree(icon);
            Require(iconCorrect, "Exact Unicode EXE icon location");
            PWSTR title = nullptr;
            Require(SUCCEEDED(command->GetTitle(nullptr, &title)), "Get menu title");
            const bool titleCorrect = std::wstring(title) ==
                (mode == 0 ? L"Convert PDF to PNG" : L"Convert PDF to JPG");
            CoTaskMemFree(title);
            Require(titleCorrect, "Menu labels preserved");
            auto wrong = Selection({text});
            auto mixed = Selection({pdf, text});
            Require(FAILED(command->Invoke(nullptr, nullptr)), "Null selection rejected");
            Require(FAILED(command->Invoke(wrong.Get(), nullptr)), "Non-PDF rejected");
            Require(FAILED(command->Invoke(mixed.Get(), nullptr)), "Mixed selection rejected");
            for (const auto& paths : {std::vector<std::wstring>{pdf}, std::vector<std::wstring>{pdf, otherPdf}})
            {
                DeleteFileW(report.c_str());
                auto selected = Selection(paths);
                EXPCMDSTATE state{};
                Require(SUCCEEDED(command->GetState(selected.Get(), FALSE, &state)) && state == ECS_ENABLED,
                    "PDF command enabled");
                std::wstring expected = mode == 0 ? L"--png" : L"--jpg";
                expected += L'\0'; expected += L"--progress-ui"; expected += L'\0';
                for (DWORD index = 0; index < paths.size(); ++index)
                {
                    expected += ShellPath(selected.Get(), index); expected += L'\0';
                }
                Require(SUCCEEDED(command->Invoke(selected.Get(), nullptr)), "Launch recorder");
                bool matched = false;
                for (int attempt = 0; attempt < 100 && !matched; ++attempt)
                {
                    Sleep(50);
                    HANDLE file = CreateFileW(report.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr,
                        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
                    if (file == INVALID_HANDLE_VALUE) continue;
                    std::wstring received(32768, L'\0');
                    DWORD read = 0;
                    if (ReadFile(file, received.data(), static_cast<DWORD>(received.size() * sizeof(wchar_t)),
                        &read, nullptr))
                    {
                        received.resize(read / sizeof(wchar_t)); matched = received == expected;
                    }
                    CloseHandle(file);
                }
                Require(matched, "Format/progress flags and exact Unicode batch arguments preserved");
            }
            std::cout << "PASS: " << (mode == 0 ? "PNG" : "JPG")
                << " icon, label, selection validation and Unicode single/batch argv.\n";
        }
        result = 0;
    }
    catch (const std::exception& error) { std::cerr << "FAIL: " << error.what() << '\n'; }
    if (dll) FreeLibrary(dll);
    CoUninitialize();
    return result;
}
