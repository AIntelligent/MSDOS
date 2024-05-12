program GrafikOrtamdaDijitalVeAnalogSaat(Input, Output);
{
  GRAFIK ORTAMDA DIJITAL VE ANALOG SAAT
  Hakan Emre KARTAL
  hek@nula.com.tr
  Iskenderun/HATAY
  04/05/1999
}
uses DOS, Crt, Graph;

const
  SabitAci = (Pi / 180);
  AkrepIbreKatsayi = 0.55;
  YelkovanIbreKatsayi = 0.85;
  SaniyeIbreKatsayi = 0.90;

  AkrepRenk = LightRed;
  YelkovanRenk = LightGreen;
  SaniyeRenk = Yellow;
  AnalogSaatRakamRenk = White;
  DijitalSaatYaziRenk = White;

var
  Surucu, Cozunurluk: Integer;
  DjSaatYaziX,
  DjSaatYaziY,
  AnSaatMerkezX,
  AnSaatMerkezY,
  AnSaatYariCap,
  AkrepIbreBoy,
  AkrepSonX,
  AkrepSonY,
  YelkovanIbreBoy,
  YelkovanSonX,
  YelkovanSonY,
  SaniyeIbreBoy,
  SaniyeSonX,
  SaniyeSonY: Word;

function SayidanCumleye(Sayi: Longint): string;
var
  S: string[10];
begin
  S := '';
  Str(Sayi, S);
  if (Length(S) <= 1) then S := ('0' + S);
  SayidanCumleye := S;
end;

function SinusDegeriX(KatSayi: Real; Aci: Word): Word;
begin
  SinusDegeriX := (AnSaatMerkezX + Round(KatSayi * Sin(SabitAci * Aci)));
end;

function CoSinusDegeriY(KatSayi: Real; Aci: Word): Word;
begin
  CoSinusDegeriY := (AnSaatMerkezY - Round(KatSayi * Cos(SabitAci * Aci)));
end;

procedure SaatIlkIslemler;

  procedure SaatRakamlariniYaz;
  var
    EskiRenk,
    Aci,
    K: Word;
    EskiYaziSekli: TextSettingsType;
  begin
    EskiRenk := GetColor;
    SetColor(AnalogSaatRakamRenk);
    GetTextSettings(EskiYaziSekli);
    SetTextStyle(DefaultFont, HorizDir, UserCharSize);
    SetTextJustify(CenterText, CenterText);
    for K := 1 to 12 do
    begin
      Aci := (30 * K);
      Line(
        SinusDegeriX(AnSaatYariCap, Aci),
        CoSinusDegeriY(AnSaatYariCap, Aci),
        SinusDegeriX(0.93 * AnSaatYariCap, Aci),
        CoSinusDegeriY(0.93 * AnSaatYariCap, Aci)
      );
      OutTextXY(
        SinusDegeriX(1.1 * AnSaatYariCap, Aci),
        CoSinusDegeriY(1.1 * AnSaatYariCap, Aci),
        SayidanCumleye(K)
      );
    end;

    with EskiYaziSekli do
    begin
      SetTextStyle(Font, Direction, CharSize);
      SetTextJustify(Horiz, Vert);
    end;
    SetColor(EskiRenk);
  end;

  procedure IbreIlkIslemler(
              var IbreBoy, SonX, SonY: Word;
              IbreKatSayi: Real
            );
  begin
    IbreBoy := Round(AnSaatYariCap * IbreKatSayi);
    SonX := AnSaatMerkezX;
    SonY := AnSaatMerkezY;
  end;

begin
  SetTextStyle(9, HorizDir, UserCharSize);
  SetUserCharSize(2, 1, 1, 1);
  SetColor(DijitalSaatYaziRenk);
  DjSaatYaziX := ((GetMaxX - TextWidth('99:99:99')) div 2);
  DjSaatYaziY := (GetMaxY - Round(1.2 * TextHeight('9')));
  RecTangle(0, 0, GetMaxX, DjSaatYaziY);
  RecTangle(0, DjSaatYaziY, GetMaxX, GetMaxY);
  AnSaatMerkezX := (GetMaxX div 2);
  AnSaatMerkezY := (DjSaatYaziX);
  AnSaatYariCap := Round(AnSaatMerkezY * 0.8);
  SaatRakamlariniYaz;
  IbreIlkIslemler(AkrepIbreBoy, AkrepSonX, AkrepSonY, AkrepIbreKatSayi);
  IbreIlkIslemler(
    YelkovanIbreBoy,
    YelkovanSonX,
    YelkovanSonY,
    YelkovanIbreKatSayi
  );
  IbreIlkIslemler(SaniyeIbreBoy, SaniyeSonX, SaniyeSonY, SaniyeIbreKatSayi);
end;

procedure DjAnSaatleriGuncelle;
var
  AktifSaat,
  AktifDakika,
  AktifSaniye,
  Salise,
  OncekiSaniye,
  OncekiDakika: Word;
  OnSaDaSn,
  SmSaDaSn: string[8];

  procedure DjSaatiGuncelle;
  begin
    SetColor(DijitalSaatYaziRenk);
    OutTextXY(DjSaatYaziX, DjSaatYaziY, OnSaDaSn);
    SmSaDaSn := (
      SayidanCumleye(AktifSaat) + ':' +
      SayidanCumleye(AktifDakika) + ':' +
      SayidanCumleye(AktifSaniye)
    );
    OutTextXY(DjSaatYaziX, DjSaatYaziY, SmSaDaSn);
    OnSaDaSn := SmSaDaSn;
  end;

  procedure AnSaatiGuncelle;

    procedure IbreHareket(var SonX, SonY: Word; Renk, IbreBoy, Aci: Word);
    begin
      SetColor(Renk);
      Line(AnSaatMerkezX, AnSaatMerkezY, SonX, SonY);
      SonX := SinusDegeriX(IbreBoy, Aci);
      SonY := CoSinusDegeriY(IbreBoy, Aci);
      Line(AnSaatMerkezX, AnSaatMerkezY, SonX, SonY);
    end;

  begin
    if (AktifDakika <> OncekiDakika) then
    begin
      IbreHareket(AkrepSonX, AkrepSonY, AkrepRenk, AkrepIbreBoy,
        ((AktifSaat * 30) + Round(AktifDakika / 2)));
      IbreHareket(YelkovanSonX, YelkovanSonY, YelkovanRenk,
        YelkovanIbreBoy, (AktifDakika * 6));
      OncekiDakika := AktifDakika;
    end;
    IbreHareket(SaniyeSonX, SaniyeSonY, SaniyeRenk, SaniyeIbreBoy,
      (AktifSaniye * 6));
  end;

begin
  OncekiSaniye := 61;
  OncekiDakika := 61;
  OnSaDaSn := '';

  SetWriteMode(XOrPut);

  repeat
    GetTime(AktifSaat, AktifDakika, AktifSaniye, Salise);
    if (AktifSaniye <> OncekiSaniye) then
    begin
      DjSaatiGuncelle;
      AnSaatiGuncelle;
      OncekiSaniye := AktifSaniye;
    end;
  until (KeyPressed and (ReadKey = #27));
end;

begin
  Surucu := Detect;
  InitGraph(Surucu, Cozunurluk, 'C:\TP\BGI');

  if (GraphResult <> GrOk) then
  begin
    WriteLn('Grafik srcs yklenemedi...');
    Halt;
  end;

  SetBkColor(Blue);

  SaatIlkIslemler;
  DjAnSaatleriGuncelle;

  CloseGraph;
end.
