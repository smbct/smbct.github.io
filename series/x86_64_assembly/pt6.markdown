---
title:  Assembly x86 programming 101 &#58 part 6, sorting arrays
author: smbct
date:   2024-06-20 10:00:00 +0200
categories: low-level programming assembly
comments: true
layout: series_article
back_page: headline.md
---

Having covered the basics of assembly programming, we can now put some knowledge into practice by writing concrete algorithms.
In this post, we will write classical **sorting algorithms**.
This will be the occasion to further manipulate the stack and to work on the modular organization of our code. 

## Modular assembly programs

We will start this part with our code from the previous part that prints arrays.
This time, we are going to separate our code in different files to organize our different functions.
We start with two different files : a first one containing the `print_array` function and a second one containing the main function (we will continue using the standard libc here).
Here are our two code files :

<div class="collapse-panel"><div>
<label for="code_1">Expand</label>
<input type="checkbox" name="" id="code_1"><span class="collapse-label"></span>
<div class="extensible-content">

<div class="code_frame"> Assembly x86-64 | main.s </div>
{% highlight nasm linenos %}
.global main
.intel_syntax noprefix

; main function (libc main)
main:
    
    push rbp ; storing the rbp value before manipulation
    mov rbp, rsp ; storing the rsp register

    ; the stack would be allocated here

    ; saving the preserved registers
    push rdi
    push rsi

    ; printing the "My array : " string
    xor eax, eax
    lea rdi, [my_array_str]
    call printf

    ; calling the print_array function with parameters
    lea rdi, [my_array]
    mov si, [my_array_length]
    call print_array

    ; printing a new line
    xor eax, eax
    lea rdi, [new_line]
    call printf

    ; restoring the preserved registers
    pop rsi
    pop rdi

    ; restoring the rsp and rbp registers
    mov rsp, rbp
    pop rbp

    ; return
    mov rax, 0
    ret

my_array:
    .byte 5, 12, 42, 8, 1, 3, 7, 25, 14
my_array_length:
    .word 9

new_line:
    .asciz "\n"
my_array_str:
    .asciz "My array : "

{% endhighlight %}
</div></div></div>


<div class="collapse-panel"><div>
<label for="code_2">Expand</label>
<input type="checkbox" name="" id="code_2"><span class="collapse-label"></span><div class="extensible-content">

<div class="code_frame"> Assembly x86-64 | print_array.s </div>
{% highlight nasm linenos %}
.global print_array
.intel_syntax noprefix

; print an array (encoded on bytes)
; rdi : array pointer
; si : array length
print_array:

    ; storing the rsp value before manipulation
    push rbp
    mov rbp, rsp

    ; rbp - 8 : array pointer, 8 bytes
    ; rbp - 10 : array index, 2 bytes
    ; rbp - 12 : array size, 2 bytes
    ; 4 padding bytes
    sub rsp, 16
    
    mov [rbp-8], rdi ; loading the array pointer
    mov [rbp-10], word ptr 0 ; array_index <- 0
    mov [rbp-12], si ; loading the array length

    .L_for_loop_writing_1:

        xor eax, eax
        lea rdi, [array_elt_formatter]
        mov rsi, [rbp-8] ; load the array pointer
        mov sil, [rsi] ; load the value stored at the address
        call printf

        inc byte ptr [rbp-8] ; increase the array pointer
        inc word ptr [rbp-10] ; increase the array index
        mov ax, [rbp-10]
        cmp ax, [rbp-12]
        mov bx, [rbp-12]

        jne .L_for_loop_writing_1 ; test if all characters have been printed

    ; restoring the rsp value
    mov rsp, rbp
    pop rbp

    ret

array_elt_formatter:
    .asciz "%hhd "

{% endhighlight %}
</div></div></div>

The difference with the previous version is the presence of two parameters for our `print_array` function : an address (pointer) to the first element of the array and its length.
You may notice that for the two files, the function's symbols have been defined as `global` symbols, allowing our final program to record their name.

