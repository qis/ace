# Utility Functions
function IsAdmin {
  $identity = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  return $identity.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Confirm {
  If ($Host.Name -eq "ConsoleHost") {
    Write-Output $args
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") | Out-Null
  }
}

$ace = (Resolve-Path -Path $PSScriptRoot\..).Path

Write-Output $ace

# Restart script as administrator.
If ((IsAdmin) -eq $False) {
  If ($args[0] -eq "-elevated") {
    Write-Output "Error: Could not execute script as administrator."
    Confirm "Press any key to exit ..."
    Exit
  }
  Write-Output "Executing script as Administrator ..."
  Start-Process powershell.exe -Verb RunAs -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}" -elevated' -f ($MyInvocation.MyCommand.Definition))
  Exit
}

# Make the "HKCR:" drive available.
If (!(Test-Path "HKCR:")) {
  New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
}

# Set editor command.
$editor = "$ace\dev\bin\nvim-qt.exe"

# Creates a file association.
function Associate {
  $name = $args[0]
  "text.ico" = $args[1]
  $icon = $args[2]
  $type = $args[3]
  $exec = '"' + $editor + '" "%1"'
  If ($icon.IndexOf("\") -eq -1) {
    $icon = "$PSScriptRoot\icons\" + $icon
  }
  & cmd /c "ftype ${name}=${exec}"
  Set-ItemProperty -Path "HKCR:\${name}" -Name "(Default)" -Type String -Value "${text}"
  If (!(Test-Path "HKCR:\${name}\DefaultIcon")) {
    New-Item -Path "HKCR:\${name}\DefaultIcon" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKCR:\${name}\DefaultIcon" -Name "(Default)" -Type String -Value "${icon}"
  Remove-Item -Path "HKCR:\${name}_auto_file" -Recurse -ErrorAction SilentlyContinue -Force | Out-Null
  $type | ForEach {
    & cmd /c "assoc .${_}=${name}"
    Set-ItemProperty -Path "HKCR:\.${_}" -Name "(Default)" -Type String -Value "${name}"
    Remove-Item -Path "HKCR:\.${_}_auto_file" -Recurse -ErrorAction SilentlyContinue -Force | Out-Null
  }
}

# Text
Associate "android" "Android" "text.ico" ("gradle", "iml", "lock", "metadata", "properties")
Associate "config" "Configuration" "text.ico" ("cfg", "cnf", ".clangd", "clang-format", "clang-tidy", "conf", "editorconfig", "ini")
Associate "git" "Git" "git.ico" ("gitattributes", "gitconfig", "gitignore", "gitmodules", "npmrc")
Associate "json" "JSON" "text.ico" ("json", "json5", "jsonc")
Associate "log" "Log" "text.ico" ("log", "tlog")
Associate "markdown" "Markdown" "text.ico" ("markdown", "md")
Associate "patch" "Patch" "text.ico" ("diff", "patch")
Associate "text" "Text" "text.ico" ("txt")
Associate "vimscript" "Vim Script" "text.ico" ("vim")
Associate "yaml" "YAML" "text.ico" ("yaml", "yml")
Associate "proto" "Protocol Buffers" "text.ico" ("proto")
Associate "fbs" "FlatBuffers" "text.ico" ("fbs")
Associate "jam" "JAM" "text.ico" ("jam")
Associate "xmlfile" "XML" "xml.ico" ("xml", "xaml")
Associate "sourcemap" "Source Map" "text.ico" ("map")

# Code
Associate "asm" "Assembler" "asm.ico" ("asm", "s")
Associate "c" "C Source" "c.ico" ("c")
Associate "cmake" "CMake" "code.ico" ("cmake", "in")
Associate "cpp" "C++ Source" "cpp.ico" ("c++", "cc", "cpp", "cxx")
Associate "cs" "C Sharp" "cs.ico" ("cs")
Associate "css" "CSS" "code.ico" ("css")
Associate "def" "Exports" "code.ico" ("def")
Associate "h" "C Header" "h.ico" ("h")
Associate "hpp" "C++ Header" "hpp.ico" ("h++", "hh", "hpp", "hxx", "i++", "ipp", "ixx")
Associate "java" "Java" "code.ico" ("java")
Associate "javascript" "JavaScript" "code.ico" ("js")
Associate "kotlin" "Kotlin" "code.ico" ("kt")
Associate "lua" "Lua" "code.ico" ("lua")
Associate "manifest" "Manifest" "xml.ico" ("manifest")
Associate "makefile" "Makefile" "code.ico" ("mk")
Associate "perl" "Perl" "code.ico" ("perl", "pl", "pm")
Associate "python" "Python" "code.ico" ("py")
Associate "resource" "Resource" "rc.ico" ("rc")
Associate "shell" "Shell" "code.ico" ("sh")
Associate "sql" "SQL Script" "code.ico" ("sql")
Associate "typescript" "TypeScript" "code.ico" ("ts")
Associate "vb" "Visual Basic" "vb.ico" ("vb")

& ie4uinit.exe -ClearIconCache
