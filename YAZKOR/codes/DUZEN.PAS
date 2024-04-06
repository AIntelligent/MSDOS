{$F+}

unit Duzen;

interface

uses DOS, Sabit;

function ChrEkle(Ch: Char; Boy: Byte; S: string; Nereye: Boolean): string;
function TarihStr(Gun, Ay, Yil: Integer): string;
function SaatStr(Saat, Dakika: Integer): string;
function BoyStr(Boy: Longint): string;
function DegerStr(Deger: Byte): string;

implementation

function ChrEkle(Ch: Char; Boy: Byte; S: string; Nereye: Boolean): string;
var
  G: string;
begin
  G[0] := Chr(Boy);
  FillChar(G[1], Boy, Ch);
  G := Copy(G, 1, (Boy - Length(S)));
  if (Nereye) then
    G := G + S
  else
    G := S + G;
  ChrEkle := G;
end;

function TarihStr(Gun, Ay, Yil: Integer): string;
var
  T, S: string;
begin
  Str(Gun, S);
  T := ChrEkle(' ', 2, S, True);
  Inc(T[0]);
  T[Length(T)] := '/';
  Str(Ay, S);
  T := T + ChrEkle('0', 2, S, True);
  Inc(T[0]);
  T[Length(T)] := '/';
  Str(Yil, S);
  TarihStr := T + ChrEkle('0', 4, S, True);
end;

function SaatStr(Saat, Dakika: Integer): string;
var
  S, G: string;
begin
  Str(Saat, S);
  G := ChrEkle('0', 2, S, True);
  Inc(G[0]);
  G[Length(G)] := ':';
  Str(Dakika, S);
  SaatStr := G + ChrEkle('0', 2, S, True);
end;

function BoyStr(Boy: Longint): string; assembler;
asm
        PUSH    ES
        LES     DI,[@Result]
        MOV     AX,CAlanBoy
        STOSB
        MOV     CX,AX
        MOV     AL,' '
        CLD
        REP     STOSB
        MOV     BX,WORD PTR [Boy][2]
        MOV     AX,WORD PTR [Boy]
        MOV     CX,10
        XOR     SI,SI
@@0:    XOR     DX,DX
        XCHG    AX,BX
        DIV     CX
        XCHG    AX,BX
        DIV     CX
        ADD     DL,'0'
        CMP     DL,('0' + 10)
        JB      @@1
        ADD     DL,(('A' - '0') - 10)
@@1:    DEC     DI
        CMP     SI,+3
        JNE     @@2
        XOR     SI,SI
        MOV     BYTE PTR ES:[DI],','
        DEC     DI
@@2:    INC     SI
        MOV     ES:[DI],DL
        MOV     DX,AX
        OR      DX,BX
        JNE     @@0
        POP     ES
end;

function DegerStr(Deger: Byte): string;
const
  CDegerStr = 'RHS?DAx';
  CDegerStrBoy = Length(CDegerStr);
  DegerChr: array[0..CDegerStrBoy] of Char = CDegerStr;
var
  I: Byte;
  S: string[CDegerStrBoy];
begin
  S[0] := Chr(0);
  for I := 0 to CDegerStrBoy do
    if (Boolean(Deger and (1 shl I))) then
      if (Boolean(Deger and Directory)) then
        begin
          S := CDizinStr;
          Break;
        end
      else
        begin
          Inc(S[0]);
          S[Length(S)] := DegerChr[I];
        end;
  DegerStr := ChrEkle(' ', CDegerStrBoy, S, False);
end;

end.
