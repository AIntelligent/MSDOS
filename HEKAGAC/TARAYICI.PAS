unit Tarayici;

interface

uses
  Crt,
  DOS,
  Kuyruk;

{
   18.04.2024:HEK
   DOSBox'ta sekme (tab) karakteri islevsiz oldugu -
   icin sekmeyi sabit uzunlukta boslukla degistirdim.
}
const
  SEKME_BOSLUK = 4;

var
  RaporGoster: Boolean;
  AyrintiGoster: Boolean;
  HedefYol: string;

procedure Tara;
procedure Rapor;

implementation

const
  ENCOK_SEVIYE      = 255;
  ENCOK_DIZINAD     = 12;
  ENCOK_YATAY_RAPOR = 4;
  DAL_UZUNLUK       = 3;
  ENCOK_SEVIYE_RENK = 7;

type
  TSeviyeRenkleri = array[0..(ENCOK_SEVIYE_RENK - 1)] of Byte;
  TDizinAd = string[ENCOK_DIZINAD];
  PDizin = ^TDizin;
  TDizin = packed record
    Sonraki, Sahip: PDizin;
    Uyeler: Pointer;
    Seviye: Integer;
    Ad: TDizinAd;
  end;

const
  SeviyeRenkleri: TSeviyeRenkleri = (LightBlue, LightGreen, LightCyan,
                                     LightRed, LightMagenta, Yellow,
                                     White);

var
  Dizinler: Pointer;
  SeviyeSayaclari: array[0..ENCOK_SEVIYE - 1] of Integer;
  ToplamDizinSayisi: LongInt;
  SeviyeSayisi: Byte;
  Bosluk, Dal: string[DAL_UZUNLUK];

procedure SeviyeRenginiAyarla(Seviye: Byte);
begin
  if (LastMode in [BW40, BW80, Mono]) then
    HighVideo
  else
    TextAttr := SeviyeRenkleri[(Seviye mod ENCOK_SEVIYE)];
end;

procedure SeviyeRenginiIptalEt;
begin
  if (LastMode in [BW40, BW80, Mono]) then
    LowVideo
  else
    TextAttr := LightGray;
end;

function YeniDizin(Sahip: PDizin; Ad: TDizinAd): PDizin;
var
  P: PDizin;
begin
  New(P);

  P^.Sonraki := nil;
  P^.Sahip   := Sahip;
  P^.Uyeler  := nil;
  P^.Seviye  := 0;
  P^.Ad      := Ad;

  if (Sahip = nil) then
    KuyrugaEkle(Dizinler, P)
  else
    begin
      P^.Seviye := Succ(Sahip^.Seviye);

      if (P^.Seviye > SeviyeSayisi) then
        SeviyeSayisi := P^.Seviye;

      if (Sahip^.Uyeler = nil) then
        Sahip^.Uyeler := YeniKuyruk;

      KuyrugaEkle(Sahip^.Uyeler, P);
    end;

  YeniDizin := P;
end;

{$F+}
procedure DizinSil(Dizin: Pointer);
var
  U : Pointer;
begin
  with PDizin(Dizin)^ do
  begin
    Sonraki := nil;
    Sahip := nil;

    U := Uyeler;
    Uyeler := nil;

    Seviye := -1;
    Ad := '';
  end;

  Dispose(PDizin(Dizin));

  if (U <> nil) then
    KuyrukSil(U, DizinSil);
end;
{$F-}

procedure Yoket;
var
  P: Pointer;
begin
  P := Dizinler;
  Dizinler := nil;

  KuyrukSil(P, DizinSil);

  Release(P);
end;

function SahipMi(Dizin: PDizin): Boolean;
begin
  with Dizin^do
    SahipMi := not KuyrukBosMu(Uyeler)
end;

function SonuncuMu(Dizin: PDizin): Boolean;
begin
  with Dizin^ do
    if (Sahip <> nil) then
      SonuncuMu := Sonraki = nil
    else
      SonuncuMu := False;
end;

function Baglanti(Dizin: PDizin): string;
begin
  if (SonuncuMu(Dizin)) then
    Baglanti := #$C0
  else
    Baglanti := #$C3;
end;

function Desen(Dizin: PDizin): string;
begin
  with Dizin^ do
    if (Sahip = nil) then
      Desen := ''
    else if (SahipMi(Dizin) and (not SonuncuMu(Dizin))) then
      Desen := #$B3 + Bosluk
    else
      Desen := #$20 + Bosluk;
end;

{$F+}
function DizinAgacCiz(const Dizin, Paket: Pointer): Boolean;

  function Desenler: string;
  var
    P: PDizin;
    S: string;
  begin
    P := PDizin(Dizin)^.Sahip;
    S := '';

    while (P <> nil) do
    begin
      S := Desen(P) + S;
      P := P^.Sahip;
    end;

    Desenler := S;
  end;

  function DizinStr: string;
  begin
    with PDizin(Dizin)^ do
      if (Sahip = nil) then
        DizinStr := ''
      else
        DizinStr := Desenler + Baglanti(Dizin) + Dal;
  end;

