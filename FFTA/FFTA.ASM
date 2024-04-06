; --------------------------------------------------------------------------
;
; FILE FUNCTION TRACING AGENT
; 
; --------------------------------------------------------------------------
;
; Version 1.0, 18-02-1998
; Copyright 1998 by Hakan Emre Kartal. All Rights Reserved.
; https://github.com/AInteligent, hek@nula.com.tr
; 
;         This simple program; has been  written  to  explain  how  the  DOS
; constructs the file functions and to give  and  idea  for how to get these
; functions under control. Here,  I  have  added  my  code only a few names,
; but it may be increased according to the request. It is up to your  talent
; and knowledge. Now,  let  me  give  some  instructions  about  these  file
; functions briefly:
; 
; --------------------------------------------------------------------------
;
; 1. CREATE A FILE WITH HANDLE (3Ch):
;
;         Input:
;                 AH = 3Ch
;                 CX = File attributes
;                 DS:DX = ASCIIZ file name.
;         Output:
;                 If there is an error CF=1 and AX=error no, else CF=0 and
;                 AX=file handle.
; 
; --------------------------------------------------------------------------
;
; 2. OPEN A FILE WITH HANDLE (3Dh):
;         Input:
;                 AH = 3Dh
;                 AL = Open mode 
;                 DS:DX = ASCIIZ file name.
;         Output:
;                 If there is an error CF=1 and AX=error no, else CF=0 and
;                 AX=file handle.
; 
; --------------------------------------------------------------------------
;
; 3. CLOSE A FILE WITH HANDLE (3Eh):
;         Input:
;                 AH = 3Eh
;                 BX = File handle
;         Output:
;                 If there is an error CF=1 and AX=error code.
; 
; --------------------------------------------------------------------------
;
; 4. READ A FILE WITH HANDLE (3Fh):
;         Input:
;                 AH = 3Fh
;                 BX = File handle
;                 CX = Length
;                 DS:DX = Buffer
;         Output:
;                 If there is an error CF=1 and AX=error code else
;                 CF=0 and AX=Length
; 
; --------------------------------------------------------------------------
;
; 5. WRITE A FILE WITH HANDLE (40h):
;         Input:
;                 AH = 40h
;                 BX = File handle
;                 CX = Length
;                 DS:DX = Buffer
;         Output:
;                 If there is an error CF=1 and AX=error code else
;                 CF=0 and AX=Length
;
;         If you pay attention,  it  will be seen that all are directed by a
; "File handle". Well, we will form our program on this. Now, let me explain
; how I construct it briefly:
;
;         INVALID_HANDLE_VALUE       = 0FFFFh
;         FILE_DATA        struc
;                 Handle      dw      INVALID_HANDLE_VALUE    #1
;                 Attrib      dw      0                       #2
;                 Mode        db      0                       #3
;                 TotalRead   dd      0                       #4
;                 TotalWrite  dd      0                       #5
;         MAX_NAME            =       100
;                 Name        db      MAX_NAME dup (0), 0     #6
;         FILE_DATA        ends
;
; #1. Handle: This is the number  of  the  file  which  the  functions  will  be
; constructed on. When you examine the source  code,  you will see that "Handle"
; is work up if it is over  cartain  value.  The  reason  of  that  is,  DOS
; hides the values which are inferior of the _INVALID_HANDLE  values for some
; devices. For example; 0=CON represents the standart output device.
;
; #2. Attrib: Characteristics of the created file. (Look: 3Ch)
;
; #3. Mode: Manipulated characteristics of the opened file. (Look: 3Dh)
;
; #4. TotalRead: Keeps the total knowledge which is read over the file.
; I think this is more appropriate. (Look: 3Fh)
; 
; #5. TotalWrite: Keeps the total knowledge written on the file.    
; I think this is more appropriate. (Look: 40h)
;
; --------------------------------------------------------------------------
; 
;         Well  I keep the file informations for using them afterwards by  a
; structure like this. 
;  
;         Now, let me tell you how I direct an  information  chain  that  is
; defined under this type structure.
; 
; --------------------------------------------------------------------------
;
; _Find(@@Handle): Finds any knowledge inside the FILE_DATA typed information
; chain. If it finds CF=0 holds DX=Sequence number and DI=Offset address.
; 
; --------------------------------------------------------------------------
;
; _Add(@@Handle, @@NamePtr, @@Attrib, @@Mode): Makes an addion to 
; the FILE_DATA typed information chain. If it is successful CF becomes 
; CF=0 and  DI holds the offset address (DI=offset address).
; 
; --------------------------------------------------------------------------
;
; _Remove(@@Handle): Removes any  knowledge  from the FILE_DATA typed 
; information chain.
; 
; --------------------------------------------------------------------------
;
; _NullData( ): It unloads the FILE_DATA typed information chain and
; gets them to their first values.
;
; --------------------------------------------------------------------------
;
;         Because of the codes are easy, I think it is unnecessary  to  tell
; the other lower programs. Now,  let's  see  how  I  have done the function
; control:
;
;
;        FUNCFILTER      struc
;                 Func     db      ?       #1
;                 Filter	dw      ?       #2
;                 Message	dw      ?       #3
;        FUNCFILTER      ends
;
; #1. Func: Holds the code of the function which will be controlled.
;
; #2. Filter: Well, this holds the offset address of the lower program which
; will be making the control. By this way if that function is called, we can
; control  it  by  calling  with  an easy CALL. This  provides  us security,
; simplicty and it allows us to increase the development of our code.
;
; #3. Message: Holds  the  offset address of the message which is used to give
; information about the function.
;
; --------------------------------------------------------------------------
;
;         WELL, NOW THE EASY CODIFYING LOGIC LYING UNDER THE WHOLE CODE.
;
;
;         This code is codified
;      by no errors to the utmost.
;
;             If you wish
;           to ask question,
;      to inform about the errors
;       or to express your ideas
;           about this code;
;
;         Please send me E-Mail.
;
;         Good luck...
;
;         !!! WARNING !!!
;
;         The copyright holder offers no warranty with this code whatsoever,
; including its fitness for any particular purpose. Neither shall  be liable
; for damages of any kind that may arise from its use.
;
;         If you consider using all or parts of this code in your own
; product, you may get permission from the author.
;
; NOT: If an error occours, change the GEN_TIME value. If the error
; continues, please fill and send the error declaration form to me.
;
;                                                        Hakan Emre Kartal
;                                                        hek@nula.com.tr
;
	.286

	model	tiny,	pascal

	codeseg
	startupcode

	locals	@@
	jumps

	org	100h


		jmp	Start