Regarding the `main` function, we also cautiously save the `rdi` and `rsi` registers in the stack as they are overwritten in our function.
They are indeed supposed to be **preserved** registers in the C language and since these registers are used in our function to pass parameters, it is necessary to save them.
You may refer to the [table](https://i.sstatic.net/j8hpC.png) given in the [stackoverflow](https://stackoverflow.com/questions/38335212/calling-printf-in-x86-64-using-gnu-assembler) post that was already linked in the previous part for the other registers to preserve.

To compile (assemble) this program, we first assemble separately our two code files : `as main.s -o main.o && as print_array.s -o print_array.o`.
Then, we combine the files with gcc to create the final executable : `gcc -static main.o print_array.o -o main`.
Simple! 😀

## Copying an array

For now, we have a program that prints an array.
Our problem is that the array is stored in the program's memory as a constant : it cannot be modified. during its execution 🔂.
In order to modify an array, it is then necessary to store it in a writable [place](https://www.geeksforgeeks.org/stack-vs-heap-memory-allocation/?ref=header_searchplace) : on the heap 🍚 or in the stack 🥞.

In our case, we can copy the array in the **stack** as we previously saw how to manipulate it.
In our program, the length of the array will be given as a parameter in order to manage different sizes.
This implies that we will perform a **dynamical** allocation on the stack, something that is not usually done in languages such as C.  

#### Dynamic allocation on the stack 

We know that allocations on the stack are performed by subtracting a given number of bytes from the stack pointer. 
One problem that arises from this design choice is that it is no longer possible to know in advance how to modify the `rsp` pointer to verify the *16* bytes alignment discussed previously.

This step can however be executed automatically.
To see how, let's add the `sub rsp, 7` instruction at line 11 in our previous main function.
We can then use gdb to display the `rsp` point by adding a breakpoint juste after this instruction :

<div class="code_frame"> GDB </div>
{% highlight plaintext linenos %}
(gdb) b main.s:20
Breakpoint 1 at 0x40168d: file main.s, line 22.
(gdb) run
...
(gdb) p/t $rsp
$1 = 11111111111111111111111111111111101101111011001
{% endhighlight %}

The `p/t` command in gdb allow to display a value (register for instance) in the binary format.
We can see the misalignment of the stack pointer here by looking at the last 4 digits (bits) of this number.
Indeed, in base 10, *16=2^4*, hence the last 4 bits of the number encode values from *0* to *15*.

Thus our stack pointers address currently ends with *1001* in binary, which is *9* in decimal.
The misalignment is equal to *16-9=7*, which corresponds to our previous allocation of 7 bytes (the stack was previously correctly aligned).
As the stack grows downward, it is necessary to subtract the right amount of bytes in order to re-align the stack pointer.
This step is actually straightforward in assembly : we need to subtract *rsp modulo 16* to our `rsp` pointer.

> 📝 Note that here we are considering that the binary numbers' first bytes are on the right.
> This is in fact a question of convention with the choice of the [endianness](https://en.wikipedia.org/wiki/Endianness).

To compute *rsp mod 16*, we can simply compute a logical **and** with the binary number **1 1 1 1** (15 in decimal), hence isolating the last four bytes of the number : 


<font size="4">  
<pre style="border: solid 1px; padding: 0.3rem; border-radius:0.3rem;">
    [...] <span style="color: blue;"> 1 0 1 1 0 1 1 1 1 0 1</span> <strong>1 0 0 1</strong> <- rsp
and [...] <span style="color: red;"> 0 0 0 0 0 0 0 0 0 0 0</span> <strong>1 1 1 1</strong> <- 15
    ------------------------------------
    [...] <span style="color: red;"> 0 0 0 0 0 0 0 0 0 0 0</span> <strong>1 0 0 1</strong>
</pre>
</font>




We can then use the `xor` operation (exclusive or) between our original address and the isolated 4 last bytes in order to turn all these 4 bytes into zeros : 

<font size="4">  
<pre style="border: solid 1px; padding: 0.3rem; border-radius:0.3rem;">
    [...] <span style="color: blue;"> 1 0 1 1 0 1 1 1 1 0 1</span> <strong>1 0 0 1</strong> <- rsp
xor [...]  <span style="color: red;">0 0 0 0 0 0 0 0 0 0 0</span> <strong>1 0 0 1</strong> <- rsp mod 16
    ------------------------------------
    [...] <span style="color: blue;"> 1 0 1 1 0 1 1 1 1 0 1</span> <strong>0 0 0 0</strong> <- rsp - (rsp mod 16)
</pre>
</font>

Let's achieve these operations in practice after our 7 bytes allocation :

<div class="code_frame"> Assembly x86-64 </div>
{% highlight nasm linenos %}
; allocate any number of bytes in the stack
sub rsp, 7

; automatic 16 bytes alignement of stack pointer rsp    
mov rax, rsp ; temporary storing the stack pointer
and rax, 15 ; computing rsp modulo 16 to compute the misalignment
xor rsp, rax ; subtracting the additional bytes with a xor operation
{% endhighlight %}

We can now add a breakpoint after these instructions and check the binary value of `rsp` with gdb :

<div class="code_frame"> GDB </div>
{% highlight plaintext linenos %}
(gdb) b main.s:25
Breakpoint 1 at 0x401697: file main.s, line 27.
(gdb) run
...
Breakpoint 1, main () at main.s:27
27	    push rdi
(gdb) p/t $rsp
$1 = 11111111111111111111111111111111101101111010000
{% endhighlight %}

Yay! The last 4 bytes are now all zeroes! 🥳


#### A copy array function

Let's now write our `copy_array` function that allows to copy an array from one location (memory address) to other one.
Note 📝 that this function does not actually need to manipulate the stack or allocate any memory space.
The allocation would be performed by the calling function and the only use of the function is to manipulate memory at that memory space to copy the array.

Let's create a base file for this function :

<div class="code_frame"> Assembly x86-64 | copy_array.s </div>
{% highlight nasm linenos %}
.global copy_array
.intel_syntax noprefix

; copy an array from one address to another one
; array elements are coded on 1 byte 
; rdi: address of the array
; si: length of the array
; rdx: target address of the array
copy_array:

    push rbp
    mov rbp, rsp

    ; local variables allocation
    sub rsp, 32 ; 20 bytes allocation + 12 bytes for stack pointer alignment

    ; rbp-8 (8 bytes) original array address
    ; rbp-10 (2 bytes) array length
    ; rbp-18 (8 bytes) address of the target array
    ; rbp-20 (2 bytes) array index

    ; saving preserved registers
    push rdi
    push rsi

    ; copy the array
    ; ...

    ; restoring preserved registers
    pop rsi
    pop rdi

    mov rsp, rbp
    pop rbp

    ret
{% endhighlight %}

Our new function takes three parameters, passed by registers : the address of the original array on 8 bytes, its length on 2 bytes and the address of the new array on 8 bytes.
These 3 parameters are stored in the stack.
One additional local variable is allocated to store an array index.

Just after the stack allocation, we can initialize our local variables.
The local variables corresponding to the parameters are initialized from their respective values and the index is initialized to 0 :

<div class="code_frame"> Assembly x86-64 </div>
{% highlight nasm linenos %}
mov [rbp-8], rdi ; rdi: original address
mov [rbp-10], si ; rsi: array length
mov [rbp-18], rdx ; address of the target array
mov [rbp-20], word ptr 0 ; array index
{% endhighlight %}

Then, the function should iterate over all elements of the arrays and copy the values from the original array to the target array.
This part is to be inserted at lines 26-27 of our "copy_array.s" backbone :

<div class="code_frame"> Assembly x86-64 </div>
{% highlight nasm linenos %}
.L_push_array:

    ; store the value from origin to target address
    mov rdx,[rbp-8] 
    mov al, [rdx] ; get the value

    mov rdx, [rbp-18] ; load the address
    mov [rdx], al

    ; go to the next addresses
    inc qword ptr [rbp-8]
    inc qword ptr [rbp-18]

    ; increment index and test length limit
    inc word ptr [rbp-20]
    mov ax, [rbp-10]
    cmp ax, word ptr [rbp-20]
    jne .L_push_array
{% endhighlight %}

This algorithm is essentially a "for" loop that iterate over both array elements.
The goal of the first part of the loop is to store the value of the original array into a 1-byte register.
Two operations are necessary to store or write the value into the array since the first one only recover the address of the value.

After this copy operation, the adresses are increased to point toward ↗️ the next array elements.
Finally, the array index (2 bytes) is increased and its value is compared to the array length in order to decide if a new iteration is required 🔁. 

#### Testing our copy function

Let's now complete our main function to test our `copy_array` function.
The first step is the allocation of the copy array in the stack.
To do so, we first allocate 8 bytes right after the `rbp` address in order to store the array copy address, and then, we allocate the sufficient number of bytes to store the array :

<div class="code_frame"> Assembly x86-64 </div>
{% highlight nasm linenos %}
; stack allocation
sub rsp, 8 ; store the address of the array copy
xor rax, rax
mov ax, [my_array_length] ; the length is stored on a word : 4 bytes -> ax registers
sub rsp, rax ; store the array
{% endhighlight %}

After that, we can insert the code that stores the address of the new array and the one that calls the `copy_array` function, right after saving the preserved registers :  

<div class="code_frame"> Assembly x86-64 </div>
{% highlight nasm linenos %}
; store the address of the array copy
mov [rbp-8], rsp

; copy the array
lea rdi, my_array
mov si, my_array_length
mov rdx, [rbp-8]
call copy_array
{% endhighlight %}



## Sorting arrays

