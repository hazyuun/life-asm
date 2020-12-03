;
; Conway's game of life in x86 assembly (NASM syntax)
;

org 0x100

jmp .main

ROW_COUNT equ 28
COL_COUNT equ 30

GRID_SIZE equ 840

GRID_DATA db GRID_SIZE dup (0)
GRID_TEMP db GRID_SIZE dup (0)


.main:

; Switch to 0x13 mode (graphics mode)
mov ax, 0x13
int 0x10

; Initial setup (A hardcoded glider)
mov ax, 4
mov bx, 4
call .set_cell

mov ax, 4
mov bx, 5
call .set_cell

mov ax, 4
mov bx, 6
call .set_cell

mov ax, 2
mov bx, 5
call .set_cell

mov ax, 3
mov bx, 6
call .set_cell


.game_loop:

; Draw the grid
call .cls
mov bx, 0
.cells_row_loop:
	mov ax, 0
	.cells_col_loop:
		call .get_cell
		cmp byte [ecx], 1
		jne .dead_cell
		call .put_alive_cell
		.dead_cell:
		inc ax
		cmp ax, ROW_COUNT
		jnz .cells_col_loop
	inc bx
	cmp bx, COL_COUNT
	jnz .cells_row_loop
		

; Update the grid
call .clear_temp_grid
mov bx, 0
.update_cells_row_loop:
	mov ax, 0
	.update_cells_col_loop:
		call .get_cell
		cmp byte [ecx], 1
		jnz .dead
		
		.alive:
		call .should_survive
		jz .alive_in_next_gen
		jmp .continue
		
		.dead:
		call .should_resurrect
		jz .alive_in_next_gen
		jmp .continue
		
		.alive_in_next_gen:
		call .set_temp_cell
		
		.continue:
		inc ax
		cmp ax, ROW_COUNT
		jnz .update_cells_col_loop
	inc bx
	cmp bx, COL_COUNT
	jnz .update_cells_row_loop
call .update_grid
	

; Exits if a key is pressed	
mov ah, 0xb
int 0x21
cmp al, 0x0
je .game_loop

.exit:
mov ah, 0x4c
int 21h


; Put the address of the cell (ax, bx) in ecx
.get_cell:
	push bx
	push ax
	
	mov ax, bx
	imul ax, ROW_COUNT
	mov bx, ax
	pop ax
	add bx, ax
	
	mov ecx, GRID_DATA
	push bx
	mov ebx, 0
	pop bx
	add ecx, ebx
	
	pop bx
	ret

; Set the state of the cell (ax, bx) to "alive"
.set_cell:
	push ecx
	call .get_cell
	mov byte [ecx], 1
	pop ecx
	ret

; Set the state of the cell (ax, bx) to "dead"
.reset_cell:
	push ecx
	call .get_cell
	mov byte [ecx], 0
	pop ecx
	ret	

.get_temp_cell:
	push bx
	push ax
	mov ax, bx
	imul ax, ROW_COUNT
	mov bx, ax
	pop ax
	add bx, ax
	mov ecx, GRID_TEMP
	push bx
	mov ebx, 0
	pop bx
	add ecx, ebx
	pop bx
	ret
	
.set_temp_cell:
	push ecx
	call .get_temp_cell
	mov byte [ecx], 1
	pop ecx
	ret

.reset_temp_cell:
	push ecx
	call .get_temp_cell
	mov byte [ecx], 0
	pop ecx
	ret	

.clear_temp_grid:
	push cx
	push si
	mov si, GRID_TEMP
	mov cx, GRID_SIZE
	.clear_temp_loop:
		mov byte [si], 0
		inc si
		dec cx
		jnz .clear_temp_loop	
	pop si
	pop cx
	ret
	
.update_grid:
	push si
	push di
	push cx
	push ax
	
	mov si, GRID_TEMP
	mov di, GRID_DATA
	mov cx, GRID_SIZE
	.update_grid_loop:
		mov al, byte [si]
		mov byte [di], al
		inc si
		inc di
		dec cx
		jnz .update_grid_loop
			
	pop ax
	pop cx
	pop di
	pop si
	ret
	
; Counts neighbors of the cell in (ax, bx)
; Result goes in dl
.count_neighbors:
	cmp ax, 0
	je .edge
	cmp ax, ROW_COUNT-1
	je .edge
	cmp bx, 0
	je .edge
	cmp bx, COL_COUNT-1
	je .edge
	
	push ax
	push bx
	
	sub bx, 1
	sub ax, 1
	mov dl, 0
	mov cl, 3
	mov ch, 3
	.row_count_loop:
		push ax
		mov cl, 3
		.col_count_loop:
			push ecx
			call .get_cell
			add dl, byte [ecx]
			pop ecx
			inc ax
			dec cl
			jnz .col_count_loop
		pop ax
		inc bx
		dec ch
		jnz .row_count_loop
	
	pop bx
	pop ax
	call .get_cell
	sub dl, byte [ecx]
	ret
	.edge:
		mov dl, 0
		ret
	

; Checks the cell in (ax, bx) if it should survive
; Sets the zero flag to 
;  0 - the cell dies
;  1 - the cell survives
.should_survive:
	pusha
	call .count_neighbors
	cmp dl, 2
	jz .survive
	cmp dl, 3
	.survive:
	popa
	ret
	

; Checks the cell in (ax, bx) if it should resurrect
; sets the zero flag to 
;  0 - the cell remains dead
;  1 - the cell resurrects
.should_resurrect:
	pusha 
	call .count_neighbors
	cmp dl, 3
	popa
	ret




.cls:
	pusha
	
	mov ax, 0A000h
	mov es, ax
	mov dl, 0x0
	mov cx, 64000
	mov di, 0x0
	.cls_loop:
		mov [es:di], dl
		inc di
		dec cx
		jnz .cls_loop
	popa
	ret

; Sleeps for 1s
.sleep:
	pusha
	mov cx, 0x0007
	mov dx, 0x8480
	mov ah, 0x86
	mov al, 0x0
	int 15h
	popa
	ret
	
; Puts a white pixel in (ax, bx) coordinates
.put_pxl:
	pusha
	; Position = 320 * ax + bx since there is 320 pixel per line
	
	mov cx, 320
	mul cx
	add ax, bx
	mov di, ax
	
	
	; White color 
	mov dl, 0xF 
	
	; Put video memory address into es
	mov ax, 0A000h
	mov es, ax
	mov [es:di], dl 
	
	popa
	ret

; Puts a 6x6 filled box in (ax, bx) coordinates
.put_filled_box:
	pusha
	mov cx, bx
	add cx, 0x6
	.col_loop:
		push cx
		mov cx, ax
		add cx, 0x6
		push ax
		.row_loop:
			call .put_pxl
			inc ax
			cmp ax, cx
			jnz .row_loop
		pop ax
		pop cx
		inc bx
		cmp bx, cx
		jnz .col_loop
	popa
	ret
	
; Puts a living cell in (ax, bx) coordinates of a 10x10 grid of 6x6 cells
.put_alive_cell:
	pusha
	mov cx, 0x7
	mul cx
	
	push ax
	mov ax, bx
	mul cx
	mov bx, ax
	pop ax
	call .put_filled_box
	popa
	ret
