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

        inc qword ptr [rbp-8] ; increase the array pointer
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

You can see that the address of the new array is directly obtained from the value of the `rsp` register.
Indeed, the array was allocated with a `sub` operation on `rsp`.
Since the stack grows downward ⬇️, this means that the first address of our array is actually the lowest address of the allocated portion of the stack (assuming the array's first element is at the lower address). 

Nothing new however regarding the function call, the addresses of the two arrays are given to the registers that take the parameters, as well as the array length.
Let's add another printing calls to compare the result.
The final `main` function should look like this :


<div class="collapse-panel"><div>
<label for="code_3">Expand</label>
<input type="checkbox" name="" id="code_3"><span class="collapse-label"></span><div class="extensible-content">

<div class="code_frame"> Assembly x86-64 | main.s </div>
{% highlight nasm linenos %}
.global main
.intel_syntax noprefix

; main function (libc main)
main:
    
    push rbp ; storing the rbp value before manipulation
    mov rbp, rsp ; storing the rsp register

    ; stack allocation
    sub rsp, 8 ; store the address of the array copy
    xor rax, rax
    mov ax, [my_array_length] ; the length is stored on a word : 4 bytes -> ax registers
    sub rsp, rax ; store the array

    ; automatic 16 bytes alignement of rsp    
    mov rax, rsp ; temporary storing the stack pointer
    and rax, 15 ; computing rsp modulo 16 to compute the misalignment
    xor rsp, rax ; subtracting byte to align rsp

    ; storing the preserved registers
    push rdi
    push rsi

    ; store the address of the array copy
    xor rax, rax
    mov ax, [my_array_length]
    mov rcx, rbp
    sub rcx, 8
    sub rcx, rax
    mov [rbp-8], rcx

    ; copy the array
    lea rdi, my_array
    mov si, [my_array_length]
    mov rdx, [rbp-8]
    call copy_array

    ; -------------------------------------------------------------
    ; Print the original array

    ; printing the "My array : " string
    xor eax, eax
    lea rdi, [my_array_str]
    call printf

    ; calling the print_array function
    lea rdi, [my_array]
    mov si, [my_array_length]
    call print_array

    ; printing a new line
    xor eax, eax
    lea rdi, [new_line]
    call printf

    ; -------------------------------------------------------------
    ; Print the copy array

    ; printing the "My array copy : " string
    xor eax, eax
    lea rdi, [my_array_copy_str]
    call printf

    ; calling the print_array function with parameters
    mov rdi, [rbp-8]
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
    .asciz "My array :      "
my_array_copy_str:
    .asciz "My array copy : "

{% endhighlight %}
</div></div></div>

You should now be able to see the two identical arrays printed in the terminal :

<div class="code_frame"> Bash | main output </div>
{% highlight plaintext linenos %}
My array :      5 12 42 8 1 3 7 25 14 
My array copy : 5 12 42 8 1 3 7 25 14
{% endhighlight %}

That's great! 👏 We can now add some additional lines to verify that we are indeed able to modify the array.
To do so, we will load the address of the third element of the copy array and write the value 0 into it : 

<div class="code_frame"> x86-64 assembly </div>
{% highlight nasm linenos %}
; modify the copy array
mov rax, [rbp-8]
add rax, 2
mov [rax], byte ptr 0
{% endhighlight %}

Which gives :

<div class="code_frame"> Bash | main output </div>
{% highlight plaintext linenos %}
My array :      5 12 42 8 1 3 7 25 14 
My array copy : 5 12 0 8 1 3 7 25 14 
{% endhighlight %}

Perfect! 🥳 We are now able to store and modify arrays in our codes!

## Sorting an array

In this second sub part, we will now implement a sorting algorithm in assembly : the **selection sort** algorithm.
The idea of the selection sort is to successively compute the minimum of sub-arrays of the input one.

In the first step, the algorithm finds the minimum value of the entire array and stores it at the first position.
In the second one, the algorithm then looks for the minimum value of the sub-array starting at the second position.
The algorithm then continues until the sub-array contains only one element.

#### Pseudocode

To simplify the implementation, we will start with a pseudocode of the algorithme.
This will help define the local variables and the global structure of the function.

<div class="code_frame"> Pseudocode | selection sort </div>
{% highlight plaintext linenos %}

* Parameters :
    array : the array (modifiable) to be sorted
    array_len : length of the array

* Local variables :
    outer_index : index to iterate over the array
    inner_index : index to iterate over the sub-arrays
    min_ind : index of the minimum value of a sub-array
    temp : a temporary variable to swap two array values

* Algorithm :

    for outer_index in {1,..,array_len-1}
        
        // init the min value to the first element
        min_ind <- out_index

        // iterate over the sub array array[outer_index+1 : array_len-1]
        for inner_index in {outer_index+1,..,array_len-1}

            if array[inner_index] < array[min_index] then
                min_index <- inner_index
            endif

        endfor

        // swap the first value of the sub-array and the min value
        temp <- array[inner_index]
        array[inner_index] <- array[min_index]
        array[min_index] <- temp

    endfor
{% endhighlight %}

In our code, the two parameters will be turned into local variables in order to free their respective registers.
You can also see the two nested loops which which allow to iterate respectively over the complete array and the sub-arrays.
In this configuration, the minimum of each sub-array is recorded through its index.

#### Assembly implementation

We start our implementation by defining our variables and writing the backbone of the function.
As the pseudocode contains two "for" loops (the inner and the outer loops), we will used two indexes and two array addresses to control the iterations and access the array elements.
We will also use two additional variables : one to store the min value of the sub arrays in the inner loop, and another one to store a temporary value. (useful for swapping values and storing the min value of sub arrays).

Here is the function's backbone :

<div class="code_frame"> Assembly x86-64 | selection_sort.s </div>
{% highlight nasm linenos %}
.global selection_sort
.intel_syntax noprefix

; Sort an array with the selection sort algorithm
; rdi : array pointer
; si : array length
selection_sort:

    push rbp
    mov rbp, rsp

    sub rsp, 48 
    ; rbp-8 : (8 bytes) array address (param)
    ; rbp-10 : (2 bytes) array length (param)
    ; rbp-12 : (2 bytes) outer index
    ; rbp-14 : (2 bytes) inner index
    ; rbp-22 : (8 bytes) outer array address
    ; rbp-30 : (8 bytes) inner array address
    ; rbp-32 : (2 bytes) sub-array min index
    ; rbp-33 : (1 byte) temp value for swapping

    ; a) first variable initialization
    ; [...]

    ; ----------------------------------------
    ; outer loop
    .L_outer_for:

        ; b) init the inner array index and address
        ; [...]

        ; e) init the variables to store the sub array min
        ; [...]

        ; ----------------------------------------
        ; inner loop
        .L_inner_for:

            ; f) compare the current value with the min value recorded
            ; [...]

            ; c) increase the inner index and address
            ; [...]

        ; ----------------------------------------
        ; g) swap the first value and the min value
        ; [...]

        ; d) increase the outer index and address
        ; [...]

    mov rsp, rbp
    pop rbp

    ret
{% endhighlight %}

