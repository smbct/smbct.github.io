---
title:  Assembly x86 programming 101 &#58 part 4, recursive power
author: smbct
date:   2024-05-14 10:00:00 +0200
categories: low-level programming assembly
comments: true
layout: post
---

In the last post of the assembly x86 series, we have seen how to manipulate the stack in order to store local variables.
The stack is also essential for **calling functions** : it is used to store information such as the return instruction address.
In this post, we will see how to write and call functions, and also how to interact with C functions in our program!
We will apply these new notions to write a recursive functions that computes the power of a number.


## More about the stack : pushing and popping values

Before diving into the mechanism of function calls, we should see two important instructions related to the stack that were bot mentioned in the previous post : `push` and `pop`.
The `push` instruction allows to move a value to the stack in an automated way.
This instruction will concretely perform two operations : 

- subtracting the stack address to allocate some bytes in the stack
- moving the value at the resulting address in the stack

`pop` is the reversed instruction : it moves the value from the stack to a register and increases the stack pointer accordingly.
Let's create a simple example :

{% highlight nasm linenos %}
.global _start, debug, debug2
.intel_syntax noprefix

_start:
    mov rbp, rsp

    ; moving the value 42 into 8 bytes in the stack
    sub rsp, 8
    mov [rsp], qword ptr 42

    debug:

    mov rsp, rbp

    ; exit
    mov rax, 60
    mov rdi, 0
    syscall
{% endhighlight %}

Nothing new here, we allocate 8 bytes on the stack and we store the value 42.
We will check that the value is properly stored : run GDB on the program, type `b debug` and `run` to stop just after the move.
After that, execute the commands `print $rbp` and `print $rsp`.
This gives me *0x7fffffffdda0* and *0x7fffffffdd98*.
*98-a0=-8* in hexadecimal, the 8 bits have been allocated (*0x* here simply means hexadecimal).

