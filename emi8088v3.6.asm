name "TP20182"

org 100h
      
jmp start

;area de definicion de datos
new_line        db 10,13,'$'; Enter para imprimir el tablero correctamente

;definicion de las propiedades del tablero
width           db 20; ancho del tablero en cantidad de caracteres
height          db 15; alto del tablero en cantidad de caracteres
base_board_x    EQU 0; Posicion en X de la esquina superior izquierda del tablero
base_board_y    EQU 0; Posicion en Y de la esquina superior izquierda del tablero
ini_cursor_x    EQU 0; Posicion inicial en X del cursor
ini_cursor_y    EQU 0; Posicion inicial en Y del cursor 
step_x          EQU 1; Tamanio de paso en X que separa las posiciones validas para el cursor en el tablero
step_y          EQU 1; Tamanio de paso en Y que separa las posiciones validas para el cursor en el tablero
tot_pos_x       EQU 20; Cantidad total en X de posiciones validas del tablero
tot_pos_y       EQU 15; Cantidad total en Y de posiciones validas del tablero


last_x_x        EQU 19
last_x_y        EQU 14

;definicion de las teclas de control
up              EQU 'w'
down            EQU 's'
left            EQU 'a'
right           EQU 'd'
enter           EQU 0Dh
esc             EQU 1Bh

letras db 300 dup(?)
palabra db 23 dup(?)
mov di,0
path    db "C:\emu8086\vdrive\tpf\archivo.txt", 0 
path2    db "C:\emu8086\vdrive\tpf\archivoreferencias.txt", 0 
respuestas  db 46 dup (0)
referencias db 300 dup(0)
mov bp,0
handle  dw ?
palabraPuntaje db "Puntuacion: $"
puntaje db 0      

            
start:
  call gen_letras   
  CALL leer_archivo
  call print_board 
  call imprimir 
  CALL leer_archivo2
  call imprimirReferencias   
play: 
  call posicionar_cursor
  call mov_cursor 
  call letra_elegida
ret

;Procedimiento encargado de validar si las teclas oprimidas por el usuario son las
;definidas en el programa.



PROC gen_letras  
    
     mov si,0     ;copio en si el valor 0
     mov bx,300   ;copio en bx el valor 300(cantidad de letras que debe haber en el arreglo)
     push bx      ;guardo el valor de bx en la pila
     
ciclo:  
    mov ah, 2ch     ; Esta interrupcion me entrega la hora fragmentada en los registros, 
                  ; CH(h) CL(m) DH(s),DL (centesimo seg)
    int 21h       ; como este es solo un  entre 1y6 
                  ;tomo solo los centesimo seg
    xor ah,ah     ;limpio registro ah
    mov al,dl     ;copio las sentecimas de segundos a al
      
    cmp al,1      ;comparo con 1
    jb ciclo      ;si es menor vuelve a repetir ciclo,ya que buscamos un valor entre 1 y 26
                  ;menor a 1 no nos sirve      
    cmp al,26     ;comparo con 26
    ja ciclo      ;si es mayor vuelve a repetir ciclo,ya que buscamos un valor entre 1 y 26
                  ;mayor a 26 no nos sirve 
    add al,64     ;sumo 64 a al para obtener el valor de una letra en caracteres ascii
    
    mov letras[si] ,al ;muevo el valor de la letra generada a la posicion de memoria letras en si
    
    pop bx    ;recupero el valor de bx de la pila
    inc si    ;incremento si
    dec bx    ;tamanio_vect, reduzco la cantidad de letras que faltan  
    cmp bx, 0 ;comparo las letras que faltan con 0
    jz fin    ;si no falta ninguna salta a la etiqueta fin
    push bx   ;si faltan letras, guardar el valor de la cantidad de letras q faltan en la pila 
    jnz ciclo ;y salta a ciclo   
   fin:       ;etiqueta de fin de procedimiento
    pop bx    ;recupero el valor de bx de la pila
    xor bx,bx ;limpio el valor del registro bx 
endp gen_letras  

 


        
;Se encarga de imprimir el tablero de juego
proc print_board
    ;Se establece el uso de la pantalla en modo texto 
    mov al, 03h
    mov ah, 0
    int 10h
    xor cx,cx
    mov bx, offset letras 
    mov cl, height
  ptr_lineCount:  
    push cx
    mov cl, width 
    mov ah, 02h
  ptr_line:
    mov dl, [bx]
    inc bx
    int 21h
    loop ptr_line
    mov dx, offset new_line
    mov ah, 09h
    int 21h
    pop cx
    loop ptr_lineCount 
endp print_board    
                   
;LECUTRA E IMPRESION DE ARCHIVO

