{

 GÅncelleme:

   4/Haziran/2000: DoldurPen birimi eklendi.
                   Pencere, OgrenOfs, Merkez tamamen ASM ile yazçldç.

}

unit Goruntu;

interface

type
  TPencere = array[0..8] of Char;
  TGoster = (goGoster, goBelirt);
  TAktar = (akByte, akWord);
  TBaslik = (poSol, poOrta, poSag);
  TGolge = (goRenkVer, goDegistir);
  TMesaj = string[80];

const
  clBlack        = 0;
  clBlue         = 1;
  clGreen        = 2;
  clCyan         = 3;
  clRed          = 4;
  clMagenta      = 5;
  clBrown        = 6;
  clLightGray    = 7;
  clDarkGray     = 8;
  clLightBlue    = 9;
  clLightGreen   = 10;
  clLightCyan    = 11;
  clLightRed     = 12;
  clLightMagenta = 13;
  clYellow       = 14;
  clWhite        = 15;

const
  StdTPen: TPencere = #218#196#191#179#032#179#217#196#192;
  StdCPen: TPencere = #201#205#187#186#032#186#188#205#200;
  Std1Pen: TPencere = #219#219#219#032#032#032#032#032#032;
  Std2Pen: TPencere = #219#219#219#179#032#179#217#196#192;
  CBelirtec = '&';

var
  GoRenk,               { Pencere gîlge rengi }
  PeRenk: Byte;         { Pencere áeráeve rengi }
  Baslik: TMesaj;       { Pencere baülçßç }
  GrSeg,
  EsKursor,
  BsRenk: Word;         { Pencere baülçk rengi (Aktiflenebilir) }

function KursorNerede: Word;
procedure KursorGonder(Sutun, Satir: Byte);

function OgrenSeg: Word;
function OgrenOfs(X, Y: Byte): Word;
procedure DegistirX(X, Y, Genislik: Byte; RenkKarakter: Word);
procedure DegistirY(X, Y, Boy: Byte; RenkKarakter: Word);
procedure DegerGonder(X, Y: Byte; KarakterRenk: Word);
procedure RenkGonder(X, Y, Renk: Byte; Boy: Integer);
function BelirtecBoyHesap(const Gonderi: string): Word;
procedure Goster(
            const Mesaj: TMesaj;
            X, Y: Byte;
            Renk: Word;
            const Goster: TGoster
          );
procedure GosterLn(
            const Mesaj: TMesaj;
            X, Y: Byte;
            Renk: Word;
            const Goster: TGoster
          );
procedure Kaydir(A, B, C, D, Renk, Sayac: Byte; AsagiYukari: Boolean);
procedure DoldurPen(A, B, C, D: Byte; RenkVeKarakter: Word);
procedure Pencere(
            A,
            B,
            C,
            D: Byte;
            const Cerceve: TPencere;
            const GolgeVarMi: Boolean;
            const BaslikPozisyon: TBaslik;
            const GolgeBicim: TGolge
          );
function Merkez(X, XBoy, MesajBoy: Byte): Byte;
procedure DegistirKursor(Kursor: Word);
function OgrenKursor: Word;
procedure Kursor(Goruntu: Boolean);
function Doldur(Boy: Byte; ASCII: Char): TMesaj;
procedure Degistir(var Adres; Harita, Boy: Word);
procedure YanipSonme(Goruntu: Boolean);
procedure Golge(A, B, C, D: Byte; const Tur: TGolge);
function SutunBoy(XBoy, X: Byte): Word;
function GoruntuBoy(A, B, C, D: Byte): Word;
procedure Kopyala(Sutun, Satir, En, Boy: Byte; var Adres);
procedure Yapistir(var Adres; Sutun, Satir: Byte);
procedure Aktar(var Kaynak, Hedef; Boy: Word; const Aktarma: TAktar);
procedure SayfaOku(No: Byte);
procedure SayfaYaz(No: Byte);
procedure EkranTemizle(Renk: Byte);

implementation

function KursorNerede: Word; assembler;
asm
        MOV     AH,$03
        XOR     BX,BX
        INT     $10
        ADD     DX,$0101
        MOV     AX,DX
end;

procedure KursorGonder(Sutun, Satir: Byte); assembler;
asm
        MOV     AH,$02
        XOR     BX,BX
        MOV     DH,[Satir]
        MOV     DL,[Sutun]
        SUB     DX,$0101
        INT     $10
end;

