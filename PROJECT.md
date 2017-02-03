# Project configuration documentation

Project configuration in Beast is based on a JSON format. For configuration options, execute `beast --help-config`.

## Configuring the project

There are multiple ways how to pass these options to the compiler:

1. You can pass them as an argument to the compiler in format `--config <optName>=<jsonValue>`, for example `--config targetFileName="app.exe"`. These options overwrite project configuration priorities.
2. You can set up a `beast.json` file in the project directory and put options there.

All file paths in the configuration file are considered to be relative to the project base path, which is:
1. Path explicitly set by flag `--root`
2. Path of the project configuration file set by `--project` (if set)
3. Current working directory