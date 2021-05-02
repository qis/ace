# ACE
Toolchain for game development.

```sh
WINEPATH=/opt/ace/windows/bin wine main.exe
```

```sh
make download
make stage llvm libcxxabi libcxx windows
make benchmark doctest fmt
make clean
```

VS Code `Extensions: Show Installed Extensions`.

```
xaver.clang-format
llvm-vs-code-extensions.vscode-clangd
twxs.cmake
ms-vscode.cmake-tools
vadimcn.vscode-lldb
eamodio.gitlens
marvhen.reflow-markdown
alefragnani.rtf
```

VS Code `Preferences: Open Settings (JSON)`.

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
  "clang-format.executable": "/opt/ace/bin/clang-format",
  "clangd.arguments": [ "--compile-commands-dir=build" ],
  "clangd.onConfigChanged": "restart",
  "clangd.path": "/opt/ace/bin/clangd",
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

VS Code `Preferences Open Keyboard Shortcuts (JSON)`.

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

VS Code `CMake: Edit User-Local CMake Kits`.

```json5
[
  {
    "keep": true,
    "name": "Linux",
    "toolchainFile": "/opt/ace/linux.cmake"
  },
  {
    "keep": true,
    "name": "Windows",
    "toolchainFile": "/opt/ace/windows.cmake"
  }
]
```