function OgrenSeg: Word; assembler;
asm
        PUSH    ES
        MOV     AX,$0040
        MOV     ES,AX
        MOV     AX,$B800
        CMP     BYTE PTR ES:[$0049],$03
        JE      @@0
        MOV     AH,$B0
@@0:    POP     ES
end;

function OgrenOfs(X, Y: Byte): Word; assembler;
asm
        XOR     AX,AX
        MOV     AL,[Y]
        DEC     AL
        MOV     AH,$A0
        MUL     AH
        XOR     BX,BX
        MOV     BL,[X]
        DEC     BX
        SHL     BX ,$01
        ADD     AX,BX
end;

procedure DegistirX(X, Y, Genislik: Byte; RenkKarakter: Word); assembler;
asm
        CLD
        PUSH    ES
        MOV     ES,[GrSeg]
        PUSH    X[0].WORD
        PUSH    Y[0].WORD
        CALL    OgrenOfs
        MOV     DI,AX
        XOR     CX,CX
        MOV     CL,[Genislik]
        JCXZ    @@0
        MOV     AX,[RenkKarakter]
        REPE    STOSW
@@0:    POP     ES
end;

procedure DegistirY(X, Y, Boy: Byte; RenkKarakter: Word); assembler;
asm
        CLD
        PUSH    ES
        MOV     ES,[GrSeg]
        PUSH    X[0].WORD
        PUSH    Y[0].WORD
        CALL    OgrenOfs
        MOV     DI,AX
        XOR     CX,CX
        MOV     CL,[Boy]
        JCXZ    @@1
        MOV     AX,[RenkKarakter]
@@0:    STOSW
        ADD     DI,$A0 - $02
        LOOP    @@0
@@1:    POP     ES
end;

procedure DegerGonder(X, Y: Byte; KarakterRenk: Word); assembler;
asm
        CLD
        PUSH    ES
        MOV     ES,[GrSeg]
        PUSH    [X].WORD
        PUSH    [Y].WORD
        CALL    OgrenOfs
        MOV     DI,AX
        MOV     AX,[KarakterRenk]
        MOV     ES:[DI],AX
        POP     ES
end;

procedure RenkGonder(X, Y, Renk: Byte; Boy: Integer); assembler;
asm
        CLD
        PUSH    ES
        MOV     ES,[GrSeg]
        PUSH    [X].WORD
        PUSH    [Y].WORD
        CALL    OgrenOfs
        MOV     DI,AX
        MOV     CX,[Boy]
        MOV     AL,[Renk]
@@0:    INC     DI
        STOSB
        LOOPNZ  @@0
        POP     ES
end;


function BelirtecBoyHesap(const Gonderi: string): Word; assembler;
asm
        CLD
        PUSH    DS
        LDS     SI,[Gonderi]
        LODSB
        XOR     BX,BX
        XOR     CX,CX
        XOR     DX,DX
        MOV     CL,AL
        MOV     BH,CL
@@0:    LODSB
        CMP     AL,(CBelirtec)
        JNE     @@1
        INC     DL
        TEST    DL,0010B
        JNE     @@1
        ADD     BL,DL
        XOR     DL,DL
@@1:    LOOP    @@0
        XOR     AH,AH
        MOV     AL,BH
        SUB     AL,BL
        POP     DS
end;

procedure Goster(
            const Mesaj: TMesaj;
            X,
            Y: Byte;
            Renk: Word;
            const Goster: TGoster
          ); assembler;
asm
        CLD
        PUSH    ES
        PUSH    DS
        MOV     ES,[GrSeg]
        PUSH    X[0].WORD
        PUSH    Y[0].WORD
        CALL    OgrenOfs
        MOV     DI,AX
        LDS     SI,[Mesaj]
        LODSB
        OR      AL,AL
        JZ      @@2
        XOR     CX,CX
        MOV     CL,AL
        MOV     BL,[Goster].BYTE
        MOV     AH,Renk[0].BYTE
@@0:    LODSB
        OR      BL,BL
        JZ      @@1
        CMP     AL,(CBelirtec)
        JNE     @@1
        LODSB
        XCHG    Renk[1].BYTE,AH
        DEC     CX
        JCXZ    @@2
@@1:    STOSW
        LOOP    @@0
@@2:    POP     DS
        POP     ES
end;

procedure GosterLn(
            const Mesaj: TMesaj;
            X,
            Y: Byte;
            Renk: Word;
            const Goster: TGoster
          ); assembler;