PROC leer_archivo
        
    mov al, 0h                            
    mov dx, offset path           
    mov ah, 3Dh                             
    int 21h                                
                                
    mov handle, ax                       
 
    mov ax, 0
    mov dx, offset respuestas 

leer:
    mov ah, 3Fh
    mov cx, 1             ; cantidad de bytes q se leeran del archivo            
    mov bx, handle        ; debemos dejar en bx el handle del archivo
     
    int 21h
    cmp ax, 0                                
    jz  cerrar
    inc dx
    jmp leer
                    
cerrar: 
    mov ah, 3Eh                 
    mov bx, handle        
    int 21h                     
              
endp leer_archivo     
    
    
     
     
PROC imprimir  
    mov dh, 0
    mov dl, 0
    mov bh, 0
    mov ah, 02h
    int 10h  
    
    ;xor bx,bx
    Escribir:
    cmp respuestas[bp], "$"
    je final  
    cmp respuestas[bp], ","
    je sumarVolver
    ;mov dx, offset respuestas 
    mov dl,respuestas[bp]
    inc bp      
    ;  
    mov ah, 2
	mov dl, dl
	int 21h
    ;
    jmp Escribir
      
    sumarVolver: 
    inc bp
    ;pedir posicion cursor
    mov ah , 03h        
    int 10h  
    ;inc dl
    ;cmp dl,16 ;comparo posicion columna con 16
    ;jae saltarLinea;si es mayor a 16 salto linea 
    jmp saltarLinea
    ;mov ah, 02h
    ;int 10h       ;posiciona cursor	
	jmp Escribir  
	
	saltarLinea:    
	push dx
	posicionarAzar:
	    mov ah, 2ch   ;recupero hora
	    int 21h       
	    mov al,dl     ;muevo centecimas a al

	    cmp al,16      ;comparo con 16
        jae posicionarAzar      ;si es mayor o igual vuelve a repetir ciclo
        
        pop dx 
        inc dh
        cmp dh,15
        jae final
        ;cmp al,dl	
	    ;mov dh, ini_cursor_y
        mov dl, al
        mov bh, 0
        mov ah, 02h
        int 10h
        jmp Escribir 
final:
   ; ret
endp imprimir       

PROC leer_archivo2
        
    mov al, 0h                            
    mov dx, offset path2           
    mov ah, 3Dh                             
    int 21h                                
                                
    mov handle, ax                       
 
    mov ax, 0
    mov dx, offset referencias 

leer2:
    mov ah, 3Fh
    mov cx, 1             ; cantidad de bytes q se leeran del archivo            
    mov bx, handle        ; debemos dejar en bx el handle del archivo
     
    int 21h
    cmp ax, 0                                
    jz  cerrar2
    inc dx
    jmp leer2
                    
cerrar2: 
    mov ah, 3Eh                 
    mov bx, handle        
    int 21h                     
              
endp leer_archivo2

proc imprimirReferencias  
    xor bp,bp
    mov dh, 17
    mov dl, 0
    mov bh, 0
    mov ah, 02h
    int 10h   
    push dx
    EscribirReferencias:
    cmp referencias[bp], "$"
    je finalReferencias  
    cmp referencias[bp], ","
    je siguienteReferencias
    ;mov dx, offset respuestas 
    mov dl,referencias[bp]
    inc bp      
    ;  
    mov ah, 2
	mov dl, dl
	int 21h
    ;
    jmp EscribirReferencias
    
    siguienteReferencias:
    inc bp
    pop dx
    inc dh
    mov dl, 0
    mov bh, 0
    mov ah, 02h
    int 10h
    push dx  
    jmp EscribirReferencias
     
    finalReferencias:
    ;ret 
      
endp imprimirReferencias         
                        
                   
proc  posicionar_cursor
 ;Se lleva el cursor a la posicion inicial
  mov dh, ini_cursor_y
  mov dl, ini_cursor_x
  mov bh, 0
  mov ah, 02h
  int 10h
  ;loop principal en el que se pide continuamente una tecla
  
  get_key: 
    ;Se pide una tecla sin eco
    mov ah,07h
    int 21h
    call mov_cursor
    jmp get_key
endp posicionar_cursor                                                                                                                    
;recibe en AL la orden de movida del cursor
     
     
     
;este procedimiento simplemente verifica si las posiciones a las que me voy a mover son validas
;es decir, que solo me mueva de X en X y no caiga nunca en un * del tablero. Se podria mejorar
;haciendo que cuando se llegue a un borde, se pase a la posicion inmediatamente superior
;Este procediminto hace uso de las variables de posicion inicial del tablero, tamaño de paso, etc

