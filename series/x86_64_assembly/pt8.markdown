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
This library offers numerous functionalities to build graphical applications with hardware acceleration, support for audio 🎧 and networking 🛜, etc.. while being extremely to use.
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
The code should now compile ⚙️ with the `make` command.


## A simple window loop

We can now start calling SFML functions through its C API.
Our first goal will be to create and open a new window 🪟.

#### Opening a window in CSFML

A simple way to start our implementation consists in first creating a C code that creates a window in SFML and then using GCC to create assembly from this code and analyse how the functions are called.
This is in fact similar to what we did in [chapter 7](pt7#how-are-floats-implemented-in-c-) to see how floating point operations were performed.
Our basis will be the follwing code :

<div class="code_frame">C | create_window_c.c </div>
{% highlight C linenos %}
#include <unistd.h>
#include <SFML/Graphics.h>

int main(int argc, char* argv[]) {

    const sfVideoMode mode = {800, 600, 32};

    // create the main window
    sfRenderWindow* window = sfRenderWindow_create(mode, "SFML window", sfResize | sfClose, NULL);

    // display the window
    sfRenderWindow_display(window);

    // pause
    sleep(5);
    
    // destroy the window
    sfRenderWindow_destroy(window);

    return 0;
}
{% endhighlight %}

You can see that this program simply creates a window "object" (data **struct**ure) by calling the `sfRenderWindow_create` function.
The window is then displayed followed by a pause to actually see the window.
After that, the window object is cleaned up using a destroy function.
The C API of the SFML library will always follow this scheme : the data of a C++ object is encapsulated in a `struct`, and dedicated functions allow the user to interact with it, including mermory allocating and de-allocating the object.

The following two lines in our Makefile will allow to test the code :

<div class="code_frame">Makefile</div>
{% highlight Make linenos %}
create_window_c.o: create_window_c.c
	gcc create_window_c.c -c -o create_window_c.o

create_window_c: create_window_c.o
	gcc create_window_c.o -lcsfml-graphics -lcsfml-window -lcsfml-system -o create_window_c
{% endhighlight %}

Now before compiling this code into assembly, we need to perform some refactoring in order to simplify the task of calling the library 📚 from assembly.
Indeed, in the above C code, the problem is that values are directly  given in the function call without defining a proper variable with the corresponding data type.
This makes the code more difficult to read 👓 since we should be able to understand precisely how the data structures are defined and what memory to allocate. 

Here is the actual definition of the `sfRenderWindow_create` function, directly taken from the header file :

<div class="code_frame">C | RenderWindow.h </div>
{% highlight C linenos %}
CSFML_GRAPHICS_API sfRenderWindow* sfRenderWindow_create(sfVideoMode mode, const char* title, sfUint32 style, const sfContextSettings* settings);
{% endhighlight %}

Let's now refactor our previous code by explicitely creating variables for all the arguments :

<div class="code_frame">C | create_window_c.c </div>
{% highlight C linenos %}
// [...]

// window pointer
sfRenderWindow* window;

// window arguments
const sfVideoMode mode = {800, 600, 32};
const char* title = "SFML window";
sfUint32 style = sfResize | sfClose;
const sfContextSettings* settings = NULL;

// create the main window
window = sfRenderWindow_create(mode, title, sfResize | sfClose, settings);

// [...]
{% endhighlight %}

The code should function exactly as previously, except that now we can explicitly see what data is allocated in order to pass the parameters.

#### Opening a window from assembly

Let's add a new entry in our Makefile to transform our previous code into assembly :

<div class="code_frame">Makefile</div>
{% highlight Make linenos %}
create_window_c.s: create_window_c.c
	gcc -S create_window_c.c -masm=intel -fdiagnostics-color=always -fverbose-asm -o create_window_c.s
{% endhighlight %}

For now, let's extract the portion responsible of allocating the window 🪟 structure :

<div class="code_frame">Assembly x86-64 | create_window_c.s </div>
{% highlight nasm linenos %}
; create_window_c.c:12:     const char* title = "SFML window";
	lea	rax, .LC0[rip]	; tmp84,
	mov	QWORD PTR -24[rbp], rax	; title, tmp84
; create_window_c.c:13:     sfUint32 style = sfResize | sfClose;
	mov	DWORD PTR -28[rbp], 6	; style,
; create_window_c.c:14:     const sfContextSettings* settings = NULL;
	mov	QWORD PTR -16[rbp], 0	; settings,
; create_window_c.c:17:     window = sfRenderWindow_create(mode, title, sfResize | sfClose, settings);
	mov	rcx, QWORD PTR -16[rbp]	; tmp85, settings
	mov	rdx, QWORD PTR -24[rbp]	; tmp86, title
	mov	rsi, QWORD PTR mode.0[rip]	; tmp87, mode
	mov	eax, DWORD PTR mode.0[rip+8]	; tmp88, mode
	mov	r8, rcx	;, tmp85
	mov	ecx, 5	;,
	mov	rdi, rsi	;, tmp87
	mov	esi, eax	;, tmp88
	call	sfRenderWindow_create@PLT	;
	mov	QWORD PTR -8[rbp], rax	; window, tmp89
{% endhighlight %}

The arguments of the `sfRenderWindow_create` function are of multiple types.
`mode` is a `sfVideoMode` **struct**ure (as we can see from the definition), title is a **char array**, style is a **32 bits integer** and settings is a **pointer**.

* The "settings" argument is the easyest to start with.
Indeed, although this argument is a pointer the default value `NULL` is used in our code.
Since pointers are just addresses, and since addresses are coded on **8 bytes**, the value that will be given to the function will simply be a *0* coded on 8 bytes.
This can be seen at lines *7* and *9* from the code above.

* The "title" argument is also an easy one to specify.
Indeed, we already saw in the previous chapters how to manipulate arrays of characters in assembly.
We can see at lines *2* and *3* that the string is defined at the `.LC0` symbol in the code and its address is the stored in the stack.
We can omit the stack part in our code as it is possible to directly reference the address of the symbol in the program's memory.

* We saw that the "style" argument is a simple integer. Howether, its value is obtained through *[bitwise](https://www.geeksforgeeks.org/bitwise-operators-in-c-cpp/)* operators, which is a way to store several values into a unique variable.
We can see at lines *4* and *5* that the resulting value of the combined flags `sfResize | sfClose` is actually **6**. In our case, we can directly use this raw value in the code to simplify things.

* The last parameter, "mode", has the type `sfVideoMode`, which is a structure with 4 integers.
We can see at lines *11* and *12* that its value is defined at symbol `mode.0`, that is :

{% highlight nasm linenos %}
mode.0:
; width:
	.long	800
; height:
	.long	600
; bitsPerPixel:
	.long	32
{% endhighlight %}

Since data values of a **struct** are contiguous in memory, this order will actually always be verified when defining a `sfVideoMode`.
We can see that the *3* values are coded on **4** bytes each (`.long`).
This implies that 12 bytes of memory are necessary to pass all the values.
This is the reason why this parameter is splitted across two registers, `rdi` that contains the width and height values contiguously (lines *11* and *15*) and `esi` that contains the "bitsPerPixel" field on 4 bytes (lines *12* and *16*).

We can now write our own assembly code to open the window, starting from the following basis :

<div class="code_frame">create_window_assembly.s | Assembly x86-64</div>
{% highlight nasm linenos %}
.global main
.intel_syntax noprefix

main:
    
    push rbp ; storing the rbp value before manipulation
    mov rbp, rsp ; storing the rsp register

    ; memory allocation (window pointer)
    sub rsp, 8

    ; storing the preserved registers
    push rdi
    push rsi
    push rbx

    ; window creation
    ; [...]

    ; calling "display"
    ; [...]

    ; calling "sleep"
    ; [...]

    ; window destruction
    ; [...]

    pop rbx
    pop rsi
    pop rdi

    ; restoring the rsp and rbp registers
    mov rsp, rbp
    pop rbp

    ; return
    mov rax, 0
    ret

; constants definitions

{% endhighlight %}

Note that 8 bytes are allocated in the stack as we need to store the window pointer (returned by the create function).
We then start completing by defining the constants : the video mode, the window title and the style :

{% highlight nasm linenos %}
; constants definitions
window_title:
   .string	"SFML x86 window"

; window video mode
window_width:
    .long 800
window_height:
    .long 600
window_depth:
    .long 32

; window style (sfResize | sfClose)
window_style:
    .long 6
{% endhighlight %}

Now we can complete the code by calling the "create" function. Recall that the order of the registers for the parameters are given in this [table](https://i.sstatic.net/j8hpC.png) (see [chapter 5](pt5)).

{% highlight nasm linenos %}
; window creation
; video mode
mov rdi, [rip+window_width]
mov esi, [rip+window_depth]
; title
lea rdx, [rip+window_title]
; style
mov ecx, [rip+window_style]
; settings
mov r8, qword ptr 0
call sfRenderWindow_create
mov [rbp-8], rax ; store the window ptr
{% endhighlight %}

Recall that it is now necessary to specify the `rip` register as we are creating **PIE** and that it is not necessary to provide any definition of the library functions to our code, contrary to other languages such as C or C++ as we saw in [chapter 5](pt5#calling-a-custom-c-function).

We can now add the other function calls, that are much simpler in terms of arguments :

{% highlight nasm linenos %}
; calling "display"
mov rdi, [rbp-8]
call sfRenderWindow_display

; calling "sleep"
mov edi, 5
call sleep

; window destruction
mov rdi, [rbp-8]
call sfRenderWindow_destroy
{% endhighlight %}

We can see that the two other CSFML functions have only one argument which is the address of the window object (pointer), and do not return anything.
The complete code can be compiled with a Makefile entry similar to the one from our previous CSFML "hello world".
It should now function exactly as the analog C program.


## Graphical Mandelbrot

#### Drawing in SFML

#### Drawing the Mandelbrot set


## Bonus : coding the window loop

Now that our program can open a window, we need to add more code so 


## What's next ?
