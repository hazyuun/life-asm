# life-asm
Conway's game of life in x86 assembly (NASM syntax)
<br />
<p align="center">
<img src="https://github.com/A-Rain-Lover/life-asm/blob/master/screenshot.gif" />
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

# Issues
* Edge cells are not updated (intentionnally, I might fix it later)
