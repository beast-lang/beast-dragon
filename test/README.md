# Beast test suite

Tests can be composed of:
* Either single file beginning with `t_`
* Or a directory beginning with `t_`
  * If the directory contains `beast.json`, it is used
  * If not, the test suite includes all `.be` files as source files

## Test directives
Test directives are scanned for in all `.be` source files belonging to the test (dumb scan, not looking into `beast.json`). They are included into the code as comments beginning with the `//!`.

The format is:
```
code //! directive1Name: mainDirectiveValue, arg1: arg1Val, arg2 ; directive2Name: etcetc
```

# Supported directives

## error, warning, hint
Expects error/warning/hint on the file and line of the directive (error type is passed as main value).

**Arguments** \
`noLine` - error is not related to the line (it does not have line attribute) \
`noFile` - error is not related to the file (it does not have file attribute) \
`lineSpan` - indicates that the error can occur anywhere in next N lines

## onlyLexing, onlyParsing
Compiler performs only lexing/parsing phase

## stdout
Expects program to output given string to stdout (string is passed as main valued and parsed as JSON string if in quotation marks, otherwise as a plain string with stripped spaces around).

When there are more stdout directives, the resulting stdout is expected to be concatenation of all of them.

Directives do not take execution or parsing order into consideration - they are parsed in the order they are mentioned in the source file.