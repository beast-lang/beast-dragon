# Beast programming language
Beast is a concept for a new programming language inspired by C++ and D.

This repository contains (everything is WIP):
* Sample transcompiler to C++
* Language reference
* Bachelor thesis text (thich language is a bachelor thesis) - written in Czech

## Basic language features
* Importable modules (no header files like in C++)
* C++ style multiple inheritance class system
* Powerful compile-time engine
* Compiled to binary (to C++ so far)
* Const-by-default
* Compile-time language reflection

## Sample code
Please note that this code describes what the language should be able to do when done, not what it can do now.
```beast
class C {
  
@public:
  Int! x; // Int! == mutable Int
  
@public:
  Int #operator( Operator.binaryPlus, Int other ) { // Operator overloading
    return x + other;
  }
  
}

Void main() {
  @ctime Type T! = Int; // Type variables!
  T x = 3;
  
  T = C;
  T!? c := new C; // C!? - reference to a mutable object, := reference assignment operator
  c.x = 5;
  
  console.write( c + x ); // Writes 8
  console.write( c.#operator.#parameters[1].#type.#identifier ); // Language reflection; writes "Int"
}
```
