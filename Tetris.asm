.model small
.stack 100h

.data

	; -------------------------------------------------------------------------------- Time Stuff

    S_time db '00:00', '$'
    seconds db 0
    seconds1 db 99
    delay_Hunseconds db 5  ;delay between frames
    ranNum db 0            ;number being incremented by several procedures, used in GenerateRanNum
    delay_stop db 0
    

    
	
    x1 dw 150           ; X coordinate of the start of the first line
    y1 dw 174           ; Y coordinate of the first line
    len1 dw 71          ; Length of the first line
    color1 db 15        ; Color (palette index) of the first line
    
    x2 dw 150           ; X coordinate of the start of the second line
    y2 dw 33            ; Y coordinate of the second line
    len2 dw 71         ; Length of the second line
    color2 db 15         ; Color (palette index) of the second line

    x3 dw 150           ; X coordinate of the start of the line
    y3 dw 33            ; Y coordinate of the start of the line
    len3 dw 142        ; Length of the line
    color3 db 15         ; Color (palette index) of the line

    x4 dw 221           ; X coordinate of the start of the line
    y4 dw 33            ; Y coordinate of the start of the line
    len4 dw 142         ; Length of the line
    color4 db 15         ; Color (palette index) of the line
;--------------------------------------------------------------------------- Pieces

	

    LengthALL dw 7 ;Universal length for all of the PIECE

    StartSquareX dw 179 
    StartSquareY dw 37
    ColorSquare db 4
    
    Start_T_X dw 179
    Start_T_Y dw 37
    Color_T db 130

    Start_S_X dw 179
    Start_S_Y dw 37
    Color_S db 1

    Start_Z_X dw 179
    Start_Z_Y dw 37
    Color_Z db 75

    Start_L_X  dw 179
    Start_L_Y dw 37
    Color_L db 2

    Start_J_X  dw 179
    Start_J_Y dw 37
    Color_J db 6
    
    Start_I_X  dw 179
    Start_I_Y dw 37
    Color_I db 14
    
	
	Start_SmallSquare_X dw 179
	Start_SmallSquare_Y dw 37
	Color_SmallSquare db 85 
	
	StartLinePiece_X dw 179
	StartLinePiece_Y dw 37
	Color_LinePiece db 46
	
	CurrentX dw ?
    CurrentY dw ?
    CurrentPiece db ?
	
	;Boolean vars
	IsColor db ? ; is there a color at current location ( boolean var 0 - BLACK 1 - COLOR)
	
	
	

;--------------------------------------------------------------------------- String
	ScoreDig_1 db '0', '$'
	ScoreDig_2 db '0', '$'
	ScoreDig_3 db '0', '$'
	Score_2 db 'Score: ', '$'
	newline db 13, 10, '$'
	;"S_time db '00:00', '$' ------------ Time String in the time section"
	
	

;----------------------------------------------------------------------------Line checks
CheckLine_X dw 151
CheckLine_Y dw 173 
CheckLine_Color db 90

	

;----------------------------------------------------------------------------Pictures
STRT db 'STRT.bmp',0
Instructions db 'INSTR.bmp',0
Score db 'Score.bmp',0
Game db 'Game.bmp',0
EndScreen db 'EndGame.bmp',0
filehandle dw ?
Header db 54 dup (0)
Palette db 256*4 dup (0)
ScrLine db 320 dup (0)
ErrorMsg db 'Error', 13, 10 ,'$'

	
.code
start:
    mov ax, @data       ; Initialize data segment
    mov ds, ax

    mov ax, 13h         ; Set up video mode 13h (320x200, 256 colors)
    int 10h
	
	call SetUpGame
	
 
	Tetris:		
	call GenerateRanPiece
	jmp Tetris






SetUpGame PROC
	call ClearScreen
	call PrintPicture_STRT
	call waitForENTERKeyPress
	call CloseFile
	call PrintPicture_Instructions
	call waitForENTERKeyPress
	call CloseFile
	call PrintPictureScore
	call waitForENTERKeyPress
	call CloseFile
	call ClearScreen
	call PrintPictureGame
	call printScore2
	call PrintBox
	ret
SetUpGame ENDP 

DrawLine_horizontal proc
    draw_line_horizontal:
        mov bh, 0h          ; Video page number
        mov ah, 0ch         ; BIOS function to set pixel
        int 10h             ; Call BIOS video services

        inc cx              ; Move to the next pixel
        dec si              ; Decrement the length counter
        jnz draw_line_horizontal       ; Repeat until the entire line is drawn

    ret
DrawLine_horizontal endp



DrawLine_vert proc
    draw_line_vert:
        mov bh, 0h          ; Video page number
        mov ah, 0ch         ; BIOS function to set pixel
        int 10h             ; Call BIOS video services

        inc dx              ; Move to the next pixel vertically
        dec si              ; Decrement the length counter
        jnz draw_line_vert       ; Repeat until the entire line is drawn

    ret
DrawLine_vert endp




PrintPixel PROC

    mov bh, 0h         ; Video page number (default)
  
    mov ah, 0Ch        ; BIOS function to plot pixel
    int 10h            ; Call BIOS video services

    ret
PrintPixel ENDP

PrintBigPixel proc

; do not change _AL register saved for COLOR
	push di
    mov di, 7
    mov bx, cx 
DrawLines:  
    mov cx, bx        ; X coordinate of the start of the first line
    inc dx
    mov si, 7      ; Length of the first line
    call DrawLine_horizontal       ; Call the DrawLine function
    
    dec di 
    jnz DrawLines
	
	pop di
    ret 

    

PrintBigPixel endp


; Subroutine to set the cursor position
setCursorPosition proc
    mov ah, 02h       ; Set cursor position function
    mov dh, bh        ; Row (Y position)
    mov dl, al        ; Column (X position)
    mov bh, 0         ; Page number (default)
    int 10h           ; Call BIOS video services
    ret
setCursorPosition endp






; --------------------------------------------------------------------------MESSAGE FUNCTIONS




printScoreDig1 proc
    ; Set position for printing the message
    mov ax, 11   ; X position (half of screen width)
    mov bx, 1700 ; Y position (half of screen height)
    call setCursorPosition

    mov ah, 09h       ; Function to display string
    mov dx, offset ScoreDig_1 ; Offset of message string
	
    int 21h           ; Call DOS services
    ret
printScoreDig1 endp

printScoreDig2 proc
    ; Set position for printing the message
    mov ax, 10   ; X position (half of screen width)
    mov bx, 1700 ; Y position (half of screen height)
    call setCursorPosition

    mov ah, 09h       ; Function to display string
    mov dx, offset ScoreDig_2; Offset of message string
	
    int 21h           ; Call DOS services
    ret
printScoreDig2 endp

printScoreDig3 proc
    ; Set position for printing the message
    mov ax, 9   ; X position (half of screen width)
    mov bx, 1700 ; Y position (half of screen height)
    call setCursorPosition

    mov ah, 09h       ; Function to display string
    mov dx, offset ScoreDig_3; Offset of message string
	
    int 21h           ; Call DOS services
    ret
printScoreDig3 endp


printScore2 proc
    ; Set position for printing the message
    mov ax, 3    ; X position (half of screen width)
    mov bx, 1700 ; Y position (half of screen height)
    call setCursorPosition

    mov ah, 09h       ; Function to display string
    mov dx, offset Score_2 ; Offset of message string
	
    int 21h           ; Call DOS services
    ret
printScore2 endp




UpdateScore proc
	
	
	inc ScoreDig_1
	cmp ScoreDig_1, '9'
	jg Tens
	
	call printScoreDig1
	ret
	Tens:
		inc ScoreDig_2
		mov ScoreDig_1, '0'
		cmp ScoreDig_2, '9'
		jg Hundreds
		call printScoreDig1
		call printScoreDig2
		ret
	Hundreds:
		mov ScoreDig_1, '0'
		mov ScoreDig_2, '0'
		inc ScoreDig_3
		call printScoreDig1
		call printScoreDig2
		call printScoreDig3
		ret
UpdateScore endp