asm
        CLD

        PUSH    ES

        PUSH    DS

        MOV     ES,[GrSeg]

        LDS     SI,[Mesaj]

        LODSB

        OR      AL,AL
        JZ      @@Bitti

        XOR     CX,CX
        MOV     CL,AL

        MOV     BL,[Goster].BYTE

        MOV     AH,[Renk].BYTE

        MOV     DL,[X]
        MOV     DH,[Y]

@@Ogren:
       LODSB

       CMP      AL,$0A
       JNE      @@AltSatiraMi?

       MOV      DL,[X]

       DEC      CX
       JCXZ     @@Bitti

       JMP      @@Ogren


@@AltSatiraMi?:
       CMP     AL,$0D
       JNE     @@IsaretliMi?

       INC     DH

       DEC     CX
       JCXZ    @@Bitti

       JMP     @@Ogren


@@IsaretliMi?:
       OR       BL,BL
       JZ       @@Goster

       CMP      AL,CBelirtec
       JNE      @@Goster

       LODSB

       XCHG     [Renk + 1].BYTE,AH

       DEC      CX
       JCXZ     @@Bitti

@@Goster:

       PUSH     AX
       PUSH     BX

       PUSH     DX
       XCHG     DH,DL
       PUSH     DX
       XCHG     DL,DH
       CALL     OgrenOfs

       MOV      DI,AX

       POP      BX
       POP      AX

       STOSW

       INC      DL

       LOOP     @@Ogren

@@Bitti:
       POP      DS

       POP      ES

end;

procedure Kaydir(
            A,
            B,
            C,
            D,
            Renk,
            Sayac: Byte;
            AsagiYukari: Boolean
          ); assembler;
asm
        MOV     AH,$07
        SUB     AH,[AsagiYukari]
        MOV     AL,[Sayac]
        MOV     BH,[Renk]
        MOV     CH,[B]
        MOV     CL,[A]
        MOV     DH,[D]
        MOV     DL,[C]
        SUB     CX,$0101
        SUB     DX,$0101
        INT     $10
end;

procedure DoldurPen(A, B, C, D: Byte; RenkVeKarakter: Word); assembler;
asm
        CLD
        PUSH    ES
        MOV     ES,[GrSeg]
        PUSH    [A].WORD
        PUSH    [B].WORD
        CALL    OgrenOfs
        MOV     DI,AX
        XOR     CX,CX
        MOV     CL,[D]
        SUB     CL,[B]
        INC     CX
        XOR     BX,BX
        MOV     BL,[C]
        SUB     BL,[A]
        INC     BL
        MOV     AX,[RenkVeKarakter]
@@1:    PUSH    CX
        MOV     CX,BX
        PUSH    DI
        REP     STOSW
        POP     DI
        ADD     DI,$A0
        POP     CX
        LOOP    @@1
@@0:    POP     ES
end;

procedure Pencere(
            A,
            B,
            C,
            D: Byte;
            const Cerceve: TPencere;
            const GolgeVarMi: Boolean;
            const BaslikPozisyon: TBaslik;
            const GolgeBicim: TGolge
          ); assembler;
asm
        PUSH    DS
        CMP     [GolgeVarMi],False
        JE      @@0
        XOR     AX,AX
        MOV     AL,[A]
        INC     AX
        INC     AX
        PUSH    AX
        MOV     AL,[B]
        INC     AX
        PUSH    AX
        MOV     AL,[C]
        INC     AX
        INC     AX
        PUSH    AX
        MOV     AL,[D]
        INC     AX
        PUSH    AX
        PUSH    [GolgeBicim].WORD
        CALL    Golge
