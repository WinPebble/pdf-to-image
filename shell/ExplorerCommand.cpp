#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <shobjidl.h>
#include <shlwapi.h>

#include <atomic>
#include <new>
#include <string>
#include <vector>

#pragma comment(lib, "shell32.lib")
#pragma comment(lib, "shlwapi.lib")
#pragma comment(lib, "ole32.lib")

namespace
{
    // Stable development CLSIDs. Keep these synchronized with AppxManifest.xml.
    const CLSID CLSID_ConvertPdfToPng =
    { 0x5f0cda3b, 0x27ee, 0x4aa4, { 0x96, 0xe4, 0x2d, 0x38, 0xa0, 0x9f, 0x83, 0xb1 } };

    const CLSID CLSID_ConvertPdfToJpg =
    { 0x83008b83, 0x8e5e, 0x45e2, { 0x8b, 0x6b, 0xcb, 0x7f, 0x5b, 0x38, 0x6d, 0x9c } };

    enum class CommandMode
    {
        Png,
        Jpg
    };

    HMODULE g_module = nullptr;
    std::atomic<long> g_objectCount{ 0 };
    std::atomic<long> g_lockCount{ 0 };

    std::wstring ModuleDirectory()
    {
        wchar_t buffer[32768]{};
        DWORD length = GetModuleFileNameW(
            g_module,
            buffer,
            static_cast<DWORD>(std::size(buffer))
        );

        if (length == 0 || length >= std::size(buffer))
        {
            return {};
        }

        std::wstring path(buffer, length);
        const size_t slash = path.find_last_of(L"\\/");

        if (slash == std::wstring::npos)
        {
            return {};
        }

        return path.substr(0, slash);
    }

    bool IsPdfPath(const wchar_t* path)
    {
        if (!path || !*path)
        {
            return false;
        }

        const wchar_t* extension = PathFindExtensionW(path);
        return extension && _wcsicmp(extension, L".pdf") == 0;
    }

    HRESULT SelectedPdfPaths(
        IShellItemArray* items,
        std::vector<std::wstring>& paths)
    {
        if (!items)
        {
            return E_INVALIDARG;
        }

        DWORD count = 0;
        HRESULT hr = items->GetCount(&count);

        if (FAILED(hr))
        {
            return hr;
        }

        if (count == 0)
        {
            return HRESULT_FROM_WIN32(ERROR_NO_MORE_ITEMS);
        }

        paths.clear();
        paths.reserve(count);

        for (DWORD i = 0; i < count; ++i)
        {
            IShellItem* item = nullptr;
            hr = items->GetItemAt(i, &item);

            if (FAILED(hr))
            {
                return hr;
            }

            PWSTR rawPath = nullptr;
            hr = item->GetDisplayName(SIGDN_FILESYSPATH, &rawPath);
            item->Release();

            if (FAILED(hr))
            {
                return hr;
            }

            const bool isPdf = IsPdfPath(rawPath);

            if (!isPdf)
            {
                CoTaskMemFree(rawPath);
                return HRESULT_FROM_WIN32(ERROR_INVALID_DATA);
            }

            paths.emplace_back(rawPath);
            CoTaskMemFree(rawPath);
        }

        return S_OK;
    }

    HRESULT LaunchCore(
        CommandMode mode,
        const std::vector<std::wstring>& paths)
    {
        const std::wstring directory = ModuleDirectory();

        if (directory.empty())
        {
            return HRESULT_FROM_WIN32(GetLastError());
        }

        const std::wstring exePath =
            directory + L"\\WinPebble.PDFToImage.exe";

        const DWORD attributes = GetFileAttributesW(exePath.c_str());

        if (attributes == INVALID_FILE_ATTRIBUTES ||
            (attributes & FILE_ATTRIBUTE_DIRECTORY))
        {
            return HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND);
        }

        // Windows filenames cannot contain a double quote, so ordinary quoting
        // is sufficient for the file-system paths received from Explorer.
        std::wstring commandLine =
            L"\"" + exePath + L"\" " +
            (mode == CommandMode::Png ? L"--png --progress-ui" : L"--jpg --progress-ui");