;Print the SQUARE piece
PrintSquare proc
    
    ;TWO ABOVE
    mov cx, StartSquareX        ; X coordinate of the start of the first line
    mov dx, StartSquareY       ; Y coordinate of the first line
    mov si, LengthALL      ; Length of the first line
    mov al, ColorSquare    ; Color of the first line
   
    call PrintBigPixel
	
    mov dx, StartSquareY       ; Y coordinate of the first line
    mov si, LengthALL      ; Length of the first line
    mov al, ColorSquare    ; Color of the first line
    call PrintBigPixel
    ; TWO BELOW
    sub cx, 14       ; X coordinate of the start of the first line
    mov si, LengthALL      ; Length of the first line
    mov al, ColorSquare    ; Color of the first line
    call PrintBigPixel
    sub dx, 7
    mov si, LengthALL      ; Length of the first line
    mov al, ColorSquare    ; Color of the first line
    call PrintBigPixel
    ret
PrintSquare endp





;Print T piece
PrintT proc
    ; --------------------THREE BOXES ABOVE--------------------
    mov cx, Start_T_X     
    mov dx, Start_T_Y       
    mov si, LengthALL     
    mov al, Color_T  
    call PrintBigPixel

	sub cx,14
	mov si, LengthALL     
    mov al, Color_T  
    call PrintBigPixel
	sub dx,7
	mov si, LengthALL     
    mov al, Color_T
	call PrintBigPixel
	sub dx,7
	mov si, LengthALL     
    mov al, Color_T
	call PrintBigPixel
	ret
PrintT endp









; PRINT S PIECE
PrintS PROC
    ; TWO ABOVE
    mov cx, Start_S_X       
    mov dx, Start_S_Y       
    mov si, LengthALL     
    mov al, Color_S  
    call PrintBigPixel

    sub cx, 14     
    mov dx, Start_S_Y        
    mov si, LengthALL      
    mov al, Color_S 
    call PrintBigPixel 

    ; TWO BELOW
    sub cx, 7       ; X coordinate of the start of the first line
    mov si, LengthALL      ; Length of the first line
    mov al, Color_S  ; Color of the first line
    call PrintBigPixel  
    
    sub cx, 14      ; X coordinate of the start of the first line
    sub dx, 7       ; Y coordinate of the first line
    mov si, LengthALL      ; Length of the first line
    mov al, Color_S  ; Color of the first line
    call PrintBigPixel  
    ret
PrintS ENDP











;Print Z piece
PrintZ PROC
    ;TWO ABOVE
    mov cx, Start_Z_X      
    mov dx, Start_Z_Y       
    mov si, LengthALL     
    mov al, Color_Z 
    call PrintBigPixel
     
    sub dx, 7  
    mov si, LengthALL      
    mov al, Color_Z 
    call PrintBigPixel 

    ;TWO BELOW

    sub cx, 7
    mov si, LengthALL      ; Length of the first line
    mov al, Color_Z  ; Color of the first line
    call PrintBigPixel  

    sub dx, 7
    mov si, LengthALL     
    mov al, Color_Z  
    call PrintBigPixel
    ret

PrintZ ENDP










;Print L piece
PrintL PROC

	;ONE ABOVE
	mov cx, Start_L_X
	mov dx, Start_L_Y 
    mov si, LengthALL     
    mov al, Color_L 
    call PrintBigPixel
	
    ;THREE BELOW
    sub cx, 7
    mov si, LengthALL     
    mov al, Color_L 
    call PrintBigPixel

	sub cx,14
	sub dx, 7
    mov si, LengthALL     
    mov al, Color_L 
    call PrintBigPixel

	sub cx,14
	sub dx, 7
    mov si, LengthALL     
    mov al, Color_L 
    call PrintBigPixel

    ret
PrintL ENDP










;Print J piece
PrintJ proc
;ONE ABOVE
	mov cx, Start_J_X
	mov dx, Start_J_Y
    mov si, LengthALL    
    mov al, Color_J
    call PrintBigPixel 
	
;THREE BELOW
	inc dx
	sub cx,7
	dec dx
    mov si, LengthALL    
    mov al, Color_J
    call PrintBigPixel 
	

	sub dx,7
    mov si, LengthALL    
    mov al, Color_J
    call PrintBigPixel 
	
	sub dx,7
    mov si, LengthALL    
    mov al, Color_J
    call PrintBigPixel 
	
	
    ret 
PrintJ endp






;print ---- (l) shaped piece
Print_I proc
    mov cx, Start_I_X       ; X coordinate of the start of the first line
    mov dx, Start_I_Y       ; Y coordinate of the first line
    mov si, LengthALL      ; Length of the first line
    mov al, Color_I   ; Color of the first line
    call PrintBigPixel

    mov dx, Start_I_Y   
    mov si, LengthALL     
    mov al, Color_I  
    call PrintBigPixel

    mov dx, Start_I_Y     
    mov si, LengthALL      
    mov al, Color_I 
    call PrintBigPixel
 
    mov dx, Start_I_Y      
    mov si, LengthALL    
    mov al, Color_I  
    call PrintBigPixel
    
    ret
Print_I endp

PrintSmallSquare proc

	mov cx, Start_SmallSquare_X
    mov dx, Start_SmallSquare_Y   
    mov si, LengthALL      
    mov al, Color_SmallSquare  
    call PrintBigPixel
	ret
	
PrintSmallSquare endp


PrintLinePiece PROC
	mov cx, StartLinePiece_X
    mov dx, StartLinePiece_Y
    mov si, LengthALL      
    mov al, Color_LinePiece
    call PrintBigPixel
	
	sub cx, 7
	call PrintBigPixel
	
	sub cx, 7
	call PrintBigPixel
	
	ret
PrintLinePiece endp









PrintBox proc
    ; Draw the lower line
    mov cx, [x1]        ; X coordinate of the start of the first line
    mov dx, [y1]        ; Y coordinate of the first line
    mov si, [len1]      ; Length of the first line
    mov al, [color1]    ; Color of the first line
    call DrawLine_horizontal       ; Call the DrawLine function

    ; Draw the upper line
    mov cx, [x2]        ; X coordinate of the start of the second line
    mov dx, [y2]        ; Y coordinate of the second line
    mov si, [len2]      ; Length of the second line
    mov al, [color2]    ; Color of the second line
    call DrawLine_horizontal       ; Call the DrawLine function

    ; Draw the left line
    mov cx, [x3]        ; X coordinate of the start of the line
    mov dx, [y3]        ; Y coordinate of the start of the line
    mov si, [len3]      ; Length of the line
    mov al, [color3]    ; Color of the line
    call DrawLine_vert       ; Call the DrawLine function 
    
    ; Draw the right line
    mov cx, [x4]        ; X coordinate of the start of the line
    mov dx, [y4]        ; Y coordinate of the start of the line
    mov si, [len4]      ; Length of the line
    mov al, [color4]    ; Color of the line
    call DrawLine_vert       ; Call the DrawLine function 
    ret
PrintBox endp


Delay1 proc
    push ax
    push bx
    push cx
    push dx
	
	call ChangeTime
    ;read current time
    xor bl,bl
    mov ah,2Ch
    int 21h

    mov al,[ranNum]
    add al,dl
    mov [ranNum],al

    ;store seconds
    mov [seconds],dh

    ;calculate stopping point and adjust
    add dl,[delay_Hunseconds]
    cmp dl,100
    jb delay_secondAdjustmentDone

    ;adjust
    sub dl,100
    mov bl,1

    delay_secondAdjustmentDone:
    mov [delay_stop],dl

    readTime:
    int 21h

    cmp bl,0;is it the same second
    je SameSecond;yes

    cmp dh,[seconds]
    je readTime
    ;not in the same second, so stop
    push dx
    sub dh,[seconds]
    cmp dh,2
    pop dx
    jae DelayDone
    jmp StoppingPointReachedCheck

    SameSecond:
    cmp dh,[seconds];if false were done
    jne DelayDone

    StoppingPointReachedCheck:
    cmp dl,[delay_stop];keep reading time if dl is below than stopping point
    jb readTime

    DelayDone:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
