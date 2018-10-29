
<p align="center">
	<img src="./doc/logo_256w.png">
</p>

# Beast Programming Language

[![Build Status](https://travis-ci.org/beast-lang/beast-dragon.svg?branch=master)](https://travis-ci.org/beast-lang/compiler)

Beast is a new programming language mostly inspired by C++ and D.

This repository contains (everything is WIP):

* Sample transcompiler to C (you will need a [D compiler](http://dlang.org/))
* [Language reference](https://github.com/beast-lang/beast-dragon/blob/master/doc/reference/main.pdf)
* [Excel@FIT article describing basic concepts of Beast](https://github.com/beast-lang/beast-dragon/blob/master/doc/excel_article/2017-ExcelFIT-Beast.pdf)
* [Bachelor thesis text](https://github.com/beast-lang/beast-dragon/blob/master/doc/bachelor_thesis_CZ/projekt.pdf) (Czech language)

Source file extension: `.be`

## Notable language features

* Importable modules (no header files like in C++)
* C++ style multiple inheritance class system
* Powerful compile-time engine
* Compiled (to C so far, switch to LLVM is planned)
* Const-by-default
* Compile-time language reflection

## Progress

!!! DEVELOPMENT CANCELLED

* Compiler: The compiler now works as a proof-of-concept. It has some core functionality working, but not really anything you could write your programs with.
  * See test/tests for working code examples
* Std library: Nothing at all
* Language reference: Nothing much

## Contact

| **Author**: | Daniel 'Danol' Čejchan |
| --- | --- |
| **Email**: | czdanol@gmail.com |
| **IRC**: | irc.freenode.net#beast-lang |
| **Discord**: | [Invitation](https://discord.gg/FMCQQdT) |

## Sample code

Please note that this code describes what the language should be able to do when done, not what it can do now.

For currently compilable code, ses tests in ```test/tests```. Compiling and running the testsuite (```./runTests```) generates commands required for running each test (commands are in log files in the ```test/log``` directory).

Specifically, tests in the [examples folder](https://github.com/beast-lang/beast-dragon/tree/master/test/tests/examples) are designed as examples.

```beast
class C {

@public:
  Int! x; // Int! == mutable Int

@public:
  Int #opBinary( Operator.binPlus, Int other ) { // Operator overloading, constant-value parameters
    return x + other;
  }

}

enum Enum {
  a, b, c;

  // Enum member functions
  Enum invertedValue() {
    return c - this;
  }
}

String foo( Enum e, @ctime Type T ) { // T is a 'template' parameter
  // 'template' and normal parameters are in the same parentheses
  return e.to( String ) + T.#identifier; 
}

Void main() {
  // @ctime variables are evaluated at compile time
  @ctime Type T! = Int; // Type variables!
  T x = 3;

  T = C;
  T!? c := new auto(); // C!? - reference to a mutable object, := reference assignment operator
  c.x = 5;

  // Compile-time function execution, :XXX accessor that looks in parameter type
  @ctime String s = foo( :a, Int );
  stdout.writeln( s );

  stdout.writeln( c + x ); // Writes 8
  stdout.writeln( c.#opBinary.#parameters[1].type.#identifier ); // Compile-time reflection
}
```

## How to build

1. Download a [D compiler](http://dlang.org/)
2. Clone this repository
3. Execute ```dub build``` in the root
4. Folder ```bin``` is created with the Beast Dragon compiler

# News
__29.10.2018__: __Development cancelled__. I was planning to continue working on Beast as my master thesis, but they rejected it. Bummer. Feel free to use anything, but I don't expect it to be of any use in the current state.

__05.05.2017__: Finished writing code for bachelor's thesis. Development of this project is now halted until master thesis or until excessive interest for this project is shown from a community.

__27.04.2017__: Static functions with @ctime parameters implemented! They generate kinda messy code ("template" instances are not joined when provided with same arguments), but still, we have them!

__21.04.2017__: We now should have fully working @ctime mirroring in both interpreter and cpp backends.

__14.04.2017__: @ctime variables now work in runtime functions and are properly mirrored! (the subsystem has to be implemented for interpreter yet). See test/ctime/t_basicmirroring.

__04.04.2017__: We have classes now! Constructors are not generated automatically, so you have to do ```Void #ctor() { mem1.#ctor(); mem2.#ctor(); }```