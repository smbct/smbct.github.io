---
title:  Assembly x86-64 programming 101 &#58 chapter 3, drawing a circle
author: smbct
date:   2024-05-09 10:00:00 +0200
categories: low-level programming assembly
comments: true
layout: series_article
back_page: headline.md
language: en
---

We've previously seen how to code a "hello world" program in assembly and how to perform conditions and loops.
In our previous program that draws a square, we used registers to store our variables.
Unfortunately, registers are not meant to store data and should rather be used as an intermediate memory location to perform the processor's instructions.
To "define" variables in assembly, we instead need to directly allocate memory to our program.
Our goal in this post we will be to start from our square drawing program and modify it in order to draw a circle.
More importantly, we will see how to properly store our variables in **the stack** 🥞 instead of using registers. 

## Defining local variables on the stack

Programming languages usually rely on two different modes for storing variables : [the stack and the heap](https://www.geeksforgeeks.org/stack-vs-heap-memory-allocation/?ref=header_search).
You may have heard of them if you are familiar with lower level languages such as C or C++.
The heap is dedicated to dynamic allocations : it is used when the size of the data to be allocated is only known during the program's execution (at runtime).
On the other hand, the stack is used to store local variables and internal information about function calls.

We will use the stack here to store our program's variables.
It is the simplest way to perform memory allocation since it does not require any system or function call.
Its use is similar to a stack of plates, with a last-in-first-out management : memory is always allocated on its top and the last allocated memory would be de-allocated first.
The top of the stack can be accessed via its memory address stored in the `rsp` register ("sp" standing for "stack pointer").
Our memory allocation will be performed by manually manipulating this address.

#### Manipulating the stack pointer to allocate memory

The stack pointer address stored in the `rsp` registers is expressed in bytes, meaning that it points to a 8-bits memory space (recall that the [byte](https://en.wikipedia.org/wiki/Byte) is the smallest unit of storage and 1 byte equals to 8 bits).
The stack in x86 assembly grows **downward**, meaning that the address stored in `rsp` will actually decrease as memory is allocated. 

In the following example, 4 bytes of memory are allocated on the stack by subtracting the value 4 to the stack address (addresses being expressed in bytes):

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
.global _start
.intel_syntax noprefix

_start:

    ; allocating 4 bytes in the stack
    sub rsp, 4

    ; storing the value 42 to the reserved space
    mov [rsp], dword ptr 42

    ; inspecting the value through a register
    mov rax, [rsp]

    ; memory is de-allocated by restoring the original rsp value
    add rsp, 4

    ; exit
    mov rax, 60
    mov rdi, 0
    syscall
{% endhighlight %}

Let's compile and analyse the code with GDB, as we did in the first chapter of the assembly series.
We will start by compiling the code in debug mode (-g option) and by adding breakpoints at three different places in the code: `b code.s:5` (before the allocation), `b code.s:8` (after the allocation) and `b code.s:14` (after writing in the stack).
Here "code.s" corresponds to the name of our assembly file.

Now let's start the program in GDB until the first breakpoint and print the initial stack's top address : `print $rsp`.
This outputs *0x7fffffffddb0* in hexadecimal in my terminal.
This address points toward the last byte that has been reserved before we started our function.
Thus memory at this address should not be used by our code.

Then the 4 bytes (32 bits) of memory are allocated by subtracting 4 to the current stack top address.
After this operation, the `rsp` register points toward the start of our 4 bytes memory location that is, this time, reserved for our own use. 
We can use the command `continue` in GDB to go to the next breakpoint after the allocation and check the new value of `rsp`:
This gives me *0x7fffffffddac*.
Checking the difference in an hexadecimal calculator : *0x7fffffffddac-0x7fffffffddb0 = -4*, we have reserved our 4 bytes  of memory in the stack!

We can let the program continue again so that the value 42 is stored in the stack at the reserved location in the with the `mov` instruction.
As opposed to previously, we use the brackets here to indicate that the value 42 should not be stored in the `rsp` register but rather at the memory address stored in `rsp`.
Having this value stored, we then load it in the `rax` register in order to inspect it in GDB.
We can output the value of `rax`, which is supposed ton contain the value 42, with `print $rax` : 

`$3 = 4294967338` ???

Oh! The Value of `rax` is not what we expected.
In fact, when managing memory stored in the stack it is important to correctly specify the number of bytes that is being accessed and manipulated. 

#### Reading from and writing to the stack

If you carefully followed the previous code, we added additional directives when moving the value 42 to the stack.
Indeed, when writing to or reading from a memory address, the program requires us to specify the number of bytes to access as it has no other way to know it.
The instruction `mov [rsp], dword ptr 42` then means that we are writing the value 42 into at the address stored in `rsp`, encoded over 8 bytes (dword standing from double word, where a word corresponds to 4 bytes).
There exists actually several versions of instructions like `mov` that dictates the number of bytes to consider, but the exact version to use is inferred by the compiler.

When specifying `mov rax, [rsp]`, the program would consider that we are reading 8 bytes from the stack, inferred from the fact that `rax` is an 8 bytes register.
Since we actually reserved 4 bytes, the additional 4 bytes the program is reading from in the stack are undefined and as a result `rax` contains undefined bits.

The solution here consists in using a register with the proper size in order tell our program to read the correct number of bytes.
In fact, several 8 bytes registers such as `rax`, `rbx`, `rcx` etc.. exist in multiple versions with various sizes.
We will fix our previous issue by using the 4 bytes version of `rax` which is named `eax`.
We can replace our instruction by : `mov eax, [rsp]`.
In GDB, the command `print $eax` now gives : `$3 = 42`!
Perfect, we are now able to reserve some space in memory to store our local variables.

Note the difference between the instruction `mov` used here and `lea` that we encountered in the previous posts.
`mov` is used to put a value into a register or at a memory address while, `lea` which stands for "Load Effective Address", will rather consider the memory address, without accessing the value at that address.

#### Defining a stack frame

We have just seen how to "reserve" some space in the stack by subtracting from the stack pointer the desired number of bytes to reserve.
We then accessed our memory space by directly using the `rsp` value, which then contained the address of our first byte.
However, the stack is meant to grow further as the code of our function (and sub functions) would be executed.
This makes our reference address stored in `rsp` invalid as soon as additional data is pushed into the stacK.
This is why we need an invariant reference to access our variables in the function.

In assembly, the **stack frame** designates the space of the stack that is reserved for our function.
In the previous example, our stack goes from the address stored in `rsp` to this same address minus the reserved 4 bytes.
As the top of the stack would potentially change when executing the function, we should save a reference address before allocating in the stack so that we can refer to our data from "bellow".
This is exactly the function of the `rbp` pointer (the **b**ase **p**ointer).

We can now modify the previous program by saving the value of `rsp` into `rbp`.
This time, we will store two 4-bytes values by reserving a total of 8 bytes.
Then, at the end of the function, the stack will be de-allocated and the previous value of `rbp` will be restored from `rsp`.
> Keep in mind that registers such as `rsp` and `rbp` are being used by other functions in our program and they should be preserved across function calls.

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
.global _start
.intel_syntax noprefix

_start:

    ; allocating 4 bytes in the stack
    mov rbp, rsp ; save the current stack address in the rbp register
    sub rsp, 8 ; allocate two 4-bytes variables in the stack
    ; First variable, address=[rbp-4], size = 4 bytes
    ; Second variable, address=[rbp-8], size = 4 bytes

    ; storing the values 40 and 2 to our 2 variables in the stack
    mov [rbp-4], dword ptr 40
    mov [rbp-8], dword ptr 2

    ; computing the sum of the values previously stored
    mov eax, [rbp-4]
    add eax, [rbp-8]
    
    ; memory is de-allocated by restoring the original rsp value
    mov rsp, rbp

    ; exit
    mov rax, 60
    mov rdi, 0
    syscall
{% endhighlight %}

Compared to the previous example, we refer this time to our variables by subtracting a corresponding number of bytes from the address in `rbp`, our stack base.
I added 1 line of comment for each variable allocated with its size and offset for the readability of our code.
Since the stack grows toward lower addresses, we access our variables by offsetting the base address with their size in bytes and the size of their preceding variables.
The values of our variables will be read from lower to higher adresses which is why we need to subtract their entier size from the base address.

Once again, variables can be inspected with GDB after compiling in debug mode.
We would run GDB and add a breakpoint at `code.s:19` in order to print the `eax` register.
You will notice that inspecting memory rapidly becomes difficult since the values should be stored into some register in order to be printed.
There is actually a command named [examine](https://ftp.gnu.org/old-gnu/Manuals/gdb/html_node/gdb_55.html) in GDB to look at a specific location in memory, by providing an address. 


## Drawing a circle in assembly

Now that we are able to define variables and perform control flow in assembly, our programs become much more interesting.
To demonstrate theses notions, we will modify our square drawing program from the previous post in order to draw a circle.
We start from the following base (I included only the drawing part for clarity) :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
mov r9, 0
.L_for_loop_rows:    

    mov r8, 0
    .L_for_loop_columns:

        ; printing a star
        mov rax, 1
        mov rdi, 1
        lea rsi, [star_character]
        mov rdx, 1
        syscall

        ; printing a space
        mov rax, 1
        mov rdi, 1
        lea rsi, [space_character]
        mov rdx, 1
        syscall

        inc r8
        cmp r8, [square_size]
        jne .L_for_loop_columns

    ; printing a new line
    mov rax, 1
    mov rdi, 1
    lea rsi, [new_line]
    mov rdx, 1
    syscall
            
    inc r9
    cmp r9, [square_size]
    jne .L_for_loop_rows
{% endhighlight %}

#### Storing indexes on the stack

The first step will be to modify the program and store the index variables in the stack. 
We can replace the r8 and r9 registers by allocating two 8-bytes variables in the stack.
The code is similar to what we saw previously :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
mov rbp, rsp
sub rsp, 16
; row index : offset=8, size=8
; column index : offset=16, size=8

mov qword ptr [rbp-8], 0 ; row index var is set to 0
.L_for_loop_rows:    

    mov qword ptr [rbp-16], 0 ; col index var is set to 0
    .L_for_loop_columns:

        ; printing a star
        mov rax, 1
        mov rdi, 1
        lea rsi, [star_character]
        mov rdx, 1
        syscall

        ; printing a space
        mov rax, 1
        mov rdi, 1
        lea rsi, [space_character]
        mov rdx, 1
        syscall

        ; increment col index var
        inc qword ptr [rbp-16]
        ; test column loop termination
        mov rax, [rbp-16]
        cmp rax, [square_size]
        jne .L_for_loop_columns

    ; writing a new line
    mov rax, 1
    mov rdi, 1
    lea rsi, [new_line]
    mov rdx, 1
    syscall
        
    ; increment col index var
    inc qword ptr [rbp-8]
    ; test row loop termination
    mov rax, [rbp-8]
    cmp rax, [square_size]
    jne .L_for_loop_rows

; memory de-allocation
mov rsp, rbp
{% endhighlight %}

We have previously seen how to allocate two variables on the stack.
The changes regarding the previous version of our program are symmetrical for the two index variables for rows and columns.
The two variables are first assigned to 0.
This time, it is necessary to specify their size with `qword ptr` for 8 bytes, and they are references through an offset relatively to the address in `rbp`.

After a loop iteration, the indexes are incremented in a similar way.
The `cmp` operation is then performed to test for the loop termination condition.
Here, you will notice that the variable is stored into the `rax` register instead of being directly referenced in the `cmp` instruction.
This is because an instruction cannot be given two memory references, only one is allowed and the other one must be a register.
In the previous version, we saw that the `rax` register could not be used to store our index since it was already used elsewhere in the program.
Using this register here is not an issue since it is only used as a temporary location to perform the test. 


#### Drawing a circle

Now that we have a better base, let's draw the circle.
The circle will be centered in the center of the square and its diameter will be the square's length.
For each character position, we will test if the character belongs to the circle or not.
This is performs by calculating the distance between the character's position and the center of the circle.
If the distance is smaller or equal to the radius of the circle, the character can be printed.
Writing it as a pseudocode first will help in our assembly implementation :

<div class="code_frame"> Pseudocode </div>
{% highlight plaintext linenos %}
const square_size

var row_index
var col_index
var square_center
var radius_squared
var distance_squared

square_center <- square_size / 2
radius_squared <- (square_size / 2)²

distance_squared <- (row_index-square_center)² + (col_index-square_center)² 

if distance_squared <= radius_squared 
    draw '*'
else:
    draw ' '
endif
{% endhighlight %}

In this pseudocode, I decomposed the instructions in order to simplify the assembly implementation.
You may first notice that instead of compute distances, we compute squared distances to avoid calculating a square root.
This implied having the square radius value stored somewhere, this will be one of our local variable.
We also add a local variable to store the center of the square, which is half its size.
Our last variable is a temporary variable used to store the squared distance, so that it can be compare to the square radius.

#### Defining the local variables

Let's write or new stack allocation from this :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
mov rbp, rsp
sub rsp, 40
; row index : offset=8, size=8
; column index : offset=16, size=8
; square center : offset=24, size=8
; radius squared : offset=32, size=8
; distance squared : offset=40, size=8
{% endhighlight %}

We can then add two lines to assign the square center and radius squared variables at the beginning of our function, as their value won't change :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
; rax is temporary used to compute square_size/2
mov rax, [square_size]
shr rax
; storing the value in the square center variable
mov qword ptr [rbp-24], rax

; rax is squared
imul rax, rax
; storing the squared radius
mov qword ptr [rbp-32], rax
{% endhighlight %}

The rax register is used temporarily to compute the values of our variables.
The square center variable is the first one to be assigned.
It is not easy to read but the division of the square size by 2 is performed by the `shr` operation.
`shr` is a common instruction in programming that performs "bits shift" (to the right in this case) : the rightmost bit of the value is lost and all the other ones are shifted to the right.
This as the effect of efficiently dividing the value by 2 (this line could be replaced by a more complexe divide instruction).

After assigning the square center variable, the value of rax is squared in order to obtain the squared radius.
The `imul` instruction is used here to perform an integer multiplication of the register with itself.



#### Computing the distance and drawing the circle

We can now add the last missing piece of code that compare the distances and decide if the printed character should be a star '*' or a space ' ' :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
; compute (row_index - square_center)² into distance_squared
mov rax, [rbp-8]
sub rax, [rbp-24]
imul rax, rax
mov [rbp-40], rax

; add (col_index - square_center)² to distance_squared
mov rax, [rbp-16]
sub rax, [rbp-24]
imul rax, rax
add [rbp-40], rax

; compare distance_squared to radius_squared
mov rax, [rbp-32]
cmp [rbp-40], rax
jge .L_print_space

; .L_print_star:
    lea rsi, [star_character]
    jmp .L_end_print
.L_print_space:
    lea rsi, [space_character]
.L_end_print:

; printing the chosen character
mov rax, 1
mov rdi, 1
mov rdx, 1
syscall
{% endhighlight %}

Once again, we use the `rax` register as a temporary register to compute our values.
The first two groups of lines correspond to the computation of the squared distance between the current character and the center.

The distance is the compared to the squared radius in order to select the right character to be printed.
In this code, the conditional statement is used for setting the `rsi` register only, which contains the address of the character strings to be printed with "sys_write".
Indeed, the value of the other registers do not change between the two cases.

And voilà, our circle is now printed to the terminal :

<div class="code_frame"> Bash </div>
{% highlight plaintext linenos %}
            * * * * * * * * *           
          * * * * * * * * * * *         
      * * * * * * * * * * * * * * *     
      * * * * * * * * * * * * * * *     
    * * * * * * * * * * * * * * * * *   
  * * * * * * * * * * * * * * * * * * * 
  * * * * * * * * * * * * * * * * * * * 
  * * * * * * * * * * * * * * * * * * * 
  * * * * * * * * * * * * * * * * * * * 
  * * * * * * * * * * * * * * * * * * * 
  * * * * * * * * * * * * * * * * * * * 
  * * * * * * * * * * * * * * * * * * * 
  * * * * * * * * * * * * * * * * * * * 
  * * * * * * * * * * * * * * * * * * * 
    * * * * * * * * * * * * * * * * *   
      * * * * * * * * * * * * * * *     
      * * * * * * * * * * * * * * *     
          * * * * * * * * * * *         
            * * * * * * * * *           
{% endhighlight %}

## What's next ?

By interacting with the stack to store our variables, our program is now much cleaner.
There is still a lot to say about the stack, in particular how to properly use it when calling function.
We will discuss function calls in details in the next chapter of the series.

By the time, you will find the complete code for drawing the circle at [that address](https://github.com/smbct/x86-64_101_linux/tree/main/pt3_draw_circle).
Many improvements are still possible such as defining a circle radius that is different from the size of the square.
Once again, do not hesitate to share your thoughts in the comments, I will welcome your feedbacks!