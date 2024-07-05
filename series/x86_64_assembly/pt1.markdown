---
title:  Assembly x86 programming 101 &#58 chapter 1, Hello, world!
author: smbct
date:   2024-05-03 10:00:00 +0200
categories: low-level programming assembly
comments: true
layout: series_article
series: x86_64_assembly
back_page: headline.md
---

The last few months, I developed an increasing interest in low level programming and especially in assembly programming.
What seemed for a long time an obscure and inaccessible hobby to me has become a fascinating and engaging topic as I started digging.
From someone with a computer science background, learning assembly programming feels like exploring the fundamentals of computing and looking back at the history of modern computers.
Learning to code in assembly is a way to become better at understanding how computers and programs work and how they can be secured and optimized.

This blog post is the first of a series where I would like to introduce the basics of assembly.
I plan to cover fundamental notions as well as practical development with higher level libraries.
My goal is to make us feel that it is actually possible to develop modern applications in assembly, although it is much slower and much less convient than using any modern language.
I should however warn you that I am still very new to the topic and I will probably make some imprecisions and mistakes along the way.
I will still focus on bringing enough content so that we become autonomous at proof reading and learning more advanced notions.
I will use Linux tools in theses posts but this could probably be adapted to any other operating system.
Some notions of "relatively" low level languages such as C would be helpful (but not mandatory) as I will mention mechanisms like the program's stack. 

