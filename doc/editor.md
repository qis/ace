# Editor
Editor setup instructions.

## VSCode/VSCodium
1. Install and configure [VSCode][vsc] or [VSCodium][vsu].

2. Install required extensions.
   * CMake Tools `ms-vscode.cmake-tools`
   * clangd `llvm-vs-code-extensions.vscode-clangd`
   * LLDB DAP `llvm-vs-code-extensions.lldb-dap`

3. Install optional extension for license formatting.
   * Reflow Markdown `marvhen.reflow-markdown`

4. Add required user or workspace settings.

```json5
{
  // Extension: CMake Tools
  "cmake.copyCompileCommands": "${workspaceFolder}/build/compile_commands.json",
  "cmake.ctest.testExplorerIntegrationEnabled": true,
  "cmake.showConfigureWithDebuggerNotification": false,
  "cmake.showNotAllDocumentsSavedQuestion": false,
  "cmake.showOptionsMovedNotification": false,
  "cmake.useCMakePresets": "always",
  "cmake.pinnedCommands": [
    "workbench.action.tasks.configureTaskRunner",
    "workbench.action.tasks.runTask",
    "workbench.action.tasks.debug"
  ],

  "cmake.debugConfig": {
    "name": "LLDB",
    "type": "lldb-dap",
    "request": "launch",
    "program": "${command:cmake.launchTargetPath}",
    "cwd": "${workspaceRoot}",
    "args": [],
    "env": []
  },

  // Extension: clangd
  // Linux: /opt/ace/bin/clangd
  // Windows: C:/Ace/bin/clangd.exe
  "clangd.path": "C:/Ace/bin/clangd.exe",
  "clangd.onConfigChanged": "restart",
  "clangd.arguments": [
    "--experimental-modules-support",
    "--header-insertion=never",
  ],

  // Extension: LLDB DAP
  // Linux: /opt/ace/bin/lldb-dap
  // Windows: C:/Ace/bin/lldb-dap.exe
  "lldb-dap.executable-path": "C:/Ace/bin/lldb-dap.exe",

  // Extension: Reflow Markdown
  "reflowMarkdown.preferredLineLength": 76,

  // Preferences: Open Remote Settings
  // "clangd.path": "/opt/ace/bin/clangd",
  // "lldb-dap.executable-path": "/opt/ace/bin/lldb-dap",
  // "cmake.ctest.testExplorerIntegrationEnabled": true,
  // "cmake.debugConfig": {
  //   "name": "LLDB",
  //   "type": "lldb-dap",
  //   "request": "launch",
  //   "program": "${command:cmake.launchTargetPath}",
  //   "cwd": "${workspaceRoot}",
  //   "args": [],
  //   "env": []
  // }
}
```

5. Add recommended user settings.

```json5
{
  "debug.showInStatusBar": "never",
  "debug.toolBarLocation": "commandCenter",
  "window.commandCenter": true,
  "window.titleBarStyle": "custom",

  // Extension: CMake Tools
  "cmake.buildBeforeRun": true,
  "cmake.configureOnOpen": true,
  "cmake.deleteBuildDirOnCleanConfigure": true,
  "cmake.enableAutomaticKitScan": false,
  "cmake.ignoreCMakeListsMissing": true,
  "cmake.launchBehavior": "breakAndReuseTerminal",

  "cmake.options.statusBarVisibility": "hidden",
  "cmake.options.advanced": {
    "configurePreset": {
      "statusBarVisibility": "compact"
    },
    "buildPreset": {
      "statusBarVisibility": "compact"
    },
    "buildTarget": {
      "statusBarVisibility": "compact"
    },
    "launchTarget": {
      "statusBarVisibility": "compact"
    },
    "build": {
      "statusBarVisibility": "hidden"
    },
    "debug": {
      "statusBarVisibility": "hidden"
    },
    "launch": {
      "statusBarVisibility": "icon"
    },
  },
}
```

6. Add recommended keyboard shortcuts.

```json5
[
  {
    "key": "f5",
    "command": "cmake.debugTarget",
    "when": "!inDebugMode"
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
    "key": "ctrl+f5",
    "command": "cmake.launchTarget"
  },
  {
    "key": "pausebreak",
    "command": "workbench.action.togglePanel"
  }
]
```

[vsc]: https://code.visualstudio.com/
[vsu]: https://vscodium.com/
