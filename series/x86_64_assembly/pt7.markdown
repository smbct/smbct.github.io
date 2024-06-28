---
title:  Assembly x86 programming 101 &#58 part 6, ascii Mandelbrot
author: smbct
date:   2024-06-28 10:00:00 +0200
categories: low-level programming assembly
comments: true
layout: series_article
back_page: headline.md
---

Although we already covered numerous basics in x86 assembly so far, one thing that has not been discussed yet is the use of **floating point** computation : namely numbers with a **decimal** part.
As we are used to working with computers, we absolutely love integers 🥰! No rounding, no loss of precision, no [absorption problems](https://softwareengineering.stackexchange.com/questions/310173/floating-point-absorption-phenomena-and-ulp), etc..
Unfortunately, non-integer values arise in many real world problems hence it is rather useful to know a little bit about them.

In this post, we will write a program that draws an ascii version of the famous Mandelbrot set.
The Mandelbrot set is a famous fractal that has been intensively rendered on computes in all of its shapes : with colors, in 3d, etc..
Its computation however relies on some complex numbers arithmetic, it is hence necessary to manipulate floating point numbers.
We will see here how to draw an ascii version of this fractal by relying on some basic floating point numbers operations. 

## Floating point operations in x86 assembly

#### Vector registers

[vector registers](https://en.wikipedia.org/wiki/Streaming_SIMD_Extensions)

#### Comparison between floating point values

In GDB, to look at the `eflags` register : `p $eflags`. Discuss flags after compare instruction.

[which jump operation to use ?](https://stackoverflow.com/questions/7057501/x86-assembler-floating-point-compare)

Another post on [comparisons](https://stackoverflow.com/questions/7057501/x86-assembler-floating-point-compare) with floating point arithmetic. 

[another ressource](http://www.ray.masmcode.com/tutorial/fpuchap7.htm#fcomex)

## The famous Mandelbrot set

[algorithms and variants page](https://en.wikipedia.org/wiki/Plotting_algorithms_for_the_Mandelbrot_set)

## What's next ?