P_			equ	<PTR>
P_POINT	equ	<DWORD>
P_DB		equ	<BYTE P_>
P_DW		equ	<WORD P_>
P_DD		equ	<P_POINT P_>

; ===========================================================================
;  FILE DATA TABLO AND MENAGEMENT UNIT
; ===========================================================================

_INVALID_HANDLE		=	4
INVALID_HANDLE_VALUE	=  0FFFFh

FILE_DATA	struc
   Handle		dw	(INVALID_HANDLE_VALUE)
   Attrib		dw	(0)
   Mode			db	(0)
   TotalRead	dd	(0)
   TotalWrite	dd	(0)
MAX_NAME					=	100
   FileName    db      MAX_NAME dup (0), (0)
FILE_DATA	ends

FILE_DATA_SIZE			equ	size FILE_DATA
MAX_FILE_DATA			=	(10)

Datum     	FILE_DATA MAX_FILE_DATA dup (?)

Counter		dw	(0)

PFILE_DATA				equ	<FILE_DATA P_>

_Find	proc	pascal

	arg	@@Handle

		xor     dx,dx
		lea     di,Datum
		mov     ax,[@@Handle]
		clc
	@@Arastir:
		cmp		[PFILE_DATA di].Handle,ax
		je	@@End
		add		di,FILE_DATA_SIZE
		inc		dx
		cmp		dx,MAX_FILE_DATA
		jbe	@@Arastir
		stc
	@@End:
		ret