proc mov_cursor
    ;Se pide la posicion del cursor
    mov ah,03h
    mov bh,0h
    int 10h
  cmp_enter:
    cmp al, enter
    je letra_elegida
  cmp_escape:
    cmp al, esc
    je aplicarCaracterDeCierre
  cmp_up:
    cmp al, up
    jne cmp_down
    sub dh, step_y
    cmp dh, base_board_y
    jg  continue_y_1
    mov dh, last_x_y
  continue_y_1:
    mov ah,2
    int 10h
    jmp fin_mov_cursor
  cmp_down:
    cmp al, down
    jne cmp_left
    add dh, step_y
    cmp dh, height
    jl continue_y_2
    mov dh, ini_cursor_y 
  continue_y_2:
    mov ah,2
    int 10h
    jmp fin_mov_cursor
  cmp_left:
    cmp al, left
    jne cmp_right
    sub dl, step_x
    cmp dl, base_board_x
    jg continue_x_1
    mov dl, last_x_x
  continue_x_1:
    mov ah,2
    int 10h
    jmp fin_mov_cursor
  cmp_right:
    cmp al, right
    jne fin_mov_cursor
    add dl, step_x
    cmp dl, width
    jl continue_x_2
    mov dl, ini_cursor_x
  continue_x_2:
    mov ah,2
    int 10h
                  

fin_mov_cursor: 
    ret
endp mov_cursor

letra_elegida:
proc elegida 
    mov ah,08h
    int 10h
    mov palabra[di],al
    inc di
    jmp mov_cursor
    
ret
endp elegida

aplicarCaracterDeCierre:
    mov palabra[di],"$"    
    inc di
    jmp comparar 
    
comparar:
    mov cx, 0
    mov bp, 0
    mov bx, 0
    mov dl, 0
proc compararpalabra
compararcaracter:
    
    cmp respuestas[bp],"$"
    je finalcomp
    cmp respuestas[bp], ","
    je compintermedia
    cmp palabra[bx],"$"
    je compintermedia
    mov dl, palabra[bx]
    cmp respuestas[bp], dl
    je  caractercorrecto 
    jne caracterincorrecto


caractercorrecto:
   cmp cx, 0
   je caractercorrectoprimerc
   jmp correctosiguientecaracter
            
caractercorrectoprimerc:
   mov al, 1
   inc bp
   inc cx
   inc bx
   jmp compararcaracter
   
correctosiguientecaracter:
    and al,1
    inc bp
    inc bx
    inc cx
    jmp compararcaracter

caracterincorrecto:
    cmp cx, 0
    je caracterincorrectoprimerc
    jmp incorrectosiguientecaracter    

caracterincorrectoprimerc:
    mov al, 0
    inc bp
    inc cx
    inc bx
    jmp compararcaracter

incorrectosiguientecaracter:
    and al, 0
    inc bp
    inc cx
    inc bx
    jmp compararcaracter

    
compintermedia:
    cmp al, 1
    je respuestacorrecta 
    cmp respuestas[bp],","
    je siguientecomparacion
    cmp palabra[bx],"$"
    je siguienterespuesta

siguienterespuesta:    
    inc bp
    cmp respuestas[bp], "$"
    je  finalcomp
    cmp respuestas[bp], ","
    je  siguientecomparacion
    jmp siguienterespuesta

siguientecomparacion:
    inc bp
    mov bx, 0 
    mov cx, 0
    jmp compararcaracter

finalcomp:
    cmp al, 1
    je respuestacorrecta
    jmp limpiarrespuesta
    
    
limpiarrespuesta: 
    inc cx 
    cmp palabra[bx], "$"
    jne PalabraUltimoCaracter
    ;dec bx      
    mov di,0  
    ;mov cx,6
    limpiarVectorPalabra:
    mov palabra[bx], 0
    dec bx
    loop limpiarVectorPalabra 
    jmp terminarcomparacion
PalabraUltimoCaracter:
    cmp palabra[bx], "$"
    je limpiarrespuesta
    inc bx 
    inc cx
    jmp PalabraUltimoCaracter     
respuestacorrecta:
    push cx
    mov cl, puntaje
    inc cx
    mov puntaje, cl
    pop cx
    jmp imprimirpuntaje
    
imprimirpuntaje:
    mov dh, 0
	mov dl, 30
	mov bh, 0
	mov ah, 2
	int 10h	
	mov dx, offset palabraPuntaje
    mov ah, 9
	int 21h 
	mov dx,0
	mov ah, 2
	mov dl, puntaje
	add dl,48
	int 21h
	jmp limpiarrespuesta

terminarcomparacion:
    mov dh, 0
	mov dl, 0
	mov bh, 0
	mov ah, 2
	int 10h
    jmp mov_cursor


endp compararpalabra    






