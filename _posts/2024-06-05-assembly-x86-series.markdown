---
title:  A series on x86 assembly programming
author: smbct
date:   2024-06-05 10:00:00 +0200
categories: programming low-level
comments: true
layout: post
tags: assembly x86 programming low-level
lang: en
back_page: /index.html
---

This is an announce that I am currently working on a series of posts about assembly programming.
For this occasion, I created the **series** section in the blog 📑 : a place dedicated to articles that intend to deeply explore 🔎 some specific topics with advanced explanations and hands-on examples.

In my first series, I will hence explore assembly programming : namely programming directly with the processors' instruction sets 🧑‍💻.
x86 being the most common processor architecture on desktop and laptop computers 💻, I will solely focus on this platform.
The idea is to progress step by step toward the goal of being able to implement practical programs directly in assembly.

My interest in assembly programming and more generally in low level programming comes from the impression that modern softwares have a very intensive use of resources for many avoidable tasks ⚡ (as a rebound effect due to the increase of computing power).
The idea is to understand more deeply how softwares work and apprehend their use of computing resources.
I am also concerned by planned obsolescence that could come from softwares becoming unusable after system upgrade for instance.
For this reason, I am also interested in the idea of retro-compatibility and the possibility to patch softwares without any source code by manipulating its assembly instructions 💾.
For instance, see this [example](https://www.youtube.com/watch?v=eQOOx4mmY6I) about patching an old game to make it work on modern operating systems.
Slowly, theses different concerns got me into the topic of assembly and more generally low level programming.

This series will be written as I learn on the topic, with potential mistakes and imprecisions made along the way 🤐.
I take some time to write about it as a ways to compile knowledge that can be sometimes difficult to find on the web, and also to rise the interest in this approach.
The series would be more adapted to someone already familiar with programming, preferably with a low level language like C.

The first few posts of this series are available in this [page](/series/x86_64_assembly/headline).
I will also update the links directly here :

{% for p in site.pages %}
{% if p.name == "headline.md" and p.dir == "/series/x86_64_assembly/" %}
    {% assign target = p %}
{% endif %}
{% endfor %}

{{ target.content }}

Enjoy!

