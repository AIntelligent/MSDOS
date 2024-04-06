unit Arastir;

interface

uses DOS, Tuslar;

const
  CBoslukStrBoy = 7;
  CAdStrBoy = Length('NONAME??');
  CUzantiStrBoy = Length('.PAS');
  CTarihStrBoy = Length('??/??/????');
  CSaatStrBoy = Length('??:??');
  COzellikStrBoy = Length('RHS?DAx');
  CBoyStrBoy = Length('?,???,???,???');

  CGorunenStrBoy = (
    CAdStrBoy + CBoslukStrBoy +
    CUzantiStrBoy + CBoslukStrBoy +
    CBoyStrBoy + CBoslukStrBoy +
    CTarihStrBoy + CBoslukStrBoy +
    CSaatStrBoy + CBoslukStrBoy +
    COzellikStrBoy
  );

  CBosDizinStr = '! BOû !';
  CArananlarStr = '*.*';
  CDizinStr = '<DòZòN>';
  CBirDizinUsteStr = ' öSTE ';

  CDosyaRenk = $9B;
  CDizinRenk = $9E;
  CDizinUsteRenk = $9C;
  CRenkMaske = $88;

  CArananOzellikler = (Directory or Archive);

  CSayfaBoy = 14;

const
  CEncokDosya = 8192;

type
  PDosya = ^TDosya;
  TDosya = record
    Renk: Byte;
    Isaret: Boolean;
    Ozellik: Byte;
    TarihSaat,
    Boy: Longint;
    Ad: string[CAdStrBoy + CUzantiStrBoy];
  end;

  PListe = array[1..CEncokDosya] of PDosya;

  TSuzgec = function(const Bulunan: SearchRec): Boolean;

const
  CSizeOfTDosya = SizeOf(TDosya);

  CSag = True;
  CSol = False;

{ Genel deßiükenler. }
var
  fSayfa,
  fKayit,
  sP,
  sListe,
  sDizin,
  sDosya,
  sSecilen: Integer;
  Liste: PListe;
  Renk,
  GSutun,
  GSatir: Byte;
  DizinBoy,
  SecilenBoy: Longint;
var
  Suzgec : TSuzgec;

function BirOncekiDizinAdi(DizinAdi: string): string;
function BirDizineGir(DizinAdi, DegisenAd: string): string;
procedure ListeyeKaydet;
procedure ListeBosalt;
procedure Gezgin(Adres: string);
function BoyStr(Boy: Longint): string;
function ChrEkle(Ch: Char; Boy: Byte; S: string; Nereye: Boolean): string;
function BicimStr(G: TDosya): string;

procedure GezginBaslat;
procedure GezginGorev(Basilan: TOlay);

procedure BaslikGoster(Baslik: string);

implementation

uses Goruntu, Sira_;

var
  Gecici: TDosya;
  SR: SearchRec;
  Sicra,
  iSayac: Integer;

function BirOncekiDizinAdi(DizinAdi: string): string;
var
  S: string;
