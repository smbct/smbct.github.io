---
title:  Assembly x86 programming 101 &#58 chapter 4, recursive power
author: smbct
date:   2024-05-14 10:00:00 +0200
categories: low-level programming assembly
comments: true
layout: series_article
back_page: headline.md
---

In the last post of the assembly x86 series, we have seen how to manipulate the stack in order to store local variables.
The stack is also essential for **calling functions** : it is used to store information such as the return instruction address.
In this post, we will see how to write and call functions, and also how to interact with C functions in our program!
We will apply these new notions to write a recursive function that computes the power of a number.


## More about the stack : pushing and popping values

Before diving into the mechanism of function calls, we should see two important instructions related to the stack that I did not mention in the previous post : `push` and `pop`.
The `push` instruction allows to move a value to the stack in an automated way.
This instruction will concretely perform two operations : 

- subtracting from the stack address to allocate some bytes in the stack
- copying the value at the resulting address in the stack (`mov` instruction)

`pop` is the reversed instruction : it copies the value from the stack to a register and increases the stack pointer accordingly.
Let's create a simple example :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
.global _start, debug, debug2
.intel_syntax noprefix

_start:
    mov rbp, rsp

    ; moving the value 42 into 8 bytes in the stack
    sub rsp, 8
    mov [rsp], qword ptr 42

    mov rsp, rbp

    ; exit
    mov rax, 60
    mov rdi, 0
    syscall

{% endhighlight %}

