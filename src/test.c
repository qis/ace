#ifndef _WIN32
#ifndef _DEFAULT_SOURCE
#define _DEFAULT_SOURCE
#endif
#endif

#include <cpuid.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <pathcch.h>
#include <process.h>
#include <shlobj.h>
#include <strsafe.h>
#include <windows.h>
#else
#include <libgen.h>
#include <stdio.h>
#include <unistd.h>
#endif

// clang-format off

typedef enum : uint32_t {
  // https://clang.llvm.org/docs/UsersManual.html#x86
  // https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html
  // Intel® 64 and IA-32 Architectures Software Developer's Manual Volume 2A:
  // Instruction Set Reference, A-L

  // x86-64-v1
  CPU_FEATURE_FPU        = 0x1 <<  0,  // CPUID (0x1) EDX bit 00: Floating-Point Unit On-Chip
  CPU_FEATURE_CX8        = 0x1 <<  1,  // CPUID (0x1) EDX bit 08: CMPXCHG8B Instruction
  CPU_FEATURE_CMOV       = 0x1 <<  2,  // CPUID (0x1) EDX bit 15: Conditional Move Instructions
  CPU_FEATURE_MMX        = 0x1 <<  3,  // CPUID (0x1) EDX bit 23: Intel MMX Technology
  CPU_FEATURE_FXSR       = 0x1 <<  4,  // CPUID (0x1) EDX bit 24: FXSAVE and FXRSTOR Instructions
  CPU_FEATURE_SSE        = 0x1 <<  5,  // CPUID (0x1) EDX bit 25: SSE Extensions
  CPU_FEATURE_SSE2       = 0x1 <<  6,  // CPUID (0x1) EDX bit 26: SSE2 Extensions
  CPU_FEATURE_SCE        = 0x1 <<  7,  // CPUID (0x80000001) EDX bit 11: SYSCALL/SYSRET Instructions

  // x86-64-v2
  CPU_FEATURE_SSE3       = 0x1 <<  8,  // CPUID (0x1) ECX bit 00: SSE3 Extensions
  CPU_FEATURE_SSSE3      = 0x1 <<  9,  // CPUID (0x1) ECX bit 09: SSSE3 Extensions
  CPU_FEATURE_CMPXCHG16B = 0x1 << 10,  // CPUID (0x1) ECX bit 13: CMPXCHG16B Instruction
  CPU_FEATURE_SSE4_1     = 0x1 << 11,  // CPUID (0x1) ECX bit 19: SSE4.1 Extensions
  CPU_FEATURE_SSE4_2     = 0x1 << 12,  // CPUID (0x1) ECX bit 20: SSE4.2 Extensions
  CPU_FEATURE_POPCNT     = 0x1 << 13,  // CPUID (0x1) ECX bit 23: POPCNT Instruction
  CPU_FEATURE_LAHF_SAHF  = 0x1 << 14,  // CPUID (0x80000001) ECX bit 00: LAHF/SAHF in 64-bit Mode

  // x86-64-v3
  CPU_FEATURE_FMA        = 0x1 << 15,  // CPUID (0x1) ECX bit 12: FMA Extensions
  CPU_FEATURE_MOVBE      = 0x1 << 16,  // CPUID (0x1) ECX bit 22: MOVBE Instruction
  CPU_FEATURE_XSAVE      = 0x1 << 17,  // CPUID (0x1) ECX bit 26: XSAVE/XRSTOR Processor States
  CPU_FEATURE_AVX        = 0x1 << 18,  // CPUID (0x1) ECX bit 28: AVX Extensions
  CPU_FEATURE_F16C       = 0x1 << 19,  // CPUID (0x1) ECX bit 29: 16-bit Floating-Point Conversion
  CPU_FEATURE_BMI1       = 0x1 << 20,  // CPUID COUNT (0x7, 0) EBX bit 03: BMI1 Extensions
  CPU_FEATURE_AVX2       = 0x1 << 21,  // CPUID COUNT (0x7, 0) EBX bit 05: AVX2 Extensions
  CPU_FEATURE_BMI2       = 0x1 << 22,  // CPUID COUNT (0x7, 0) EBX bit 08: BMI2 Extensions
  CPU_FEATURE_LZCNT      = 0x1 << 23,  // CPUID (0x80000001) ECX bit 05: LZCNT

  CPU_FEATURES_X86_64_V1 =
    CPU_FEATURE_FMA        |
    CPU_FEATURE_MOVBE      |
    CPU_FEATURE_XSAVE      |
    CPU_FEATURE_AVX        |
    CPU_FEATURE_F16C       |
    CPU_FEATURE_BMI1       |
    CPU_FEATURE_AVX2       |
    CPU_FEATURE_BMI2       |
    CPU_FEATURE_LZCNT      ,

  CPU_FEATURES_X86_64_V2 =
    CPU_FEATURE_SSE3       |
    CPU_FEATURE_SSSE3      |
    CPU_FEATURE_CMPXCHG16B |
    CPU_FEATURE_SSE4_1     |
    CPU_FEATURE_SSE4_2     |
    CPU_FEATURE_POPCNT     |
    CPU_FEATURE_LAHF_SAHF  ,

  CPU_FEATURES_X86_64_V3 =
    CPU_FEATURE_FPU        |
    CPU_FEATURE_CX8        |
    CPU_FEATURE_CMOV       |
    CPU_FEATURE_MMX        |
    CPU_FEATURE_FXSR       |
    CPU_FEATURE_SSE        |
    CPU_FEATURE_SSE2       |
    CPU_FEATURE_SCE        ,
} cpu_features;

