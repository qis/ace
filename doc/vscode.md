# Visual Studio Code
Install and configure [VS Code][vsc].

## Extensions
1. Install required extensions.
  - CMake Tools `ms-vscode.cmake-tools`
  - clangd `llvm-vs-code-extensions.vscode-clangd`
  - CodeLLDB `vadimcn.vscode-lldb`

2. Install optional extension for license formatting.
  - Reflow Markdown `marvhen.reflow-markdown`

## Configuration
Required configuration, that must be added to the user or workspace `settings.json` file.

```json5
{
  "clangd.arguments": [ "--header-insertion=never" ],
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
  "reflowMarkdown.preferredLineLength": 76
}
```

Recommended configuration, that can be added to the user `settings.json` file.

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
  "debug.toolBarLocation": "commandCenter",
  "lldb.showDisassembly": "auto",
  "lldb.dereferencePointers": true,
  "lldb.consoleMode": "commands",
  "lldb.displayFormat": "auto"
}
```

[vsc]: https://code.visualstudio.com/