_Find	endp

_Add		proc	pascal

	arg	@@Handle, @@NamePtr : P_POINT, @@Attrib, @@Mode

		stc
		cmp		[@@Handle],_INVALID_HANDLE
		jbe		@@End
		cmp		[Counter],MAX_FILE_DATA
		jae		@@End
		call		_Find, INVALID_HANDLE_VALUE
		jc	@@End
		cld
		mov		ax,[@@Handle]
		stosw	
		mov		ax,[@@Attrib]
		stosw	
		mov		ax,[@@Mode]
		stosb	
		xor		ax,ax
		stosw
		stosw
		stosw
		stosw
		push		ds
		lds		si,[@@NamePtr]
		call		_StrCopy, si, di, CPY_ASCIIZ
		pop		ds
		inc		[Counter]
		clc
	@@End:
		ret

_Add		endp

_Remove		proc	pascal

	arg	@@Handle

		cmp		[@@Handle],_INVALID_HANDLE
		jbe		@@End
		cmp		[Counter],0
		jz	@@End
		call		_Find, [@@Handle]
		jc	@@End
		cld
		mov		ax,INVALID_HANDLE_VALUE
		stosw
		call		_StrNull, di, 0, FILE_DATA_SIZE - 2
		dec		[Counter]
	@@End:
		ret

_Remove		endp

_NullData  	proc

		call		_StrNull, offset Datum, 0, FILE_DATA_SIZE * MAX_FILE_DATA
		cld
		lea		di,Datum
		mov		cx,MAX_FILE_DATA
	@@Change:
		mov		P_DW [PFILE_DATA di].Handle,INVALID_HANDLE_VALUE
		add		di,FILE_DATA_SIZE
		loop		@@Change
		ret

_NullData  endp
;
; Image form
;
__END__		equ	'$'
__LF__		equ	0Dh
__SPACE__	equ	20h

__Title        	db      "FILE FUNCTION TRACING AGENT "
						db      "(INT 21h/3Ch,3Dh,3Eh,3Fh,40h)",__END__

__Programmer    	db      "Programmed by Hakan Emre Kartal",__LF__
						db      "E-Mail: hek@nula.com.tr",__END__

__Caption       	db      "FileName        : "
__Name				db	MAX_NAME dup (__SPACE__),__LF__,__LF__
						db      "Handle      : "
__Handle				db	"0000h",__LF__
						db      "Attribute   : "
__Attrib				db	"----",__LF__
						db      "Open Mode   : "
__Mode				db	"--",__LF__
						db      "Total Read  : "
__TotalRead			db	"00000000h",__LF__
						db      "Total Write : "
__TotalWrite    	db      "00000000h",__LF__,__LF__
						db      "Function    : "
MAX_FUNC	=	0Bh
__Function			db	MAX_FUNC dup (__SPACE__),__LF__
						db      "Error       : "
__Error          	db      '0',__LF__,__LF__

						db      "Calling Adr.: "
__CgSeg				db	"0000h",':'
__CgOfs				db	"0000h",__LF__
						db      "Registers   : AX="
__AX					db	"0000h BX="
__BX					db	"0000h CX="
__CX					db	"0000h DX="
__DX					db	"0000h DS="
__DS					db	"0000h",__END__

__Wait        		db      "Please wait...",__END__

RegisterMap  		dw      __CgSeg, __CgOfs
						dw      __DS
						dw      __DX, __CX, __BX, __AX
