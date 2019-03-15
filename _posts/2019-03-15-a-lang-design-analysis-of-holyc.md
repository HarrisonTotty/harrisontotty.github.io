---
layout: post
title: "A Language Design Analysis of HolyC"
---

# A Language Design Analysis of HolyC

I was recently intoduced to the story of [Terry A. Davis](https://en.wikipedia.org/wiki/Terry_A._Davis), a schizophrenic programmer who independently designed the free operating system [TempleOS](https://en.wikipedia.org/wiki/TempleOS). This article will not delve into the story of Terry or TempleOS, but instead the programming language Terry wrote specifically for developing the operating system - a language he dubbed "_HolyC_".

_HolyC_, as the name would imply, is a _C-like_ programming language with a number of key differences and improvements. Like _C_, it's whitespace independent and compiles to assembly. However, as Terry describes in the OS's own documentation for the built-in assembly language:

> TempleOS uses nonstandard opcodes. Asm is kind-of a bonus and I made changes to make the assembler simpler. For opcodes which can have different numbers of args, I separated them out -- Like `IMUL` and `IMUL2`. The assembler will not report certain invalid forms. Get an Intel datasheet and learn which forms are valid.

This article won't cover the assembly layer of TempleOS, but the above is interesting nonetheless.

## Types in HolyC

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