begin
  SeviyeRenginiIptalEt;
  Write(DizinStr);

  SeviyeRenginiAyarla(PDizin(Dizin)^.Seviye);
  WriteLn(PDizin(Dizin)^.Ad);

  Inc(ToplamDizinSayisi);

  with PDizin(Dizin)^ do
  begin
    if (SeviyeSayaclari[Seviye] = -1) then
      SeviyeSayaclari[Seviye] := 1
    else
      Inc(SeviyeSayaclari[Seviye]);

    if (not KuyrukBosMu(Uyeler)) then
      KuyruguGez(Uyeler, DizinAgacCiz, nil);
  end;

  DizinAgacCiz := True;
end;
{$F-}

procedure Tara;

  procedure DizinTara(Yol: string; Sahip: PDizin);
  var
    SR: SearchRec;
  begin
    if (Yol[Length(Yol)] <> '\') then
      Yol := Yol + '\';

    FindFirst( Yol + '*.*', AnyFile, SR);

    while (DOSError = 0) do
    begin
      with SR do
        if ((Name[1] <> '.') and ((Attr and Directory) <> 0)) then
          DizinTara(Yol + Name, YeniDizin(Sahip, Name));

      FindNext(SR);
    end;
  end;

begin
  DizinTara(HedefYol, YeniDizin(nil, HedefYol));
  KuyruguGez(Dizinler, DizinAgacCiz, nil);
  Yoket;
end;

procedure Rapor;

  procedure AyrintiliRapor;
  var
    I, J: Integer;
    Bitti: Boolean;

    procedure UstCizgi;
    var
      J: Integer;
    begin
      SeviyeRenginiIptalEt;

      for J := 0 to (ENCOK_YATAY_RAPOR - 1) do
      begin
        if (SeviyeSayaclari[(I + J)] = -1) then
          Break;

        Write('':SEKME_BOSLUK, #$DA#$C4#$C4#$C4#$C4#$C4#$C4#$C4#$C4#$BF );
      end;
    end;

    procedure AyracCizgisi;
    var
      J: Integer;
    begin
      SeviyeRenginiIptalEt;

      for J := 0 to (ENCOK_YATAY_RAPOR - 1) do
      begin
        if (SeviyeSayaclari[(I + J)] = -1) then
          Break;

        Write('':SEKME_BOSLUK, #$C3#$C4#$C4#$C4#$C4#$C4#$C4#$C4#$C4#$B4);
      end;
    end;

    procedure AltCizgi;
    var
      J: Integer;
    begin
      SeviyeRenginiIptalEt;

      for J := 0 to (ENCOK_YATAY_RAPOR - 1) do
      begin
        if (SeviyeSayaclari[(I + J)] = -1) then
          Break;

        Write('':SEKME_BOSLUK, #$C0#$C4#$C4#$C4#$C4#$C4#$C4#$C4#$C4#$D9);
      end;
    end;

    function SeviyeSonuMu: Boolean;
    begin
      SeviyeSonuMu := (SeviyeSayaclari[(I + J)] = -1);
    end;

  begin
    I := 0;

    while (I < ENCOK_SEVIYE) do
    begin
      Bitti := False;

      for J := 0 to (ENCOK_YATAY_RAPOR - 1) do
        if (SeviyeSonuMu) then
        begin
          Bitti := True;
          Break;
        end;

      UstCizgi;

      WriteLn;

      for J := 0 to (ENCOK_YATAY_RAPOR - 1) do
      begin
        if (SeviyeSonuMu) then
          Break;

        SeviyeRenginiIptalEt;
        Write('':SEKME_BOSLUK, #$B3);

        SeviyeRenginiAyarla(I + J);
        Write(' S: ', (I + J):3);

        SeviyeRenginiIptalEt;
        Write(' '#$B3);
      end;

      WriteLn;

      AyracCizgisi;

      WriteLn;

      for J := 0 to (ENCOK_YATAY_RAPOR - 1) do
      begin
        if (SeviyeSonuMu) then
          Break;

        SeviyeRenginiIptalEt;
        Write('':SEKME_BOSLUK, #$B3' ');

        SeviyeRenginiAyarla(I + J);
        Write(SeviyeSayaclari[(I + J)]:6);

        SeviyeRenginiIptalEt;
        Write(' '#$B3);
      end;

      WriteLn;

      AltCizgi;

      WriteLn;
      WriteLn;

      if (Bitti) then
        Break;

      Inc(I, ENCOK_YATAY_RAPOR);
    end;
  end;

begin
  TextAttr := LightGray;

  WriteLn;
  WriteLn('*** RAPOR:');
  WriteLn;
  WriteLn('':SEKME_BOSLUK, 'Hedef Yol: ', HedefYol);
  WriteLn;
  WriteLn('':SEKME_BOSLUK, 'Toplam Dizin Says: ', ToplamDizinSayisi);
  WriteLn('':SEKME_BOSLUK, 'Seviye Says: ', (1 + SeviyeSayisi));
  WriteLn;

  if (AyrintiGoster) then
    AyrintiliRapor;
end;

begin
  Dizinler := YeniKuyruk;

  FillChar(SeviyeSayaclari, SizeOf(SeviyeSayaclari), $FF);

  ToplamDizinSayisi := 0;
  SeviyeSayisi := 0;

  RaporGoster := False;
  AyrintiGoster := False;

  HedefYol := '';

  FillChar(Bosluk[1], DAL_UZUNLUK, #32);
  FillChar(Dal[1], DAL_UZUNLUK, #196);

  Bosluk[0] := Chr(DAL_UZUNLUK);
  Dal[0] := Chr(DAL_UZUNLUK);
end.