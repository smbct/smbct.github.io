---
title:  Assembly x86-64 programming 101 &#58 chapter 5, printing arrays
author: smbct
date:   2024-05-21 10:00:00 +0200
categories: low-level programming assembly
comments: true
layout: series_article
back_page: headline.md
lang: en
---

The last post taught us how to write functions in x68 assembly.
The interesting thing is that now we can interact with compiled libraries from other languages.
This will allow us to perform higher level tasks such as opening windows, networking, etc...
In this post, we will start by looking at how to **call C functions**.
We will first see how to use the `printf` function in order to print variables 🖨️.
This will let us print the content of an integer array in assembly.
We will also see how to create a function that can be called from a C program 🔄!


## Calling the C `printf` functions

Although we previously had the freedom to decide our own convention about functions parameters and return value, calling a function from an external library requires us to follow the library's convention.
We will see how to do so by calling the `printf` function from the C standard library. 

#### Using the C standard lib in our program

Our program's compilation will now change a bit.
Previously, we created executables that did not rely on any external library.
We will now need to link the standard library from C to be able to use `printf`. 

Adding the C standard library to our programs is simply done by removing the option `-nostdlib` when linking the executable with gcc, as it is actually linked by default.
However, the C library adds a lot more features to our program : it defines the `_start` function (our program's entry point) by itself.
For this reason, our program's first function will now be the classical `main` function.

The "hello world" code becomes :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
.global main
.intel_syntax noprefix

main:

    mov rax, 1
    mov rdi, 1
    lea rsi, [hello_world]
    mov rdx, 14
    syscall

    ; return
    mov rax, 42
    ret

hello_world:
    .asciz "Hello, World!\n"
{% endhighlight %}

There are two changes regarding the previous "hello_world" program : our function is now named `main` and it will be automatically be called by the `_start` function defined in the libc (C standard library) ; and since it is now a called function, the `ret` instruction is necessary at its end.
Also note that contrarily to what we saw previously, since our function does not use the stack 🥞 we do not need to save and restore the `rsp` and `rbp` registers here.

The compilation is done as previously, except for the second command that becomes `gcc -static my_program.o -o my_program` (the `-nostdlib` option has been removed).
You can verify that the program's output is actually *42*, which is indeed `main`'s return value : `./my_program ; echo $?`.

Note that if you try to compile any of our previous programs without the `-nostdlib` option, it would not work because the `_start` function would be defined twice.
If you want a more precise idea of the additional elements added to our programs by the standard libc, you might check this [interesting article](http://www.muppetlabs.com/~breadbox/software/tiny/teensy.html) 💡!

#### Passing parameters to `printf`

Now that our code's backbone is in place, let's call the `printf` function.
Since the standard libc (C standard library) is now linked to our program, the `printf` symbol will be known by the linker.
Now the important thing is to see how to pass parameters to the `printf` functions.
That part is tricky : the (calling) convention used by Linux is called the **AMD64 System V ABI**.

Documentation is sometimes hard to find and I personally learned this from this [stackoverflow post](https://stackoverflow.com/questions/38335212/calling-printf-in-x86-64-using-gnu-assembler).
You can see that in this convention, registers are used for arguments and return values that are not *composed* data types.

Here is a summary of the order : 

* 1st argument : `rdi`
* 2nd argument : `rsi`
* 3rd argument : `rdx`
* 4th argument : `rcx`
* 5th argument : `r8`
* 6th argument : `r9`
* 1st return value : `rax`
* 2nd return value : `rdx`

We can also learn that since `printf` has a variable number of arguments, the `al` register (the 8 bits version of `rax` register) must be set in order to give information about the use of specific registers.
In our case, we will only have to set it to *0*.

Following the convention, our `printf` call to print "hello world" now becomes :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
    xor eax, eax ; al is set to 0
    lea rdi, [hello_world] ; 1st argument passed to register
    call printf
{% endhighlight %}

If you try this, you would normally see a segmentation fault 🙁

#### One more requirement : stack pointer alignment 🥞

By further reading the stackoverflow post that I linked above, we learn that there is one more condition that needs to be met when calling C functions in the **AMD64 System V ABI** convention : the stack pointer must be aligned to 16 bytes, meaning its value must be a multiple of 16.

We can run gdb on your program and check the value of `rsp` after entering the main function by adding a breakpoint in debug mode.
In my case, the value of `rsp` is *0x7fffffffdbb8*.
We then compute `print 0x7fffffffdbb8 % 0x10` (where *0x10* is 16 in hexadecimal).
The result should be *8* : hence we see that there is an 8 bytes misalignment of the `rsp` value.

> 📝 An easier way to check the alignment is by directly looking at the binary representation of the `rsp` pointer.
> To do so, one can use the `p/t rsp` command in GDB.
> In my case, I obtain : `$2 = [...]111101101110111000`.
> Since 16 is a power of 2 (*16 = 2^4*), we can directly see if the value is a multiple of 16 by looking at the last 4 bits, which indicate wether there is an extra part between 0 and 15.
> We can see that it is indeed the case.

This misalignment comes from the fact that the `call` instruction that actually triggers the execution of `main` pushes the return address (8 bytes) to the stack, as we saw in the last chapter.
As a result the stack pointer is then misaligned by 8 bytes.
This can be fixed by simply re-aligning the stack pointer before starting the call, which can be done by "allocating" 8 additional bytes (unused) :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
    sub rsp, 8

    xor eax, eax ; al is set to 0
    lea rdi, [hello_world] ; 1st argument passed to register
    call printf

    add rsp, 8
{% endhighlight %}

This should now work as expected! 🥳
Note that since our string is zero terminated (it ends by '\0', as defined by the .asci**z** type with the gnu assembler), it is not necessary to specify its length to `printf`. 

In our following codes, we will now make sure the stack pointer is well aligned before starting any operation in our functions.
A proper place to do it is when the local variables are allocated, as we saw in the previous post of the series.

This operation can also be done automatically by subtracting the offset : `rsp` modulo *8*, which can be performed by "anding" *15* to the value of `rsp`: `and rsp, 15` (recall that a modulo operation on a power of two can be obtained by directly looking at the right number of bits in the binary representation).

#### Printing integers with printf

Calling a C function is not easy!
The good thing is this is going to help us to bring concrete features to our programs.
Let's start by accomplishing a task that was previously much harder : printing integer values!

To print a value in the terminal, we can use the `printf` function with its formatting abilities.
In our setup, `printf` would take as argument a string containing a formatter (which decides how the value is displayed) and the value to be printed.
We can have a look at the [documentation](https://cplusplus.com/reference/cstdio/printf/) of `printf` to choose the correct formatter.
In C, this would look like :

<div class="code_frame"> C language</div>
{% highlight C linenos %}
int x = 42;
printf("%i\n", x);
{% endhighlight %}

To do so in assembly, we start by defining a string that contains a formatter :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
integer_formatter:
    .asciz "integer value: %i\n"
{% endhighlight %}

The  "%i" formatter is used to print a decimal integer.
We then call `printf` and pass this string as well as the value to be printed.
For this, we will use the `rsi` register, as it is dedicated to the second argument in the calling convention.

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
    xor eax, eax
    lea rdi, [integer_formatter]
    mov rsi, 42
    call printf
{% endhighlight %}

The program should now print: "integer value: 42".
This now adds a lot more possibilities to interact with the user!




## Printing an array

Now that we know how to call `printf`, we will create a function that will be useful for the future post : printing an array!
We start by defining a constant array in the program's memory :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
my_array:
    .byte 5, 12, 42, 8, 1, 3, 7, 25, 14
my_array_length:
    .word 9
{% endhighlight %}

In this case, the array elements are stored as bytes (8 bits long, coding integer values between -128 and 127).
We also define a constant indicating its size as a word (2 bytes).

We may now define our strings constants to be used by `printf` :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
array_elt_formatter:
    .asciz "%hhd "
new_line:
    .asciz "\n"
my_array_str:
    .asciz "My array : "
{% endhighlight %}

The `array_elt_formatter` is used to format a single byte as an integer with `printf`, followed by a space.
We also define the `new_line` string that only prints the return character for convenience, as well as a string announcing the array to be printed.

#### The local variables

We will need 2 local variables in our `print_array` function : an 8-bytes variable to store the array address and a 2-bytes variable to store an index for iterating over the array.
This results in 10 bytes allocated on the stack 🥞.
With the 8 bytes already present to store the return address of the `main` function, the stack pointer would be aligned to 18 bytes.
Hence, 6 additional bytes are necessary to reach 32 bytes, for a 16 bytes alignment requirement (*32=2x16*).
This gives a total of 24 bytes to allocate. 

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
print_array:

    ; storing the rsp value before local variables definition
    mov rbp, rsp
    ; rbp - 8 : array pointer, 8 bytes
    ; rbp - 10 : array index, 2 bytes
    ; 6 padding bytes
    sub rsp, 24
{% endhighlight %}
The local variables are then initialized, and the first string announcing the array can be printed :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
    mov [rbp-10], word ptr 0 ; array_index <- 0
    ; loading the array pointer
    lea rax, my_array
    mov [rbp-8], rax

    ; printing the "my_array_str" string
    xor eax, eax
    lea rdi, [my_array_str]
    call printf
{% endhighlight %}

#### Writing the main loop

The main scheme here is similar to our `print_square` and `print_circle` programs from previous posts.
What changes is the call to `printf` and the array manipulation in order to extract its values.

Accessing the values of the array is performed by increasing 🔼 the array address.
Indeed, the address accessed through the label `my_array` actually points toward the first value of the array in the program's memory.
Since the values are contiguous in memory, and since they are coded on 1 byte each, accessing the next value is performed by increasing the address by one (recall that the addresses are expressed as bytes).

Our main loop is as follows :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
    .L_for_loop_writing:
        ; printing the "my_array_str" string
        xor eax, eax
        lea rdi, [array_elt_formatter]
        mov rsi, [rbp-8] ; load the array pointer
        mov sil, [rsi] ; load the value stored at the address
        call printf

        inc qword ptr [rbp-8] ; increase the array pointer
        inc word ptr [rbp-10] ; increase the array index
        mov al, [rbp-10]
        cmp al, [my_array_length]
        jne for_loop_writing ; test if all elements have been printed
{% endhighlight %}

You may notice that two steps are necessary to load a value from the array before calling `printf` : the address of the array must first be retrieved from the stack and then, the `mov` instruction is used to load the value coded at the address.
Note that the 1-byte register `sil` is used here to store the array values since they are encoded as single bytes.
These two steps cannot be concatenated into a single one since an instruction can have a memory reference in only one of its operand.

After the call to `printf`, the array index is increased as well as the array address.
Note the different prefixes as these two values are not coded on the same number of bytes.
Then, the index is compared to the array size, which is performed on two steps for the reason evoked just before.

Out `printing_array` function can be completed by printing a new line and then restoring the stack registers and exiting :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
    ; printing a new line
    xor eax, eax
    lea rdi, [new_line]
    call printf

    ; restoring the stack registers
    mov rsp, rbp
    pop rbp
    ret
{% endhighlight %}

This is it for printing the array!
We can execute this function from our `main` with a simple `call` instruction.

The next step for this code would be to give the array address and its size as parameters to the function : for instance using `rdi` and `si` (`rsi`) to pass the array pointer (namely the address) and the array length respectively.
I will leave it as an exercise and put the solution in the code repository.



## Calling a custom C function

We will now see how we can write ✍️ our own C functions and call them from our assembly code.
This can be useful for instance to add functionalities to our assembly programs from external libraries.

We will start by writing a C function to print arrays, as we previously did in assembly :

<div class="code_frame"> C language</div>
{% highlight C linenos %}
#include <stdio.h>

int print_array_c(char* array, short length) {
    
    for(unsigned int i = 0; i < length; i ++) {
        printf("%d ", array[i]);
    }
    printf("\n");

    return 42;
}

{% endhighlight %}

I added a return value to this function in order to test its interface with our assembly program.
In terms of calling convention, we have already seen that C functions use registers to pass some of the parameters.
Hence we can simply follow the register order given earlier in this post.

In this code, we choose the types `char` and `short` to store our data.
That is because in our assembly program, our array elements will be encoded on 1 byte each and the array size will be encoded on two bytes.
The size in bytes of the C variables types can be found [online](https://en.wikipedia.org/wiki/C_data_types).

We can then write our main function in assembly :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
.global main
.intel_syntax noprefix
main:

    push rbp
    mov rbp, rsp

    ; printing an array
    lea rdi, my_array
    mov si, my_array_length
    call print_array_c

    mov rsp, rbp
    pop rbp

    ; return
    mov rax, 0
    ret

my_array:
    .byte 5, 12, 42, 8, 1, 3, 7, 25, 14

my_array_length:
    .word 9
{% endhighlight %}

That's it! There are no extra steps required to call the C functions.
The `rdi` and `si` registers are used to pass parameters following the order of the convention given earlier.
Since the array length is encoded as a `word`, the 2-bytes version `si` of the `rsi` register is used. 

To compile the program, we can first use the command `as assembly_code.s -o assembly_code.o` for the assembly code, then the command `gcc c_code.c -c -o c_code.o` for the C code.
We can finally create the final executable with the command `gcc -static assembly_code.o c_code.o -o my_program`, which should produce a working program!

You can test the presence of the symbols associated with our C functions in the executable : `strings my_program | grep print_array_c` should now return the name of our C function, showing that it is present in the final executable.
You can also compile in debug mode and set a breakpoint just after the return value to verify that the return value is correctly stored in the `ax` register.


## Using our code in a C function

Our last part in this chapter is to go the other way around : calling an assembly function from a C program, a simple "hello word" function in this case.
Once again, we will apply the calling convention for C programs.

We start by writing an assembly function that displays the "Hello, World!" string thanks to a system call :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
.global _hello_world_assembly
.intel_syntax noprefix

_hello_world_assembly:

    push rbp
    mov rbp, rsp

    mov rax, 1
    mov rdi, 1
    lea rsi, [hello_world_str]
    mov rdx, 14
    syscall

    mov rsp, rbp
    pop rbp
    ret

hello_world_str:
    .asciz "Hello, World!\n"
{% endhighlight %}
<!-- </div> -->

Note that since this code is not the main program, there are no `main` or `_start` functions.
We can now write the C `main` to call this "hello world" function.
The only extra step here consists in defining the function before calling it.
Without the definition, the compiler would complain.

<div class="code_frame"> C language</div>
{% highlight C linenos %}
void _hello_world_assembly();

int main(int argc, char* argv) {

    // call an assembly function
    _hello_world_assembly();

}
{% endhighlight %}

This program can be compiled the same away as previously : the assembly code is compiled with `as` and the C code is compiled with `gcc`.
Then, the object files are assembled into one executable that produces the intended output!

## What's next ?

This article is the final one about the basics of assembly.
Our programs can now perform more advanced functions by using external libraries.
The following posts will focus on concrete examples on the use of assembly language.

As done before, the codes from this post are available at the following [link](https://github.com/smbct/x86-64_101_linux/tree/main/pt5_print_array).