This first post will give some insights about assembly languages and we will then see how to write a first hello world program.
Among the ressources that I used for this series, I can recommend the great Youtube channel [Low Level Learning](https://www.youtube.com/@LowLevelLearning), that offers content about low level programming and security.
They made few basic [videos](https://www.youtube.com/watch?v=6S5KRJv-7RU) about assembly that hooked my motivation.
I also really enjoyed playing the video "game" [Human Resource Machine](https://en.wikipedia.org/wiki/Human_Resource_Machine) that proposes to solve several computing tasks by writing programs in a language similar to assembly (although I admit this is not quite the typical game to enjoy at night).



## Programming with... Assembly?

Assembly may be a famous word in the wold of computing, it is still worth researching a little about this term.
[Wikipedia](https://en.wikipedia.org/wiki/Assembly_language) says that assembly actually refers to programming languages that are very close to the real processor's instructions.
Assembly languages allow us to program by almost directly using the processor's instruction, it is a way to program computers at a very low level.

#### Architecture specific programming

A given assembly language is thus associated to a specific computer architecture such as x86 (desktop and portable computers) or ARM (processors found in smartphones and other mobile devices).
A program made with an x86 assembly language will be then unable to run on ARM devices for instance.
In this series, we will only look at **x86-64 assembly** since x86-64, the 64 bits version of x86 processors, is the most common architecture of everyone's personal computers.
However, learning assembly for other platforms is also possible by using emulators.
Architectures other than x86 are also quite interesting to study since ARM, for instance, has recently become more present in personal computers with the [apple silicons](https://en.wikipedia.org/wiki/Apple_silicon) and the [Microsoft's copilot+ pc](https://www.microsoft.com/fr-fr/windows/copilot-plus-pcs) and is also used in Raspberry Pi boards and Nintendo switch consoles.
MIPS is another interesting architecture as it is used in several old generation consoles such as the Nintendo 64 and the first Playstation.

[![The Raspberry Pi model 5](/assets/assembly_series/23551-raspberry-pi-5.jpg)](https://fr.wikipedia.org/wiki/Raspberry_Pi#/media/Fichier:23551-raspberry-pi-5.jpg)
<div style="font-size:0.7em; margin-top:-15px; margin-bottom:1rem;">The Raspberry Pi model 5, embedding an ARM processor.</div>


An important note is that while writing assembly really feels like having a precise control on our computer's processor, modern processors are extremely complex and many hidden operations are still happening under the hood, which prevents us from fully apprehending it.
Learning assembly remains an important step to better understand how computers work.

#### Compilation of assembly programs?

When it comes to programming languages, one may often distinguish compiled langages such as C, C++, Rust, etc..  from interpreted languages like Python or Lua.
Compilation may be described as the process of translating a program's code into machine code, an operation after which the original source code is gone.
Nonetheless, the machine code that is produced is actually nothing more than one of our architecture's specific assembly language.

This means that assembly code does not need to be compiled : it is already in the form of processor's instructions.
It is in fact possible to read the assembly code from any compiled program by *disassembling* it.
However, you should not expect to recover a clean, abstract and commented version of the code with variable names and so on, since most information is lost during compilation.
The ability to read compiled program's code remains a good motivation to learn assembly.
Without evoking potential illegal action on proprietary softwares, manipulating binary programs can be used for instance to [patch](https://www.youtube.com/watch?v=cwBoUuy4nGc) old and unmaintained softwares that would no longer properly work on recent systems. 

Obviously, programming in assembly is performed by writing instructions in a text format, and not by adding an obscure succession of zeroes and ones that would encode the operations in binary.
Producing an executable program from the assembly code thus requires a translation from the text to a binary form.
This step is performed by the *assembler*, a program that creates the actual object code in a proper format.
For instance, Linux systems use the [elf format](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format) for their executable programs.


## A first assembly program

We will start assembly programming by writing a simple program that performs the most basic operations.
Our tools here will be any text editor supporting x86 assembly syntax, an assembler of x86 assembly code and a linker that produces the final executable.
Visual Studio Code can be used with the "x86 and x86_64 Assembly" extension for the writing part.
We will use the **".s"** extension for our code files.
To translate our code into binary, we will then use the [GNU Assembler](https://www.gnu.org/software/binutils/) which is the assembler used by the [GCC](https://gcc.gnu.org/) compiler.
GCC will also be our linker in order to produce the executable file (GCC actually calls "ld" for linking).
Last, but not least, we will rely on the [GNU debugger (GDB)](https://sourceware.org/gdb/) to inspect and debug our programs.

Let's write our first lines of x86 assembly :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
.intel_syntax noprefix
.global _start

_start:

    ; do nothing

{% endhighlight %}

The first line of the code just specifies the use of the intel syntax with some noprefix mode, a syntax that is more readable for beginners.
The second line makes sure that the symbol `_start` (our function's name) will be visible from outside the program.
In general, symbols such as local function names would not be exported when releasing programs as they are not necessary from the outside.
On the contrary, function names that are part of a library's interface would be made visible to the users.
`_start` is in fact the name of the program's entry point (first line to be executed), which is why this symbol must always be known from the outside.

Then the definition of our `_start` function begins with its label followed by a colon (:).
For now the function does nothing, as indicated with a comment.

> 📝 Note that the semicolon ";" symbol for comments seems to be unsupported by the GNU assembler.
> I will use it in my examples for the purpose of syntax highlighting but it should be replaced with a hash "#" symbol to work properly with the "as" command.

> 📝 If you use vscode with the extension I mentioned before and if you want to modify the shortcut comment symbol from ";" to "#", you can edit the file "language-configuration.json". 
> In ubuntu, this configuration file would be located in the ~/.vscode/extensions/[...]x86[...] directory (the extension folder should be the only one containing the "x86" name)

#### Compilation and linking

I will use the term *compilation* to designate the process of making an executable file from the assembly code even though this term is more adapted to languages like C.
To compile this piece of code, we will first execute the `as` command that produces an object file :

`as hello_world.s -o hello_world.o`

You may recognize the .o extension that is also used as temporary compiled files when compiling C language.
You may run command `file hello_world.o` on the output to verify that the produced file is a binary code on the "elf" format.

Now we can use GCC to produce an actual executable :

`gcc hello_world.o -o hello_world -static -nostdlib`

Two important options are passed to gcc : `-static` to produce a position-dependant executable and `-nostdlib` which prevent from using the C standard library in our program.
These two options are required for now but we will see in another post how to do differently.

When we try to execute this program it results into a *segmentation fault*.
This happens because our program does not actually know how to exit.
We will add the following lines to solve the issue :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
_start:

    ; exiting
    mov rax, 60
    mov rdi, 42
    syscall
{% endhighlight %}

The program should now terminate properly.
In assembly, even simple things such as exiting a program have to be done manually!
This step is performed by a "system call", triggered by the last instruction.
[System calls](https://www.geeksforgeeks.org/introduction-of-system-call/) are a way for programs to interact with the operating system. 
The two instructions preceding the call are used to specify parameters through the two registers `rax` and `rdi`.
The first line specify the type of system call to perform, which is sys_exit here ([tables](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/) of Linux system calls can be found online).
The second line sets the return value of the program, similarly to ``return 42;`` at the end of a C program.

After compiling the program again the execution does not produce a segmentation fault anymore.
This time we can run it and check its return value in bash :
```./hello_world ; echo $?``` which outputs 42!


#### Registers

We have just seen the use of registers to pass parameters to the system call.
Registers are ultra fast memory spots in the processor that are used as **temporary** variables to perform the program's operations.
This means that these spots will not serve as storing our data, as registers may be used to successively perform operations on unrelated data.
There are a limited number of registers in the x86-64 architecture and all registers have a name and a more or less specified use.
A list of registers can be found online, [here](https://wiki.osdev.org/CPU_Registers_x86-64), [here](https://en.wikibooks.org/wiki/X86_Assembly/X86_Architecture) and also [there](https://flint.cs.yale.edu/cs421/papers/x86-asm/asm.html) for instance. 

It is important to note that registers have various sizes, which is expressed in bits or bytes (recall that 1 byte equals 8 bits).
In the x86-64 architecture, registers can be up to 64 bits (8 bytes).
Once more, tables can be found online with information on [registers sizes](https://en.wikibooks.org/wiki/X86_Assembly/X86_Architecture).


## Hello world

Starting from the previous code, we can now make a program that writes the famous "hello world" in the terminal.
To do so, we will use the `sys_write` system call.
From the link [on linux system calls](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/), we see that invoking a "sys_write" system call is performed by setting the `rax` register to `1`.
The `rdi` register specifies the file descriptor, which will be set to `1` to write to the standard output.
There are two other parameters passed by registers : `rsi`, the memory address of our "hello world" string and ``rdx``, the length of the string.
We can define the string as a constant in our program thanks to a new symbol :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
hello_world:
    .asciz "Hello, World!\n"
{% endhighlight %}

By doing so, the string will be hard coded into the executable and the label `hello_world` will allow us to directly refer to it (more especially to its address) in our code.
You can test the command `strings hello_world` on the compiled program to verify that the string is indeed present in the executable.
We can now complete our code to produce the desired output :

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
    mov rdi, 42
    syscall

hello_world:
    .asciz "Hello, World!\n"
{% endhighlight %}

That's it! We just created the famous hello world program in x86-64 assembly.

## Inspecting our program with gdb

It might strike us that in assembly, simple operations such as writing to the standard output are already difficult to perform and take several lines of code.
This makes us realize all the computations performed in background when using higher level programming languages.
In C, printing the value of a variable, which is essential for debugging, would be as easy as simply calling the "printf" function and passing the variable to it.
Here, a sys_write only handles a string and there are no predefined functions to output the value of a register.

Instead of coding our own functions to do it, we can run the GNU debugger for now to inspect our program.
Let's add the following lines at the beginning of our function first :

<div class="code_frame"> Assembly x86-64</div>
{% highlight nasm linenos %}
_start:

    mov rax, 30
    add rax, 12
    debug:
{% endhighlight %}

You may guess that the first new line assigns the value 30 to the `rax` register and the second one adds 12 to it.
We will verify this behavior with GDB by adding a *breakpoint*.
*Breakpoints* can be used to stop the program during its execution at a specific location.
Here instead of relying on line numbers, we can tell GDB to stop at a given symbol, which will be "debug" in our case.

We can recompile the program and run GDB by attaching the program to it : `gdb hello_world`.
Then, the breakpoint can be added by referring to the new "debug" symbol : `b debug`.
We now execute the program from the beginning with `start`.
Normally, the program would stop after executing the instruction preceding our label, indicating "Breakpoint 1".
From this point, we can verify the register's value with : `print $rax`, which produces the intended output "$1 = 42".
We can also obtain information about other registers with the command `info registers`. 

Great! GDB allows us to debug our program in a much simpler way than having to manually convert our numerical registers into character strings.
I find the use of symbols as in-code labels very convenient for debugging.
For instance you may define several debugging symbols like `debug1`, `debug2`, ... and set breakpoints to them in GDB such that the program execution would stop successively at these different points in the program.
GDB will be of great use for debugging as we practice assembly so it is worth covering it.

#### Edit from 2024-06-05 ⚠️

This is an edit to the previous statement about using symbols for debugging purposes.
As I am learning through the making of these posts, I realized that using symbols for debugging actually seems not to be good practice as it may disturb GDB for instance.
It seems that exported symbols must be only used for function definitions.
Alternatively, we can inspect our program by adding debugging information during the compilation process with the *-g* option :  `as -g hello_world.s -o hello_world.o`

After that, breakpoints can be added by directly referencing a line number : `b hello_world.s:11` where 11 is the line that follows the instruction `add rax, 12` in my code.
This would give some higher level information about the code execution :

<div class="code_frame"> GDB</div>
{% highlight plaintext linenos %}
(gdb) breakpoint hello_world.s:11
Breakpoint 1 at 0x40100b: file hello_world.s, line 12.
(gdb) run
Breakpoint 1, _start () at hello_world.s:12
12	    mov rax, 1
(gdb) print $rax
$1 = 42
{% endhighlight %}

Here gdb directly indicates the line that follows the breakpoint.
As it has stopped at the expected place, we can now check the value of the rax register and verify that the computation was executed successfully.  

## What's next ?

Although writing the hello world is a good success for such a low level language, our capabilities remain limited for now.
In the next post, we will se how to add control flow to our programs so that we can write conditionals and loops.
In the mean time, you will find the hello world code from this post at the [following link](https://github.com/smbct/x86-64_101_linux/tree/main/pt1_hello_world).
Feel free to modify it and experiment with registers and simple operations such as `mov`, `add`, `and`, etc...
Tutorials and references can usually be found online and I invite you to use GDB (and its documentation) to understand the program. 

