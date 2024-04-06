unit Cubuk;

interface

uses Tuslar;

type
  TCubukBit = (
    cbTamam,
    cbDegistir,
    cbIptal,
    cbOnce,
    cbSonra,
    cbYardim,
    cbCikis,
    cbSrcA,
    cbSrcB,
    cbSrcC,
    cbSrcD,
    cbSrcE,
    cbSrcF
  );

  TCubukBitSet = set of TCubukBit;

const
  TusBitStr: array[TCubukBit] of string[10] = (
    ' Tamam ',
    ' Deßiütir ',
    ' òptal ',
    ' ônceki ',
    ' Sonraki ',
    ' Yardçm ',
    ' Äçkçü ',
    ' A: ',
    ' B: ',
    ' C: ',
    ' D: ',
    ' E: ',
    ' F: '
  );

var
  BitDeger: TCubukBitSet;
  SonAdim: TCubukBit;

  Tus,
  Cevir,
  Say: TCubukBit;

  P,
  I: Byte;

  Renk: Word;


function CbKoy(Sutun, Satir: Byte; Renk: Word; var Basilan: TOlay): TCubukBit;

implementation

uses Goruntu, Arastir;

function BitSina: Boolean;
begin
  BitSina := (Tus in BitDeger);
end;

procedure CbListe(Sutun, Satir: Byte);
var
  C: Byte;

begin
  I := Ord(cbTamam);

  for C := Ord(cbTamam) to Ord(SonAdim) do
  begin

    Tus := TCubukBit(C);

    if (BitSina) then
    begin
      Goster(TusBitStr[TCubukBit(C)], (Sutun + I), Satir, Renk, goGoster);
      Inc(I, Succ(Length(TusBitStr[TCubukBit(C)])));
      Say := TCubukBit(C);
    end;

  end;

end;

procedure BitAtla(var T, C: TCubukBit);
var
  A, B: Byte;
begin
  B := Ord(C);

  for A := B to Ord(SonAdim) do
  begin

    T := TCubukBit(A);

    if (BitSina) then
      Break
    else
      if (B < Ord(SonAdim)) then
        Inc(B);

  end;

  C := TCubukBit(B);
  T := TCubukBit(A);

end;


procedure CbGoster;
begin
  if (Cevir < Say) then
    begin
      Inc(I, Succ(Length(TusBitStr[Tus])));
      Inc(Cevir);
    end
  else
    begin
      I := Ord(cbTamam);
      Cevir := cbTamam;
    end;
end;


function CbKoy(Sutun, Satir: Byte; Renk: Word; var Basilan: TOlay): TCubukBit;
var
  gBas: TOlay;
  Cikti: Boolean;
begin
  gBas.Basilan := KB_NoKey;

  Cubuk.Renk := Renk;
  CbListe(Sutun, Satir);

  I := 0;

  Tus := cbTamam;
  Cevir := cbTamam;

  repeat

    BitAtla(Tus, Cevir);

    Goster(TusBitStr[Tus], (Sutun + I), Satir, Swap(Renk), goGoster);

    repeat
      Cikti := KeybOlay(gBas)
    until (gBas.Basilan <> KB_NoKey);

    Goster(TusBitStr[Tus], (Sutun + I), Satir, Renk, goGoster);

    if (Cikti) then
    begin
      Basilan := gBas;
      gBas.Basilan := KB_Enter;
    end;

    if (gBas.Gorev = gbGenel) and (gBas.Hangisi = Lo(KB_Tab)) or
    (gBas.Basilan = KB_Left) or (gBas.Basilan = KB_Right) then
        CbGoster;

  until (Cikti);

  CbKoy := Tus;

end;

begin
  SonAdim := cbSrcF;
end.