unit GrSakla;

interface

uses Goruntu;

type
  PGoruntuSaklayici = ^TGoruntuSaklayici;
  TGoruntuSaklayici = record
    EskiSutunSatir: Word;
    GrSutun,
    GrSatir: Byte;
    Boy: Word;
    Adres: Pointer;
    Sonra: PGoruntuSaklayici;
  end;

var
  Saklayici: PGoruntuSaklayici;

procedure GSakla(Sutun, Satir, En, Boy: Byte);
procedure GGeriVer;

implementation



procedure GSakla(Sutun, Satir, En, Boy: Byte);
var
  P: PGoruntuSaklayici;
  W: Word;
begin
  GetMem(P, SizeOf(TGoruntuSaklayici));

  P^.EskiSutunSatir := KursorNerede;

  P^.GrSutun := Sutun;
  P^.GrSatir := Satir;
  W := GoruntuBoy(Sutun, Satir, En, Boy);
  P^.Boy := W;
  GetMem(P^.Adres, W);
  Kopyala(Sutun, Satir, En, Boy, P^.Adres^);
  P^.Sonra := Saklayici;
  Saklayici := P;
end;

procedure GGeriVer;
var
  P: PGoruntuSaklayici;
begin
  P := Saklayici;
  with (P^) do
  begin

    KursorGonder(Lo(EskiSutunSatir), Hi(EskiSutunSatir));

    Yapistir(Adres^, GrSutun, GrSatir);
    FreeMem(Adres, Boy);
    P := Sonra;
    FreeMem(Saklayici, SizeOf(TGoruntuSaklayici));
  end;
  Saklayici := P;
end;

begin
  Saklayici := nil;
end.