MAX_REGSMAP	equ	(($-RegisterMap) / 2)
;
; Hiding, giving, listing Register values.
; ----------------------------------------
;
_AX			dw	?
 _BX			dw	?
  _CX			dw	?
   _DX		dw	?
    _SI		dw	?
     _DI		dw	?
_DS			dw	?
 _ES			dw	?
  _CS			dw	?
   _IP		dw	?

_FLAGS		dw	?

AX_			equ	<P_DW cs:_AX>
 BX_			equ	<P_DW cs:_BX>
  CX_			equ	<P_DW cs:_CX>
   DX_		equ	<P_DW cs:_DX>
    SI_		equ	<P_DW cs:_SI>
     DI_		equ	<P_DW cs:_DI>
DS_			equ	<P_DW cs:_DS>
 ES_			equ	<P_DW cs:_ES>
  CS_			equ	<P_DW cs:_CS>
   IP_		equ	<P_DW cs:_IP>

FLAGS_		equ	<P_DW cs:_FLAGS>



_RegisterSave	proc

		mov		AX_,ax
		mov		BX_,bx
		mov		CX_,cx
		mov		DX_,dx
		mov		SI_,si
		mov		DI_,di
		mov		DS_,ds
		mov		ES_,es
		pushf	
		pop		FLAGS_

		ret

_RegisterSave	endp



_RegisterRestore	proc

		mov		ax,AX_
		mov		bx,BX_
		mov		cx,CX_
		mov		dx,DX_
		mov   	si,SI_
		mov		di,DI_
		mov		ds,DS_
		mov		es,ES_
		push		FLAGS_
		popf

		ret

_RegisterRestore	endp
;
; Helper tools
; -----------------
;
; _HexConvert: Converts a string in Hex. which ephasized as @@Value.
; CX = Length, @@String = Destination offset address.
;
_HexConvert	proc	pascal

	arg	@@Value : P_POINT, @@Address

		jcxz		@@End
		mov		di,[@@Address]
		add		di,cx
	@@Convert:
		dec		di
		mov		ax,P_DW [@@Value]
		and		ax,000Fh
		add		al,('0')
		cmp		al,('0' + 10)
		jb	@@Send
		add		al,('A' - '0' - 10)
	@@Send:
		mov		[di],al
		push    	cx
		mov     	cx,+4
		mov     	dx,P_DW [@@Value][2]
		mov     	ax,P_DW [@@Value][0]
	@@ShiftBits:
		shr     	dx,1
		rcr     	ax,1
		loop    	@@ShiftBits
		mov     	P_DW [@@Value][2],dx
		mov     	P_DW [@@Value][0],ax
		pop     	cx
		loop    	@@Convert
	@@End:
		ret

_HexConvert	endp
;
; _StrNull: @@Dest area is filled by @@Height piece @@Dolgu.
;
_StrNull		proc	pascal

	arg	@@Dest, @@Dolgu, @@Height

		cld
		mov		di,[@@Dest]
		mov		ax,[@@Dolgu]
		mov		cx,[@@Height]
		shr		cx,1
		rep		stosw
		jnc		@@End
		stosb
	@@End:
		ret

_StrNull		endp
;
; _KopyalaASCIIZ: While copying @@Source area to @@Dest area it copies with
; ASCIIZ (0)
;
CPY_ASCIIZ	=	0
CPY_GENERAL		=	1
;
_StrCopy	proc	pascal

	arg	@@Source, @@Dest, @@ASCIIZ

		cld
		mov		si,[@@Source]
		mov		di,[@@Dest]
		cmp     	[@@ASCIIZ],CPY_ASCIIZ
		jne     	@@GenCopy
	@@ASCIIZ_Copy:
		cmp     	P_DB [si],0
		movsb
		jnz     	@@ASCIIZ_Copy
		ret
	@@GenCopy:
		cmp     	P_DB [si + 1],0
		movsb
		jnz     	@@GenCopy
		ret

