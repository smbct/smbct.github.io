---
title:  Assembly x86 programming 101 &#58 part 6, sorting arrays
author: smbct
date:   2024-06-20 10:00:00 +0200
categories: low-level programming assembly
comments: true
layout: series_article
back_page: headline.md
---

## Copying an array

#### Dynamic allocation on the stack 

One particularity of our program is that the array that is sent to the C function is allocated on the stack.
This in in fact the easiest way to allocate memory.
Thus, at the beginning of our program, the stack pointer is decreased accordingly to the length of the array.
You may realize that this kind of operation is actually not allowed in C : arrays that are allocated during the execution of the program must have their size known in advance.
Although we actually know the size in advance in our case, it could be possible to allocate the array depending on a variable given.   

#### Dynamic stack alignment

One problem that arises from this design choice is that it is no longer possible to know in advance how to modify the `rsp` pointer to verify the *16* bytes alignment discussed previously.
This step can however be executed automatically as it is shown just after the stack allocation.
This code first computes *`rsp` modulo 16* and the **extra bytes** are then subtracted (as the stack grows downward) to achieve the alignement.

## Sorting arrays

<div class="collapse-panel"><div>
<label for="col1">Uncover </label>
<input type="checkbox" name="" id="col1"><span></span>

<div class="code_frame"> Assembly x86-64 | main.s </div>
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

<div class="code_frame"> Assembly x86-64 | test.s </div>
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
</div></div>

