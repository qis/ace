# Editor
Editor setup instructions.

## VSCode/VSCodium
1. Install and configure [VSCode][vsc] or [VSCodium][vsu].

2. Install required extensions.
   * CMake Tools `ms-vscode.cmake-tools`
   * clangd `llvm-vs-code-extensions.vscode-clangd`
   * CodeLLDB `vadimcn.vscode-lldb`

3. Install optional extension for license formatting.
   * Reflow Markdown `marvhen.reflow-markdown`

4. Add required user or workspace settings.

```json5
{
  "clangd.arguments": [
    "--experimental-modules-support",
    "--header-insertion=never",
  ],
  "clangd.onConfigChanged": "restart",
  "cmake.copyCompileCommands": "${workspaceFolder}/build/compile_commands.json",
  "cmake.ctest.testExplorerIntegrationEnabled": true,
  "cmake.useCMakePresets": "always",
  "cmake.debugConfig": {
    "name": "LLDB",
    "type": "lldb",
    "request": "launch",
    "cwd": "${workspaceFolder}",
    "program": "${command:cmake.launchTargetPath}",
    "args": []
  },
  "reflowMarkdown.preferredLineLength": 76,
}
```

5. Add recommended user settings.

```json5
{
  "cmake.buildBeforeRun": true,
  "cmake.configureOnOpen": true,
  "cmake.options.statusBarVisibility": "compact",
  "cmake.options.advanced": {
    "configurePreset": {
      "statusBarVisibility": "compact"
    },
    "build": {
      "statusBarVisibility": "icon"
    },
    "buildPreset": {
      "statusBarVisibility": "compact"
    },
    "buildTarget": {
      "statusBarVisibility": "compact"
    },
    "debug": {
      "statusBarVisibility": "hidden",
    },
    "launch": {
      "statusBarVisibility": "icon"
    },
    "launchTarget": {
      "statusBarVisibility": "compact"
    },
    "testPreset": {
      "statusBarVisibility": "hidden"
    },
    "ctest": {
      "statusBarVisibility": "icon"
    },
    "packagePreset": {
      "statusBarVisibility": "hidden"
    },
    "cpack": {
      "statusBarVisibility": "icon"
    },
    "workflowPreset": {
      "statusBarVisibility": "hidden"
    },
    "workflow": {
      "statusBarVisibility": "hidden"
    }
  },
  "debug.showInStatusBar": "never",
  // When VS Code draws it's own window decorations.
  //"debug.toolBarLocation": "commandCenter",
  "lldb.showDisassembly": "auto",
  "lldb.dereferencePointers": true,
  "lldb.consoleMode": "commands",
  "lldb.displayFormat": "auto",
}
```

6. Add recommended user settings on Linux.

```json5
{
  "clangd.path": "/opt/ace/bin/clangd",
  "cmake.cmakePath": "/opt/cmake/bin/cmake",
}
```

7. Add recommended user settings on Windows.

```json5
{
  "clangd.path": "C:/Ace/bin/clangd.exe",
}
```

[vsc]: https://code.visualstudio.com/
[vsu]: https://vscodium.com/