We can then complete the first initialization of the variables outside of the outer loops.
This will concern the function parameters and the index and address for the outer loop :

<div class="code_frame"> Assembly x86-64 </div>
{% highlight nasm linenos %}

; a) first variable initialization
mov [rbp-8], rdi ; first parameter
mov [rbp-10], si ; second parameter
mov [rbp-12], word ptr 0 ; outer loop index
mov [tbp-22], rdi ; array address for the outer loop
{% endhighlight %}

We can then put in place the iterations of the two loops by initializing the inner loop variables, increasing the indexes and addresses and testing for loop termination ( b, c, d) :

<div class="code_frame"> Assembly x86-64 </div>
{% highlight nasm linenos %}
; ----------------------------------------
; outer loop
.L_outer_for:

    ; b) init the inner array index and address

    ; inner array index
    mov ax, [rbp-12]
    mov [rbp-14], ax
    inc word ptr [rbp-14]

    ; inner array address
    mov rax, [rbp-22]
    mov [rbp-30], rax
    inc qword ptr [rbp-30]

    ; e) init the temp value (current min) with the outer current element

    ; ----------------------------------------
    ; inner loop
    .L_inner_for:

        ; f) compare the current value with the min value recorded
        ; [...]

        ; c) increase the inner index and address
        inc word ptr [rbp-14]
        inc qword ptr [rbp-30]

        ; compare then inner index with the array length
        mov ax, [rbp-10]
        cmp ax, [rbp-14]
        jne .L_inner_for
 
    ; ----------------------------------------
    ; g) swap the first value and the min value
    ; [...]

    ; d) increase the outer index and address

    ; increase the outer index and address
    inc word ptr [rbp-12]
    inc qword ptr [rbp-22]

    ; compare the outer index with the array length
    mov ax, [rbp-12]
    inc ax
    cmp ax, [rbp-10]
    jne .L_outer_for

