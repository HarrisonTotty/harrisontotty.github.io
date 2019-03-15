---
layout: post
title: "A Language Design Analysis of HolyC"
---

I was recently intoduced to the story of [Terry A. Davis](https://en.wikipedia.org/wiki/Terry_A._Davis), a schizophrenic programmer who independently designed the free operating system [TempleOS](https://en.wikipedia.org/wiki/TempleOS). This article will not delve into the story of Terry or TempleOS, but instead the programming language Terry wrote specifically for developing the operating system - a language he dubbed "_HolyC_".

_HolyC_, as the name would imply, is a _C-like_ programming language with a number of key differences and improvements. Like _C_, it's whitespace independent and compiles to assembly. However, as Terry describes in the OS's own documentation for the built-in assembly language:

> TempleOS uses nonstandard opcodes. Asm is kind-of a bonus and I made changes to make the assembler simpler. For opcodes which can have different numbers of args, I separated them out -- Like `IMUL` and `IMUL2`. The assembler will not report certain invalid forms. Get an Intel datasheet and learn which forms are valid.

This article won't cover the assembly layer of TempleOS, but the above is interesting nonetheless.

## Numeric Types in HolyC

_HolyC_ allows the following numeric types: `U0`, `I8`, `U8`, `I16`, `U16`, `I32`, `U32`, `I64`, `U64`, and `F64`. As you probably would guess, a `U` vs `I` prefix denotes a signed/unsigned integer/float and the numerical value represents the number of bits associated with the type. The two most interesting types are `U0` and `F64`. 

`U0` is essentially `void` but with _zero_ size. In regular _C_, `void` is actually considered a [Unit Type](https://en.wikipedia.org/wiki/Unit_type) and thus when computing `sizeof(void)` in GCC, you will find that it resolves to `1`. `U0` is actually closer to a [Bottom Type](https://en.wikipedia.org/wiki/Bottom_type), like `!` in Rust.

`F64` is interesting because it is the only _float_ available in _HolyC_. I can't find a specified reason in the source code, but I presume it is a combination of "if you're going to do floating-point operations, wouldn't you pretty much always want maximum precision by definition?" and maybe the fact that 

> All values are extended to 64-bit when accessed. Intermediate calculations are done with 64-bit values.

The example given is:

```c
U0 Main()
{
    I16 i1;
    I32 j1;
    j1=i1=0x12345678;           // i1 is 0x5678 but j1 is 0x12345678
    
    I64 i2=0x8000000000000000;
    Print("%X\n", i2>>1);       // Prints 0xC0000000000000000
    
    U64 u3=0x8000000000000000;
    Print("%X\n", u3>>1);       // Prints 0x40000000000000000
    
    I32 i4=0x80000000;          // This is loaded into a 64-bit register variable.
    Print("%X\n", i4>>1);       // Prints 0x40000000
    
    I32 i5=-0x80000000;
    Print("%X\n", i5>>1);       // Prints 0xFFFFFFFFC0000000
}
```

## Functions

Functions are where you start to see some of the more drastic differences. For starters, functions that are invoked without arguments (or without overriding any default arguments) may be syntactically shortened to just the function name followed by a semicolon.

```c
// The following are equivalent.

x = Foo();  // C
y = Foo;    // HolyC
```

Speaking of default arguments, in _HolyC_ it's a-okay to have default args at any point in the function definition like so:

```c
// ----- Function Definition -----
I32 Foo(I32 i=8, I32 j)
{
    return (i + j)
}

// ----- Invocation -----
I32 x;
x = Foo(,6);
```

Note the prepended comma in the function invocation arguments. At first this seems pretty useless (why wouldn't you just re-order your args?) but it _does_ allow you to write functions with some logical order:

```c
// Copies the files in "source" path to the "destination" path
U0 CopyTo(char *source="T:/Doc/Files", char *dest)
{
    // ...
}

CopyTo(,"T:/Doc/Files2");
```

Similarly to Python and other modern languages, functions can have variable argument counts, here specified with `(...)` in the function definition. The function body may then access its arguments by utilizing the built-in `argc` and `argv` variables:

```c
I64 Sum(...)
{
    I64 i,tot = 0
    for (i = 0; i < argc; i++)
        tot += argv[i];
    return tot;
}

I64 x = Sum(3, 4, 5); // x = 12
```

Note that `for` loops in _HolyC_ don't require curly braces if they only perform one operation.

Finally, _HolyC_ does _not_ have a required `Main()` function. Expressions outside of functions are simply evaluated from top to bottom in source. This also allows the programming language to act like a shell, and in-fact _is_ the shell of TempleOS.

## Switch Statements

Terry explained multiple times how switch statements are the most powerful constructs in _HolyC_. In the language, switch statements always utilize jump tables in assembly (and thus the documentation mentions to not use them in cases with large/sparse value ranges). The ones in _HolyC_ offer quite a range of convenience improvements over their _C_ counterparts. For starters, _HolyC_ offers experienced programmers an _unchecked variant_ of the switch expression, denoted via `switch [foo]` instead of `switch (foo)`. In addition, the language also has implicit case values and even case ranges!

```c
I64 i;
switch (i) {
    case: "zero\n"; break;         // Implicit case statements start at 0
    case: "one\n"; break;          // ... and increment by 1 each time.
    case: "two\n"; break;
    case 3: "three\n"; break;      // Explicit cases work as you would expect.
    case 3...8: "others\n"; break; // Cases 3 through 8 will print "others\n".
}
```

Note that in the above example I technically skipped explaining another quirk with _HolyC_, which is that constant (literal) string expressions all by themselves will automatically be sent to `Print`. This lets you do neat things like:

```c
U0 PrintMessage(char *first, char *last)
{
    "Hello person!\n";
    "Your name is %s %s.\n", first, last;
}
```

Back to switch statements, they may actually be nested into what are known as "sub_switch" statements via the `start` and `end` keywords. Below is the example code included in TempleOS for this functionality:

```c
U0 SubSwitch ()
{
    I64 i;
    for (i=0;i<10;i++)
        switch(i) {
            case 0: "Zero ";     break;
            case 2: "Two ";      break;
            case 4: "Four ";     break;
            start:
                "[";
                case 1: "One";   break;
                case 3: "Three"; break;
                case 5: "Five";  break;
            end:
                "] ";
                break;
        }
    '\n';
}

SubSwitch;
```

The above code will print `Zero [One] Two [Three] Four [Five]` to the command line.

## `#exe {}`

This is my personal favorite feature. This expression allows you to write code or execute programs whose output is embedded into the rest of your source code at compile time. This let you do things like:

```c
#include #exe { /* code to find location of library */ }
```

This is essentially _HolyC_'s solution to _macros_.

## Misc Features & Quirks

* In _HolyC_, you can `Free()` a null pointer.
* The stack does not grow because _HolyC_ does not utilize virtual memory.
* There is no `continue` keyword in the language. Instead, Terry urges programmers to use `goto`'s instead.
* There is no `#define` capability. Terry's explanation for this is that he's just "not a fan".
* The `typedef` keyword is replaced with `class`.
* `#include` does not support `<>` for importing standard libraries. All `#include` statements must use `""`.
* There is no type checking what-so-ever.
* `try {}`, `catch {}`, and `throw` are supported, however `throw` only returns up to an 8-byte `char` argument, which may be accessed in a `catch {}` as `Fs->except_ch`.