Nothing new here, we allocate 8 bytes on the stack and we store the value 42.
We will check that the value is properly stored : run GDB on the program after compiling in debug mode (as we did in a previous post), type `b my_prog.s:10` and `run` to stop just after the `mov` instruction (replace "my_prog" with your program's name).
After that, execute the commands `print $rbp` and `print $rsp`.
This gives me *0x7fffffffdd90* and *0x7fffffffdd88*.
*0x90-0x88=0x8* in hexadecimal, the 8 bits have been allocated (*0x* here simply means hexadecimal).

Now we would check the value that has been moved to the stack, directly from its memory address this time : `print *0x7fffffffdd88` (in this step, you should replace the specified address by the output you obtained with the `print $rsp` command).
The star character (\*) here is used to specify an address. 
We end up with the value *42*, perfect!
Note that the alternative command `x/dg 0x7fffffffdd88` could also be used to print the value, where *x* stands for "examining" memory.
[This page](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Memory.html#Memory) shows the different options such as the output format and the number of bytes to read.

Now let's modify this code with the push instruction and let's add a pop instruction afterward :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
_start:
    mov rbp, rsp

    ; moving the value 42 into 8 bytes in the stack
    push qword ptr 42

    pop rax

    mov rsp, rbp

    ; exit ...
{% endhighlight %}

Let's verify that the `push` instruction did exactly the same as a `sub` followed by a `mov`.
We run gdb in debug mode as previously and verify the rbp and rsp addresses after the `push` instruction at line 5 (to be replaced with your correct line number if different).
We end up with the same values as previously.
Great the `push` instruction did what we expected! 

Now let's inspect the action of `pop` by adding a breakpoint at line 8.
gdb indicates that `rbp = 0x7fffffffdd90` and `rsp = 0x7fffffffdd90`.
This is it.
After the `pop` instruction, the `rsp` register is now equal to the `rbp` register, which means the stack pointer took back its value before our allocation.
We can see the second effect of the `pop` instruction : the popped value is now stored in the `rax` register.
In this specific case, our last line `mov rsp, rbp` is not even necessary anymore since the de-allocation is now handled by `pop`.



## Writing basic functions

We have discovered in the previous posts of the series the `jmp` instruction which allows to go to a certain location in the program's code.
You may guess that this is the same mechanism at the base of function call : a jump is performed to the first instruction of the called function.
However, when the execution of the function is terminated, the program must go back to the instruction that follows this `jmp`.
To do so, we will see the `call` and `ret` instructions that take care of this.

When defining new functions, our labels will not have the "`_L.`" prefix anymore as they will not be local symbols.
Indeed, the functions can be called in other portions of the code or even from external programs (in libraries for instance). 

#### Writing and calling our first function

Let's start with a simple function that prints "hello world" :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
.global _start
.intel_syntax noprefix

_print_hello_world:
    mov rax, 1
    mov rdi, 1
    lea rsi, [hello_world]
    mov rdx, 14
    syscall
    ret

_start:

    call _print_hello_world

    ; exit
    mov rax, 60
    mov rdi, 69
    syscall

hello_world:
    .asciz "Hello, World!\n"
{% endhighlight %}

Compared to our hello_world example, this code simply encapsulates the printing instructions within a function with the use of a new symbol : "`_print_hello_world`".
The new function is executed with the `call` instruction and, at its end, the program returns to the execution of the `_start` function thanks to the `ret` instruction.

The ability to perform function calls brings a new dimension in our code : we are now working with the program's instructions addresses at runtime.
Indeed, when a function is being executed, the program must remember the address of the instruction that called the function (in the program's memory, where all instructions are loaded).
By doing so, the programs knows where to "return" in the program's memory at the  `ret` instruction.
There exists a register dedicated to store the address of the next instruction to be executed : the `rip` register (Relative Instruction Pointer).
We will look at this register to understand our program.

#### How function calls work ⚙️

Let's use gdb on the previous code to see what is happening.
We add breakpoints at lines 13 and 15 and another one at the `_print_hello_world` symbol (with `breakpoint _print_hello_world`) to see how the stack is manipulated.
After executing the `run` command in gdb, the program will start and pause just before the `call` instruction.
To illustrate the `rip` register mentioned before, we can already print the pointed instruction as follows :

<div class="code_frame"> GDB </div>
{% highlight plaintext linenos %}
(gdb) x/i $rip
=> 0x401020 <_start>:	call   0x401000 <_print_hello_world>
{% endhighlight %}

We can see the instruction's address in memory, *0x401020* and the decoded instruction which is our `call`.
Let's also print our stack pointer address : `print $rsp`, which gives *0x7fffffffdd70* in my case.
Then, the `continue` command in gdb makes the program stop at the beginning of the `_print_hello_world` function, just after the execution of the `call` instruction.
We will see what changed on the stack :

<div class="code_frame"> GDB </div>
{% highlight plaintext linenos %}
Breakpoint 2, _print_hello_world () at hello_world_func.s:9
9	    mov rax, 1
(gdb) print $rsp
$2 = (void *) 0x7fffffffdd68
(gdb) x *0x7fffffffdd68
   0x401025 <_start+5>:	mov    $0x3c,%rax
(gdb) print 0x7fffffffdd68 - 0x7fffffffdd70
$3 = -8
{% endhighlight %}

We can see that the `rsp` register has changed from *0x7fffffffdd70* to *0x7fffffffdd68*.
8 bytes have been allocated : the program has stored the return address of the function call.
Indeed, by printing the instruction at the corresponding location, we see that it corresponds to the instruction that follows `call` in the `_start` function : `mov $0x3c,%rax` (*0x3c* corresponds to the value 60 in decimal).

We continue the execution to see what happens when returning from the function :

<div class="code_frame"> GDB </div>
{% highlight plain linenos %}
Continuing.
Hello, World!

Breakpoint 3, _start () at hello_world_func.s:22
22	    mov rax, 60
(gdb) print $rsp
$4 = (void *) 0x7fffffffdd70
(gdb) x/i $rip
=> 0x401025 <_start+5>:	mov    $0x3c,%rax
{% endhighlight %}
The `continue` command in gdb now brings us right after the `call` instruction.
We can see that the `rsp` register took back its value from before the call, the return address is no longer necessary and has been popped out from the stack by the `ret` instruction.
We additionally print the value of the `rip` register : the value is the same as the one previously stored on the stack, that is the return address of our function call.


## Writing a recursive pow function

We will now study more complex functions to gain a deeper understanding of how the stack is manipulated when functions are called.
A good exercise for this is recursion : a recursive function (a function that calls itself) must pay attention to preserve the stack in a coherent state, in order to avoid unpredicted behaviors.
This is in fact an obligation for every function call but errors become easily fatal for our programs in the recursive case 💀.

In this chapter, we will write a function that computes the exponentiation of a number recursively, by performing successive multiplications.
Such an operation would easily be done iteratively with a simple loop but the recursive way is going to be more instructive. 


#### Passing parameters by registers

We have previously seen how to write a simple function that takes no parameters and that returns nothing.
In practice, parameters and return values are essential to our programs.
There are actually different ways to pass information between the functions : you may pass parameters into registers for instance or store them into the stack, it depends on the **convention** that is adopted.

We will start writing our pow function by passing the two parameters (the base and the exponent) to our function.
In this example, we pass the two values (the base and the exponent) by using the two registers `rdi` and `rsi` :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
_pow_rec:
    mov rbp, rsp

    ; ...

    mov rsp, rbp
    ret

_start:
    ; pushing the two parameters to the stack
    mov rdi, 5 ; base
    mov rsi, 4 ; exponent

    call _pow_rec

    ; exit
    mov rax, 60
    mov rdi, 0
    syscall
{% endhighlight %}

In this code, the `_start` function starts by placing the two parameters in their (temporarily) respective registers.
The first parameter to be pushed is the base and the second one is the exponent ; hence we will expect our program to compute *5^4* here.
The `_start` function then calls the `_pow_rec` function and eventually exits normally.

For now, our `_pow_rec` function simply takes care of saving and restoring the stack pointer, as we saw in the previous post of the series on the local variables allocation.
These precautions will be useful as we will use the stack in our function. 
You can run the program in gdb and verify that the two registers `rdi` and `rsi` received the correct values when the function `_pow_rec` is being called.

Let's now store the two parameters on the stack by allocating two 8-bytes local variables :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
_pow_rec:
    
    mov rbp, rsp
    sub rsp, 16
    ; base : offset=rbp-8, size=8
    ; exponent : offset=rbp-16, size=8

    ; storing the base and exponent parameters
    mov [rbp-8], rdi
    mov [rbp-16], rsi

    mov rsp, rbp
    ret
{% endhighlight %}

#### The recursive pow algorithm

We can now write the recursion, namely the central part of our algorithm.
Our program will first accumulate the function calls on the stack until the value *0* is reached for the exponent parameter.
Once it is done, the function can return 1 (*x^0 = 1* for all *x*) without any additional recursive call.
After that, the function calls would be unstacked and, at each time, the results of the previous call would be multiplied by the base.

To implement this, we separate the base case, when the exponent is *0*, from the general case :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
_pow_rec:
    
    ; saving the stack register and allocating memory
    ; ...

    ; storing the parameters on the stack
    ; ...

    ; compare the exponent to 0
    mov rbx, [rbp-16]
    test rbx, rbx
    jnz else_exponent_not_0

    .L_if_exponent_0:

        mov rax, 1
        jmp .L_endif

    .L_else_exponent_not_0:

        dec qword ptr [rbp-16]

        ; store the base and the exponent parameters in their associated registers
        mov rdi, [rbp-8]
        mov rsi, [rbp-16]

        call _pow_rec ; the recursive call
        imul rax, [rbp-8] ; compute the result

    .L_endif:

    ; restoring the stack pointer and returning
    ; ...

{% endhighlight %}

The first part of the algorithm is the comparison of the exponent value with *0*, indirectly done through the `rbx` register (an instruction cannot be given two memory addresses).
Here this comparison is performed with the `test` [instruction](https://en.wikipedia.org/wiki/TEST_(x86_instruction)) that performs a logical "and" operation and sets an internal flag depending on the result.
The `jnz` instruction (jump if not zero) will be triggered if the tested value (`rbx` here) is not equal to zero, as the instruction says.

The following instructions emulate an "if..else.." statement, where the first condition corresponds to the base being equal to *0*.
In this example, we choose to put the return value of the function in the `rax` register, which is handled in these two different conditions without using additional memory.
In the first case, the value *1* is simply moved to the register and the program jumps 🦘 to the end of the function, hence skipping the second case's instructions.
In the second case, the base variable is first decremented and the recursive call is then performed after moving the parameters to their registers.


#### Preserving the stack pointers across function calls

If you test the complete function by adding the remaining instructions from the previous code snippet, you would observe an infinite loop! ♾️
There is one crucial missing step in our code that handles the stack pointers.
For now we had only performed function calls from the main function.

We have seen how to save the stack pointer and restore it at the end of the function but we did not take care of the **base** pointer.
That is the issue here : the base pointer is modified in each sub call.
Hence, when returning from the function, the base pointer then written in `rsp` is no longer valid, causing the function to return in the wrong place.
In this situation, since the sub-calls are recursive, the function actually returns to itself, causing this infinite loop.

We will now change the function's base code to :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
_my_function_base:
    
    push rbp
    mov rbp, rsp

    ; allocate memory
    ; ...
    ; compute stuff
    ; ...

    mov rsp, rbp
    pop rbp
    ret

{% endhighlight %}

The two additional instructions `push` and `pop` here make sure that the `rbp` register is saved and restored at each function call.
This is handled directly by the called function, which is convenient for readability as these instructions would always be placed at the beginning and at the end of our functions.

We can now write the complete code of our recursive pow function : ✅

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
_pow_rec:
    
    ; saving the stack and the base registers
    push rbp
    mov rbp, rsp

    sub rsp, 16
    ; base : offset=rbp-8, size=8
    ; exponent : offset=rbp-16, size=8

    ; storing the base and exponent parameters
    mov [rbp-8], rdi
    mov [rbp-16], rsi

    ; compare the exponent to 0
    mov rbx, [rbp-16]
    test rbx, rbx
    jnz else_exponent_not_0

    .L_if_exponent_0:

        mov rax, 1
        jmp .L_endif

    .L_else_exponent_not_0:

        dec qword ptr [rbp-16]

        ; store the base and the exponent parameters in their associated registers
        mov rdi, [rbp-8]
        mov rsi, [rbp-16]

        call _pow_rec ; the recursive call
        imul rax, [rbp-8] ; compute the result

    .L_endif:

    ; restoring the stack and the base registers and returning
    mov rsp, rbp
    pop rbp
    ret
{% endhighlight %}

#### Testing and memory usage

We can now test our complete program with the help of gdb.
As we did previously, the program can be compiled in debug mode in order to add a breakpoint in gdb just after the call to `_pow_rec` in the `_start` function.
You should be able to see that the value returned by the function in the `rax` register is indeed the value *5^5 = 125*!

Now it is also interesting to take a look at the memory usage of this function.
As explained previously, the recursive calls in our program are accumulated on the stack until the base case is reached, namely when the base parameter equals *0*. 
This means that all information required for the function calls are multiplied on the stack, leading to a consequent use of memory.

To verify this, we can set a breakpoint at the base case of the recursion, just after the `.L_if_exponent_0` symbol.
If we now run the program in gdb, the calls will be accumulated until this base case is reached.
We can then use the `backtrace` (or `bt`) command in gdb to see the different calls present on the stack, namely the stack frames :

<div class="code_frame"> GDB </div>
{% highlight plain linenos %}
Breakpoint 1, _pow_rec () at pow_rec.s:31
31	        mov rax, 1
(gdb) backtrace
#0  _pow_rec () at pow_rec.s:31
#1  0x0000000000401033 in _pow_rec () at pow_rec.s:41
#2  0x0000000000401033 in _pow_rec () at pow_rec.s:41
#3  0x0000000000401033 in _pow_rec () at pow_rec.s:41
#4  0x0000000000401054 in _start () at pow_rec.s:61
{% endhighlight %}

This list shows all the functions that are being called by our program and that are not terminated.
We can see that there are 4 different calls to the `_pow_rec` function that are pending in the stack.
Indeed, at each call the base parameter is decreased.
Since the execution starts with *base=3*, four calls are required to reach the value *0*.

gdb allows us to navigate to each of these **stack frames** and explore the memory and registers there.
The command `frame 0` for instance will load the first frame.
This helps us to analyze the evolution the the stack pointer register `rsp` :

<div class="code_frame"> GDB </div>
{% highlight plain linenos %}
(gdb) frame 4
#4  0x0000000000401054 in _start () at pow_rec.s:61
61	    call _pow_rec
(gdb) print $rsp
$1 = (void *) 0x7fffffffdd88
(gdb) frame 0
#0  _pow_rec () at pow_rec.s:31
31	        mov rax, 1
(gdb) print $rsp
$2 = (void *) 0x7fffffffdd08
(gdb) print 0x7fffffffdd88-0x7fffffffdd08
$3 = 128
{% endhighlight %}

We can see the 128 bytes are used on the stack between the oldest function call (`_start`) and the most recent one.
Let's see if we can understand each of this use :

Our `_pow_rec` function stores 2 8-bytes registers on the stack for each call. 
Additionally, the `rbp` register is saved.
Moreover, for each function call, the program must store its return address as an additional 8-bytes value.
This means that we have 4 8-bytes values stored for each function call.
Since our program is currently executing 4 times the `_pow_rec` function, this results in *4 \* 4 \* 8 = 128* bytes of memory being used !

Our analysis helps to realize how much memory is used for our small `_pow_rec` function.
We would directly see that the value stored by the intermediate calls are actually useless since an iterative version of our program can be made : each intermediate computation step in our function only depends on the previous result.
Recursion can be very handy to use but sometimes its memory usage is not beneficial.

## An alternative version : passing parameters through the stack

In our last example, we have passed parameters to our function by the use of two registers.
It is however possible to do it differently, for instance by using the stack.

We will now write a second version of our algorithm following this new convention.
We will start from the initial code backbone and modify the `_start` function to pass the parameters on the stack :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
_pow_rec:
    push rbp
    mov rbp, rsp

    ; recursive pow computation 

    mov rsp, rbp
    pop rbp
    ret

_start:
    ; pushing the two parameters to the stack
    push qword ptr 5 ; base
    push qword ptr 4 ; exponent

    call _pow_rec

    ; popping the parameters stored on the stack
    add rsp, 16

    ; exit
    mov rax, 60
    mov rdi, 0
    syscall
{% endhighlight %}

Compared to our previous version, the `_start` function now contains two `push` instructions, one for each parameter.
Since the `rsp` pointer is modified at this point, it is necessary to restore it after the call, hence the `add` instruction.
You may realize that in the configuration, we did not bother to save the stack and the frame pointers contrarily to what we saw previously.
Indeed, the `_start` function remains simple and our program exits right after the power computation.

It is now necessary to modify the code in charge of storing the parameters in the stack in our `_pow_rec` function.
I agree that this step seems counterintuitive as the parameters are now already present in the stack when the function is called.
However, it is important to place the local variables of our function in their own stack frame and **not interfere** with the stack frame of the calling function.

The beginning of `_pow_rec` becomes :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
_pow_rec:
    push rbp
    mov rbp, rsp

    sub rsp, 16
    ; base : offset=rbp-8, size=8
    ; exponent : offset=rbp-16, size=8

    ; storing the base parameter
    mov rax, [rbp+24]
    mov [rbp-8], rax

    ; storing the exponent parameter
    mov rax, [rbp+16]
    mov [rbp-16], rax

    ; instructions that follow do not change
    ; ...
{% endhighlight %}

The only difference with the previous version is where the parameters' values are taken from.
Counterintuitively, we get access to the values by navigating backward in the stack, adding  a positive offset to the `rbp` register instead of a negative one.
This is because our parameters were stored in the previous stack frame (the stack frame of the calling function).

When the function starts, the `rsp` register points toward the return address as we saw previously.
Since the `rbp` register is also pushed to the stack, this means that two registers are already present between the start of our stack frame and our function parameters.
For this reason, the parameters are being picked from above in the stack addresses : the exponent parameter being that last to be pushed, it is accessed at offset *16* from the `rbp` register.
On the other hand, the base parameter is accessed from above, at offset *24*.

I find it useful to take some time to apprehend how the stack is being used here.
The best way to organize our code for the function calls is to carefully respect the stack frame from each function call and refrain from interfering with the frame of another function.

 
## What's next ?

This one was pretty dense!
Correctly manipulating the stack with function calls is certainly an important step toward the ability to program in assembly.
I hope this post was not too technical.
The good news is : this is I think the most technical content to digest before advancing to more practical exercises 🥳.
The next chapter will be about interfacing our code with C programs : calling functions from the C standard library for instance.
This will allow us to perform higher level operations without requiring any single line of C. 

Before that, I invite you to continue practicing 🧑‍💻 from the different codes realized here.
For instance, you may create a program that computes the multiplication of two numbers recursively, similarly to what we saw with the pow function.
You may also try more complex recursions such as writing a function that computes the Fibonacci series.
As previously, I put the codes from this post as well as bonus ones (the Fibonacci function for instance) at this following [link](https://github.com/smbct/x86-64_101_linux/tree/main/pt4_recursive_power).