Delay1 endp
ChangeTime proc 
    mov ah,2Ch
    int 21h

    cmp dh,[seconds]
    ja ChangeTime1
    ret
    ChangeTime1:
    mov [seconds1],dh
    cmp [s_Time+4],'9'
    jne ChangeSeconds
    cmp [s_Time+3],'5'
    jne ChangeTens
    cmp [s_Time+1],'9'
    jne ChangeMin
    cmp [s_Time],'9'
    jne ChangeTensMin
    mov [s_Time],0
    mov [s_Time+1],0
    mov [s_Time+3],0
    mov [s_Time+4],0
    jmp endingSeconds


    ChangeSeconds:
    add [s_Time+4],1
    jmp endingSeconds

    ChangeTens:
    mov [s_Time+4],'0'
    add [s_Time+3],1
    jmp endingSeconds

    ChangeMin:
    mov [s_Time+3],'0'
    mov [s_Time+4],'0'
    add [s_Time+1],1
    jmp endingSeconds

    ChangeTensMin:
    mov [s_Time+1],'0'
    mov [s_Time+3],'0'
    mov [s_Time+4],'0'
    add [s_Time],1

    endingSeconds:
    call PrintTime    
    ret
 ChangeTime endp

;Print the time (00:00)
PrintTime PROC
	push ax
	push bx
	push dx
    mov ax, 1000 ; X position (half of screen width)
    mov bx, 1600  ; Y position
    call setCursorPosition

    mov ah, 09h         ; Function to display string
    mov dx, offset S_time ; Offset of message string
    int 21h    
	pop ax
	pop bx
	pop dx	
    ret
PrintTime ENDP

 ; Delay of a second (בערך)
DelaySecond PROC
    call Delay1
    call Delay1
    call Delay1
    call Delay1
    call Delay1
    call Delay1
    call Delay1
    call Delay1
    call Delay1
    call Delay1
    ret
DelaySecond ENDP


GenerateRanNum proc 
    mov al, [ranNum] ; Load random number
    add al, 31       ; Add 31 (0x1F) to ensure result is in the range 1-7
    xor ah, ah       ; Clear ah before division
    div bl           ; Divide by bl
    ret
GenerateRanNum endp
 
;Genarates a random piece to the mid top of the gameboard, uses the function generate RanNum 
;   0 - Square Piece
;   1 - I Piece
;   2 - S Piece
;   3 - Z Piece
;   4 - L Piece
;   5 - J Piece
;   6 - T Piece
;   7 - SmallSquare Piece
GenerateRanPiece PROC
    Again_If_Nine:
    mov CurrentPiece, -1
    call Delay1
    mov bl, 9        ; Set bl to 7 for generating a number between 0 and 6
    call GenerateRanNum   ; Call the GenerateRanNum procedure
    
    
    ; Ensure the generated number is in the range of 0 to 6
    and al, 00001111b  ; Mask the bits to ensure it's between 0 and 6
   
    ; Check if the generated number is 0
    cmp al, 0      ; Compare with ASCII character '0'
    je Zero         

   
    cmp al, 1    
    je One         
    
  
    cmp al, 2
    je Two          
    

    cmp al,3
    je Three   
    
   
    cmp al,4
    je Four         
    
 
    cmp al,5
    je Five         
    
   
    cmp al,6
    je Six          
    
  
    cmp al,7
    je Seven
    
	cmp al,8
	je Eight
	
	cmp al, 9
	je Nine
    jmp Again_If_Nine
    
    ; Print the corresponding shape based on the generated number
    Zero: 
    mov CurrentPiece, 0 
    call SquareFalling
    ret
    One: 
    mov CurrentPiece, 1 
    call I_Falling
    ret
    Two:
    mov CurrentPiece, 2 
    call S_Falling
    ret
    Three:
    mov CurrentPiece, 3 
    call Z_Falling
    ret
    Four:
    mov CurrentPiece, 4 
    call L_Falling
    ret
    Five:
    mov CurrentPiece, 5 
    call J_Falling
    ret
    Six:
    mov CurrentPiece, 6 
    call T_Falling
    ret
	Seven:
    mov CurrentPiece, 7
    call SmallSquareFalling
    ret
	Eight:
	mov CurrentPiece, 7
    call SmallSquareFalling
	Nine:
	mov CurrentPiece, 9
	call LinePiece_Falling
    ret
    ret
	

GenerateRanPiece ENDP



SquareFalling proc ;Falling square piece
	SquareFallingLoop:
    call MoveSquare
	mov CurrentX, cx
	mov currentY, dx
    call Delay1
    call PrintSquare
    sub ColorSquare, 4
    call PrintSquare 
    add StartSquareY, 1
    add ColorSquare, 4
    call PrintSquare
    call Delay1
	CheckCollsionSquare:
		inc dx
		mov di,14
		SquareLoop:
			dec cx
			call CheckIfBlack
			cmp IsColor,1
			je End_Square_Falling
			dec di
			cmp di,0
			je SquareFallingLoop
			jmp SquareLoop

    jmp SquareFallingLoop
    End_Square_Falling:
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call UpdateScore
		mov StartSquareX, 179
		mov StartSquareY, 37
		ret

		
		
	
SquareFalling endp



 ;Falling T piece
T_Falling PROC
    T_Piece_Falling:
    call MoveT
    call Delay1
    call PrintT
    sub Color_T, 130
    call PrintT
    add Start_T_Y, 1
    add Color_T, 130
    call PrintT
    call Delay1
    CheckCollsion_T:
		inc dx
		mov di,21
		T_Loop:
			dec cx
			call CheckIfBlack
			cmp IsColor,1
			je End_T_Falling
			dec di
			cmp di,0
			je T_Piece_Falling
			jmp T_Loop

    jmp T_Piece_Falling
    End_T_Falling:
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call UpdateScore
		mov Start_T_X, 179
		mov Start_T_Y, 37
		ret

T_Falling ENDP




S_Falling PROC
    S_Piece_Falling:
        call MoveS
        call Delay1
        call PrintS
        dec Color_S
        call PrintS
        add Start_S_Y, 1
        inc Color_S 
        call PrintS
        call Delay1
    CheckCollsion_S:
		add cx, 7
		inc dx
		mov di,14
		S_Loop:
			dec cx
			call CheckIfBlack
			cmp IsColor,1
			je End_S_Falling
			
			dec di
			cmp di,0
			je S_Piece_Falling
			cmp di, 7
			jg S_Above
			jmp S_Loop

    jmp S_Piece_Falling
	; The S shape consists of two levels, the S Above secotion is created to check the collision above side of the shape 
	S_Above:            
		sub dx, 7
		add cx, 7
		call CheckIfBlack
		cmp IsColor,1
		je End_S_Falling
		add dx, 7
		sub cx, 7
		jmp S_Loop
    End_S_Falling:
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call UpdateScore
		mov Start_S_X, 179
		mov Start_S_Y, 37
		ret
	
S_Falling ENDP


Z_Falling PROC
    Z_Piece_Falling:
        call MoveZ
        call Delay1
        call PrintZ
        sub Color_Z, 75
        call PrintZ
        add Start_Z_Y, 1
        add Color_Z, 75
        call PrintZ
        call Delay1
        CheckCollsion_Z:
		inc dx
		mov di,14
		Z_Loop:
			dec cx
			call CheckIfBlack
			cmp IsColor,1
			je End_Z_Falling
			dec di
			cmp di, 1
			jl Z_Above
			jmp Z_Loop

    jmp Z_Piece_Falling
	Z_Above:
		sub dx,7
		mov di, 7
		Z_Mini_Loop:
		dec cx
		call CheckIfBlack
		cmp IsColor,1
		je End_Z_Falling
		dec di
		cmp di,0
		je Z_Piece_Falling
		je End_Z_Falling
		jmp Z_Mini_Loop
    End_Z_Falling:
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call UpdateScore
		mov Start_Z_X, 179
		mov Start_Z_Y, 37
		ret
Z_Falling ENDP


