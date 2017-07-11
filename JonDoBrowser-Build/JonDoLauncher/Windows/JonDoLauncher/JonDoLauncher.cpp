// JonDoLauncher.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include <windows.h>
#include <tlhelp32.h>
#include <tchar.h>
#include <iostream>
#include <string>

using namespace std;

//  Forward declarations:
bool CheckJonDo();
void printError(TCHAR* msg);

//get current directory path
wstring ExeDir() {
	wchar_t buffer[MAX_PATH];
	GetModuleFileName(NULL, buffer, MAX_PATH);
	wstring::size_type pos = wstring(&buffer[0]).find_last_of(L"\\");
	return wstring(buffer).substr(0, pos);
}

int _tmain(int argc, TCHAR*argv[])
{
	FreeConsole();
	if (argc == 2) {
		bool isJAPRunning = CheckJonDo();
		if (!isJAPRunning && wcscmp(argv[1], L"on") == 0) {
			wcout << "Initializing JonDo Connection..." << endl;

			// additional information
			STARTUPINFO si;
			PROCESS_INFORMATION pi;

			// set the size of the structures
			ZeroMemory(&si, sizeof(si));
			si.cb = sizeof(si);
			ZeroMemory(&pi, sizeof(pi));

			wstring fullpath = ExeDir() + L"\\JonDo.exe";

			// start the program up
			if (CreateProcess(fullpath.c_str(),   // the path
				L"JonDo.exe --hideUpdate",			// Command line
				NULL,           // Process handle not inheritable
				NULL,           // Thread handle not inheritable
				FALSE,          // Set handle inheritance to FALSE
				0,              // No creation flags
				NULL,           // Use parent's environment block
				NULL,           // Use parent's starting directory 
				&si,            // Pointer to STARTUPINFO structure
				&pi             // Pointer to PROCESS_INFORMATION structure (removed extra parentheses)
			) == 0) {
				cout << GetLastError() << endl;
			}
			else {
				wcout << L"Successfully opened " << fullpath << endl;
			}
			// Close process and thread handles. 
			CloseHandle(pi.hProcess);
			CloseHandle(pi.hThread);
		}
		if (isJAPRunning && wcscmp(argv[1], L"off") == 0) {
			system("taskkill /F /T /IM JonDo.exe &");
			system("wmic process where \"name like '%java%'\" delete &");
		}
	}
	return 0;
}

bool CheckJonDo()
{
	HANDLE hProcessSnap;
	//HANDLE hProcess;
	PROCESSENTRY32 pe32;
	//DWORD dwPriorityClass;

	// Take a snapshot of all processes in the system.
	hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	if (hProcessSnap == INVALID_HANDLE_VALUE)
	{
		printError(TEXT("CreateToolhelp32Snapshot (of processes)"));
		return(false);
	}

	// Set the size of the structure before using it.
	pe32.dwSize = sizeof(PROCESSENTRY32);

	// Retrieve information about the first process,
	// and exit if unsuccessful
	if (!Process32First(hProcessSnap, &pe32))
	{
		printError(TEXT("Process32First")); // show cause of failure
		CloseHandle(hProcessSnap);          // clean the snapshot object
		return(false);
	}

	bool isJonDoFound = false;

	// Now walk the snapshot of processes, and
	// display information about each process in turn
	do
	{
		if (_wcsicmp(pe32.szExeFile, L"JonDo.exe") == 0) {
			isJonDoFound = true;
		}
	} while (Process32Next(hProcessSnap, &pe32));

	CloseHandle(hProcessSnap);
	return(isJonDoFound);
}

void printError(TCHAR* msg)
{
	DWORD eNum;
	TCHAR sysMsg[256];
	TCHAR* p;

	eNum = GetLastError();
	FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
		NULL, eNum,
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
		sysMsg, 256, NULL);

	// Trim the end of the line and terminate it with a null
	p = sysMsg;
	while ((*p > 31) || (*p == 9))
		++p;
	do { *p-- = 0; } while ((p >= sysMsg) &&
		((*p == '.') || (*p < 33)));

	// Display the message
	_tprintf(TEXT("\n  WARNING: %s failed with error %d (%s)"), msg, eNum, sysMsg);
}