        for (const auto& path : paths)
        {
            commandLine += L" \"";
            commandLine += path;
            commandLine += L"\"";
        }

        // CreateProcessW uses a 32,767-character command-line limit.
        if (commandLine.size() >= 32000)
        {
            return HRESULT_FROM_WIN32(ERROR_BUFFER_OVERFLOW);
        }

        STARTUPINFOW startupInfo{};
        startupInfo.cb = sizeof(startupInfo);

        PROCESS_INFORMATION processInfo{};

        std::vector<wchar_t> mutableCommandLine(
            commandLine.begin(),
            commandLine.end()
        );
        mutableCommandLine.push_back(L'\0');

        const BOOL created = CreateProcessW(
            exePath.c_str(),
            mutableCommandLine.data(),
            nullptr,
            nullptr,
            FALSE,
            CREATE_NO_WINDOW | CREATE_UNICODE_ENVIRONMENT,
            nullptr,
            directory.c_str(),
            &startupInfo,
            &processInfo
        );

        if (!created)
        {
            return HRESULT_FROM_WIN32(GetLastError());
        }

        CloseHandle(processInfo.hThread);
        CloseHandle(processInfo.hProcess);

        return S_OK;
    }

    class ExplorerCommand final : public IExplorerCommand
    {
    public:
        explicit ExplorerCommand(CommandMode mode)
            : _mode(mode)
        {
            ++g_objectCount;
        }

        ~ExplorerCommand()
        {
            --g_objectCount;
        }

        IFACEMETHODIMP QueryInterface(REFIID riid, void** object) override
        {
            if (!object)
            {
                return E_POINTER;
            }

            *object = nullptr;

            if (riid == IID_IUnknown || riid == __uuidof(IExplorerCommand))
            {
                *object = static_cast<IExplorerCommand*>(this);
                AddRef();
                return S_OK;
            }

            return E_NOINTERFACE;
        }

        IFACEMETHODIMP_(ULONG) AddRef() override
        {
            return static_cast<ULONG>(InterlockedIncrement(&_refCount));
        }

        IFACEMETHODIMP_(ULONG) Release() override
        {
            const ULONG remaining =
                static_cast<ULONG>(InterlockedDecrement(&_refCount));

            if (remaining == 0)
            {
                delete this;
            }

            return remaining;
        }

        IFACEMETHODIMP GetTitle(
            IShellItemArray*,
            PWSTR* title) override
        {
            if (!title)
            {
                return E_POINTER;
            }

            return SHStrDupW(
                _mode == CommandMode::Png
                    ? L"Convert PDF to PNG"
                    : L"Convert PDF to JPG",
                title
            );
        }

        IFACEMETHODIMP GetIcon(
            IShellItemArray*,
            PWSTR* icon) override
        {
            if (!icon)
            {
                return E_POINTER;
            }

            *icon = nullptr;
            return E_NOTIMPL;
        }

        IFACEMETHODIMP GetToolTip(
            IShellItemArray*,
            PWSTR* toolTip) override
        {
            if (!toolTip)
            {
                return E_POINTER;
            }

            *toolTip = nullptr;
            return E_NOTIMPL;
        }

        IFACEMETHODIMP GetCanonicalName(
            GUID* canonicalName) override
        {
            if (!canonicalName)
            {
                return E_POINTER;
            }

            *canonicalName =
                _mode == CommandMode::Png
                    ? CLSID_ConvertPdfToPng
                    : CLSID_ConvertPdfToJpg;

            return S_OK;
        }

        IFACEMETHODIMP GetState(
            IShellItemArray*,
            BOOL,
            EXPCMDSTATE* state) override
        {
            if (!state)
            {
                return E_POINTER;
            }

            // The package manifest scopes the command to .pdf.
            // Keep menu construction fast; detailed validation happens in Invoke.
            *state = ECS_ENABLED;
            return S_OK;
        }

        IFACEMETHODIMP Invoke(
            IShellItemArray* items,
            IBindCtx*) override
        {
            std::vector<std::wstring> paths;
            HRESULT hr = SelectedPdfPaths(items, paths);

            if (FAILED(hr))
            {
                return hr;
            }

            return LaunchCore(_mode, paths);
        }

        IFACEMETHODIMP GetFlags(EXPCMDFLAGS* flags) override
        {
            if (!flags)
            {
                return E_POINTER;
            }

            *flags = ECF_DEFAULT;
            return S_OK;
        }

        IFACEMETHODIMP EnumSubCommands(
            IEnumExplorerCommand** commands) override
        {
            if (!commands)
            {
                return E_POINTER;
            }

            *commands = nullptr;
            return E_NOTIMPL;
        }

    private:
        LONG _refCount = 1;
        CommandMode _mode;
    };

    class CommandClassFactory final : public IClassFactory
    {
    public:
        explicit CommandClassFactory(CommandMode mode)
            : _mode(mode)
        {
            ++g_objectCount;
        }

        ~CommandClassFactory()
        {
            --g_objectCount;
        }

        IFACEMETHODIMP QueryInterface(REFIID riid, void** object) override
        {
            if (!object)
            {
                return E_POINTER;
            }

            *object = nullptr;

            if (riid == IID_IUnknown || riid == IID_IClassFactory)
            {
                *object = static_cast<IClassFactory*>(this);
                AddRef();
                return S_OK;
            }

            return E_NOINTERFACE;
        }

        IFACEMETHODIMP_(ULONG) AddRef() override
        {
            return static_cast<ULONG>(InterlockedIncrement(&_refCount));
        }

        IFACEMETHODIMP_(ULONG) Release() override
        {
            const ULONG remaining =
                static_cast<ULONG>(InterlockedDecrement(&_refCount));

            if (remaining == 0)
            {
                delete this;
            }

            return remaining;
        }

        IFACEMETHODIMP CreateInstance(
            IUnknown* outer,
            REFIID riid,
            void** object) override
        {
            if (outer)
            {
                return CLASS_E_NOAGGREGATION;
            }

            if (!object)
            {
                return E_POINTER;
            }

            auto* command = new (std::nothrow) ExplorerCommand(_mode);

            if (!command)
            {
                return E_OUTOFMEMORY;
            }

            const HRESULT hr = command->QueryInterface(riid, object);
            command->Release();
            return hr;
        }

        IFACEMETHODIMP LockServer(BOOL lock) override
        {
            if (lock)
            {
                ++g_lockCount;
            }
            else
            {
                --g_lockCount;
            }

            return S_OK;
        }

    private:
        LONG _refCount = 1;
        CommandMode _mode;
    };
}

