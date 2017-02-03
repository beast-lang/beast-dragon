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

## error
Expects error (severity error) on the file and line of the directive.

**Arguments** \
`noLine` - error is not related to the line (it does not have line attribute) \
`noFile` - error is not related to the file (it does not have file attribute)

---
## onlyLexing 
Compiler performs only lexing phase

---