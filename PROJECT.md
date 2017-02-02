# Project configuration documentation

Project configuration in Beast is based on a JSON format.

## Configuration options

| Key | Type | Description |
|-----|:------:|-------------|
| targetFileName | STRING | File name of target application/library |
| sourceDirectories | ARRAY OF STRING | Root source file directories; all modules in these directories are included in the project |
| includeDirectories | ARRAY OF STRING | Root include directories; modules in include directories are not included in the project unless they're explicitly imported |
| sourceFiles | ARRAY OF STRING | Explicit source files included in the project |
| messageFormat | 'gnu' \| 'json'| Format of compiler messages |
| runAfterBuild | BOOLEAN | If set to true, target application will be run after succesful build |

## Configuring the project

There are multiple ways how to pass these options to the compiler:

1. You can pass them as an argument to the compiler in format `--config <optName>=<jsonValue>`, for example `--config targetFileName="app.exe"`. These options overwrite project configuration priorities.
2. You can set up a `beast.json` file in the project directory and put options there.

All file paths in the configuration file are considered to be relative to the project base path, which is:
1. Path explicitly set by flag `--root`
2. Path of the project configuration file set by `--project` (if set)
3. Current working directory