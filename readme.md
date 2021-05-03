# ACE
LLVM toolchain for Linux and Windows development on Ubuntu 20.04.

## Build
See [docker.md](docker.md) for build instructions.

## Usage
Configure [VS Code][code] to use the toolchain.

<details>
<summary><b>Extensions</b></summary>

Install required [VS Code][code] extensinos.

```
xaver.clang-format
llvm-vs-code-extensions.vscode-clangd
twxs.cmake
ms-vscode.cmake-tools
vadimcn.vscode-lldb
```

Install optional [VS Code][code] extensions.

```
eamodio.gitlens
marvhen.reflow-markdown
alefragnani.rtf
```

</details>

<details>
<summary><b>Settings</b></summary>

Configure [VS Code][code] settings with `CTRL+P` and `Preferences: Open Settings (JSON)`.

```json5
{
  // ==========================================================================
  // Settings
  // ==========================================================================
  "debug.onTaskErrors": "showErrors",
  "editor.copyWithSyntaxHighlighting": false,
  "editor.detectIndentation": false,
  "editor.dragAndDrop": false,
  "editor.folding": false,
  "editor.fontFamily": "'DejaVu LGC Sans Mono', Consolas, monospace",
  "editor.fontSize": 12,
  "editor.largeFileOptimizations": false,
  "editor.links": false,
  "editor.minimap.scale": 2,
  "editor.multiCursorModifier": "ctrlCmd",
  "editor.renderFinalNewline": false,
  "editor.renderLineHighlight": "gutter",
  "editor.renderWhitespace": "selection",
  "editor.rulers": [ 128 ],
  "editor.smoothScrolling": true,
  "editor.tabSize": 2,
  "editor.wordWrap": "on",
  "editor.wordWrapColumn": 128,
  "explorer.confirmDelete": false,
  "explorer.confirmDragAndDrop": false,
  "extensions.ignoreRecommendations": true,
  "files.associations": {
    "*.rc": "cpp"
  },
  "files.defaultLanguage": "markdown",
  "files.eol": "\n",
  "files.hotExit": "off",
  "files.insertFinalNewline": true,
  "files.trimTrailingWhitespace": true,
  "git.autofetch": false,
  "git.autoRepositoryDetection": false,
  "git.confirmSync": false,
  "git.enableSmartCommit": true,
  "git.postCommitCommand": "push",
  "git.showPushSuccessNotification": true,
  "problems.autoReveal": false,
  "telemetry.enableCrashReporter": false,
  "telemetry.enableTelemetry": false,
  "window.closeWhenEmpty": false,
  "window.newWindowDimensions": "inherit",
  "window.openFilesInNewWindow": "off",
  "window.openFoldersInNewWindow": "off",
  "window.restoreWindows": "one",
  "workbench.startupEditor": "none",

  // ==========================================================================
  // Extensinos
  // ==========================================================================
  "clang-format.executable": "${env:ACE}/bin/clang-format",
  "clangd.arguments": [ "--compile-commands-dir=build" ],
  "clangd.onConfigChanged": "restart",
  "clangd.path": "${env:ACE}/bin/clangd",
  "cmake.buildDirectory": "${workspaceFolder}/build",
  "cmake.cmakePath": "/opt/cmake/bin/cmake",
  "cmake.configureOnOpen": true,
  "cmake.generator": "Ninja Multi-Config",
  "cmake.installPrefix": "${workspaceFolder}",
  "cmake.configureSettings": {
    "CMAKE_VERBOSE_MAKEFILE": "OFF"
  },
  "cmake.debugConfig": {
    "name": "LLDB",
    "type": "lldb",
    "request": "launch",
    "terminal": "console",
    "cwd": "${workspaceRoot}",
    "program": "${command:cmake.launchTargetPath}"
  },
  "gitlens.codeLens.enabled": false,
  "gitlens.currentLine.enabled": false,
  "gitlens.defaultDateFormat": "YYYY-MM-DD hh:mm",
  "gitlens.defaultDateShortFormat": "YYYY-MM-DD hh:mm",
  "gitlens.defaultTimeFormat": "hh:mm",
  "gitlens.hovers.currentLine.over": "line",
  "gitlens.hovers.enabled": false,
  "gitlens.statusBar.enabled": false,
  "lldb.library": "/opt/ace/lib/liblldb.so",

  // ==========================================================================
  // File Formats
  // ==========================================================================
  "html.format.extraLiners": "",
  "html.format.indentInnerHtml": false,
  "javascript.format.insertSpaceAfterFunctionKeywordForAnonymousFunctions": false,
  "javascript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets": true,
  "typescript.format.insertSpaceAfterFunctionKeywordForAnonymousFunctions": false,
  "typescript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets": true,
  "[c]": {
    "editor.formatOnSave": false,
    "editor.defaultFormatter": "xaver.clang-format"
  },
  "[cpp]": {
    "editor.formatOnSave": false,
    "editor.defaultFormatter": "xaver.clang-format"
  },
  "[javascript]": {
    "editor.formatOnSave": false,
    "editor.defaultFormatter": "xaver.clang-format"
  },
  "[makefile]": {
    "editor.tabSize": 8,
    "editor.renderWhitespace": "boundary"
  }
}
```