{% endhighlight %}

These loop controls are very similar to what we did previously.
Regarding the inner loop, the iteration starts from the array element that follows the one pointed to by the outer loop.
The sub array is then defined as all the remaining elements to the end of the array.

In this code, the indexes are tested at the end of the iterations and the loop termination occurs when they reach the end of the array.
You may notice that the outer index actually stops just before reaching the last element of the array (hence the `inc ax` operation).
Otherwise, the inner loop's first iteration would go beyond the array bounds.

#### Comparing and swapping elements

The central part of our algorithm will be the computation of the minimum values in the sub-arrays as we iterate in the inner loop.
To do so, we will use two variables to store respectively the array index of the current min and its value.

These variables can be initialized from the position of the outer array index (e) : 

<div class="code_frame"> Assembly x86-64 </div>
{% highlight nasm linenos %}
; e) init the temp value (current min) with the outer current element

; init the index of the current min value in the sub array
mov ax, [rbp-12]
mov [rbp-32], ax

; init the current min value to the element at the outer loop index
mov rax, [rbp-22]
mov al, [rax]
mov [rbp-33], al
{% endhighlight %}

We may note that as we already saw, two operations are necessary here to access an element of the array from its address.
First, the address is stored from the stock to a register.
Then, the value is taken at the address from the register and is stored in another register.
These two operations are necessary since two dereferences (namely taking the value stored at a given memory address) occur : one from the stack and another one from the array.

Then, at each inner loop iteration, it is necessary to compare the pointed value to the temporary minimum (f) :

<div class="code_frame"> Assembly x86-64 </div>
{% highlight nasm linenos %}
; f) compare the current value with the min value recorded

; compare the two values
mov rax, [rbp-30]
mov al, [rax] ; inner array value
cmp al, [rbp-33] ; current min value
jge .L_else_not_lower

; .L_if_lower update the min index       
    mov rax, [rbp-30]  
    mov al, [rax]
    Mov [rbp-33], al ; store the current min in the temp variable

    mov ax, [rbp-14]
    mov [rbp-32], ax ; record the index 

.L_else_not_lower:
{% endhighlight %}

The first operations consist in comparing the value of the element at the inner loop index to the one temporarily stored as the minimum.
If the element is smaller, then the two corresponding variables are updated.
Otherwise, the program jumps to the following instructions (inverted if conditional).

We can now achieve the last part of the function : swapping the element at the outer index with the minimum element found in the sub-array (g);
In this operation, we will re-use two local variables that are no longer used at this point of the function.
The address of the inner loop element (`rbp-30`) will be used to store the address of the sub array min value.
The temp variable (`rbp-33`) will be used to store on of the value to swap the two elements  :

<div class="code_frame"> Assembly x86-64 </div>
{% highlight nasm linenos %}
; g) swap the element at the outer loop index with the min value

; mov the address of the min element to the inner address variable
xor rax, rax
add al, [rbp-32]
add rax, [rbp-8]
mov [rbp-30], rax

; swap the values

; move the value at the outer address to the temp variable 
mov rax, [rbp-22]
mov al, [rax]
mov [rbp-33], al ; the outer element is stored in the temp variable

; move the min element value to the outer element's index 
mov rax, [rbp-30]
mov al, [rax]
mov rcx, [rbp-22]
mov [rcx], al

; move the temp element (outer address) to the index of the min element
mov al, [rbp-33] ; get the temp value
mov rcx, [rbp-30]
mov [rcx], al ; store it to the inner
{% endhighlight %}

And voilà!
For each of these operations sub actions unfortunately, multiple assembly operations are necessary which makes the code less readable. 
I tried to partition the code as much as possible and decompose it into several simpler parts.

#### Final function

Here is the complete version of our `selection_sort` assembly function :

<div class="collapse-panel"><div>
<label for="code_4">Expand</label>
<input type="checkbox" name="" id="code_4"><span class="collapse-label"></span><div class="extensible-content">

<div class="code_frame"> Assembly x86-64 | selection_sort.s </div>
{% highlight nasm linenos %}
.global selection_sort
.intel_syntax noprefix