L_Falling PROC
    L_Piece_Falling:
        call MoveL
		mov currentX,cx
		mov currentY,dx
        call Delay1
        call PrintL
        sub Color_L, 2
        call PrintL
        add Start_L_Y, 1
        add Color_L, 2
        call PrintL
        call Delay1
        CheckCollsion_L:
			add cx, 14
			inc dx
			mov di,21
			L_Loop:
				dec cx
				call CheckIfBlack
				cmp IsColor,1
				je End_L_Falling
				dec di
				cmp di,0
				je L_Piece_Falling
				jmp L_Loop

    jmp L_Piece_Falling
    End_L_Falling:
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call UpdateScore
		mov Start_L_X, 179
		mov Start_L_Y, 37
		ret
		
		
L_Falling ENDP

J_Falling PROC
    J_Piece_Falling:
        call MoveJ
        call Delay1
        call PrintJ
        sub Color_J, 6
        call PrintJ
        add Start_J_Y, 1
        add Color_J, 6
        call PrintJ
        call Delay1
        CheckCollsion_J:
			inc dx
			mov di,21
			J_Loop:
				dec cx
				call CheckIfBlack
				cmp IsColor,1
				je End_J_Falling
				dec di
				cmp di,0
				je J_Piece_Falling
				jmp J_Loop

    jmp J_Piece_Falling
    End_J_Falling:
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call UpdateScore
		mov Start_J_X, 179
		mov Start_J_Y, 37
		ret
		
J_Falling ENDP

I_Falling PROC
	I_Piece_Falling:
		call MoveI
		mov currentX,cx
		mov currentY,dx
        call Delay1
        call Print_I
        sub Color_I, 14
        call Print_I
        add Start_I_Y, 1
        add Color_I, 14
        call Print_I
        call Delay1
		CheckCollsion_I:
			inc dx
			mov di,28
			I_Loop:
				dec cx
				call CheckIfBlack
				cmp IsColor,1
				je End_I_Falling
				dec di
				cmp di,0
				je I_Piece_Falling
				jmp I_Loop

    jmp I_Piece_Falling
    End_I_Falling:
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call CheckIfLineCompleted
		call UpdateScore
		mov Start_I_X, 179
		mov Start_I_Y, 37
		ret

       
I_Falling ENDP





SmallSquareFalling proc ;Falling Small Square Piece
	Small_Square_Falling_Loop:
    call MoveSmallSquare
	mov CurrentX, cx
	mov currentY, dx
    call Delay1
    call PrintSmallSquare
    sub Color_SmallSquare, 85
    call PrintSmallSquare
    add Start_SmallSquare_Y, 1
    add Color_SmallSquare, 85
    call PrintSmallSquare
    call Delay1
	Check_Collsion_Small_Square:
		inc dx
		mov di,7
		Small_Square_Loop:
			dec cx
			call CheckIfBlack
			cmp IsColor,1
			je End_Small_Square_Falling
			dec di
			cmp di,0
			je Small_Square_Falling_Loop
			jmp Small_Square_Loop
			
    jmp Small_Square_Falling_Loop
    End_Small_Square_Falling:
		call CheckIfLineCompleted
		call UpdateScore
		mov Start_SmallSquare_X, 179
		mov Start_SmallSquare_Y, 37
		ret

		
SmallSquareFalling endp


LinePiece_Falling proc ;Falling Small Square Piece
	LinePiece_Falling_Loop:
    call MoveLinePiece
	mov CurrentX, cx
	mov currentY, dx
    call Delay1
    call PrintLinePiece
    sub Color_LinePiece, 46
    call PrintLinePiece
    add StartLinePiece_Y, 1
    add Color_LinePiece, 46
    call PrintLinePiece
    call Delay1
	Check_Collsion_LinePiece:
		inc dx
		mov di,7
		LinePiece_Loop:
			dec cx
			call CheckIfBlack
			cmp IsColor,1
			je End_LinePiece_Falling
			dec di
			cmp di,0
			je LinePiece_Falling_Loop
			jmp LinePiece_Loop
			
    jmp LinePiece_Falling_Loop
    End_LinePiece_Falling:
		call CheckIfLineCompleted
		call UpdateScore
		mov StartLinePiece_X, 179
		mov StartLinePiece_Y, 37
		ret

		
LinePiece_Falling endp
;

MoveSquare PROC
    call checkKeyPress
    cmp al, 'A'
    je SquareMoveLeft 
    cmp al, 'D'
    je SquareMoveRight
    cmp al, 'S'
    je SquareMoveDown
    cmp al, 'a'
    je SquareMoveLeft
    cmp al, 'd'
    je SquareMoveRight
    cmp al, 's'
    je SquareMoveDown
    ret
	
    SquareMoveLeft:                         ; Check collision using a loop if no collision move square left
		Check_Collision_Square_Left:
		sub cx,1    
		mov di, 14
		Square_Left_Loop:
			dec dx
			dec di
			call CheckIfBlack
			cmp IsColor, 1
			je EndSquareLeft
			cmp di, 0
			je No_Collision_End_Square_Left
			jmp Square_Left_Loop
		EndSquareLeft:
			ret 
		No_Collision_End_Square_Left:
        call PrintSquare
        sub ColorSquare, 4
        call PrintSquare 
        sub StartSquareX, 7
        add ColorSquare, 4
        call PrintSquare
        ret
		
		
    SquareMoveRight:
		Check_Collision_Square_Right:
		add cx,14           ; 15 because cx ends at the left side of the square at the SquareFalling procedure
		mov di, 14
		Square_Right_Loop:
			dec dx 
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je EndSquareRight
			cmp di, 0
			je No_Collision_End_Square_Right
			jmp Square_Right_Loop
			
		EndSquareRight:
			ret 
		No_Collision_End_Square_Right:
		sub cx, 15
        call PrintSquare
        sub ColorSquare, 4
        call PrintSquare 
        add StartSquareX, 7
        add ColorSquare, 4
        call PrintSquare
		ret
		
    SquareMoveDown:
		Check_Collision_Square_Down:
		mov di, 14
		dec cx
		add dx, 1
		Square_Down_Loop:
			inc cx 
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je EndSquareDown
			inc dx
			call CheckIfBlack
			cmp IsColor,1
			je EndSquareDown
			dec dx
			cmp di,0
			je No_Collision_End_Square_Down
			jmp Square_Down_Loop
		
	
		
		
		EndSquareDown:
			ret
		
		No_Collision_End_Square_Down:
        call PrintSquare
        sub ColorSquare, 4
        call PrintSquare 
        add StartSquareY, 2
        add ColorSquare, 4
        call PrintSquare
        ret
MoveSquare ENDP

MoveT PROC
    call checkKeyPress
    cmp al, 'A'
    je T_MoveLeft 
    cmp al, 'D'
    je T_MoveRight
	cmp al, 'S'
    je T_MoveDown 
    cmp al, 'a'
    je T_MoveLeft
    cmp al, 'd'
    je T_MoveRight
	cmp al, 's'
    je T_MoveDown 
    ret
	
	
	
	 T_MoveDown:
		call Move_T_Down
		ret
	 T_MoveLeft:                         ; Check collision using a loop if no collision move T left
		Check_Collision_T_Left:
		sub cx,1  
		mov di, 7
		T_Left_Loop:
			dec dx
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_T_Left
			add cx,7
			sub dx,7
			call CheckIfBlack
			cmp IsColor, 1
			je End_T_Left
			sub cx,7
			add dx,7
			cmp di, 0
			je No_Collision_End_T_Left
			jmp T_Left_Loop
		End_T_Left:
			ret 
		No_Collision_End_T_Left:
        call PrintT
		sub Color_T, 130
		call PrintT
		sub Start_T_X, 7
		add Color_T, 130
		call PrintT
		ret
		
		
		
		
		
		
		
		
		T_MoveRight:
		Check_Collision_T_Right:
		add cx,21 
		mov di, 7
		T_Right_Loop:
			dec dx
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_T_Right
			sub cx,7
			sub dx,7
			call CheckIfBlack
			cmp IsColor,1
			je End_T_Right
			add cx,7
			add dx,7
			cmp di, 0
			je No_Collision_End_T_Right
			jmp T_Right_Loop
		End_T_Right:
			ret 
		No_Collision_End_T_Right:
        call PrintT
		sub Color_T, 130
		call PrintT
		add Start_T_X, 7
		add Color_T, 130
		call PrintT
		ret
	
	
	
	
     
		
	

    