_StrCopy	endp
;
; IMAGE PREPARE AND SHOW UNIT
; ---------------------------
;
; _Goto: Sends the cursor by using Int 10h.
; DH = Row, DL = Column.
;
_Goto		proc

		sub     	dx,0101h
		mov		ah,02h
		xor		bx,bx
		int		10h
		ret

_Goto		endp
;
; _Where: Where the cursor is.
; Return value is DH = Row, DL = Column.
;
_Where		proc

		mov		ah,03h
		xor		bx,bx
		int		10h
		add     	dx,0101h
		ret

_Where		endp
;
; _SendToScr: Shows any charecter according to desired value and length.
; AL = Character, BL = Color, CX = Length.
;
_SendToScr	proc

		mov		ah,09h
		xor		bh,bh
		int		10h
		ret

_SendToScr	endp
;
; Show: Shows a string.
;
Show		proc	pascal

	arg	@@Message, @@X, @@Y, @@Color

		cld
		mov		si,[@@Message]
		mov		di,[@@X]
	@@Send:
		lodsb
		cmp		al,__END__
		je	@@End
		cmp		al,__LF__
		jne		@@PostInScr
		inc		[@@Y]
		mov		[@@X],di
		jmp		short @@Send
	@@PostInScr:
		mov     	dh,P_DB [@@Y]
		mov     	dl,P_DB [@@X]
		call		_Goto
		mov		bl,P_DB [@@Color]
		mov		cx,1
		call		_SendToScr
		inc		[@@X]
		jmp		short @@Send
	@@End:
		ret

Show		endp
;
; Window: Draws a window.
;
Window		proc	pascal

	arg	@@X : byte, @@Y : byte, @@Width : byte,	\
		@@Height : byte, @@Color : byte

		mov		ax,0600h
		mov		bh,[@@Color]
		mov		ch,[@@Y]
		mov		cl,[@@X]
		mov		dh,[@@Height]
		mov		dl,[@@Width]
		sub   	cx,0101h
		sub   	dx,0101h
		add		dx,cx
		int		10h
		ret

Window		endp
;
; ScrPage: Moves screen page to the other pages.
;
SS_SAVE		=	0
SS_RESTORE	=	1
;
ScrPage	proc	pascal

	arg	@@Source, @@Dest, @@SS

		push		ds es
		mov		ah,0Fh
		int		10h
		mov		dx,0B800h
		cmp		al,03h
		je	@@OK
		mov		dh,0B0h
	@@OK:
		mov		es,dx
		mov		ds,dx
		mov		si,[@@Source]
		imul		si,80 * 25 * 2
		mov		di,[@@Dest]
		imul  	  di,80 * 25 * 2
		mov		cx,80 * 25
		rep		movsw
		pop		es ds
		cmp		[@@SS],SS_RESTORE
		je	@@GeriVer
		call		_Where
		mov		[@@Whereis],dx
		ret
	@@GeriVer:
		mov		dx,[@@Whereis]
		call		_Goto
		ret

@@Whereis dw 0

ScrPage	endp
;
; Wait: Keeps the functions waiting.
; AX = Second
;
_Wait           proc

		push		es
		xor		dx,dx
		mov		es,dx
_SYSTIMER		equ	<P_DW es:[046Ch]>
		add		ax,_SYSTIMER
	@@_Wait:
		cmp		_SYSTIMER,ax
		jb      	@@_Wait
		pop		es
		ret

_Wait           endp
;
; ShowLists: Shows the prepared list.
;
ShowLists	proc
;
; Calculations and addresses.
;
BS_X            	= 2
BS_Y            	= 09h
BS_LEN				= 1
BS_COLOR				= 4Fh
PR_X            	= 2
PR_Y					= BS_Y + BS_LEN
PR_LEN				= 2
PR_COLOR        	= 74h
LS_X            	= 2
LS_Y					=	PR_Y + PR_LEN
LS_LEN          	=  0Dh
LS_COLOR				=	3Fh
BE_X            	=  2
BE_Y            	=  LS_Y + LS_LEN
BE_LEN          	=  1
BE_COLOR        	=  2Eh