static cpu_features get_cpu_features() {
  uint32_t features = 0;
  unsigned eax, ebx, ecx, edx;
  if (__get_cpuid(0x1, &eax, &ebx, &ecx, &edx)) {
    if (edx & (0x1 <<  0)) features |= CPU_FEATURE_FPU;
    if (edx & (0x1 <<  8)) features |= CPU_FEATURE_CX8;
    if (edx & (0x1 << 15)) features |= CPU_FEATURE_CMOV;
    if (edx & (0x1 << 23)) features |= CPU_FEATURE_MMX;
    if (edx & (0x1 << 24)) features |= CPU_FEATURE_FXSR;
    if (edx & (0x1 << 25)) features |= CPU_FEATURE_SSE;
    if (edx & (0x1 << 26)) features |= CPU_FEATURE_SSE2;

    if (ecx & (0x1 <<  0)) features |= CPU_FEATURE_SSE3;
    if (ecx & (0x1 <<  9)) features |= CPU_FEATURE_SSSE3;
    if (ecx & (0x1 << 12)) features |= CPU_FEATURE_FMA;
    if (ecx & (0x1 << 13)) features |= CPU_FEATURE_CMPXCHG16B;
    if (ecx & (0x1 << 19)) features |= CPU_FEATURE_SSE4_1;
    if (ecx & (0x1 << 20)) features |= CPU_FEATURE_SSE4_2;
    if (ecx & (0x1 << 22)) features |= CPU_FEATURE_MOVBE;
    if (ecx & (0x1 << 23)) features |= CPU_FEATURE_POPCNT;
    if (ecx & (0x1 << 26)) features |= CPU_FEATURE_XSAVE;
    if (ecx & (0x1 << 28)) features |= CPU_FEATURE_AVX;
    if (ecx & (0x1 << 29)) features |= CPU_FEATURE_F16C;
  }
  if (__get_cpuid_count(0x7, 0, &eax, &ebx, &ecx, &edx)) {
    if (ebx & (0x1 <<  3)) features |= CPU_FEATURE_BMI1;
    if (ebx & (0x1 <<  5)) features |= CPU_FEATURE_AVX2;
    if (ebx & (0x1 <<  8)) features |= CPU_FEATURE_BMI2;
  }
  if (__get_cpuid(0x80000001, &eax, &ebx, &ecx, &edx)) {
    if (edx & (0x1 << 11)) features |= CPU_FEATURE_SCE;
    if (ecx & (0x1 <<  0)) features |= CPU_FEATURE_LAHF_SAHF;
    if (ecx & (0x1 <<  5)) features |= CPU_FEATURE_LZCNT;
  }
  return features;
}