Now we would check the value, directly from the stack this time : `print *0x7fffffffdd98` (in this step, you should replace the specified address by the output you obtained with the `print $rsp` command).
The star character (\*) here is used to specify an address. 
We end up with the value *42*, perfect!
Note that alternative command `x/dg 0x7fffffffdd98` could also be used to print the value, where *x* stands for "examining" memory.
[This page](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Memory.html#Memory) shows the different options such as the output format and the number of bytes to read.

Now let's modify this code with the push instruction and let's add a pop instruction afterward :

{% highlight nasm linenos %}
_start:
    mov rbp, rsp

    ; moving the value 42 into 8 bytes in the stack
    push qword ptr 42

    debug:

    pop rax

    debug2:

    mov rsp, rbp

    ; exit
    ; ...
{% endhighlight %}

We can use GDB with the previous commands to check that the `push` instruction did exactly the same as a `sub` followed by a `mov`:

```
(gdb) break debug
(gdb) break debug2
(gdb) print $rbp
$1 = (void *) 0x7fffffffdda0
(gdb) print $rsp
$2 = (void *) 0x7fffffffdd98
(gdb) print *0x7fffffffdd98
$3 = 42
(gdb) print 0x7fffffffdda0-0x7fffffffdd98
$4 = 8
```

Alright, that is indeed an 8 bytes allocation followed by the value 42 being stored in the stack.
Now let's inspect the action of `pop`:

```
(gdb) continue
(gdb) print $rsp
$5 = (void *) 0x7fffffffdda0
(gdb) print $rbp
$6 = (void *) 0x7fffffffdda0
(gdb) print $rax
$7 = 42
```

This is it.
After the `pop` instruction, the `rsp` register is now equal to the `rbp` register, which means the stack pointer took back its value before our allocation.
We can see the second effect of the `pop` instruction : the popped value is now stored in the `rax` register.




## Writing basic functions

We have discovered in a previous post of the series the `jmp` instruction which allows to go to a certain location in the program's code.
You may guess that this is the same mechanism at the base of function call : a jump is performed to the first instruction of the called function.
However, when the execution of the function is terminated, the program must go back to the instruction that follows this `jmp`.
To do so, we will see the `call` and `ret` instructions that take care of this.

#### Writing and calling our first function

Let's start with a simple function that prints "hello world" :

{% highlight nasm linenos %}
.global _start, _before_call, _after_call
.intel_syntax noprefix

_print_hello_world:
    mov rax, 1
    mov rdi, 1
    lea rsi, [hello_world]
    mov rdx, 14
    syscall
    ret

_start:

    _before_call:
    call _print_hello_world
    _after_call:

    ; exit
    mov rax, 60
    mov rdi, 69
    syscall

hello_world:
    .asciz "Hello, World!\n"
{% endhighlight %}

Compared to our hello_world example, this code simply encapsulates the printing instructions within a function by the use of a new symbol ("_print_hello_world").
The function is executed with the `call` instruction and the program returns the the `_start` function execution thanks to the `ret` instruction.
We will use the two additional symbols "_before_call" and "_after_call" as debugging labels with gdb to see how it works.

Calling functions brings a new dimension in our code : we are now manipulating the program's instructions addresses at runtime.
Indeed, when a function is being executed, the program must remember the address of the instruction that calls the function (in the program's memory, where all instructions are loaded).
By doing so, at the return instruction the programs knows where to "return" in the program's memory.
There exists a register that is dedicated to store the address of the next instruction to be executed : the `rip` register (Relative Instruction Pointer).
We will use look at this register to understand our program.

#### How function calls work

Let's use gdb on the previous code to see what is happening.
We add breakpoints at `_before_call`, `_print_hello_world` (just after the `call` instruction) and at `_after_call` to see how the stack is manipulated.
After executing the `run` command in gdb, the program will start and pause at `_before_call`, just before the function call.
To illustrate the `rip` register mentioned before, we can already print the pointed instruction with :

```
(gdb) x/i $rip
=> 0x401020 <_start>:	call   0x401000 <_print_hello_world>
```

We can see the address, *0x401020* and the encoded instruction which is our `call`.
Let's also print our stack pointer address : `print $rsp`, which gives *0x7fffffffdda0* in my case.
Then, the `continue` command makes the program stops at `_print_hello_world`.
We will see what changed on the stack :

```
Breakpoint 3, 0x0000000000401000 in _print_hello_world ()
(gdb) print $rsp
$3 = (void *) 0x7fffffffdd98
(gdb) x *0x7fffffffdd98
   0x401025 <_after_call>:	mov    $0x3c,%rax
(gdb) print 0x7fffffffdd98-0x7fffffffdda0
$4 = -8
```

We can see that the `rsp` register has changed from *0x7fffffffdda0* to *0x7fffffffdd98*.
8 Bytes have been allocated : the program has stored the return address of the function call.
Indeed, by printing the instruction at the corresponding location, we see that it corresponds to the instruction that follows the `call` one in the `_start` function : `mov $0x3c,%rax` (*0x3c* corresponds to the value 60 in decimal).

We continue the execution to see what happens when returning from the function :
```
Continuing.
Hello, World!

Breakpoint 2, 0x0000000000401025 in _after_call ()
(gdb) print $rsp
$5 = (void *) 0x7fffffffdda0
(gdb) x/i $rip
=> 0x401025 <_after_call>:	mov    $0x3c,%rax
```
The `continue` command in gdb now brings us at the `_after_call` label.
We can see that the `rsp` register took back its value from before the call, the return address was is no longer necessary and is popped out with the `ret` instruction.
We additionally print the value of the `rip` register : the value is the same as the one previously stored on the stack.


## Writing a recursive pow function

We will now study more complex functions to gain a deeper understanding of how the stack is manipulated when functions are called.
A good exercise for this is recursion : a recursive function (a function that calls itself) must pay attention to preserve the stack in coherent state, in order to avoid unpredicted behaviors.

In this part, we will write a function that wil compute the exponentiation of a number recursively, by performing successive multiplications.
Such operation would easily be done with a simple loop but the recursive way is going to be more instructive. 


#### Passing parameters through the stack

We have previously seen how to write a simple function that takes no parameters and that returns nothing.
In practice, parameters and return values are essential to our programs.
There are actually different ways to pass information between the functions : you may pass parameters into registers for instance or store them into the stack, it depends on the **convention** that is adopted.

We will start or pow function by passing the two parameters (the base and the exponent) to our function.
In this example, we pass the values by using the stack :

{% highlight nasm linenos %}
_pow_rec:
    mov rbp, rsp
    mov rbx, [rbp+8]
    debug:
    mov rsp, rbp
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

In this code, the `_start` function starts by placing the two parameters of our pow function on the stack.
The first parameter to be push is the base and the second one is the exponent, hence we expect to compute *5^4* here.
The `_start` then calls the `_pow_rec` function and after that it removes the values from the stack with the `add` instructions (2* (8 bytes)).

For now, our `_pow_rec` function only extracts one of the parameter from the stack.
Since this function will use the stack, we added the rwo `mov` instructions to save and restore the stack pointer, as we saw in the previous post of the series on the local variables allocation.
However at this point, since no additional data is stored in stack, the `rbp` and `rsp` registers would be equal during the function's execution.

You can test run the program in gdb and add a breakpoint at `debug` to test the `rbx` register.
The resulting value is *4*, which corresponds to the exponent parameter.
The value is accessed by adding *8* to the `rbp` register.
This can be understand from the fact that the stack pointer points toward the return address of the function call (8 bytes) as we saw previously.
This means that `rsp+8` points to the last value added to the stack before the call (as the stack grows toward lower addresses), which corresponds to the exponent parameter in our case.
By going further in the stack we end up finding the base parameter, 16 bytes above the current stack address.

Let's now store the two parameters on the stack by allocating two 8 bytes local variables :

{% highlight nasm linenos %}
_pow_rec:
    
    mov rbp, rsp
    sub rsp, 16
    ; base : offset=rbp-8, size=8
    ; exponent : offset=rbp-16, size=8

    ; storing the base parameter
    mov rbx, [rbp+8]
    mov [rbp-8], rbx

    ; storing the exponent parameter
    mov rbx, [rbp+16]
    mov [rbp-16], rbx

    mov rsp, rbp
    ret
{% endhighlight %}

#### The recursive pow function

Now we can now write the recursion, the central part of our algorithm.
Our program will first accumulate the function calls on the stack until the exponent *0* is reached.
Once it is done, the function can return 1 (x^0 = 1 for all x) without any additional recursive call.
After that, the function calls would be unstacked and each time, as the results of the previous call would be multiplied by the base.

To implement this, we separate the base case, when the exponent is 0, from the general case :

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

        ; store the left and right parameters for the next recursive call
        push qword ptr [rbp-8]
        push qword ptr [rbp-16]

        call _pow_rec ; the recursive call
        imul rax, [rbp-8] ; compute the result

        add rsp, 16

    .L_endif:

    ; restoring the stack pointer and returning
    ; ...

{% endhighlight %}

The first part of the algorithm is the comparison of the exponent value with 0, indirectly done through the `rbx` register.
Here this comparison is performed with the `test` [instruction](https://en.wikipedia.org/wiki/TEST_(x86_instruction)) that performs a logical and operation and sets an internal flag depending on the result.
The `jnz` instruction (jump if not zero) will be triggered if the tested value (`rbx` here) is not equal to zero, as the instruction says.

The following instructions emulate an if..else.. statement, where the first condition corresponds to the base equal to 0.
In this example, we choose to put the return value of the function in the `rax` register, which is handled in these two different conditions without using additional memory.
In the first case, the value 1 is simply moved to the register and the program jumps to the end of the function, to skip the second case's instructions.
In the second case, the base variable is first decremented and the recursive call is performed after pushing the parameters to the stack.


#### Preserving the stack pointers across function calls

If you test the complete function by adding the remaining instructions from the previous code snippet, you would observe an infinite loop!
There is one crucial missing step in our code that handles the stack pointers.
For now we had only performed function calls from the main function.

We have seen how to save the stack pointer and restore it at the end of the function but we did not do anything for the base pointer.
That is the issue here : the base pointer is modified in each sub call.
Hence, when returning in the function, the base pointer which is then written in `rsp` is no longer valid, causing the function to return in the wrong place.
In this situation, since the sub-calls are recursive calls, the function actually returns inside itself, just after the recursive call.

We will now change the function's base code to :

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

The two additional `push` instructions here make sure that the `rbp` register is saved and restore at each function call.
This is handled in the called function directly, which is convenient for readability as these instructions would always be the at the beginning and at the end the our functions.

We can now add the first instructions of the functions (indicated by comments in the previous snippet) :

{% highlight nasm linenos %}
    push rbp
    mov rbp, rsp

    sub rsp, 16
    ; rbp-8 : base (8 bytes)
    ; rbp-16 : exponent (8 bytes)

    ; store the local variables
    mov rax, [rbp+24]
    mov [rbp-8], rax
    mov rax, [rbp+16]
    mov [rbp-16], rax
{% endhighlight %}

Note that since the stack now contains one more 8-byte value, the addresses of the parameters, relative to `rbp`, should be changed by subtracting 8 additional bytes hence the modification. 

And here is how the function is exited :

{% highlight nasm linenos %}
    mov rsp, rbp
    pop rbp
    ret
{% endhighlight %}

#### Memory usage with recursion



## What's next ?


