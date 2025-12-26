# [Fareed R](./index.md)


# FPGA - Zero to Calculator

I have been curiuos about digital electronics for a long time and have attempted to learn the subject making significant progress when I watched [Building an 8-bit breadboard computer!](https://www.youtube.com/playlist?list=PLowKtXNTBypGqImE405J2565dvjafglHU) by [Ben Eater](https://www.youtube.com/@BenEater) on YouTube quite a long time ago. However, I never got myself to gather the components to actually build one myself. Being a person who learns by doing and not just watching, this left me without a true grasp of fundamental concepts of digital electronics.

I knew something called FPGAs and CPLDs existed since working on an advanced DVB settop box around 2005 where it was innovatively used to communicate between two processors. However, I was never truly curious about it thinking that it was part of some dark art that needed brilliant brains to comprehend. Until, a few months ago (November 2025), by chance, I stumbled upon the most beautiful looking educational board on FB Marketplace called "[Altera DE1](https://www.terasic.com.tw/cgi-bin/page/archive.pl?No=83)" which the owner parted with for A$35.

![image](https://www.terasic.com.tw/attachment/archive/83/image/image_39_thumb.jpg)
*The Altera DE1*

When I switched it on, it ran the factory demo with running lights and cyclic hex numbers on the seven-segment displays. After researching a little, I realized that it was a phased-out board but had immense educational value with the ability to host a RISC soft-core processor called [Nios II](https://en.wikipedia.org/wiki/Nios_II). The amount of 'hardware' that could be crammed into this board opened a plethora of possibilities in my mind. It was a mysterious concoction that sparked immense cuirosity and triggered quite a compulsion to get something useful working on the board.

I downloaded "Quartus II v13.1" which was releaed on 2013 and set about making it work on a modern Linux Mint machine. Surprisingly, with slight [tweaks by zkrx](https://zkre.xyz/posts/quartus/), it now runs like a charm crunching away synthesis, analysis, fitting etc. required to compile VHDL code into something that can be loaded onto the FPGA and turn the board into whatever custom machine one can imageine. Of course, you can get an upgraded FPGA which would also most probably have a hard-processing system which you can communicate with the FPGA part of the machine. However, the DE1 is sufficient for my current needs so I don't see the point of a ugrading yet.

Starting with knowing absolutely nothing about FPGAs, in about a months time, I was able to grasp the very basics and make a small 3 digit 2-s compliment decimal integer calculator that demonstrates some of the fundamental concepts I encountered. It may not look like much but it got me ready for the next step which will be an 8-digit fixed-point calculator which I hope to soon publish.

I have published the source code of this journey on GitHub in a public repository called [fareed1983/fpga-zero-to-calculator](https://github.com/fareed1983/fpga-zero-to-calculator).


# What is an FPGA





# [< Back to Fareed R](./index.md)