MoveT ENDP

Move_T_Down PROC
Check_Collision_T_Down:
		mov di, 21
		dec cx
		add dx,1
		T_Down_Loop:
			inc cx 
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_T_Down
			inc dx
			call CheckIfBlack
			cmp IsColor,1
			je End_T_Down
			dec dx
			cmp di,0
			je No_Collision_End_T_Down
			jmp T_Down_Loop
		
	
		
		
		End_T_Down:
			ret
		
		No_Collision_End_T_Down:
			call PrintT
			sub Color_T, 130
			call PrintT
			add Start_T_Y, 2
			add Color_T, 130
			call PrintT
			ret
Move_T_Down endp


MoveS PROC
    call checkKeyPress
    cmp al, 'A'
    je S_MoveLeft 
    cmp al, 'D'
    je S_MoveRight
    cmp al, 'S'
    je Move_S_Down_Small
    cmp al, 'a'
    je S_MoveLeft
    cmp al, 'd'
    je S_MoveRight
    cmp al, 's'
    je Move_S_Down_Small
    ret
	
		Move_S_Down_Small:
			call Move_S_Down
			ret
	
	S_MoveLeft:                         ; Check collision using a loop if no collision move S left
		Check_Collision_S_Left:
		sub cx,1  
		mov di, 7
		S_Left_Loop:
			dec dx
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_S_Left
			add cx,7
			sub dx,7
			call CheckIfBlack
			cmp IsColor, 1
			je End_S_Left
			sub cx,7
			add dx,7
			cmp di, 0
			je No_Collision_End_S_Left
			jmp S_Left_Loop
		End_S_Left:
			ret 
		No_Collision_End_S_Left:
			call PrintS
			sub Color_S, 1
			call PrintS
			sub Start_S_X, 7
			add Color_S, 1
			call PrintS
			ret
			
			
			
			S_MoveRight:                         ; Check collision using a loop if no collision move S left
		Check_Collision_S_Right:
		add cx,14
		mov di, 7
		S_Right_Loop:
			dec dx
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_S_Right
			add cx,7
			sub dx,7
			call CheckIfBlack
			cmp IsColor, 1
			je End_S_Right
			sub cx,7
			add dx,7
			cmp di, 0
			je No_Collision_End_S_Right
			jmp S_Right_Loop
		End_S_Right:
			ret 
		No_Collision_End_S_Right:
			call PrintS
			sub Color_S, 1
			call PrintS
			add Start_S_X, 7
			add Color_S,  1
			call PrintS
			ret
	
	

MoveS ENDP

Move_S_Down PROC




Check_Collision_S_Down:
		mov di, 14
		dec cx
		add dx,1
		S_Down_Loop:
			inc cx 
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_S_Down
			inc dx
			call CheckIfBlack
			cmp IsColor,1
			je End_S_Down
			dec dx
			cmp di,0
			je No_Collision_End_S_Down
			cmp di, 7 
			jg CheckHigherPartS
			
			jmp S_Down_Loop
		
		CheckHigherPartS:
		add cx, 15
		sub dx, 7
		mov al, 40 
		call CheckIfBlack
		cmp IsColor,1
		je End_S_Down
		sub cx, 15
		add dx, 7
		add cx, 15
		sub dx, 7
		mov al, 40 
		call CheckIfBlack
		cmp IsColor,1
		je End_S_Down
		sub cx, 15
		add dx, 7
		jmp S_Down_Loop
		End_S_Down:
			ret
		
		No_Collision_End_S_Down:
			call PrintS
			sub Color_S,1
			call PrintS
			add Start_S_Y, 2
			add Color_S, 1
			call PrintS
			ret
			
			


    
Move_S_Down endp

MoveZ PROC
    call checkKeyPress
    cmp al, 'A'
    je Z_MoveLeft 
    cmp al, 'D'
    je Z_Move_Right_Small
    cmp al, 'S'
    je Z_MoveDown
    cmp al, 'a'
    je Z_MoveLeft
    cmp al, 'd'
    je Z_Move_Right_Small
    cmp al, 's'
    je Z_MoveDown
    ret
	
	Z_Move_Right_Small:
		call Z_Move_Right
		ret
	
	 Z_MoveLeft:
	Check_Collision_Left_Z:
		mov di, 7
		sub cx,1  
		Z_Left_Loop:
			dec dx
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_Z_Left			
			add cx, 7
			add dx, 7
			call CheckIfBlack
			cmp IsColor,1
			je End_Z_Left
			cmp di,0
			je End_Z_No_Collision_Left
			sub cx, 7
			sub dx, 7
			je End_Z_Left
			jmp Z_Left_Loop
			ret
	End_Z_Left:
		ret
	End_Z_No_Collision_Left:
		call PrintZ
		sub Color_Z, 75
		call PrintZ
		sub Start_Z_X, 7
		add Color_Z,  75
		call PrintZ
		ret
	
	Z_MoveDown:
	Check_Collision_Down_Z:
	mov di, 14   
	add dx, 8
	add cx,6
	Z_Down_Loop:
		inc cx
		dec di
		call CheckIfBlack
		cmp IsColor,1
		je End_Z_Down
		inc dx
		call CheckIfBlack
		cmp IsColor,1
		je End_Z_Down
		cmp di,0
		je End_Z_No_Collision_Down
		dec dx
		cmp di, 7 
		jg CheckHigherPartZ
		jmp Z_Down_Loop
	
	
   CheckHigherPartZ:
		sub dx, 7 
		sub cx, 7
		call CheckIfBlack
		cmp IsColor,1
		je End_Z_Left	
		add cx, 7
		add dx, 7
		
		sub dx, 6 
		sub cx, 7
		call CheckIfBlack
		cmp IsColor,1
		je End_Z_Left	
		add cx, 7
		add dx, 6
		jmp Z_Down_Loop

	End_Z_Down:
		ret
	End_Z_No_Collision_Down:
		call PrintZ
		sub Color_Z, 75
		call PrintZ
		add Start_Z_Y, 2
		add Color_Z, 75
		call PrintZ
		ret


    
	
    
MoveZ ENDP



