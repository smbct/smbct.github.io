---
title:  Assembly x86 programming 101 &#58 part 5, printing arrays
author: smbct
date:   2024-05-21 10:00:00 +0200
categories: low-level programming assembly
comments: true
layout: series_article
back_page: headline.md
---

and also how to interact with C functions in our program!
We will use these new notions to print the content of an integer array in assembly.


## Calling the C printf functions

One dimension that function calls bring to our program is not only the ability to structure it, but also the opportunity to call higher level libraries that would perform more advanced operations like opening windows, networking, etc..
However, although we previously had the freedom to decide our own convention for parameters and return value, calling a function from a library requires us to follow the library's convention.
We will see how to do so by calling the "printf" function from the standard C library. 

#### Using the C standard lib in our program

Our program's compilation will now change a bit.
Previously, we created executables from assembly code by using nothing more than systems calls to interact with a user.
Now, the idea is to interface the program with the C standard library.

Adding the C standard library to our program's is simply done by removing the option `-nostdlib` when linking the executable with gcc.
However, the C library adds a lot more features to our program : it defines the _start function (program's entry point) by itself.
For this reason, our program's first function will now be the classical `main` function.
The "hello world" code now becomes :

```nasm
.global main
.intel_syntax noprefix

main:

    push rbp
    mov rbp, rsp

    mov rax, 1
    mov rdi, 1
    lea rsi, [hello_world]
    mov rdx, 14
    syscall

    mov rsp, rbp
    pop rbp

    ; return
    mov rax, 42
    
    ret

hello_world:
    .asciz "Hello, World!\n"
```

There are two changes regarding the previous hello_world : our function is now called main and it will be automatically be called by the `_start` function defined in the cstdlib ; and since it is now a called function, the `ret` instruction is now called at its end.
The compilation is done as previously, except for the second command that now becomes `gcc -static my_program.o -o my_program`.

You can verify that the program's output is actually *42*, which is given as the main's return value : `./my_program ; echo $?`.
Now if you try to compile our first hello_world program with this same command, so that it is linked with the c standard library, this would not work since the program's entry point `_start` would be defined twice : once in the code and another time in the library.
If you want a more precise idea of the additional material added by the standard libc, you might check this [interesting article](http://www.muppetlabs.com/~breadbox/software/tiny/teensy.html)!

#### Passing parameters to printf

Now that everything is in place, let's call the printf function.
Know that since the standard libc is now linked, the `printf` symbol will be known by the linker.
Now the important thing is to see how to pass parameters to the "printf" functions.
That part is tricky : the (calling) convention used by Linux is called the **AMD64 System V ABI**.

Documentation is sometimes hard to find and I personally learned this from this [stackoverflow post](https://stackoverflow.com/questions/38335212/calling-printf-in-x86-64-using-gnu-assembler).
You can see in the post that parameters are in part passed by registers : `rdi` for the first one, `rsi` for the second one, `rdx` for the third etc.. 
They also indicate that the `al` (the 8 bits version of `rax` register) register must be set to 0 since "printf" has a variable number of arguments.

Following the convention, our printf call to print "hello world" now becomes :

```nasm
    xor eax, eax ; al is set to 0
    lea rdi, [hello_world] ; 1st argument passed to register
    call printf
```

If you try this, you would normally see a segmentation fault :(

#### One more requirement : stack pointer alignment

By further reading the stackoverflow post that I linked above, we learn that there is on more condition that needs to be met when calling functions in the **AMD64 System V ABI** convention : the stack pointer must be aligned to 16 bytes, meaning its value must be a multiple of 16.

You can run gdb on your program and check the value of `rsp` before calling "printf" : `breakpoint main` followed by `print $rsp`.
It gives *0x7fffffffdbd8* for me and *0x7fffffffdbd8 modulo 0x10 = 0x8* (where *0x10* is 16 in hexadecimal).
We see that there is an 8 bytes shift of the `rsp` value.
This shift comes from the fact that the `call` instruction pushes the return address (8 bytes) to the stack, as we saw previously.
As a result the stack pointer is misaligned by 8 bytes.
This will be fixes by simply re-aligning the stack pointer before starting the call, which can be done by "allocating" 8 additional bytes (unused) :

```nasm
    sub rsp, 8
    xor eax, eax ; al is set to 0
    lea rdi, [hello_world] ; 1st argument passed to register
    call printf
    add rsp, 8
```

This should now work as expected!
Note that since our string is zero terminated (it ends by '\0', as defined by the .asci**z** type with the gnu assembler), it is not necessary to specify its length to printf. 

In our following codes, we will now make sure the stack pointer is well aligned before starting any operation in our functions.
A proper place to do it is when the local variables are allocated, as we saw in the previous post of the series.
This may also be done automatically by subtracting the offset : `rsp` modulo 8, which can be performed by "anding" 15 to the value of `rsp`: `and rsp, 15` (recall that a modulo operation on a power of two can be obtained by directly looking at the right number of bits in the binary representation).

#### Printing integers with printf

Calling a C function was not easy!
The good thing is now it will be much easier to bring concrete features to our programs.
Let's start by accomplishing a task that was previously much harder : printing integer values.

To print a value in the terminal, we can use the printf function with its formatting ability : the value would be passed as a parameter, as well as a string indicating how to format it.
We can have a look at the [documentation](https://cplusplus.com/reference/cstdio/printf/) of "printf" to choose the correct formatter.
We start by defining the formatter as a constant string in our program (this does not change) :

```nasm
integer_formatter:
    .asciz "integer value: %i\n"
```

The  "%i" formatter is used in order to print a decimal integer.
We will then call printf and pass this string as well as the register value.
For this, we will use the `rsi` register, as it is specified to pass the second argument in Linux.

```nasm
    xor eax, eax
    lea rdi, [integer_formatter]
    mov rsi, 42
    call printf
```

The program should now print: "integer value: 42".
This adds a lot more possibilities to interact with the user!




## Printing an array

Now that we know how to call printf, we will perform a useful task for the future post : printing an array!
We will start by defining a constant array in the program's memory :

```nasm
my_array:
    .byte 5, 12, 42, 8, 1, 3, 7, 25, 14
my_array_length:
    .word 9
```

In this case, the array elements will be stored as bytes (8 bits long, integer values between -128 and 127).
We also define a constant for its size as a word (2 bytes).
That will eventually be helpful.

Now we may define our strings constants to be used by printf :

```nasm
array_elt_formatter:
    .asciz "%hhd "
new_line:
    .asciz "\n"
my_array_str:
    .asciz "My array : "
```

The "array_elt_formatter" is used to format a single byte as an integer with printf, followed by a space.
We also define the new_line string that only prints the return character for convenience, as well as a string announcing the array to be printed.

#### The local variables

We will need 2 local variables in our code : an 8 bytes variable to store the array address and a 2 bytes variable to an index for iterating over the array.
This results in 10 bytes allocated on the stack.
With the 8 bytes already present to store the return address of the main function, the stack pointer would be aligned to 26 bytes.
Hence, 6 additional bytes are necessary for a 16 bytes alignment (*32=2x16*). 

```nasm
; storing the rsp value before local variables definition
mov rbp, rsp
; rbp - 8 : array pointer, 8 bytes
; rbp - 10 : array index, 2 bytes
; 6 padding bytes
sub rsp, 24
```
The local variables are then initialized, and the first string announcing the array can be printed :

```nasm
mov [rbp-10], word ptr 0 ; array_index <- 0
; loading the array pointer
lea rax, my_array
mov [rbp-8], rax

; printing the "my_array_str" string
xor eax, eax
lea rdi, [my_array_str]
call printf
```

#### Writing the main loop

The main scheme here is similar to our print_square and print_circle programs.
What changes is the call to printf and the array manipulation in order to extract its values.
Accessing the values of the array is performed by increasing the array address.
Indeed, the address accessed through the label "my_array" actually points toward the first value of the array in the program's memory.
Since are the values are contiguous, and since they are coded on 1 byte, accessing the next value is performed by increasing the address by one (recall that the addresses are expressed as bytes).

Our main loop is as follows :

```nasm
for_loop_writing:
    ; printing the "my_array_str" string
    xor eax, eax
    lea rdi, [array_elt_formatter]
    mov rsi, [rbp-8] ; load the array pointer
    mov sil, [rsi] ; load the value stored at the address
    call printf

    inc byte ptr [rbp-8] ; increase the array pointer
    inc word ptr [rbp-10] ; increase the array index
    mov al, [rbp-10]
    cmp al, [my_array_length]
    jne for_loop_writing ; test if all characters have been printed
```

You may notice that two steps are necessary to load a value from the array before calling printf : the address of the array must first be retrieved from the stack and then, the `mov` instruction is used to load the value coded at the address.
Note that the 1-byte register `sil` is used here to store the array values since the array values are encoded on single bytes.
These two steps cannot be concatenated into a sigle one since an instruction can have a memory reference in only one of its operand.

After the call to printf, the array index is increased as well as the array address.
Note the different prefixes as these two values are not coded on the same number of bytes.
Then, the index is compared to the array size, which is performed on two steps for the reasons evoked just before.

This is it for printing the array !
The next step for this code would be to encapsulate it as a function.
This time, we may use the "Linux calling convention" to pass the parameters : for instance using `rdi` and `si` (`rsi`) to pass the array pointer and the array length respectively.
I will leave it as an exercise and put the solution in the repository.

## What's next ?