; Sort an array with the selection sort algorithm
; rdi : array pointer
; si : array length
selection_sort:

    push rbp
    mov rbp, rsp

    sub rsp, 48 
    ; rbp-8 : (8 bytes) array address (param)
    ; rbp-10 : (2 bytes) array length (param)
    ; rbp-12 : (2 bytes) outer index
    ; rbp-14 : (2 bytes) inner index
    ; rbp-22 : (8 bytes) outer array address
    ; rbp-30 : (8 bytes) inner array address
    ; rbp-32 : (2 bytes) sub-array min index
    ; rbp-33 : (1 byte) temp value for swapping

    ; variable initialization
    mov [rbp-8], rdi ; array address
    mov [rbp-10], si ; array length
    
    mov [rbp-12], word ptr 0 ; init the outer array index
    mov [rbp-22], rdi ; init the outer array address

    ; ----------------------------------------
    ; outer loop
    .L_outer_for:

        ; init the inner array index <- array_index+1
        mov ax, [rbp-12]
        mov [rbp-14], ax
        inc word ptr [rbp-14]
        

        ; init the sub-array min index
        mov [rbp-32], ax

        ; init the inner array address
        mov rax, [rbp-22]
        mov [rbp-30], rax
        inc qword ptr [rbp-30]

        ; init the temp value (current min) with the outer current element
        mov rax, [rbp-22]
        mov al, [rax]
        mov [rbp-33], al

        ; ----------------------------------------
        ; inner loop
        .L_inner_for:

            mov rax, [rbp-30]
            mov al, [rax] ; inner array value

            cmp al, [rbp-33] ; current min value
            
            jge .L_else_not_lower

            ; .L_if_lower update the min index
                
                mov rax, [rbp-30]  
                mov al, [rax]
                mov [rbp-33], al ; store the current min in the temp variable

                mov ax, [rbp-14]
                mov [rbp-32], ax ; record the index 

            .L_else_not_lower:

            ; increase the inner address
            inc qword ptr [rbp-30]

            ; increase the inner index and compare with the array length
            inc word ptr [rbp-14]
            mov ax, [rbp-10]
            cmp ax, [rbp-14]
            jne .L_inner_for

        ; ----------------------------------------
        ; swap the values

        ; move the address of the min element in the inner address variable
        xor rax, rax
        add al, [rbp-32]
        add rax, [rbp-8]
        mov [rbp-30], rax

        ; move the value at the outer address to the temp variable 
        mov rax, [rbp-22]
        mov al, [rax]
        mov [rbp-33], al ; the outer element is stored in the temp variable

        ; swap the values
        
        ; min value to outer element's index
        mov rax, [rbp-30]
        mov al, [rax]
        mov rcx, [rbp-22]
        mov [rcx], al

        ; temp value to the min element's index
        mov al, [rbp-33] ; get the temp value
        mov rcx, [rbp-30]
        mov [rcx], al ; store it to the inner
         

        ; increase the outer address
        inc qword ptr [rbp-22]

        ; increase the outer index and compare with the array length
        inc word ptr [rbp-12]
        mov ax, [rbp-12]
        inc ax
        cmp ax, [rbp-10]
        jne .L_outer_for

    mov rsp, rbp
    pop rbp

    ret
{% endhighlight %}
</div></div></div>

You should be able to call the function from the main function on the array stored on the stack and observe such result :

<div class="code_frame"> Bash | main's output </div>
{% highlight plaintext linenos %}
My array :        5 12 42 8 1 3 7 25 14 
My array sorted : 1 3 5 7 8 12 14 25 42
{% endhighlight %}

Yeee!! 🔥

This version of the selection sort is actually quite long.
One possibility to improve it is to perform the swap in the inner loop, although it would be a little bit less efficient.
I encourage you to find possible variations in order to make it as clean as possible.

## What's next ?

I would congratulate you if you made it this far!
Although this part was more about assembling all the previous notions to solve a concrete problem, it has the advantage to make us develop a organization and abstraction abilities in order to navigate in this nonsense-of-a-code.

You will find the codes from this part at the following [address](https://github.com/smbct/x86-64_101_linux/tree/main/pt6_sorting).
I will probably write an addition last part to this series in order to produce a more visual program!
This will however not necessarily be the end of the posts or series about assembly as I have multiple ideas of how to make apply such knowledge on concrete problems.  