@@0:    LDS     SI,[Cerceve]
        MOV     DH,[PeRenk]
        MOV     DL,DS:[SI][0]
        PUSH    [A].WORD
        PUSH    [B].WORD
        PUSH    DX
        CALL    DegerGonder
        MOV     DL,DS:[SI][2]
        PUSH    [C].WORD
        PUSH    [B].WORD
        PUSH    DX
        CALL    DegerGonder
        MOV     DL,DS:[SI][8]
        PUSH    [A].WORD
        PUSH    [D].WORD
        PUSH    DX
        CALL    DegerGonder
        MOV     DL,DS:[SI][6]
        PUSH    [C].WORD
        PUSH    [D].WORD
        PUSH    DX
        CALL    DegerGonder
        MOV     DL,DS:[SI][3]
        PUSH    [A].WORD
        XOR     BX,BX
        MOV     BL,[B]
        INC     BL
        PUSH    BX
        MOV     BL,[D]
        SUB     BL,[B]
        DEC     BL
        PUSH    BX
        PUSH    DX
        CALL    DegistirY
        MOV     DL,DS:[SI][5]
        PUSH    [C].WORD
        XOR     BX,BX
        MOV     BL,[B]
        INC     BL
        PUSH    BX
        MOV     BL,[D]
        SUB     BL,[B]
        DEC     BL
        PUSH    BX
        PUSH    DX
        CALL    DegistirY
        MOV     DL,DS:[SI][1]
        XOR     BX,BX
        MOV     BL,[A]
        INC     BL
        PUSH    BX
        PUSH    [B].WORD
        MOV     BL,[C]
        SUB     BL,[A]
        DEC     BL
        PUSH    BX
        PUSH    DX
        CALL    DegistirX
        MOV     DL,DS:[SI][7]
        XOR     BX,BX
        MOV     BL,[A]
        INC     BL
        PUSH    BX
        PUSH    [D].WORD
        MOV     BL,[C]
        SUB     BL,[A]
        DEC     BL
        PUSH    BX
        PUSH    DX
        CALL    DegistirX
        XOR     AX,AX
        MOV     DL,DS:[SI][4]
        MOV     AL,[A]
        INC     AL
        PUSH    AX
        MOV     AL,[B]
        INC     AL
        PUSH    AX
        MOV     AL,[C]
        DEC     AL
        PUSH    AX
        MOV     AL,[D]
        DEC     AX
        PUSH    AX
        PUSH    DX
        CALL    DoldurPen
        POP     DS
        PUSH    SEG [Baslik]
        PUSH    OFFSET [Baslik]
        CALL    BelirtecBoyHesap
        OR      AX,AX
        JZ      @@1
        CMP     [BaslikPozisyon],poOrta
        JB      @@2
        JA      @@3
        PUSH    [A].WORD
        PUSH    [C].WORD
        PUSH    AX
        CALL    Merkez
        JMP     @@4
@@2:    XOR     AX,AX
        MOV     AL,[A]
        INC     AL
        JMP     @@4
@@3:    XOR     BX,BX
        MOV     BL,[C]
        XCHG    AX,BX
        SUB     AX,BX
@@4:    PUSH    SEG [Baslik]
        PUSH    OFFSET [Baslik]
        PUSH    AX
        PUSH    [B].WORD
        PUSH    [BsRenk].WORD
        PUSH    goBelirt
        CALL    Goster
@@1:
end;


function Merkez(X, XBoy, MesajBoy: Byte): Byte;
var
  C: Byte;
begin
  C := (Succ(SutunBoy(XBoy, X)) div 2);
  C := (C - (MesajBoy div 2));
  C := (X + C);
  Merkez := C;
end;

procedure DegistirKursor(Kursor: Word); assembler;
asm
        MOV     AH,$01
        MOV     CX,Kursor
        INT     $10
end;

function OgrenKursor: Word; assembler;
asm
        MOV     AH,$03
        INT     $10
        XCHG    AX,CX
end;

procedure Kursor(Goruntu: Boolean);
begin
  if (not Goruntu) then
  begin
    EsKursor := OgrenKursor;
    DegistirKursor($2500);
  end else DegistirKursor(EsKursor);
end;

function Doldur(Boy: Byte; ASCII: Char): TMesaj; assembler;
asm
        CLD
        PUSH    ES
        LES     DI,@Result
        XOR     CX,CX
        MOV     CL,Boy
        JCXZ    @@0
        MOV     AL,CL
        STOSB
        MOV     AL,ASCII
        REPE    STOSB
@@0:    POP     ES
end;

procedure Degistir(var Adres; Harita, Boy: Word); assembler;
asm
        CLD
        PUSH    ES
        LES     DI,Adres
        MOV     AX,Harita
        MOV     CX,Boy
        JCXZ    @@0
        REPE    STOSW
@@0:    POP     ES
end;

procedure YanipSonme(Goruntu: Boolean); assembler;
asm
        MOV     AX,$1003
        MOV     BX,WORD PTR Goruntu
        INT     $10
end;