</details>

<details>
<summary><b>Keyboard Shortcuts</b></summary>

Configure [VS Code][code] Keyboard Shortcuts with `CTRL+P` and `Preferences Open Keyboard Shortcuts (JSON)`.

```json5
[
  {
    "key": "ctrl+shift+c",
    "command": "editor.action.clipboardCopyWithSyntaxHighlightingAction"
  },
  {
    "key": "f4",
    "command": "clangd.switchheadersource"
  },
  {
    "key": "ctrl+f5",
    "command": "cmake.launchTarget",
    "when": "!inDebugMode"
  },
  {
    "key": "f5",
    "command": "cmake.debugTarget",
    "when": "!inDebugMode"
  },
  {
    "key": "f6",
    "command": "workbench.action.debug.pause",
    "when": "inDebugMode && debugState == 'running'"
  },
  {
    "key": "f6",
    "command": "workbench.action.debug.stop",
    "when": "inDebugMode && debugState != 'running'"
  },
  {
    "key": "f5",
    "command": "workbench.action.debug.pause",
    "when": "inDebugMode && debugState == 'running'"
  },
  {
    "key": "f5",
    "command": "workbench.action.debug.continue",
    "when": "inDebugMode && debugState != 'running'"
  },
  {
    "key": "ctrl+b",
    "command": "cmake.buildAll",
    "when": "!inDebugMode"
  },
  {
    "key": "f9",
    "command": "workbench.action.debug.stepOut",
    "when": "inDebugMode && debugState == 'stopped'"
  },
  {
    "key": "f10",
    "command": "workbench.action.debug.stepOver",
    "when": "inDebugMode && debugState == 'stopped'"
  },
  {
    "key": "f11",
    "command": "workbench.action.debug.stepInto",
    "when": "inDebugMode && debugState != 'inactive'"
  }
]
```

</details>

<details>
<summary><b>CMake Kits</b></summary>

Configure [VS Code][code] CMake Kits with `CTRL+P` and `CMake: Edit User-Local CMake Kits`.

```json5
[
  {
    "keep": true,
    "name": "ACE LLVM",
    "toolchainFile": "${env:ACE}/llvm.cmake",
    "cmakeSettings": {
      "BUILD_SHARED_LIBS": "ON"
    }
  },
  {
    "keep": true,
    "name": "ACE LLVM STATIC",
    "toolchainFile": "${env:ACE}/llvm.cmake",
    "cmakeSettings": {
      "BUILD_SHARED_LIBS": "OFF"
    }
  },
  {
    "keep": true,
    "name": "ACE MSVC",
    "toolchainFile": "${env:ACE}/msvc.cmake",
    "cmakeSettings": {
      "BUILD_SHARED_LIBS": "ON"
    }
  },
  {
    "keep": true,
    "name": "ACE MSVC STATIC",
    "toolchainFile": "${env:ACE}/msvc.cmake",
    "cmakeSettings": {
      "BUILD_SHARED_LIBS": "OFF"
    }
  },
  {
    "keep": true,
    "name": "ACE LLVM (Exceptions)",
    "toolchainFile": "/opt/llvm/toolchain.cmake",
    "cmakeSettings": {
      "LLVM_ENABLE_EXCEPTIONS": "ON",
      "BUILD_SHARED_LIBS": "ON"
    }
  },
  {
    "keep": true,
    "name": "ACE LLVM STATIC (Exceptions)",
    "toolchainFile": "/opt/llvm/toolchain.cmake",
    "cmakeSettings": {
      "LLVM_ENABLE_EXCEPTIONS": "ON",
      "BUILD_SHARED_LIBS": "OFF"
    }
  },
  {
    "keep": true,
    "name": "ACE MSVC (Exceptions)",
    "toolchainFile": "${env:ACE}/msvc.cmake",
    "cmakeSettings": {
      "LLVM_ENABLE_EXCEPTIONS": "ON",
      "BUILD_SHARED_LIBS": "ON"
    }
  },
  {
    "keep": true,
    "name": "ACE MSVC STATIC (Exceptions)",
    "toolchainFile": "${env:ACE}/msvc.cmake",
    "cmakeSettings": {
      "LLVM_ENABLE_EXCEPTIONS": "ON",
      "BUILD_SHARED_LIBS": "OFF"
    }
  }
]
```

</details>

## Dependencies
Binaries compiled with this toolchain will require the following system packages.

```
libc6 (>= 2.31)
```

See [ABI Laboratory][abi] for up to date info.

```sh
ldd /opt/ace/lib/libc++.so.2.0 | grep libc.so
apt-file search /lib/x86_64-linux-gnu/libc.so.6
apt info libc6
```

[code]: https://code.visualstudio.com/
[abi]: https://abi-laboratory.pro/?view=timeline&l=glibc