BOOL WINAPI DllMain(HINSTANCE instance, DWORD reason, LPVOID)
{
    if (reason == DLL_PROCESS_ATTACH)
    {
        g_module = instance;
        DisableThreadLibraryCalls(instance);
    }

    return TRUE;
}

STDAPI DllCanUnloadNow(void)
{
    return (g_objectCount.load() == 0 && g_lockCount.load() == 0)
        ? S_OK
        : S_FALSE;
}

STDAPI DllGetClassObject(
    REFCLSID clsid,
    REFIID riid,
    LPVOID* object)
{
    if (!object)
    {
        return E_POINTER;
    }

    *object = nullptr;

    CommandMode mode;

    if (IsEqualCLSID(clsid, CLSID_ConvertPdfToPng))
    {
        mode = CommandMode::Png;
    }
    else if (IsEqualCLSID(clsid, CLSID_ConvertPdfToJpg))
    {
        mode = CommandMode::Jpg;
    }
    else
    {
        return CLASS_E_CLASSNOTAVAILABLE;
    }

    auto* factory = new (std::nothrow) CommandClassFactory(mode);

    if (!factory)
    {
        return E_OUTOFMEMORY;
    }

    const HRESULT hr = factory->QueryInterface(riid, object);
    factory->Release();

    return hr;
}