procedure Golge(A, B, C, D: Byte; const Tur: TGolge); assembler;
asm
        CLD
        PUSH    ES
        MOV     ES,[GrSeg]
        PUSH    WORD PTR A[0]
        PUSH    WORD PTR B[0]
        CALL    OgrenOfs
        MOV     DI,AX
        INC     DI
        PUSH    WORD PTR D[0]
        PUSH    WORD PTR B[0]
        CALL    SutunBoy
        MOV     CX,AX
        PUSH    WORD PTR C[0]
        PUSH    WORD PTR A[0]
        CALL    SutunBoy
        MOV     BX,AX
        MOV     AL,[GoRenk]
        MOV     AH,[Tur]
@@0:    PUSH    CX
        MOV     DX,DI
        MOV     CX,BX
@@1:    OR      AH,AH
        JZ      @@2
        MOV     AL,ES:[DI]
        XOR     AL,$88
@@2:    STOSB
        INC     DI
        LOOP    @@1
        MOV     DI,DX
        ADD     DI,$00A0
        POP     CX
        LOOP    @@0
        POP     ES
end;

function SutunBoy(XBoy, X: Byte): Word; assembler;
asm
        MOV     AL,[XBoy]
        MOV     AH,[X]
        SUB     AL,AH
        XOR     AH,AH
        INC     AL
end;

function GoruntuBoy(A, B, C, D: Byte): Word;
var
  Boy: Word;
begin
  Boy := (SutunBoy(C, A) * SutunBoy(D, B));
  Boy := (Boy * 2);
  Boy := (Boy + (SizeOf(A) + SizeOf(B)));
  GoruntuBoy := Boy;
end;

procedure Kopyala(Sutun, Satir, En, Boy: Byte; var Adres); assembler;
asm
        CLD

        PUSH    ES

        PUSH    DS

        MOV     DS,[GrSeg]

        LES     DI,[Adres]

        PUSH    [En].WORD
        PUSH    [Sutun].WORD
        CALL    SutunBoy

        STOSB

        MOV     DX,AX

        PUSH    [Boy].WORD
        PUSH    [Satir].WORD
        CALL    SutunBoy

        STOSB

        MOV     CX,AX

        PUSH    [Sutun].WORD
        PUSH    [Satir].WORD
        CALL    OgrenOfs

        MOV     BX,DX

        MOV     SI,AX

@@0:    PUSH    CX

        MOV     DX,SI

        MOV     CX,BX

        REP     MOVSW

        MOV     SI,DX

        ADD     SI,$00A0

        POP     CX

        LOOP    @@0


        POP     DS

        POP     ES

end;



procedure Yapistir(var Adres; Sutun, Satir: Byte); assembler;
asm
        CLD

        PUSH    ES

        PUSH    DS

        MOV     ES,[GrSeg]

        LDS     SI,[Adres]

        LODSB

        MOV     DL,AL

        PUSH    [Sutun].WORD
        PUSH    [Satir].WORD
        CALL    OgrenOfs

        MOV     DI,AX

        LODSB

        XOR     CX,CX
        MOV     CL,AL

@@0:    MOV     DH,CL

        MOV     BX,DI

        MOV     CL,DL

        REP     MOVSW

        MOV     DI,BX

        ADD     DI,$00A0

        MOV     CL,DH

        LOOP    @@0


        POP     DS

        POP     ES
end;


procedure Aktar(
            var Kaynak,
                Hedef;
            Boy: Word;
            const Aktarma: TAktar
          ); assembler;
asm
        CLD
        PUSH    DS
        PUSH    ES
        LDS     SI,Kaynak
        LES     DI,Hedef
        MOV     CX,Boy
        CMP     Aktarma,akByte
        JE      @@0
        REPE    MOVSW
        JMP     @@1
@@0:    REPE    MOVSB
@@1:    POP     ES
        POP     DS
end;

procedure SayfaOku(No: Byte);
begin
  Aktar(Ptr(GrSeg, 0)^, Ptr(GrSeg, (No * 4000))^, 2000, akWord);
end;

procedure SayfaYaz(No: Byte);
begin
  Aktar(Ptr(GrSeg, (No * 4000))^, Ptr(GrSeg, 0)^, 2000, akWord);
end;

procedure EkranTemizle(Renk: Byte);
begin
  Degistir(Ptr(GrSeg, 0)^, ((Renk * 256) + $20), 2000);
end;

begin
  GrSeg := OgrenSeg;
  GoRenk := $08;
  PeRenk := $1F;
  BsRenk := $1E1F;
  Baslik := '';
end.
