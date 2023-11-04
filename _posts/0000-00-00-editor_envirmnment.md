---
title: "Tool | Edirot Guide"
author: Benson Hsu
date: 0000-01-01
category: Jekyll
layout: post
tags: [tool]
---

> Notes editor environment  
{: .block-tip }

##### [VScode for Java]

Add Java jdk in vscode in `setting.json`
```json
"java.configuration.runtimes": [
    {
        "name": "JavaSE-17",
        "path": "/usr/bin/java"
    },
]
```

-   Hide **Run | Debug** in editor  
Editor: Code Lens  
<input type="checkbox" disabled /> Controls whether the editor shows CodeLens.  

-   Hide **Inlay Hints**  
Editor › Inlay Hints: Enabled  
Enables the inlay hints in the editor.  
on -> off

##### [Vscode Debugger for C/C++ using GDB]

-   Install `gdb` in Linux

```json
{
    "name": "C++ Launch",
    "type": "cppdbg",
    "request": "launch",
    "program": "${workspaceFolder}/target.out",
    "stopAtEntry": false,
    "customLaunchSetupCommands": [
        { "text": "target-run", "description": "run target", "ignoreFailures": false }
    ],
    "launchCompleteCommand": "exec-run",
    "linux": {
        "MIMode": "gdb",
        "miDebuggerPath": "/usr/bin/gdb"
    },
    "osx": {
        "MIMode": "lldb"
    },
    "windows": {
        "MIMode": "gdb",
        "miDebuggerPath": "C:\\MinGw\\bin\\gdb.exe"
    }
}
```

> ##### Last Edit
> 09-29-2023 12:22
{: .block-warning }

[VScode for Java]: https://code.visualstudio.com/docs/java/java-tutorial