GEN_TIME        	= 18

		call		ScrPage, 0, 1, SS_SAVE
		call		Window, BS_X - 1, BS_Y, 80, BS_LEN, BS_COLOR
		call		Show, offset __Title, BS_X, BS_Y, BS_COLOR
		call		Window, PR_X - 1, PR_Y, 80, PR_LEN, PR_COLOR
		call		Show, offset __Programmer, PR_X, PR_Y, PR_COLOR
		call		Window, LS_X - 1, LS_Y, 80, LS_LEN, LS_COLOR
		call		Show, offset __Caption, LS_X, LS_Y, LS_COLOR
		call    	Window, BE_X - 1, BE_Y, 80, BE_LEN, BE_COLOR
		call    	Show, offset __Wait, BE_X, BE_Y, BE_COLOR
		mov     	ax,GEN_TIME
		call    	_Wait
		call		ScrPage, 1, 0, SS_RESTORE
		ret

ShowLists	endp
;
; Well now preparing data parts.
; ---------------------------------
;
; Result = Long + Word
;
_LongAdd      	proc    pascal

	arg     @@Value : P_POINT, @@Number

		mov     	dx,P_DW [@@Value][2]
		mov     	ax,P_DW [@@Value][0]
		add     	ax,[@@Number]
		adc     	dx,+0
		ret

_LongAdd      	endp



DataPrepare	proc	pascal

	arg	@@Handle, @@Read, @@Write

		cmp		[@@Handle],_INVALID_HANDLE
		jbe		@@End
		call		_Find, [@@Handle]
		jc			@@End
		mov		bx,di
		;
		; File FileName area is being spacing and copying.
		;
		call		_StrNull, offset __Name, 2020h, MAX_NAME
		lea     	si,[PFILE_DATA bx].FileName
		call		_StrCopy, si, offset __Name, CPY_ASCIIZ
		;
		; Handle convering.
		;
		mov		cx,4
		call		_HexConvert, P_DD [PFILE_DATA bx].Handle, offset __Handle
		;
		; Calculating the whole read byte.
		;
		call    	_LongAdd, P_DD [PFILE_DATA bx].TotalRead, [@@Read]
		mov     	P_DW [PFILE_DATA bx].TotalRead[0],ax
		mov     	P_DW [PFILE_DATA bx].TotalRead[2],dx
		mov		cx,8
		call		_HexConvert, dx, ax, offset __TotalRead
		;
		; Calculating the whole written byte.
		;
		call    	_LongAdd, P_DD [PFILE_DATA bx].TotalWrite, [@@Write]
		mov     	P_DW [PFILE_DATA bx].TotalWrite[0],ax
		mov     	P_DW [PFILE_DATA bx].TotalWrite[2],dx
		mov		cx,8
		call		_HexConvert, dx, ax, offset __TotalWrite
		;
		; Attribute converting.
		;
		lea		di,__Attrib
		mov		dx,[PFILE_DATA bx].Attrib
		call		@@AttribConvert
		;
		; Open mode converting.
		;
		lea		di,__Mode
		mov		dl,[PFILE_DATA bx].Mode
		call		@@ModeConvert
		;
		; Error converting.
		;
		mov		[__Error],('0')
		push    	FLAGS_
		popf
		jnc     	@@Show
		inc		[__Error]
		;
		; Show
		;
	@@Show:
		call		@@RegisterConvert
		call		ShowLists
	@@End:
		ret
	;
	;
	@@ModeConvert	proc

	E_RDONLY		= 0
	E_WRONLY		= 1
	E_WR			= 2
	E_INVALID	= -1

			cld
			mov		ax,'-R'
			cmp		dl,E_RDONLY
			jne		@@IsWrite?
		@@Send:
			stosw
			ret
		@@IsWrite?:
			mov		ax,'-W'
			cmp		dl,E_WRONLY
			je	@@Send
			mov		ax,'RW'
			cmp		dl,E_WR
			je	@@Send
			mov		ax,'--'
			jne		@@Send

			endp
	;
	;
	@@AttribConvert	proc

	FA_RDONLY	= 1
	FA_HIDDEN	= 2
	FA_SYSTEM	= 4
	FA_ARCH		= 20h

			cld
			mov		cx,4
			test		dx,FA_RDONLY
			jz	@@IsHidden?
			mov		al,'R'
			stosb
			dec		cx
		@@IsHidden?:
			test		dx,FA_HIDDEN
			jz	@@IsSystem?
			mov		al,'H'
			stosb
			dec		cx
		@@IsSystem?:
			test		dx,FA_SYSTEM
			jz	@@IsArch?
			mov		al,'S'
			stosb
			dec		cx
		@@IsArch?:
			test		dx,FA_ARCH
			jz	@@Null
			mov		al,'A'
			stosb
			dec		cx
		@@Null:
			mov		al,'-'
			repe		stosb
			ret

			endp
			;
			;
	@@RegisterConvert	proc

			cld
			mov     	[@@SP],sp
			;
			; I'm making PUSH according to RegisterMap.
			;
			push   	AX_ BX_ CX_ DX_ DS_ IP_ CS_
			mov     	si,sp   ; ss:[si] = CS_
			lea		bx,RegisterMap
			mov		cx,MAX_REGSMAP
		@@GetRegister:
			lods		P_DW ss:[si]
			push		cx
			mov		cx,4
			call		_HexConvert, 0, ax, [bx]
			pop		cx
			inc		bx
			inc		bx
			loop		@@GetRegister
			mov     	sp,[@@SP]
			ret

	@@SP dw 0

			endp

