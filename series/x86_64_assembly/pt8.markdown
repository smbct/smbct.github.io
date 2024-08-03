---
title:  Assembly x86 programming 101 &#58 chapter 8, graphical Mandelbrot
author: smbct
date:   2024-06-28 10:00:00 +0200
categories: low-level programming assembly
comments: true
layout: series_article
series: x86_assembly
back_page: headline.md
lang: en
---

In the previou chapter, we saw the use of vector registers in assembly to perform floating point operations on decimal numbers.
Although the result was already interesting, still it is a shame that a wonderfull object such as the Mandelbrot set cannot be visualized under its best angle.

In this chapter, we will build from this previous program and bring it to a new dimension by using a graphical library 📊.
This will allow us to see how such library 📚 can be **linked** 🔗 to our program and how to **call its functions** 📣 directly from our assembly program.

## Setting up a graphical library from x86-64

Our first step is to pick an appropriate library for our project.
This idea led me directly to the [Simple and Fast Multimedia Library (SFML)](http://127.0.0.1:4000/series/x86_64_assembly/pt8).
This library offers numerous functionalities to build graphical applications with hardware acceleration, support for audio and networking, etc.. while being extremely to use.
The SFML library is coded in C++ but we will actually not rely on its native version in our program.

![TheSFML logo](/assets/assembly_series/sfml_logo.png)
<div class="custom_caption" markdown="1">
\> The SFML logo.
</div>

#### What's wrong with C++ ?

I will be honest, it took me some time to make this chapter work properly.
The obvious choice to start with SFML was to interface the assembly program directly with its C++ API.
However, it turns out to be quite delicate for several reasons.

We already saw in the [5th chapter](pt6) how to call a function from a C compiled ⚙️ program in our assembly code.
To do so, our compiled code (object file) just needed to be linked 🔗 to the compiled C code, and we were able to call 📣 our C function without any additional definition.
This changes a little bit in C++ as a lot of code is generated from the header files (function definitions, templated functions, etc..).
This code is however only generated to produce a final executable and I was not able ❌ to obtain a compiled version of all the interface functions of the library.

C is on the other hand a much simpler language where object files contain everything that is needed to call a library's [API](https://en.wikipedia.org/wiki/API).
This is why a finally decided to rely on the [C SFML binding](https://www.sfml-dev.org/download/csfml/) for this chapter.
C seems stable enough so that the binding is actually chosen instead of the native C++ API as basis of othe bindings such as the [.NET](https://www.sfml-dev.org/download/sfml.net/) or the [Rust](https://github.com/jeremyletang/rust-sfml) ones. Quoting from the .NET bind page : ``"It is built on top of the C binding, CSFML, to ensure maximum compatibility across platforms."`` 



## Our first x86-SFML program

We will start by setting up our project to develop with the C-SFML library.
The first step consists in downloading the C-SFML sources from the official [page](https://www.sfml-dev.org/download/csfml/) (there is no compiled release for Linux at the moment).
There is no need to download 🛜 the original C++ SFML library as the CSFML binding already contains these sources.
[CMake](https://cmake.org/) will then allow to compile the sources and install the binaries on your system.

#### Project configuration

We will start the program with a simple main function in `x86`.
We use define `libc` main function in order to allow the use of the C standard library in our program with usefull functions such as `printf`.

<div class="collapse-panel"><div>
<label for="code_1">Expand</label>
<input type="checkbox" name="" id="code_1"><span class="collapse-label"></span>
<div class="extensible-content">
<div class="code_frame">hello_sfml.s | Assembly x86-64</div>
{% highlight nasm linenos %}
.global main
.intel_syntax noprefix

main:
    
    push rbp ; storing the rbp value before manipulation
    mov rbp, rsp ; storing the rsp register

    ; storing the preserved registers
    push rdi
	push rsi

    mov rax, 1
    mov rdi, 1
    lea rsi, [hello_world]
    mov rdx, 14
    syscall

    pop rsi
    pop rdi

    ; restoring the rsp and rbp registers
    mov rsp, rbp
    pop rbp

    ; return
    mov rax, 0
    ret

hello_world:
    .asciz "Hello, World!\n"
{% endhighlight %}
</div></div></div>

The compilation will be performed in two steps as we already did in previous chapters : first compiling (more accurately assembling) the x86 source files into object files, and second linking the object files together with the additional external libraries 📚.

Since our compilation command would become longer here with by linking the SFML library, we will write a Makefile.
The makefile will contain only 2 lines :

<div class="code_frame">Makefile</div>
{% highlight Make linenos %}
hello_sfml: hello_sfml.o
	gcc hello_sfml.o -lcsfml-graphics -lcsfml-window -lcsfml-system -o hello_sfml

hello_sfml.o: hello_sfml.s
	as hello_sfml.s -c -o hello_sfml.o
{% endhighlight %}

The main new thing in our linking command is the C-SFML shared library files for the  `graphics`, `window` and `system` [modules](https://www.sfml-dev.org/index.php) respectively. 

You could also notice that here we omitted the `-static` options that we used in the previous chapters.
This is because now we are working with a [shared library](https://en.wikipedia.org/wiki/Shared_library).
This means that the C-SFML object code will not be incorporated in the final executable of our program but will be loaded at runtime instead.

Let's now try to compile our program thanks to our Makefile with the `make` command:

<div class="code_frame">Bash</div>
{% highlight plain linenos %}
> make hello_sfml
as -g hello_sfml.s -c -o hello_sfml.o
gcc hello_sfml.o -lcsfml-graphics -lcsfml-window -lcsfml-system -o hello_sfml
/usr/bin/ld: hello_sfml.o: relocation R_X86_64_32S against `.text' can not be used when making a PIE object; recompile with -fPIE
/usr/bin/ld : impossible de fixer les tailles des sections dynamiques : bad value
collect2: error: ld returned 1 exit status
make: *** [Makefile:48 : hello_sfml] Erreur 1
{% endhighlight %}

We can see 🧐 that removing the `-static` option from our linking command ⛓️ actually introduced an error 🚫.
The linker (`ld`) complains because we are making a **PIE** file, namely a **P**osition **I**ndependant **E**xecutable.
Indeed, adding a **shared library** to our program implies that it will references additional compiled code (from the library) during its execution.
For this reason, all the references (or line numbers) in our code must be **relative** to the current instruction (that is stored in the `rip` register).

A simple fix to make our program compile ✅ as a PIE executable consists in specifying the `rip` register werether a data label is referenced in the code.
Here, this only happens when referencing our *"Hello, World!\n"* string, at line 15. 

Our code should then become :

{% highlight nasm linenos %}
lea rsi, [rip+hello_world]
{% endhighlight %}

This way, the asembler will know we that we are creating a Position Independent Executable, where references are relatives to the pointed instruction.
The code should now compile with the `make` command.


#### A simple window loop



A simple way to start our implementation consists in first creating a C code that creates a window in SFML and then used GCC to create assembly from this code and analyse how the functions are called.
This is in fact similar to what we did in [chapter 7](pt7#how-are-floats-implemented-in-c-) to see how floating point operations were performed.

We can now start calling SFML functions through its C API.
Our first goal will be to create and open a new window 🪟.
As we saw in [chapter 5](pt5#calling-a-custom-c-function), it is not necessary to provide any definition of a C function to our code, contrary to other languages such as C or C++.

## Graphical Mandelbrot

#### Drawing in SFML

#### Drawing the Mandelbrot set

## What's next ?
