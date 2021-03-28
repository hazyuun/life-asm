# life-asm
Conway's game of life in x86 assembly (NASM syntax)
<br />
<p align="center">
<img src="https://github.com/hazyuun/life-asm/blob/master/screenshot.gif" />
</p>

# Compiling
clone the repo and compile using nasm
```bash
nasm main.asm -o main.exe
```
* Note : by default, nasm compiles to a flat raw binary format (which is what we need now) I don't know if this might change in the future, so I think compiling with :
```bash 
nasm main.asm -o main.exe -f bin
```
is more reliable.

# Executing
Execute this in a 16-bit DOS environnement (You can use DOSBox) 
## Warning !	
Use DOSBOX (or some alternative), do __NOT__ execute this directly in 32-bit or 64-bit Windows or MacOS or Linux or any other 32-bit or 64-bit OS (Your OS may reject it anyways but don't try it for safety sake !)	
because only God knows what those opcodes do in a modern CPU, it may be harmful ! I am not responsible for your acts !

# Issues
* Edge cells are not updated (intentionnally, I might fix it later)
