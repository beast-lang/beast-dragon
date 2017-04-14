
<p align="center">
	<img src="./doc/logo_256w.png">
</p>

# Beast Programming Language

[![Build Status](https://travis-ci.org/beast-lang/beast-dragon.svg?branch=master)](https://travis-ci.org/beast-lang/compiler)

Beast is a new programming language mostly inspired by C++ and D.

This repository contains (everything is WIP):

* Sample transcompiler to C (you will need a [D compiler](http://dlang.org/))
* [Language reference (WIP)](https://github.com/beast-lang/beast-dragon/blob/master/doc/reference/main.pdf)
* [Excel@FIT article describing basic concepts of Beast](https://github.com/beast-lang/beast-dragon/blob/master/doc/excel_article/2017-ExcelFIT-Beast.pdf)
* [Bachelor thesis text (WIP)](https://github.com/beast-lang/beast-dragon/blob/master/doc/bachelor_thesis_CZ/projekt.pdf) (Czech language)

Source file extension: `.be`

## Notable language features

* Importable modules (no header files like in C++)
* C++ style multiple inheritance class system
* Powerful compile-time engine
* Compiled (to C so far, switch to LLVM is planned)
* Const-by-default
* Compile-time language reflection

## Progress

* Compiler: Currently under intensive development, some very basic functionality working right now (compiles to C++)
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

```beast
class C {

@public:
  Int! x; // Int! == mutable Int

@public:
  Int #opBinary( Operator.binaryPlus, Int other ) { // Operator overloading, constant-value parameters
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
  @ctime Type T! = Int; // Type variables!
  T x = 3;

  T = C;
  T!? c := new C(); // C!? - reference to a mutable object, := reference assignment operator
  c.x = 5;

  // Compile-time function execution, :XXX accessor that looks in parameter type
  @ctime String s = foo( :a, Int );
  stdout.writeln( s );

  stdout.writeln( c + x ); // Writes 8
  stdout.writeln( c.#opBinary.#parameters[1].type.#identifier ); // Compile-time reflection
}
```

# News
__14.04.2017__: @ctime variables now work in runtime functions and are properly mirrored! (the subsystem has to be implemented for interpreter yet). See test/ctime/t_basicmirroring.

__04.04.2017__: We have classes now! Constructors are not generated automatically, so you have to do ```Void #ctor() { mem1.#ctor(); mem2.#ctor(); }```