; I had to make this function because I got a jump out of range error ( the error indicated my moveZ function was too complicated and the Code in between the je operators was too long
Z_Move_Right PROC  
Z_MoveRight:
	Check_Collision_Right_Z:
		mov di, 7
		add cx,14  
		Z_Right_Loop:
			dec dx
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_Z_Right			
			add cx, 7
			add dx, 7
			call CheckIfBlack
			cmp IsColor,1
			je End_Z_Right
			cmp di,0
			je End_Z_No_Collision_Right
			sub cx, 7
			sub dx, 7
			je End_Z_Right
			jmp Z_Right_Loop
			ret
	End_Z_Right:
		ret
	End_Z_No_Collision_Right:
		call PrintZ
		sub Color_Z, 75
		call PrintZ
		add Start_Z_X, 7
		add Color_Z,  75
		call PrintZ
		ret
    
Z_Move_Right endp



MoveL PROC
    call checkKeyPress
    cmp al, 'A'
    je L_MoveLeft 
    cmp al, 'D'
    je L_MoveRight
	cmp al, 'S'
	je L_MoveDown
    cmp al, 'a'
    je L_MoveLeft
    cmp al, 'd'
    je L_MoveRight
	cmp al, 's'
	je L_MoveDown
    
    ret
	
	
	L_MoveDown:
			call Move_L_Down 
			ret
	L_MoveLeft:
	Check_Collision_L_Left:
		sub cx,1   
		mov di, 7
		L_Left_Loop:
			dec dx
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_L_Left
			add cx,13
			sub dx,7
			call CheckIfBlack
			cmp IsColor,1
			je End_L_Left
			sub cx,13
			add dx,7
			cmp di, 0 
			je No_Collision_End_L_Left
			jmp L_Left_Loop
			
		End_L_Left:
			ret 
		No_Collision_End_L_Left:
			call PrintL
			sub Color_L, 2
			call PrintL
			sub Start_L_X,7
			add Color_L, 2
			call PrintL
			ret
	



	L_MoveRight:
		Check_Collision_L_Right:
		add cx,21           ; 21 because cx ends at the left side of the L shape at the L_falling procedure
		mov di, 14
		L_Right_Loop:
			dec dx 
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_L_Right
			cmp di, 0
			je No_Collision_End_L_Right
			jmp L_Right_Loop
			
		End_L_Right:
			ret 
		No_Collision_End_L_Right:
		sub cx, 22
        call PrintL
        sub Color_L, 2
        call PrintL
        add Start_L_X,7
        add Color_L, 2
        call PrintL
		ret
		

    
MoveL ENDP



Move_L_Down PROC
Check_Collision_Down_L:
	mov di, 21
	add dx, 1
	sub cx, 1
	L_Down_Loop:
		inc cx
		dec di
		call CheckIfBlack
		cmp IsColor,1
		je End_L_Down
		inc dx
		call CheckIfBlack
		cmp IsColor,1
		je End_L_Down
		cmp di,0
		je End_L_No_Collision_Down
		dec dx
		jmp L_Down_Loop
	
	End_L_Down:
		ret
	End_L_No_Collision_Down:
		call PrintL
		sub Color_L, 2
		call PrintL
		add Start_L_Y, 2
		add Color_L, 2
		call PrintL
		ret
Move_L_Down ENDP

MoveJ proc
 call checkKeyPress
    cmp al, 'A'
    je J_MoveLeft 
    cmp al, 'D'
    je J_MoveRight
    cmp al, 'S'
    je J_MoveDown_Small
    cmp al, 'a'
    je J_MoveLeft
    cmp al, 'd'
    je J_MoveRight
    cmp al, 's'
    je J_MoveDown_Small
    ret
	
	J_MoveDown_Small:
		call Move_J_Down
		ret
    J_MoveLeft:
	Check_Collision_J_Left:
		sub cx,1    
		mov di, 14
		J_Left_Loop:
			dec dx
			dec di
			call CheckIfBlack
			cmp IsColor, 1
			je End_J_Left
			cmp di, 0
			je No_Collision_End_J_Left
			jmp J_Left_Loop
			
		End_J_Left:
			ret 
		No_Collision_End_J_Left:
			call PrintJ
			sub Color_J, 6
			call PrintJ
			sub Start_J_X, 7
			add Color_J, 6
			call PrintJ
			ret
	
	
	
	
	J_MoveRight:
	Check_Collision_J_Right:
		add cx,21           ; 15 because cx ends at the left side of the square at the SquareFalling procedure
		mov di, 7
		J_Right_Loop:
			dec dx 
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_J_Right
			sub dx,7
			sub cx,14
			call CheckIfBlack
			cmp IsColor,1
			je End_J_Right
			add cx, 14
			add dx,7
			cmp di, 0
			je No_Collision_End_J_Right
			jmp J_Right_Loop
			
		End_J_Right:
			ret 
		No_Collision_End_J_Right:
			call PrintJ
			sub Color_J, 6
			call PrintJ
			add Start_J_X, 7
			add Color_J,  6
			call PrintJ
			ret




	
 
   
MoveJ endp



;reason for function : relative jump out of range error in MoveJ
Move_J_Down proc
J_MoveDown:
		Check_Collision_J_Down:
		mov di, 21
		dec cx
		add dx, 1
		J_Down_Loop:
			inc cx 
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_J_Down
			inc dx
			call CheckIfBlack
			cmp IsColor,1
			je End_J_Down
			dec dx
			cmp di,0
			je No_Collision_End_J_Down
			jmp J_Down_Loop
		
	
		
		
		End_J_Down:
			ret
		
		No_Collision_End_J_Down:
			call PrintJ
			sub Color_J, 6
			call PrintJ
			add Start_J_Y, 2
			add Color_J, 6
			call PrintJ
			ret
		
Move_J_Down endp


MoveI proc
 call checkKeyPress
    cmp al, 'A'
    je I_MoveLeft 
    cmp al, 'D'
    je I_MoveRight
    cmp al, 'S'
    je I_MoveDown
    cmp al, 'a'
    je I_MoveLeft
    cmp al, 'd'
    je I_MoveRight
    cmp al, 's'
    je I_MoveDown
    ret
	 
	
	
	I_MoveLeft:                         ; Check collision using a loop if no collision move square left
		Check_Collision_I_Left:
		sub cx,1    
		mov di, 7
		I_Left_Loop:
			dec dx
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_I_Left
			cmp di, 0
			je No_Collision_End_I_Left
			jmp I_Left_Loop
		End_I_Left:
			ret 
		No_Collision_End_I_Left:
			call Print_I
			sub Color_I, 14
			call Print_I
			sub Start_I_X, 7
			add Color_I, 14
			call Print_I
			ret
			
			
			
			
	I_MoveRight:
		Check_Collision_I_Right:
		add cx,28          ; 15 because cx ends at the left side of the square at the SquareFalling procedure
		mov di, 7
		I_Right_Loop:
			dec dx 
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_I_Right
			cmp di, 0
			je No_Collision_End_I_Right
			jmp I_Right_Loop
			
		End_I_Right:
			ret 
		No_Collision_End_I_Right:
			call Print_I
			sub Color_I, 14
			call Print_I
			add Start_I_X, 7
			add Color_I,  14
			call Print_I
			ret



		
    I_MoveDown:
		Check_Collision_I_Down:
		mov di, 28
		dec cx
		add dx, 1
		I_Down_Loop:
			inc cx 
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_I_Down
			inc dx
			call CheckIfBlack
			cmp IsColor,1
			je End_I_Down
			dec dx
			cmp di,0
			je No_Collision_End_I_Down
			jmp I_Down_Loop
		
	
		
		
		End_I_Down:
			ret
		
		No_Collision_End_I_Down:
			call Print_I
			sub Color_I, 14
			call Print_I
			add Start_I_Y, 2
			add Color_I, 14
			call Print_I
			ret
		
		
   
MoveI endp

MoveSmallSquare PROC

   call checkKeyPress
    cmp al, 'A'
    je SmallSquareMoveLeft 
    cmp al, 'D'
    je SmallSquareMoveRight
    cmp al, 'S'
    je SmallSquareMoveDown
    cmp al, 'a'
    je SmallSquareMoveLeft
    cmp al, 'd'
    je SmallSquareMoveRight
    cmp al, 's'
    je SmallSquareMoveDown
    ret
	
	SmallSquareMoveLeft:                         ; Check collision using a loop if no collision move small square left
		Check_Collision_SmallSquare_Left:
		sub cx,1    
		mov di, 14
		SmallSquare_Left_Loop:
			dec dx
			dec di
			call CheckIfBlack
			cmp IsColor, 1
			je End_SmallSquare_Left
			cmp di, 0
			je No_Collision_End_SmallSquare_Left
			jmp SmallSquare_Left_Loop
		End_SmallSquare_Left:
			ret 
		No_Collision_End_SmallSquare_Left:
        call PrintSmallSquare
        sub Color_SmallSquare, 85
        call PrintSmallSquare 
        sub Start_SmallSquare_X, 7
        add Color_SmallSquare, 85
        call PrintSmallSquare
        ret
		
	 SmallSquareMoveRight:
		Check_Collision_SmallSquare_Right:
		add cx,7           ; 15 because cx ends at the left side of the square at the SquareFalling procedure
		mov di, 7
		SmallSquare_Right_Loop:
			dec dx 
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_SmallSquare_Right
			cmp di, 0
			je No_Collision_End_SmallSquare_Right
			jmp SmallSquare_Right_Loop
			
		End_SmallSquare_Right:
			ret 
		No_Collision_End_SmallSquare_Right:
		sub cx, 15
        call PrintSmallSquare
        sub Color_SmallSquare, 85
        call PrintSmallSquare 
        add Start_SmallSquare_X, 7
        add Color_SmallSquare, 85
        call PrintSmallSquare
		ret
	
		SmallSquareMoveDown:
		Check_Collision_SmallSquare_Down:
		mov di, 7
		dec cx
		add dx, 1
		SmallSquare_Down_Loop:
			inc cx 
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_SmallSquare_Down
			inc dx
			call CheckIfBlack
			cmp IsColor,1
			je End_SmallSquare_Down
			dec dx
			cmp di,0
			je No_Collision_End_SmallSquare_Down
			jmp SmallSquare_Down_Loop
		
	
		
		
		End_SmallSquare_Down:
			ret
		
		No_Collision_End_SmallSquare_Down:
        call PrintSmallSquare
        sub Color_SmallSquare, 85
        call PrintSmallSquare 
        add Start_SmallSquare_Y, 2
        add Color_SmallSquare, 85
        call PrintSmallSquare
        ret
	
	
	
MoveSmallSquare ENDP

MoveLinePiece PROC

   call checkKeyPress
    cmp al, 'A'
    je LinePieceMoveLeft 
    cmp al, 'D'
    je LinePieceMoveRight
    cmp al, 'S'
    je LinePieceMoveDown
    cmp al, 'a'
    je LinePieceMoveLeft
    cmp al, 'd'
    je LinePieceMoveRight
    cmp al, 's'
    je LinePieceMoveDown
    ret
	
	LinePieceMoveLeft:                         ; Check collision using a loop if no collision move small square left
		Check_Collision_LinePiece_Left:
		sub cx,1
		mov di, 21
		LinePiece_Left_Loop:
			dec dx
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_LinePiece_Left
			cmp di, 0
			je No_Collision_End_LinePiece_Left
			jmp LinePiece_Left_Loop
		End_LinePiece_Left:
			ret 
		No_Collision_End_LinePiece_Left:
        call PrintLinePiece
        sub Color_LinePiece, 46
        call PrintLinePiece 
        sub StartLinePiece_X, 7
        add Color_LinePiece, 46
        call PrintLinePiece
        ret
		
	 LinePieceMoveRight:
		Check_Collision_LinePiece_Right:
		add cx,7       
		mov di, 21
		LinePiece_Right_Loop:
			dec dx 
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_LinePiece_Right
			cmp di, 0
			je No_Collision_End_LinePiece_Right
			jmp LinePiece_Right_Loop
			
		End_LinePiece_Right:
			ret 
		No_Collision_End_LinePiece_Right:
		sub cx, 15
        call PrintLinePiece
        sub Color_LinePiece, 46
        call PrintLinePiece
        add StartLinePiece_X, 7
        add Color_LinePiece, 46
        call PrintLinePiece
		ret
	
		LinePieceMoveDown:
		Check_Collision_LinePiece_Down:
		mov di, 7
		dec cx
		add dx, 1
		LinePiece_Down_Loop:
			inc cx 
			dec di
			call CheckIfBlack
			cmp IsColor,1
			je End_LinePiece_Down
			inc dx
			call CheckIfBlack
			cmp IsColor,1
			je End_LinePiece_Down
			dec dx
			cmp di,0
			je No_Collision_End_LinePiece_Down
			jmp LinePiece_Down_Loop
		
	
		
		
		End_LinePiece_Down:
			ret
		
		No_Collision_End_LinePiece_Down:
        call PrintLinePiece
        sub Color_LinePiece, 46
        call PrintLinePiece
        add StartLinePiece_Y, 2
        add Color_LinePiece, 46
        call PrintLinePiece
        ret
	
	
	
MoveLinePiece ENDP



CheckIfLineCompleted PROC
push bp
push cx 
push dx
push di 
push si
mov cx, CheckLine_X
mov dx, CheckLine_Y
OuterLineCompleted:
	mov di, 70
	mov si, 7
	mov bp, 20
	inc dx
	CheckLine_Loop:
		cmp di,0
		je Line_Complete
		dec dx
		dec si
		call CheckIfBlack
		cmp IsColor,0
		je Big_Y_CheckLineLoop
		cmp si, 0
		je Y_CheckLineLoop
		jmp CheckLine_Loop
		; The Y_CheckLineLoop Checks one line the Y axis
		Y_CheckLineLoop:
			dec di
			inc cx
			add dx,7
			mov si, 7
			jmp CheckLine_Loop
		; The Y_CheckLineLoop "Checks" The whole the Y axis, more simply, its the line that is responsable for "increasing" the line number  for example line 1 => line 2
		Big_Y_CheckLineLoop:
			mov di,70
			mov cx, CheckLine_X
			sub dx, 7
			dec bp
			cmp bp,0
			je End_Line_Check
			jmp CheckLine_Loop
		
Line_Complete:	
	call CopyEverythingAboveDown
	call UpdateScore
	call UpdateScore
	call UpdateScore
	call UpdateScore
	call UpdateScore
	pop cx 
	pop dx
	pop di 
	pop si
	pop bp
	
	ret
	
End_Line_Check:
	call DidGameEnd
	pop cx 
	pop dx
	pop di 
	pop si
	pop bp
	ret

CheckIfLineCompleted endp

CopyEverythingAboveDown PROC

push bp
push cx 
push dx
push di 
push si


mov di, 10
mov cx, CheckLine_X
dec dx

cmp dx, CheckLine_Y
je Is_19
cmp dx, 166
je Is_18
cmp dx, 159
je Is_17
cmp dx, 152
je Is_16
cmp dx, 145
je Is_15
cmp dx, 138
je Is_14
cmp dx, 131
je Is_13
cmp dx, 124
je Is_12
cmp dx, 117
je Is_11
cmp dx, 110
je Is_10
cmp dx, 103
je Is_9
cmp dx, 96
je Is_8
cmp dx, 89
je Is_7
cmp dx, 82
je Is_6
cmp dx, 75
je Is_5
cmp dx, 68
je Is_4
cmp dx, 61
je Is_3
cmp dx, 54
je Is_2
cmp dx, 47
je Is_1
cmp dx, 40
je Is_0
jmp Loop_Check_Color_And_Copy_Down  ; If none of the above conditions match, just jump to the loop

Is_19:
mov bp, 19
jmp Loop_Check_Color_And_Copy_Down

Is_18:
mov bp, 18
jmp Loop_Check_Color_And_Copy_Down

Is_17:
mov bp, 17
jmp Loop_Check_Color_And_Copy_Down

Is_16:
mov bp, 16
jmp Loop_Check_Color_And_Copy_Down

Is_15:
mov bp, 15
jmp Loop_Check_Color_And_Copy_Down

Is_14:
mov bp, 14
jmp Loop_Check_Color_And_Copy_Down

Is_13:
mov bp, 13
jmp Loop_Check_Color_And_Copy_Down

Is_12:
mov bp, 12
jmp Loop_Check_Color_And_Copy_Down

Is_11:
mov bp, 11
jmp Loop_Check_Color_And_Copy_Down

Is_10:
mov bp, 10
jmp Loop_Check_Color_And_Copy_Down

Is_9:
mov bp, 9
jmp Loop_Check_Color_And_Copy_Down

Is_8:
mov bp, 8
jmp Loop_Check_Color_And_Copy_Down

Is_7:
mov bp, 7
jmp Loop_Check_Color_And_Copy_Down

Is_6:
mov bp, 6
jmp Loop_Check_Color_And_Copy_Down

Is_5:
mov bp, 5
jmp Loop_Check_Color_And_Copy_Down

Is_4:
mov bp, 4
jmp Loop_Check_Color_And_Copy_Down

Is_3:
mov bp, 3
jmp Loop_Check_Color_And_Copy_Down

Is_2:
mov bp, 2
jmp Loop_Check_Color_And_Copy_Down

Is_1:
mov bp, 1
jmp Loop_Check_Color_And_Copy_Down

Is_0:
mov bp, 0
jmp Loop_Check_Color_And_Copy_Down





	
	
	
Loop_Check_Color_And_Copy_Down:
	cmp di, 0
	je Raise_The_Y_And_Check_Again
	dec di
	sub dx, 7
	mov ah, 0Dh
	int 10h

	call PrintBigPixel
	jmp Loop_Check_Color_And_Copy_Down 
	Raise_The_Y_And_Check_Again:
		
		cmp bp,0 
		je End_Loop_Check_Color_And_Copy_Down
		sub cx, 70 
		sub dx,7
		dec bp
		mov di , 10
		jmp Loop_Check_Color_And_Copy_Down
End_Loop_Check_Color_And_Copy_Down:
	sub dx, 7
	sub cx, 70
	mov al , 0
	call PrintBigPixel
	mov di, 9
	PrintBlackLineLoop:
		sub dx, 7
		dec di
		call PrintBigPixel
		cmp di, 0
		jne PrintBlackLineLoop
	pop cx 
	pop dx
	pop di 
	pop si
	pop bp
	ret

CopyEverythingAboveDown ENDP



DidGameEnd proc
push cx
push dx
push di
push si
push bp
mov cx, CheckLine_X
mov dx, 40
mov di, 70
dec cx

CheckIfGameEnded:
	inc cx
	cmp di, 0
	je End_Check_Game_Ended
	dec di
	call CheckIfBlack
	cmp IsColor,1
	je EndGame
	jmp CheckIfGameEnded
End_Check_Game_Ended:
	pop cx 
	pop dx
	pop di 
	pop si
	pop bp
	ret
EndGame:
	pop cx 
	pop dx
	pop di 
	pop si
	pop bp
	call End_Screen

DidGameEnd endp




End_Screen PROC
call ClearScreen
call PrintPicture_EndScreen
call PrintTime
call printScore2
call printScoreDig1
call printScoreDig2
call printScoreDig3
call UpdateScore
WaitForUserToPress:
	call checkKeyPress
	cmp al, 1Bh         ; Compare AL with 1Bh (ESC key)
    je esc_pressed      ; If equal, jump to esc_pressed
	cmp al, 13       ; Compare AL with 13 (ENTER key)
	je EnterPressed
	jmp WaitForUserToPress
esc_pressed:
	mov ax, 0003h       ; Return to text mode
    int 10h
    mov ax, 4c00h       ; Exit program
    int 21h

EnterPressed:
mov seconds,48 ; 48 is Ascci value for zero , need to put the value ascci because it is a string
mov seconds1,99
mov [ScoreDig_1],48
mov [ScoreDig_2],48
mov [ScoreDig_3],48
mov [s_Time],48
mov [s_Time+1],48
mov [s_Time+3],48
mov [s_Time+4],48
call ClearScreen
jmp start
End_Screen ENDP

; Function to detect if a key has been pressed and return the ASCII code of the key
checkKeyPress proc
    mov ah, 01h     ; Function to check for keystroke
    int 16h         ; BIOS interrupt to check for keystroke
    jz noKeyPress   ; If zero flag is set, no key has been pressed

    ; Key has been pressed, so read the key from the keyboard buffer
    mov ah, 00h     ; Function to read character from keyboard buffer
    int 16h         ; BIOS interrupt to read character
    ret

noKeyPress:
    xor al, al      ; Clear return value to indicate no key press
    ret
checkKeyPress endp




CheckIfBlack proc
	mov IsColor, 0
	mov ah, 0Dh
    int 10h
    cmp al, 0
	je Black	
	mov IsColor,1	
	ret
	Black:
		ret
CheckIfBlack endp

waitForENTERKeyPress proc
    waitForKeyPress:
    ; Check if any key has been pressed
    call checkKeyPress
    cmp al, 13     ; ASCII code for Enter key
    jne waitForKeyPress  ; If not Enter key, continue waiting



    ret             ; Return after Enter key is pressed
waitForENTERKeyPress endp	

; -------------------------------------------------------------------------------------------------- PICTURE RELATED FUNCITONS







OpenFileSTRT proc
; Open file
mov ah, 3Dh
xor al, al
mov dx, offset STRT
int 21h
jc openerror
mov [filehandle], ax
ret
openerror :
mov dx, offset ErrorMsg
mov ah, 9h
int 21h
ret
OpenFileSTRT endp 

OpenFile_Instructions proc
; Open file
mov ah, 3Dh
xor al, al
mov dx, offset Instructions
int 21h
jc openerror_2
mov [filehandle], ax
ret
openerror_2 :
mov dx, offset ErrorMsg
mov ah, 9h
int 21h
ret
OpenFile_Instructions endp 

OpenFile_Game proc
; Open file
mov ah, 3Dh
xor al, al
mov dx, offset Game
int 21h
jc openerror_3
mov [filehandle], ax
ret
openerror_3 :
mov dx, offset ErrorMsg
mov ah, 9h
int 21h
ret
OpenFile_Game endp 


OpenFile_EndScreen proc
; Open file
mov ah, 3Dh
xor al, al
mov dx, offset EndScreen
int 21h
jc openerror_4
mov [filehandle], ax
ret
openerror_4 :
mov dx, offset ErrorMsg
mov ah, 9h
int 21h
ret
OpenFile_EndScreen endp


OpenFile_Score proc
; Open file
mov ah, 3Dh
xor al, al
mov dx, offset Score
int 21h
jc openerror_5
mov [filehandle], ax
ret
openerror_5 :
mov dx, offset ErrorMsg
mov ah, 9h
int 21h
ret
OpenFile_Score endp


ReadHeader proc
; Read BMP file header, 54 bytes
mov ah,3fh
mov bx, [filehandle]
mov cx,54
mov dx,offset Header
int 21h
ret
ReadHeader endp 
ReadPalette proc 
; Read BMP file color palette, 256 colors * 4 bytes (400h)
mov ah,3fh
mov cx,400h
mov dx,offset Palette
int 21h
ret
ReadPalette endp
CopyPal proc 
; Copy the colors palette to the video memory
; The number of the first color should be sent to port 3C8h
; The palette is sent to port 3C9h
mov si,offset Palette
mov cx,256
mov dx,3C8h
mov al,0
; Copy starting color to port 3C8h
out dx,al
; Copy palette itself to port 3C9h
inc dx
PalLoop:
; Note: Colors in a BMP file are saved as BGR values rather than RGB .
mov al,[si+2] ; Get red value .
shr al,2 ; Max. is 255, but video palette maximal
; value is 63. Therefore dividing by 4.
out dx,al ; Send it .
mov al,[si+1] ; Get green value .
shr al,2
out dx,al ; Send it .
mov al,[si] ; Get blue value .
shr al,2
out dx,al ; Send it .
add si,4 ; Point to next color .
; (There is a null chr. after every color.)
loop PalLoop
ret
CopyPal endp
CopyBitmap proc
; BMP graphics are saved upside-down .
; Read the graphic line by line (200 lines in VGA format),
; displaying the lines from bottom to top.
mov ax, 0A000h
mov es, ax
mov cx,200
PrintBMPLoop :
push cx
; di = cx*320, point to the correct screen line
mov di,cx
shl cx,6
shl di,8
add di,cx
; Read one line
mov ah,3fh
mov cx,320
mov dx,offset ScrLine
int 21h
; Copy one line into video memory
cld ; Clear direction flag, for movsb
mov cx,320
mov si,offset ScrLine
rep movsb ; Copy line to the screen
 ;rep movsb is same as the following code :
 ;mov es:di, ds:si
 ;inc si
 ;inc di
 ;dec cx
;loop until cx=0
pop cx
loop PrintBMPLoop
ret
CopyBitmap endp
Picutre_Setup PROC
    call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
	ret
Picutre_Setup ENDP

PrintPicture_STRT proc
	call OpenFileSTRT
	call Picutre_Setup
	ret
PrintPicture_STRT endp

PrintPicture_Instructions proc
	call OpenFile_Instructions
	call Picutre_Setup
	ret
PrintPicture_Instructions endp 

PrintPictureGame PROC
call OpenFile_Game
call Picutre_Setup
ret
PrintPictureGame endp

PrintPicture_EndScreen proc
call OpenFile_EndScreen
call Picutre_Setup
ret
PrintPicture_EndScreen endp

PrintPictureScore proc
call OpenFile_Score
call Picutre_Setup
ret
PrintPictureScore endp

ClearScreen proc
    mov ah, 00h
    mov al, 13h ;set video mode
    int 10h ;execute
    mov ah,0Bh; set configuration
    mov bh, 00h ;set backgorund color
    mov bl, 00h ;choose black as background
    int 10h
    ret
ClearScreen endp

CloseFile proc  
  mov ah,3Eh
  mov bx, [filehandle]
  int  21h   
  ret 
CloseFile endp 


end start