DataPrepare	endp

; ===========================================================================
; FUNCTION FILTER AND MENAGEMENT UNIT
; ===========================================================================

FUNCFILTER	struc
    Func		db ?
    Filter	dw ?
    Message	dw ?
FUNCFILTER	ends

P_GS					equ	<FUNCFILTER P_>
FUNCFILTER_SIZE	equ	size FUNCFILTER

__DebugInter	dd 0
DebugInter__	equ	<P_DD cs:__DebugInter>


FilterCreateFile	proc

		call		DumpDebugIntr
		call		_Add, ax, DS_, dx, cx, E_INVALID
		jc	@@End
		call		DataPrepare, AX_, 0, 0
	@@End:
		ret

FilterCreateFile	endp


FilterOpenFile	proc

		push		ax
		call		DumpDebugIntr
		pop		di
		call		_Add, ax, DS_, dx, di, 0
		jc			@@End
		call		DataPrepare, AX_, 0, 0
	@@End:
		ret

FilterOpenFile	endp



FilterCloseFile	proc

		call		DumpDebugIntr
		push		bx
		call		DataPrepare, bx, 0, 0
		call		_Remove
		ret

FilterCloseFile	endp


FilterReadFile	proc
		call		DumpDebugIntr
		call   	DataPrepare, bx, ax, 0
		ret
FilterReadFile	endp


FilterWriteFile	proc
		call		DumpDebugIntr
		call    	DataPrepare, bx, 0, ax
		ret
FilterWriteFile	endp


DumpDebugIntr	proc
		push		es ds
		call		_RegisterRestore
		pushf
		call		DebugInter__
		mov		AX_,ax
		pushf
		pop		FLAGS_
		pop		ds es
		ret
DumpDebugIntr	endp
;
; Function filter declarations.
;
CreateFileMsg	db "Create file",0
OpenFileMsg		db "Open File",0
CloseFileMsg	db "Close File",0
ReadFileMsg		db "Read File",0
WriteFileMsg	db "Write File",0

