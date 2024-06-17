---
title:  Assembly x86 programming 101 &#58 part 5, printing arrays
author: smbct
date:   2024-05-21 10:00:00 +0200
categories: low-level programming assembly
comments: true
layout: series_article
back_page: headline.md
---

The last post taught us how to write functions in x68 assembly.
The interesting thing is that now we can interact with compiled libraries from other languages.
This will allow us to perform higher level tasks such as opening windows, networking, etc...
In this ost, we will start by looking at how to **call C functions**.
We will first see how to use the `printf` function in order to print variables.
This will let us print the content of an integer array in assembly.
We will also see how to create a function that can be called from a C program !


## Calling the C `printf` functions

Although we previously had the freedom to decide our own convention about parameters and return value, calling a function from an external library requires us to follow the library's convention.
We will see how to do so by calling the `printf` function from the C standard library. 

#### Using the C standard lib in our program

Our program's compilation will now change a bit.
Previously, we created executables that did not rely on any external library.
We will now need to link the standard library from C to be able to use `printf`. 

Adding the C standard library to our program's is simply done by removing the option `-nostdlib` when linking the executable with gcc, as it is actually linked by default.
However, the C library adds a lot more features to our program : it defines the `_start` function (our program's entry point) by itself.
For this reason, our program's first function will now be the classical `main` function.
The "hello world" code becomes :

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

There are two changes regarding the previous "hello_world" program : our function is now named `main` and it will be automatically be called by the `_start` function defined in the C library ; and since it is now a called function, the `ret` instruction is necessary at its end.
Also note that contrarily to what we saw previously, since our function does not use the stack we do not need to save and restore the `rsp` and `rbp` registers here.

The compilation is done as previously, except for the second command that becomes `gcc -static my_program.o -o my_program` (the `-nostdlib` option has been removed).
You can verify that the program's output is actually *42*, which is indeed `main`'s return value : `./my_program ; echo $?`.
Note that if you try to compile any of our previous programs without the `-nostdlib` option, this would not work as the `_start` function would be defined twice.
If you want a more precise idea of the additional material added by the standard libc, you might check this [interesting article](http://www.muppetlabs.com/~breadbox/software/tiny/teensy.html)!

#### Passing parameters to `printf`

Now that our code's backbone is in place, let's call the `printf` function.
Since the standard libc (C standard library) is now linked to our program, the `printf` symbol will be known by the linker.
Now the important thing is to see how to pass parameters to the `printf` functions.
That part is tricky : the (calling) convention used by Linux is called the **AMD64 System V ABI**.

Documentation is sometimes hard to find and I personally learned this from this [stackoverflow post](https://stackoverflow.com/questions/38335212/calling-printf-in-x86-64-using-gnu-assembler).
You can see that registers are used for arguments and return values that are not *composed* data types.
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

{% highlight nasm linenos %}
    xor eax, eax ; al is set to 0
    lea rdi, [hello_world] ; 1st argument passed to register
    call printf
{% endhighlight %}

If you try this, you would normally see a segmentation fault :(

#### One more requirement : stack pointer alignment

By further reading the stackoverflow post that I linked above, we learn that there is one more condition that needs to be met when calling C functions in the **AMD64 System V ABI** convention : the stack pointer must be aligned to 16 bytes, meaning its value must be a multiple of 16.

We can run gdb on your program and check the value of `rsp` after entering the main function by adding a breakpoint in debug mode.
In my case, the value of `rsp` is *0x7fffffffdbb8*.
We then compute *print 0x7fffffffdbb8 % 0x10* (where *0x10* is 16 in hexadecimal).
The result should be *8* : hence we see that there is an 8 bytes misalignment of the `rsp` value.

This misalignment comes from the fact that the `call` instruction that actually triggers the execution of `main` pushes the return address (8 bytes) to the stack, as we saw in the last part.
As a result the stack pointer is then misaligned by 8 bytes.
This can be fixed by simply re-aligning the stack pointer before starting the call, which can be done by "allocating" 8 additional bytes (unused) :

{% highlight nasm linenos %}
    sub rsp, 8

    xor eax, eax ; al is set to 0
    lea rdi, [hello_world] ; 1st argument passed to register
    call printf

    add rsp, 8
{% endhighlight %}

This should now work as expected!
Note that since our string is zero terminated (it ends by '\0', as defined by the .asci**z** type with the gnu assembler), it is not necessary to specify its length to `printf`. 

In our following codes, we will now make sure the stack pointer is well aligned before starting any operation in our functions.
A proper place to do it is when the local variables are allocated, as we saw in the previous post of the series.
This operation can also be done automatically by subtracting the offset : `rsp` modulo *8*, which can be performed by "anding" *15* to the value of `rsp`: `and rsp, 15` (recall that a modulo operation on a power of two can be obtained by directly looking at the right number of bits in the binary representation).

#### Printing integers with printf

Calling a C function was not easy!
The good thing is now it will be much simpler to bring concrete features to our programs.
Let's start by accomplishing a task that was previously much harder : printing integer values!

To print a value in the terminal, we can use the `printf` function with its formatting ability : the value would be passed as a parameter, as well as a string indicating how to format it.
We can have a look at the [documentation](https://cplusplus.com/reference/cstdio/printf/) of `printf` to choose the correct formatter.
In C, this would look like :
{% highlight C linenos %}
int x = 42;
printf("%i\n", x);
{% endhighlight %}

To do so in assembly, we start by defining the formatter as a constant string in our program (this does not change) :

{% highlight nasm linenos %}
integer_formatter:
    .asciz "integer value: %i\n"
{% endhighlight %}

The  "%i" formatter is used to print a decimal integer.
We then call `printf` and pass this string as well as the register value.
For this, we will use the `rsi` register, as it is specified to pass the second argument in the calling convention.

{% highlight nasm linenos %}
    xor eax, eax
    lea rdi, [integer_formatter]
    mov rsi, 42
    call printf
{% endhighlight %}

The program should now print: "integer value: 42".
This adds a lot more possibilities to interact with the user!




## Printing an array

Now that we know how to call printf, we will create a function that will be useful for the future post : printing an array!
We will start by defining a constant array in the program's memory :

{% highlight nasm linenos %}
my_array:
    .byte 5, 12, 42, 8, 1, 3, 7, 25, 14
my_array_length:
    .word 9
{% endhighlight %}

In this case, the array elements will be stored as bytes (8 bits long, coding integer values between -128 and 127).
We also define a constant indicating its size as a word (2 bytes).

We may now define our strings constants to be used by `printf` :

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

We will need 2 local variables in our `print_array` function : an 8 bytes variable to store the array address and a 2 bytes variable to store an index for iterating over the array.
This results in 10 bytes allocated on the stack.
With the 8 bytes already present to store the return address of the main function, the stack pointer would be aligned to 18 bytes.
Hence, 6 additional bytes are necessary to reach 32 bytes, for a 16 bytes alignment (*32=2x16*) which gives a total of 24 bytes to allocate. 

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

Accessing the values of the array is performed by increasing the array address.
Indeed, the address accessed through the label `my_array` actually points toward the first value of the array in the program's memory.
Since the values are contiguous in memory, and since they are coded on 1 byte each, accessing the next value is performed by increasing the address by one (recall that the addresses are expressed as bytes).

Our main loop is as follows :

{% highlight nasm linenos %}
    .L_for_loop_writing:
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
        jne for_loop_writing ; test if all elements have been printed
{% endhighlight %}

You may notice that two steps are necessary to load a value from the array before calling `printf` : the address of the array must first be retrieved from the stack and then, the `mov` instruction is used to load the value coded at the address.
Note that the 1-byte register `sil` is used here to store the array values since they are encoded as single bytes.
These two steps cannot be concatenated into a single one since an instruction can have a memory reference in only one of its operand.

After the call to `printf`, the array index is increased as well as the array address.
Note the different prefixes as these two values are not coded on the same number of bytes.
Then, the index is compared to the array size, which is performed on two steps for the reason evoked just before.

Out `printing_array` can be completed by printing a new line and then restoring the stack registers and exiting :

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

The next step for this code would be to give the array address and its size as parameters to the function : for instance using `rdi` and `si` (`rsi`) to pass the array pointer and the array length respectively.
I will leave it as an exercise and put the solution in the code repository.



## Calling a custom C function

We will now see how we can write our own C functions and call them from our assembly code.
This can be useful for instance add functionalities to our assembly programs from external libraries.

We will start by writing two C functions to manipulate arrays.
The first one will initialize the array elements from the value *0* to "*length -1*".
The second function will print each element of the array, as we did previously in assembly.

{% highlight C linenos %}
void init_array_c(char* array, short length) {
    for(unsigned int i = 0; i < length; i ++) {
        array[i] = i;
    }
}

void print_array_c(char* array, short length) {
    for(unsigned int i = 0; i < length; i ++) {
        printf("%d ", array[i]);
    }
    printf("\n");
}
{% endhighlight %}

In terms of calling convention, we have already seen that C functions use registers to pass some parameters.
Hence we can simply follow the register order given earlier in this post.
In this code, we choose the types `char` and `short` to store our data.
That is because in our assembly program, our array elements will be encoded on 1 byte each elements and its size will be encoded in two bytes.
The size of the C variable types can be found [online](https://en.wikipedia.org/wiki/C_data_types).

We can then write our main function in assembly :

{% highlight nasm linenos %}
.global main
.intel_syntax noprefix

main:

    push rbp
    mov rbp, rsp

    sub sp, my_array_length
    
    ; automatic 16 bytes alignement of rsp    
    mov rax, rsp ; temporary storing the stack pointer
    and rax, 15 ; computing rsp modulo 16 to compute the mis-alignement
    sub rsp, rax ; subtracting byte to align rsp

    ; init an array
    mov rdi, rbp
    sub di, my_array_length
    mov si, my_array_length
    call init_array_c

    ; printing an array
    mov rdi, rbp
    sub di, my_array_length
    mov si, my_array_length
    call print_array_c

    mov rsp, rbp
    pop rbp

    ; return
    mov rax, 0
    ret

my_array_length:
    .word 10
{% endhighlight %}

In this assembly code, we allocate an array on the stack and then we call the two C functions successively by passing them the array address and its length.
Regarding the interoperability between our the C functions and our assembly code, there is no additional definition required to make it work
Indeed, when linking the object files of both codes, the linker will know the name of the functions (symbols) and will create a combined executable file.

#### Dynamic allocation on the stack 

One particularity of our program is that the array that is sent to the C function is allocated on the stack.
This in in fact the easiest way to allocate memory.
Thus, at the beginning of our program, the stack pointer is decreased accordingly to the length of the array.
You may realize that this kind of operation is actually not allowed in C : arrays that are allocated during the execution of the program must have their size known in advance.
Although we actually know the size in advance in our case, it could be possible to allocate the array depending on a variable given.   

One problem that arises from this design choice is that it is no longer possible to know in advance how to modify the `rsp` pointer to verify the *16* bytes alignment discussed previously.
This step can however be executed automatically as it is shown just after the stack allocation.
This code first computes *`rsp` modulo 16* and the **extra bytes** are then subtracted (as the stack grows downward) to achieve the alignement.

#### Compilation and linking

To compile the program, we can first use the command `as assembly_code.s -o assembly_code.o` for the assembly code, then the command `gcc c_code.c -c -o c_code.o` for the C code.
We can then create the final executable with the command `gcc -static assembly_code.o c_code.o -o my_program`, which should produce a working program!
You can test the presence of the symbols associated with our C functions in the executable : `strings my_program | grep init_array_c` should now return the name of the initialization function, proving that the function is present in the final executable.

#### Shuffling an array in C


{% highlight C linenos %}
void shuffle_array_c(char* array, short length) {

    for(unsigned int i = 0; i < 10; i ++) {
        int i = rand()%length;
        int j = rand()%length;

        char temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }

}
{% endhighlight %}

{% highlight nasm linenos %}
; init the random seed
mov edi, 42
call srand

; shuffle the array
mov rdi, rbp
sub di, my_array_length
mov si, my_array_length
call shuffle_array_c

; printing an array
mov rdi, rbp
sub di, my_array_length
mov si, my_array_length
call print_array_c
{% endhighlight %}

#### Comparison with a C function

{% highlight C linenos %}
int test_functions_c() {

    srand(42);

    char array[10];

    init_array_c(array, 10);

    print_array_c(array, 10);

    shuffle_array_c(array, 10);

    print_array_c(array, 10);

}
{% endhighlight %}

## Using our code in a C function

Our last part in this series is to go the other way around : calling an assembly function from a C program.
Once again, we will apply the calling convention for C programs.

We will start by writing an assembly function that simply displays "Hello, World!" thanks to a system call :

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

We can now write C `main` to call this function.
The only extra step here consists in defining the function before calling it.
Without the definition, the compiler would complain.

{% highlight C linenos %}
void _hello_world_assembly();

int main(int argc, char* argv) {
    // call an assembly function
    _hello_world_assembly();
}
{% endhighlight %}

## What's next ?