begin
  S := DizinAdi;
  Dec(S[0]);
  while (S[Length(S)] <> '\') do
    Dec(S[0]);
  BirOncekiDizinAdi := S;
end;

function BirDizineGir(DizinAdi, DegisenAd: string): string;
begin
  BirDizineGir := DizinAdi + DegisenAd + '\';
end;

procedure ListeyeKaydet;
begin
  if (Liste[sListe] = nil) then
    GetMem(Liste[sListe], SizeOf(TDosya));
end;

procedure ListeBosalt;
begin
  while (Boolean(sListe)) do
  begin
    if (Liste[sListe] <> nil) then
    begin
      FreeMem(Liste[sListe], SizeOf(TDosya));
      Liste[sListe] := nil;
    end;
    Dec(sListe);
  end;
end;

procedure Gezgin(Adres: string);
var
  nCache: string;

  procedure BosMuSina;
  begin
    if (sListe <= 0) then
    begin
      sListe := 1;
      FillChar(Gecici, SizeOf(Gecici), 0);
      with (Gecici) do
      begin
        Renk := CDosyaRenk;
        Ozellik := Directory;
        Ad := CBosDizinStr;
        ListeyeKaydet;
        Liste[sListe]^ := Gecici;
      end;
    end;
  end;

  function RenkVer: Byte;
  var
    Renk: Byte;
  begin
    Renk := CDosyaRenk;

    if ((SR.Attr and Directory) = Directory) then
      begin
        Inc(sDizin);
        if (SR.Name = '..') then
          begin
            Renk := CDizinUsteRenk;
            SR.Name := CBirDizinUsteStr;
          end
        else
          Renk := CDizinRenk;
      end
    else
      Inc(sDosya);

    RenkVer := Renk;

  end;

begin

  DizinBoy := 0;

  sDosya := 0;
  sDizin := 0;

  ListeBosalt;

  sListe := 0;

  FindFirst(Adres + CArananlarStr, CArananOzellikler, SR);

  while (DOSerror = 0) do
  begin
    if (SR.Name <> '.') then
    begin
      if ((@Suzgec <> nil) and Suzgec( SR )) then
      begin
        FindNext(SR);
        Continue;
      end;

      Inc(DizinBoy, SR.Size);

      if (sListe > CEncokDosya) then
        Break;

      FillChar(Gecici, SizeOf(Gecici), 0);

      Gecici.Renk := RenkVer;

      Move(SR.Attr, Gecici.Ozellik, SizeOf(SR) - SizeOf(SR.Fill));

      Inc(sListe);

      ListeyeKaydet;

      Liste[sListe]^ := Gecici;

    end;

    FindNext(SR);

  end;

  BosMuSina;

  if (sListe > 1) then
  begin

    FSira := sOzellik;
    Sirala(1, sListe);

    FSira := sBoy;
    Sirala(Succ(sDizin), sListe);

  end;

end;


function DOzellik(Ozellik: Byte): string;
const
  OzelliklerChr: array[0..7] of Char = 'RHS?DAx';
var
  I: Byte;
  S: string;
begin
  S := '';
  for I := $00 to $07 do
    if Boolean(Ozellik and (1 shl I)) then
      if Boolean(Ozellik and Directory) then
        begin
          S := CDizinStr;
          Break;
        end
      else
        begin
          Inc(S[0]);
          S[Length(S)] := OzelliklerChr[I];
        end;
  DOzellik := S;
end;

procedure SicraAyar;
begin
  Sicra := sListe;
  if (Sicra > CSayfaBoy) then
    Sicra := CSayfaBoy;
end;

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

function BoyStr(Boy: Longint): string;
var
  S: string[13];
  I, J: Byte;
begin
  Str(Boy, S);
  J := Length(S);
  I := (Pred(J) div 3);
  while Boolean(I) do
  begin
    Insert(',', S, (J - 2));
    Dec(I);
    Dec(J, 3);
  end;
  BoyStr := S;
end;

function BicimStr(G: TDosya): string;
var
  DT: DateTime;
  Uzunluk: string[CBoyStrBoy];
  Ad: NameStr;
  Uzanti: ExtStr;
  D: DirStr;
  S: string;
begin

  UnpackTime(G.TarihSaat, DT);

  if Boolean(G.Ozellik and Directory) then
    Uzunluk := ''
  else
    Uzunluk := BoyStr(G.Boy);

  FSplit(G.Ad, D, Ad, Uzanti);
  Delete(Uzanti, 1, 1);

  S := (

    ChrEkle(' ', CAdStrBoy, Ad, False) +
    ChrEkle(' ', CUzantiStrBoy, Uzanti, True) +

    Doldur(CBoslukStrBoy, ' ') +

    TarihStr(DT.Day, DT.Month, DT.Year) +

    Doldur(CBoslukStrBoy, ' ') +

    SaatStr(DT.Hour, DT.Min) +

    Doldur(CBoslukStrBoy, ' ') +

    ChrEkle(' ', CBoyStrBoy, Uzunluk, True) +

    Doldur(CBoslukStrBoy, ' ') +

    ChrEkle(' ', COzellikStrBoy, DOzellik(G.Ozellik), False)

  );

  BicimStr := S;

end;

procedure SayfaGoster(Baslangic, Bitis: Integer);
var
  I: Integer;
  J: Byte;
begin
  J := 1;
  for I := Baslangic to Bitis do
  begin
    Goster(
      BicimStr(Liste[I]^),
      Succ(GSutun),
      (GSatir + J),
      Liste[I]^.Renk,
      goGoster
    );
    Inc(J);
  end;
end;

procedure SayfaKaydir(Boy: Byte; Nereye: Boolean);
begin
  Kaydir(
    Succ(GSutun),
    Succ(GSatir),
    ((GSutun + CGorunenStrBoy) - CBoslukStrBoy),
    (GSatir + CSayfaBoy),
    Renk,
    Boy,
    Nereye
  );
end;

procedure GezginGorev(Basilan: TOlay);


  procedure BirSatirUste;
  begin

    if (Boolean(fSayfa)) then
      Dec(fSayfa)
    else
      if (fKayit > 1) then
      begin
        Dec(fKayit);
        SayfaKaydir(1, False);
      end;

  end;


  procedure BirSatirAlta;
  begin

    if (fSayfa < Sicra) then
      Inc(fSayfa)
    else
      if (sP < sListe) then
      begin
        Inc(fKayit);
        SayfaKaydir(1, True);
      end;

  end;


  procedure BaslangicaGit;
  begin

    if (Boolean(fSayfa)) then
      fSayfa := 0
    else
      if (fKayit > 1) then
      begin
        fKayit := 1;
        SayfaGoster(1, CSayfaBoy);
      end;

  end;


  procedure BitiseGit;
  begin

    if (fSayfa < Sicra) then
      fSayfa := Sicra
    else
      if (sP < sListe) then
      begin
        fKayit := (sListe - Sicra);
        SayfaGoster(fKayit, (fKayit + Sicra));
      end;

  end;


  procedure BirSayfaUste;
  begin

    if (Boolean(fSayfa)) then
      fSayfa := 0
    else
      if (fKayit > Sicra) then
        begin
          Dec(fKayit, Sicra);
          SayfaGoster(fKayit, (fKayit + Sicra));
        end
      else
        BaslangicaGit;

  end;


  procedure BirSayfaAlta;
  begin

    if (fSayfa < Sicra) then
      fSayfa := Sicra
    else
      if (sP < (sListe - Sicra)) then
        begin
          Inc(fKayit, Sicra);
          SayfaGoster(fKayit, (fKayit + Sicra));
        end
      else
        BitiseGit;

  end;


  procedure BirTaneSec(Neresi: Integer);
  begin

    with (Liste[Neresi]^) do

      if ((Ozellik and Directory) = 0) and (Ad <> CBosDizinStr) then
      begin

        Isaret := not Isaret;
        Renk := (Renk xor CRenkMaske);

        if (Isaret) then
          begin
            Inc(sSecilen);
            Inc(SecilenBoy, Boy);
          end
        else
          begin
            Dec(sSecilen);
            Dec(SecilenBoy, Boy);
          end;

      end;

  end;


  procedure DigerleriniSec(Tazele: Boolean);
  var
    I: Integer;

  begin

    for I := 1 to sListe do
      BirTaneSec(I);

    if (Tazele) then
      SayfaGoster(fKayit, (fKayit + Sicra));

  end;


  procedure SecilenTemizle(Tazele: Boolean);
  var
    I: Integer;

  begin

    for I := 1 to sListe do

      with (Liste[I]^) do

        if (Isaret) then
        begin

          Isaret := False;
          Renk := (Renk xor CRenkMaske);

          if (sSecilen > 0) then
          begin
            Dec(sSecilen);
            Dec(SecilenBoy, Boy);
          end;

        end;

    if (Tazele) then
      SayfaGoster(fKayit, (fKayit + Sicra));

  end;


  procedure HepsiniSec;
  begin
    SecilenTemizle(False);
    DigerleriniSec(True);
  end;


begin

  case Basilan.Basilan of
    KB_Up:
      BirSatirUste;
    KB_Down:
      BirSatirAlta;
    KB_PgUp:
      BirSayfaUste;
    KB_PgDn:
      BirSayfaAlta;
    KB_Home:
      BaslangicaGit;
    KB_End:
      BitiseGit;
    KB_Insert:
      BirTaneSec(sP);
    KB_AltD:
      DigerleriniSec(True);
    KB_AltT:
      SecilenTemizle(True);
    KB_AltH:
      HepsiniSec;
  end;

end;

procedure GezginBaslat;
begin
  SicraAyar;

  DoldurPen(
    GSutun,
    GSatir,
    Succ((GSutun + CGorunenStrBoy) - CBoslukStrBoy),
    Succ(GSatir + CSayfaBoy),
    $9720
  );

  SayfaGoster(1, Sicra);
  Dec(Sicra);

  fKayit := 1;
  fSayfa := 0;

end;

procedure BaslikGoster(Baslik: string);
begin
  DegistirX(1, 1, 80, $1720);
  Goster(Baslik, Merkez(1, 80, Length(Baslik)), 1, $1F17, goBelirt);
end;

begin
  Suzgec := nil;
end.