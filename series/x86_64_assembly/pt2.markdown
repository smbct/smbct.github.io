---
title:  Assembly x86 programming 101 &#58 part 2, drawing a square
author: smbct
date:   2024-05-04 10:00:00 +0200
categories: low-level programming assembly
comments: true
layout: series_article
series: x86_assembly
back_page: headline.md
---


In the previous post, we've seen how to write a basic "hello world" program in assembly.
In this post, we will dive further in assembly by exploring the use of "jump" instructions to perform **conditionals and loops**.
In this new program, we will draw a square in the terminal with the sys_write system call that we previously used for the "hello world" example.


## Writing conditionals and loops

An important part of programming languages is the ability to control the execution through conditions.
Conditions appear not only in conditional statements but also in loops termination.
These programming structures as we know it from languages like C or Python can be reproduced in assembly by using more rudimentary instructions : jumps and conditional jumps.

#### Jump instructions

Jumps are instructions that allow to move to a specific point in our program.
In our code, this can be simply performed by defining a new symbol (with a "label" in our code) and using the `jmp` instruction to this symbol.
Let's start from the hello world written in the previous post :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
.intel_syntax noprefix
.global _start

_start:

    ; printing hello world
    mov rax, 1
    mov rdi, 1
    lea rsi, [hello_world]
    mov rdx, 14
    syscall

    ; exit
    mov rax, 60
    mov rdi, 0
    syscall

hello_world:
    .asciz "Hello, World!\n"
{% endhighlight %}

We will now add a new symbol after the "write" system call and jump to this symbol from the beginning of the start function: 

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
_start:

    jmp .L_after_printing

    ; printing hello world
    mov rax, 1
    mov rdi, 1
    lea rsi, [hello_world]
    mov rdx, 14
    syscall

    .L_after_printing:

    ; exit
    mov rax, 60
    mov rdi, 0
    syscall
{% endhighlight %}