Filters	FUNCFILTER	<3Ch, FilterCreateFile,	CreateFileMsg>, \
							<3Dh, FilterOpenFile, 	OpenFileMsg>,	\
							<3Eh, FilterCloseFile, 	CloseFileMsg>,	\
							<3Fh, FilterReadFile, 	ReadFileMsg>,	\
							<40h,	FilterWriteFile, 	WriteFileMsg>
MAX_FILTER		equ	(($-Filters) / FUNCFILTER_SIZE)

_CheckFilter?   db      (0)

_FindFilter	proc

		mov     	[_CheckFilter?],0
		lea		si,Filters
		mov		cx,MAX_FILTER
	@@Diff:
		cmp		ah,[P_GS si].Func
		jne		@@Next
		push		si
		call		_StrNull, offset __Function, 2020h, MAX_FUNC
		call		_StrCopy, [P_GS si].Message, offset __Function, CPY_GENERAL
		pop		si
		call		[P_GS si].Filter
		inc     	[_CheckFilter?]
		ret
	@@Next:
		add		si,FUNCFILTER_SIZE
		loop		@@Diff
		ret

_FindFilter	endp

; ===========================================================================
; FILTER INTERRUPT
; ===========================================================================

;
; My Interrupt Functions
;
SINT_REMOVE    = -1 ; Uninstall program.
SINT_CHECK 		= -2 ; Check program in memory.
SINT_OK       	= -3 ; Yes program in memory.
SINT_REMOVED	= -4 ; Yes program uninstalled.
SINT_GETDATA  	= -5 ; Get data structure type.

DEST_INTR		= 21h
DEBUG_INTR     = DEST_INTR

SET_VECT       = ((25h * 256) + DEBUG_INTR)
GET_VECT       = ((35h * 256) + DEST_INTR)


FilterIntr	proc	pascal

		cmp		ax,SINT_CHECK
		je     	@@InMemory
		cmp		ax,SINT_REMOVE
		je			@@Remove
		cmp     	ax,SINT_GETDATA
		jne		@@FindFilter
	@@GetData:
		mov     	dx,cs
		lea    	ax,Datum
		mov     	cx,cs:[Counter]
		iret
	@@InMemory:
		mov     	ax,SINT_OK
		iret
	@@Remove:
		lds		dx,DebugInter__
		mov     	ax,SET_VECT
		int		21h
		mov		es,cs:[2Ch]
		mov		ah,48h
		int		21h
		push		cs
		pop		es
		mov		ah,48h
		int		21h
		mov     	ax,SINT_REMOVED
		iret
	@@FindFilter:
		pop     	IP_ CS_
		push    	CS_ IP_
		call    	_RegisterSave
		push		cs cs
		pop		ds es
		call    	_FindFilter
		call    	_RegisterRestore
		cmp     	cs:[_CheckFilter?],0
		jz      	@@Exit
		retf    	2
	@@Exit:
		jmp		DebugInter__

FilterIntr	endp


	Start:
		mov     	ax,SINT_CHECK
		int     	DEBUG_INTR
		cmp     	ax,SINT_OK
		je      	@@JustInMemory
		lea     	dx,InstallMsg
		call    	@@Show
		call    	_NullData
		mov     	ax,GET_VECT
		int     	21h
		mov     	P_DW __DebugInter[0],bx
		mov     	P_DW __DebugInter[2],es
		mov     	ax,SET_VECT
		lea     	dx,FilterIntr
		int     	21h
		lea     	dx,Start
		int     	27h
	@@JustInMemory:
		lea     	dx,JustInMemMsg
		call    	@@Show
		int     	20h

InstallMsg     	db      0Dh,0Ah,"Installed...",0Dh,0Ah,__END__
JustInMemMsg   	db      0Dh,0Ah,"It is just in memory!",0Dh,0Ah,__END__

	@@Show:
		mov     	ah,9
		int     	21h
		ret

		end
