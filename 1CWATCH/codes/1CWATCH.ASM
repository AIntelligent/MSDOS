;
; TSR CLOCK (1CWATCH)
; Written by Hakan Emre KARTAL in Iskenderun/Hatay on 25/07/1998
; hek@nula.com.tr
;

.model tiny
.code
			org     100h

WatchBegin:             jmp     WatchLoad

TotalSecond             dd      ?
Hour                    dw      ?
Minute                  dw      ?
Second                  dw      ?

ClockString             db      '00:00:00'
ClockLength             equ     ($ - ClockString)

WelcomeMsg              db      'TSR CLOCK (1CWATCH), version 1.0',13,10,13,10
                        db      'Written by Hakan Emre KARTAL in Iskenderun/HATAY'
                        db      ' on 25/07/1998',13,10
                        db      'hek@nula.com.tr',13,10,'$'

WatchStart:             ;	MemL[$40:$6C] * 10) div 182)

			push    ax bx cx dx ds es si di

			mov     ax,40h
			mov     es,ax
			mov     ax,es:6ch
			mov     dx,es:6eh

			mov     cx,10
			xor     bx,bx
			call    LongMultiple
			mov     cx,182
			call    LongDivision
			mov     word ptr TotalSecond[0],ax
			mov     word ptr TotalSecond[2],dx

			;      Second = (TotalSecond mod 60)

			mov    cx,60
			call   LongDivision
			mov    Second,cx

			;      Minute = ((TotalSecond mod 3600) div 60)

			mov    ax,word ptr TotalSecond[0]
			mov    dx,word ptr TotalSecond[2]
			mov    cx,3600
			call   LongDivision
			mov    ax,cx
			mov    cx,60
			call   LongDivision
			mov    Minute,ax

                        ;      Hour = (TotalSecond div 3600)

			mov    ax,word ptr TotalSecond[0]
			mov    dx,word ptr TotalSecond[2]
			mov    cx,3600
			call   LongDivision
			mov    Hour,ax

			lea    di,ClockString
			cld

			mov    ax,Hour
			call   WordToString

			mov    ax,Minute
			call   WordToString

			mov    ax,Second
			call   WordToString

			call   PrintString

			pop    di si es ds dx cx bx ax

			iret

LongMultiple:           mov    si,ax
			mov    di,dx
			mul    cx
			push   ax dx
			mov    ax,si
			mul    bx
			mov    ax,di
			mul    cx
			mov    cx,ax
			pop    dx ax
			add    dx,bx
			add    dx,cx
			ret

LongDivision:           xchg   bx,ax
			xchg   dx,ax
			xor    dx,dx
			div    cx
			xchg   bx,ax
			div    cx
			mov    cx,dx
			mov    dx,bx
			ret

WordToString:           push    cs
			pop     es
			xor     ah,ah
			mov     cl,10
			div     cl
			add     ax,'00'
			stosw
			inc     di
			ret

PrintString:            push    es ds cs
			pop     ds

			mov     ax,40h
			mov     es,ax
			mov     ax,0b800h
			cmp     byte ptr es:49h,7
			jne     Print
			mov     ah,0b0h

Print:                  mov     es,ax
			lea     si,ClockString
			mov     cx,ClockLength

			mov     di,((73 - 1) * 2) + ((1 - 1) * 160)
			mov     ah,0bh

Repeat:                 lodsb
			stosw
			loop    Repeat

			pop     ds es
			ret

WatchLoad:              mov     dx,offset WelcomeMsg
                        mov     ah,9
                        int     21h

                        mov     ax,251ch
			mov     dx,offset WatchStart
			int     21h

			mov     dx,offset WatchLoad
			int     27h

			end     WatchBegin