In our programs, symbols for loops and conditionals will always be **local** symbols, as opposed to global symbols used to define functions as we will see in future posts.
These symbols are not exported when the code is compiled.
This is the reason why their names start with the "**.L**" prefix, telling the compiler that the should be replaced by local references in the code (using program's code addresses).

When executing this program you will observe that the "hello world" output is gone.
We have indeed told the program to skip these instructions by directly jumping to the `.L_after_printing` symbol.
A jump can be performed anywhere in the code, including backward and accros functions (we will see in another post that jumping is actually part of function calls).

Jumps becomes more interesting in their conditional form.
To achieve conditional jumps, we will use the `cmp` instruction that performs a numerical comparison between two registers/memory locations.
The `cmp` instruction does not directly produce an output but rather sets internal flags that will be read by the proper jump instructions.
Starting from the previous code, we will add a conditional jump after comparing two registers :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
_start:

    mov rax, 43
    mov rbx, 42
    cmp rax, rbx ; compare rax and rbx and set the internal flag
    jg .L_after_printing ; jump if the internal flag corresponds to "greater"

    ; printing hello world
    mov rax, 1
    mov rdi, 1
    lea rsi, [hello_world]
    mov rdx, 14
    syscall

    .L_after_printing:

    ; exit
    mov rax, 60
    mov rdi, 0
    syscall
{% endhighlight %}

Here the `jg` (jump if greater than) instruction will check wether `rax > rbx` from the internal flag set by `cmp`.
Since 43 is greater than 42, our message is not printed to the standard output.
Now if we replace the first line by `mov rax, 42`, the message would be printed as the jump is triggered on a strict inequality.

#### If..else.. statements

Thanks to jumping instructions we are now able to write conditional statements in our code.
The thinking is a be a bit different from more standard programming languages but we can setup an "if..else" by placing proper jumps.
Here is an example:

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
cmp rax, rbx ; compare rax and rbx and set the internal flag
jg .L_else_label

.L_if_label: ; entering when "rax <= rbx"

    ; code to perform if condition is not verified
    jmp endif ; skip the "else"
    
.L_else_label: ; executed when "rax > rbx" is true
    
    ; condition to perform if the code is verified
    
.L_endif:
{% endhighlight %}

In this example, we added three different labels to perform an "if..else.." statement.
When the comparison is true, the program will jump directly to the "else" label, making it skip the "if" part.
It is an inverse way of thinking compared to classical statements since the condition that is tested with `cmp` should be false in order to perform the "if" instructions.
At the end of the "if" instructions, a jump is necessary to prevent from executing the "else", hence the presence of an "endif" label.

Note that in this example, the "if_label" is not mandatory as there are no jump to this label, it could be written as a comment.
Additionally, the indentation is not really a convention in assembly but I found it to help clarify the code.
In some situations, writing an if-else statement can be simplified.
This is a question of habits and clarity.

#### Loops

Conditional jumps are not only helpful to write conditional statements but they also offer the possibility to write loops.
Indeed a loop simply consists in a jump that as conditioned on the loop termination condition.
Let's write a simple for loop:

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
mov rbx, 0

.L_for_label:

    ; loop instructions

    inc rbx ; increase the loop counter
        
    cmp rbx, 10
    jl .L_for_label ; repeat if the counter is < 10
{% endhighlight %}

Here we repeat the loop instructions for 10 iterations by using the `rbx` register as our loop index.
The comparison is performed at the end of each iteration, meaning that the program will perform at least one iteration (similarly to a do..while loop).
This behavior may be avoided by adding an additional (unconditional) jump and by performing the comparison before the loop instructions.


## Drawing a square in assembly

Now that we are able to define variables and perform control flow in assembly, our programs become more interesting.
To demonstrate theses notions, we will write a program that draws a square in the console by using the sys_write system call and by writing two nested "for" loops.
This program will iterate over coordinates of a square of a predefined size.

We will first write the base of our program with the exit system call.
We can also define the constants of our program and already add some printing calls that will help us for the following. 

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
.global _start
.intel_syntax noprefix

_start:

    ; printing a star
    mov rax, 1
    mov rdi, 1
    lea rsi, [star_character]
    mov rdx, 1
    syscall

    ; printing a new line
    mov rax, 1
    mov rdi, 1
    lea rsi, [star_character]
    mov rdx, 1
    syscall

    ; exit
    mov rax, 60
    mov rdi, 0
    syscall

square_size:
    .quad 20

star_character:
    .word '*'

new_line:
    .word '\n'
{% endhighlight %}

For this program, it will be convenient to hard-code the size of the square with a constant.
I also added the star character '*' constant and a new line character '\n' constant for convenience.
Indeed, the sys_write system call requires an address to the character to be printed and saving them as constants allow to directly give their address in the program's memory.
As you may notice, the address is given with the `lea` instruction, which stands for "Load Effective Address". 

We may notice that different directives are used for defining the constants : `.quad` for square_size and `.word` for the characters.
These directives actually specify the size of these constants (2 bytes for `.word` and 8 bytes for `.quad`).
We will discuss more about data sizes in the next post of this series.

#### Drawing a line

To start by drawing a simple line, we need to write a "for" loop that iterates over character positions (or columns).
We will dedicate a register to storing this column index, but we should care about choosing a register that is not being use elsewhere in the program.
Otherwise, its value would be lost.
We can see that rax, rdx, rsi and rdi are already used for the system calls.
We can then dedicate r8 and r9 to store our variables.

To draw the line, we can re-use the "for" loop structure that we previously implemented in the post.
The loop will surround the star printing instructions : 

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
.global _start
.intel_syntax noprefix

_start:

    ; init the column counter to 0
    mov r8, 0

    .L_for_loop_columns:

        ; printing a star
        mov rax, 1
        mov rdi, 1
        lea rsi, [star_character]
        mov rdx, 1
        syscall

        ; increment the column counter
        inc r8

        ; compare the column counter to the predefined size and jump if required
        cmp r8, [square_size]
        jne .L_for_loop_columns

    ; printing a new line
    mov rax, 1
    mov rdi, 1
    lea rsi, [star_character]
    mov rdx, 1
    syscall

    ; exit
    mov rax, 60
    mov rdi, 0
    syscall

square_size:
    .quad 20

star_character:
    .word '*'

new_line:
    .word '\n'
{% endhighlight %}

This program behaves similarly to what we previously seen.
The first action consists in initializing our column index variable in the register `r8` to 0.
Then, we enter the for-loop by passing the "for_loop_columns" label and print a first star character.
Then, the rbx register is incremented (+1) and its value is compared to the square_size constant.
The brackets '[ ]' in the `cmp` instructions mean that we consider the value stored at the constant "square_size", and not its memory address.

#### Drawing a square

Starting from the previous code, printing a square is no more complicated than adding an additional surrounding loop.
This time, we use the `r9` register for our row index variable :  

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
.global _start
.intel_syntax noprefix

_start:

    ; init the row counter to 0
    mov r9, 0

    .L_for_loop_rows:
        
        ; init the column counter to 0
        mov r8, 0

        .L_for_loop_columns:
            ; printing a star
            mov rax, 1
            mov rdi, 1
            lea rsi, [star_character]
            mov rdx, 1
            syscall

            inc r8
            cmp r8, [square_size]
            jne .L_for_loop_columns

        ; writing a new line
        mov rax, 1
        mov rdi, 1
        lea rsi, [new_line]
        mov rdx, 1
        syscall
        
        inc r9
        cmp r9, [square_size]
        jne .L_for_loop_rows

    ; exit
    mov rax, 60
    mov rdi, 0
    syscall

square_size:
    .quad 20

star_character:
    .word '*'

space_character:
    .word ' '

new_line:
    .word '\n'
{% endhighlight %}

And here is our square!
Hmm... well, if you test it, this looks more like a rectangle.
In fact, the characters are rectangle hence our square appears deformed.
We can adjust this without much effort by adding a blank character after each star:

<div class="code_frame"> Bash</div>
{% highlight plaintext linenos %}
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * *
{% endhighlight %}

## What's next ?

Alright, jumps are essential instructions that we just added in our assembly knowledge toolbox.
In our square printing program, we had to look for registers that were not used by our program to store variables.
Obviously, this is not a proper way to manage local variables in assembly since there are a limited number of registers.
In the next post, we will see how to use the program's stack for storing our local variables.

By that time, the square printing code is available at the [following link](https://github.com/smbct/x86-64_101_linux/tree/main/pt2_draw_square).
As previously, you can experiment by adding complexity to the code.
For instance, with additional jumps and modulo operations you can try to only fill some of the columns or rows, or even draw sub rectangles.
Please leave a comment if you have any suggestion or question about this post!