// clang-format on

#ifdef _WIN32

static bool enter_application_directory() {
  bool success = false;
  DWORD size = 4'096;
  PWSTR path = LocalAlloc(LMEM_FIXED, size * sizeof(WCHAR));
  if (!path) {
    return false;
  }

  DWORD result = 0;
  while ((result = GetModuleFileNameW(NULL, path, size)) == size) {
    if (GetLastError() != ERROR_INSUFFICIENT_BUFFER) {
      goto done;
    }
    size += 8'192;
    PWSTR real = LocalReAlloc(path, size * sizeof(WCHAR), LMEM_MOVEABLE);
    if (!real) {
      goto done;
    }
    path = real;
  }
  if (!result) {
    goto done;
  }

  PWSTR real = NULL;
  ULONG flag = PATHCCH_ALLOW_LONG_PATHS;
  flag |= PATHCCH_FORCE_ENABLE_LONG_NAME_PROCESS;
  if (FAILED(PathAllocCanonicalize(path, flag, &real))) {
    goto done;
  }

  SIZE_T real_size = 0;
  if (FAILED(StringCchLengthW(real, __min(STRSAFE_MAX_CCH, 32'768), &real_size))) {
    goto done;
  }
  if (FAILED(PathCchRemoveFileSpec(real, real_size + 1))) {
    goto done;
  }

  success = SetCurrentDirectoryW(real) != 0;

done:
  if (real) {
    CoTaskMemFree(real);
  }
  if (path) {
    LocalFree(path);
  }
  return success;
}

static bool isv3(int argc, PWSTR* argv) {
  if (argv) {
    for (int i = 1; i < argc; i++) {
      if (wcscmp(argv[i], L"-v2") == 0) {
        return false;
      }
    }
  }
  return (get_cpu_features() & CPU_FEATURES_X86_64_V3) == CPU_FEATURES_X86_64_V3;
}

static void report_error(PCWSTR title, PCWSTR text) {
  MessageBoxW(NULL, text, title, MB_OK | MB_ICONERROR | MB_SETFOREGROUND | MB_TOPMOST);
}

int WINAPI wWinMain(HINSTANCE instance, HINSTANCE, PWSTR cmd, int show) {
  if (!enter_application_directory()) {
    report_error(L"Critical Error", L"Could not enter application directory.");
    return EXIT_FAILURE;
  }
  int argc = 0;
  PWSTR* argv = CommandLineToArgvW(GetCommandLineW(), &argc);

  const PCWSTR name = isv3(argc, argv) ? L"test-v3.exe" : L"test-v2.exe";
  if (argv) {
    LocalFree(argv);
  }

  DWORD code = EXIT_FAILURE;
  SECURITY_ATTRIBUTES sa = { sizeof(sa), NULL, TRUE };

  PWSTR file = NULL;
  if (FAILED(SHGetKnownFolderPath(&FOLDERID_LocalAppData, 0, NULL, &file))) {
    if (file) {
      CoTaskMemFree(file);
      file = NULL;
    }
  }

  if (file) {
    const PCWSTR path = L"\\Ace\\test.log";
    PWSTR real = CoTaskMemAlloc((wcslen(file) + wcslen(path) + 1) * sizeof(WCHAR));
    if (real) {
      wcscpy(real, file);
      wcscat(real, path);
    }
    CoTaskMemFree(file);
    file = real;
  }

  if (file) {
    PWSTR real = NULL;
    ULONG flag = PATHCCH_ALLOW_LONG_PATHS;
    flag |= PATHCCH_FORCE_ENABLE_LONG_NAME_PROCESS;
    if (FAILED(PathAllocCanonicalize(file, flag, &real))) {
      real = NULL;
    }
    CoTaskMemFree(file);
    file = real;
  }

  if (file) {
    SIZE_T file_size = 0;
    if (SUCCEEDED(StringCchLengthW(file, __min(STRSAFE_MAX_CCH, 32'768), &file_size))) {
      PWSTR path = LocalAlloc(LMEM_FIXED, (file_size + 1) * sizeof(WCHAR));
      if (path) {
        CopyMemory(path, file, (file_size + 1) * sizeof(WCHAR));
        if (SUCCEEDED(PathCchRemoveFileSpec(path, file_size + 1))) {
          SHCreateDirectoryExW(NULL, path, NULL);
        }
        LocalFree(path);
      }
    }
  }

  HANDLE log = INVALID_HANDLE_VALUE;
  if (file) {
    log = CreateFileW(
      file,
      GENERIC_WRITE,
      FILE_SHARE_READ,
      &sa,
      CREATE_ALWAYS,
      FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN,
      NULL);
    CoTaskMemFree(file);
    file = NULL;
  }
  if (log == INVALID_HANDLE_VALUE) {
    log = CreateFileW(
      L"\\\\?\\NUL",
      GENERIC_WRITE,
      FILE_SHARE_READ | FILE_SHARE_WRITE,
      &sa,
      OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL,
      NULL);
    if (log == INVALID_HANDLE_VALUE) {
      goto done;
    }
  }

  const HANDLE nul = CreateFileW(
    L"\\\\?\\NUL",
    GENERIC_READ,
    FILE_SHARE_READ | FILE_SHARE_WRITE,
    &sa,
    OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL,
    NULL);
  if (nul == INVALID_HANDLE_VALUE) {
    goto done;
  }

  STARTUPINFOW si = { sizeof(si) };
  si.dwFlags = STARTF_USESTDHANDLES;
  si.hStdOutput = log;
  si.hStdError = log;
  si.hStdInput = nul;

  PROCESS_INFORMATION pi = { 0 };

  const BOOL success = CreateProcessW(
    name,               // executable path
    GetCommandLineW(),  // command-line arguments
    NULL,               // process handle not inherited
    NULL,               // thread handle not inherited
    TRUE,               // inherit handles (for stdout)
    CREATE_NO_WINDOW,   // suppress console window
    NULL,               // inherit environment
    NULL,               // inherit current directory
    &si,                // startup info
    &pi);               // process info

  if (success) {
    WaitForSingleObject(pi.hProcess, INFINITE);
    GetExitCodeProcess(pi.hProcess, &code);
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
  } else {
    report_error(L"Critical Error", L"Could not create process.");
  }

done:
  if (log != INVALID_HANDLE_VALUE) {
    CloseHandle(log);
  }
  if (nul != INVALID_HANDLE_VALUE) {
    CloseHandle(nul);
  }
  if (file) {
    CoTaskMemFree(file);
  }
  return (int)code;
}

#else

static bool enter_application_directory() {
  char* self = realpath("/proc/self/exe", NULL);
  if (!self) {
    return false;
  }
  bool success = chdir(dirname(self)) == 0;
  free(self);
  return success;
}

static bool isv3(int argc, char** argv) {
  if (argv) {
    for (int i = 1; i < argc; i++) {
      if (strcmp(argv[i], "-v2") == 0) {
        return false;
      }
    }
  }
  return (get_cpu_features() & CPU_FEATURES_X86_64_V3) == CPU_FEATURES_X86_64_V3;
}

static void report_error(const char* text) {
  fputs(text, stderr);
  fputc('\n', stderr);
  fflush(stderr);
}

int main(int argc, char* argv[]) {
  if (!enter_application_directory()) {
    report_error("Error: Could not enter application directory.");
    return EXIT_FAILURE;
  }
  execv(isv3(argc, argv) ? "test-v3" : "test-v2", argv);
  report_error("Error: Could not replace process.");
  return EXIT_FAILURE;
}

#endif
