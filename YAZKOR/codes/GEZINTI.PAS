unit Gezinti;

interface

uses DOS, Tuslar, Sabit;

const
  CGezginCikisTus = ChrAltX + ChrF3 + ChrNoKey;
  CGezginCikisTusBoy = Length(CGezginCikisTus);
  CikisStr: string[CGezginCikisTusBoy] = CGezginCikisTus;

  AramaDeger: Byte = CAramaDeger;

  GezginX: Byte = 5;
  GezginY: Byte = 3;

var
  Istenen: string;

procedure Arastir(Adres: string);
function IsListe(var Cikis; var W: Word; Adres: string): string;
procedure Gezgin(Adres: string; var BWord: Word);

implementation

uses
  Dosya,
  Goruntu,
  Duzen,
  Sira,
  Detaylar;

procedure Arastir(Adres: string);
var
  Ara: SearchRec;
  AraVeri: TDosya;

  procedure BosMuSina;
  begin
    if (Pred(ListeSayac) <= 0) then
    begin
      FillChar(AraVeri, SizeOf(AraVeri), 0);
      AraVeri.Renk := CDosyaRenk;
      AraVeri.Deger := AnyFile xor Directory;
      Inc(ListeSayac);
      AraVeri.Ad := CBosDizinStr;
      ListeyeKaydet(AraVeri, ListeSayac);
    end;
  end;

  function RenkVer: Byte;
  var
    Renk: Byte;
  begin
    Renk := CDosyaRenk;
    if Boolean(Ara.Attr and Directory) then
      begin
        Inc(DizinSayac);
        if (Ara.Name = '..') then
          Renk := 1
        else
          Renk := CDizinRenk;
      end
    else
      begin
      {
        if (Pos(CEXEBelirtec, Ara.Name) > 0) then
          Renk := CEXERenk;
      }
        Inc(DosyaSayac);
      end;
    RenkVer := Renk;
  end;

begin
  DizinBoy := 0;
  DosyaSayac := 0;
  DizinSayac := 0;
  ListeSayac := 0;

  TextAttr := CDosyaRenk;

  FillChar(Liste, SizeOf(Liste), 0);

  FindFirst(Adres + '*.*', AramaDeger, Ara);

  while (not Boolean(DOSError)) do
  begin

    if (Ara.Name <> '.') then
    begin

      Inc(ListeSayac);

      Inc(DizinBoy, Ara.Size);

      if (ListeSayac > CListeBoy) then
        Break;

      FillChar(AraVeri, SizeOf(AraVeri), 0);

      AraVeri.Renk := RenkVer;

      Move(Ara.Attr, AraVeri.Deger, (SizeOf(AraVeri) - 2));

      ListeyeKaydet(AraVeri, ListeSayac);

      GotoXY(GezginX, (GezginY + CSayfaBoy));
      Write('Bekleyiniz...');

    end;

    FindNext(Ara);

  end;

  BosMuSina;

end;

function BasilanArastir(Basilan: Word; var Hedef): Boolean;
var
  P: PWord;
begin
  BasilanArastir := False;
  if (Basilan = _NoKey) then
    Exit
  else
    begin
      P := @Hedef;
      while ((P^ <> _NoKey) and (P^ <> Basilan)) do
        Inc(Longint(P), SizeOf(Word));
      BasilanArastir := (P^ = Basilan);
    end;
end;

function IsListe(var Cikis; var W: Word; Adres: string): string;
var
  Istenen: string;
  Sicra,
  fSayfa,
  fKayit,
  IsaretSayac: Integer;
  OnayVerildi: Boolean;
  S: string[CBilgiBoy];
  Renk: Byte;

  procedure SicraAyar;
  begin
    Sicra := ListeSayac;
    if (Sicra > CSayfaBoy) then
      Sicra := CSayfaBoy;
  end;

  function BicimStr(G: TDosya): string;
  const
    SolChr: array[Boolean] of Char = ' '#16;
    SagChr: array[Boolean] of Char = ' '#17;
  var
    DT: DateTime;
    Uzunluk: string[CAlanBoy];
    Ad: string[CAdBoy];
    Uzanti: string[CCinsBoy];
  begin
    UnpackTime(G.TarihSaat, DT);
    if Boolean(G.Deger and Directory) then
      Uzunluk[0] := Chr(0)
    else
      Uzunluk := BoyStr(G.Boy);
    BicimStr := (
      SolChr[G.Isaret] +
      Chr(32) +
      ChrEkle(' ', (CAdBoy + CCinsBoy), G.Ad, True) +
      Doldur(CBoslukBoy, Chr(32)) +
      TarihStr(DT.Day, DT.Month, DT.Year) +
      Doldur(CBoslukBoy, Chr(32)) +
      SaatStr(DT.Hour, DT.Min) +
      Doldur(CBoslukBoy, Chr(32)) +
      ChrEkle(Chr(32), CAlanBoy, Uzunluk, True) +
      Doldur(CBoslukBoy, Chr(32)) +
      DegerStr(G.Deger) +
      Chr(32) +
      SagChr[G.Isaret]
    );
  end;

  procedure SyfGoster(Baslangic, Bitis: Integer);
  var
    I: Integer;
    J: Byte;
  begin
    J := 0;
    I := Baslangic;
    while (I <= Bitis) do
    begin
      S := BicimStr(Liste[I]^);
      Goster(S, GezginX, (GezginY + J), Liste[I]^.Renk, goGoster);
      Inc(J);
      Inc(I);
    end;
  end;

  procedure SyfKaydir(Boy: Byte; Nereye: Boolean);
  begin
    Kaydir(
      GezginX,
      GezginY,
      Pred(GezginX + CBilgiBoy),
      (GezginY + Sicra),
      Renk,
      Boy,
      Nereye
    );
  end;

  procedure BirSatirUste;
  begin
    if (Boolean(fSayfa)) then
      Dec(fSayfa)
    else
      if (fKayit > 1) then
      begin
        Dec(fKayit);
        SyfKaydir(1, False);
      end;
  end;

  procedure BirSatirAlta;
  begin
    if (fSayfa < Sicra) then
      Inc(fSayfa)
    else
      if (Nerede < ListeSayac) then
      begin
        Inc(fKayit);
        SyfKaydir(1, True);
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
        SyfGoster(1, CSayfaBoy);
      end;
  end;

  procedure BitiseGit;
  begin
    if (fSayfa < Sicra) then
      fSayfa := Sicra
    else
      if (Nerede < ListeSayac) then
      begin
        fKayit := (ListeSayac - Sicra);
        SyfGoster(fKayit, (fKayit + Sicra));
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
          SyfGoster(fKayit, (fKayit + Sicra));
        end
      else
        BaslangicaGit;
  end;

  procedure BirSayfaAlta;
  begin
    if (fSayfa < Sicra) then
      fSayfa := Sicra
    else
      if (Nerede < (ListeSayac - Sicra)) then
        begin
          Inc(fKayit, Sicra);
          SyfGoster(fKayit, (fKayit + Sicra));
        end
      else
        BitiseGit;
  end;

  procedure BirTaneSec(Neresi: Integer);
  begin
    with (Liste[Neresi]^) do
      if (Deger and Directory = 0) and (Ad <> CBosDizinStr) then
      begin
        Isaret := not Isaret;
        Renk := (Renk xor $FF);
      end;
  end;

  procedure DigerleriniSec;
  var
    P: Integer;
  begin
    P := 1;
    while (P <= ListeSayac) do
    begin
      BirTaneSec(P);
      Inc(P);
    end;
    SyfGoster(fKayit, (fKayit + Sicra));
  end;

  procedure SecimKaldir;
  var
    P: Integer;
  begin
    P := 1;
    while (P <= ListeSayac) do
    begin
      with (Liste[P]^) do
        if (Isaret) then
        begin
          Isaret := False;
          Renk := (not Renk);
        end;
      Inc(P);
    end;
    SyfGoster(fKayit, (fKayit + Sicra));
  end;

  procedure DizinBilgisiniGoster;
  var
    S: string;
  begin

    S := Adres;
    if (Length(S) > Pred(CBilgiBoy)) then
    begin
      S[0] := Chr(CBilgiBoy);
      S := S + CUzunBaslikStr;
    end;
    S := Chr(32) + S + Doldur(((CBilgiBoy - Length(S)) - 1), Chr(32));
    Goster(S, GezginX, (GezginY + CSayfaBoy + 1), CDizinRenk, goGoster);
    S := CBelirtec + ChrEkle(
           Chr(32),
           CAlanBoy,
           BoyStr(DosyaSayac),
           True
         ) + CBelirtec + ' dosya, ' + CBelirtec +
         ChrEkle(
           Chr(32),
           CAlanBoy,
           BoyStr(DizinSayac),
           True
         ) + CBelirtec + ' dizin, ' + CBelirtec +
         ChrEkle(
           Chr(32),
           CAlanBoy,
           BoyStr(DizinBoy),
           True
         ) + CBelirtec + ' byte.';
    Goster(S, GezginX, (GezginY + CSayfaBoy + 2), $3930, goBelirt);

  end;

var
  sListeStr: string[6];

begin

  OnayVerildi := False;

  Istenen[0] := Chr(0);

  SicraAyar;

  if (Boolean(Sicra)) then
  begin

    TextAttr := CDosyaRenk;

    Str(ListeSayac, sListeStr);
    sListeStr := ChrEkle(' ', 6, sListeStr, False);

    DizinBilgisiniGoster;

    SyfGoster(1, Sicra);

    Dec(Sicra);

    fKayit := 1;
    fSayfa := 0;

    repeat

      Nerede := (fKayit + fSayfa);

      GotoXY(GezginX, GezginY + CSayfaBoy);
      Write(sListeStr);

      S := BicimStr(Liste[Nerede]^);

      Renk := Liste[Nerede]^.Renk;

      Goster(S, GezginX, (GezginY + fSayfa), (Renk xor $2F), goGoster);

      W := _NoKey;
      while (W = _NoKey) do
        W := Basilan;

      OnayVerildi := BasilanArastir(W, Cikis);

      Goster(S, GezginX, (GezginY + fSayfa), Renk, goGoster);

      case (W) of
        _Up:
          BirSatirUste;
        _Down:
          BirSatirAlta;
        _PgUp:
          BirSayfaUste;
        _PgDn:
          BirSayfaAlta;
        _Home:
          BaslangicaGit;
        _End:
          BitiseGit;
        _Insert:
          BirTaneSec(Nerede);
        _Alt_D:
          DigerleriniSec;
        _Alt_K:
          SecimKaldir;
      end;

    until (OnayVerildi);

    Istenen := Liste[Nerede]^.Ad;

  end;

  IsListe := Istenen;

end;

procedure Gezgin(Adres: string; var BWord: Word);
const
  COnayStr = (
    ChrEnter +
    ChrAltX +
    ChrCtrlPgUp +
    ChrF3 +
    ChrF2 +
    ChrNoKey
  );
  COnayStrBoy = Length(COnayStr);
  OnayStr: string[COnayStrBoy] = COnayStr;

  EskiHeap: Pointer = nil;

begin

  repeat

    if (EskiHeap = nil) then
      Mark(EskiHeap);

    Arastir(Adres);

    SiraFunc := DegereGore;
    Sira.Duzen(1, ListeSayac);

    SiraFunc := BoyaGore;
    Sira.Duzen(DizinSayac + 1, ListeSayac);

    Baslik := ' GEZGN ';
    PeRenk := CDosyaRenk;
    BsRenk := CDizinRenk;
    Pencere(
      Pred(GezginX),
      Pred(GezginY),
      (GezginX + CBilgiBoy),
      (GezginY + CSayfaBoy + 3),
      StdTPen,
      True,
      poSol,
      goRenkVer
    );

    DegerGonder(
      Pred(GezginX),
      (GezginY + CSayfaBoy),
      ((CDosyaRenk * 256) + 195)
    );

    DegerGonder(
      (GezginX + CBilgiBoy),
      (GezginY + CSayfaBoy),
      ((CDosyaRenk * 256) + 180)
    );

    DegistirX(
      GezginX,
      (GezginY + CSayfaBoy),
      CBilgiBoy,
      ((CDosyaRenk * 256) + 196)
    );


    Istenen := IsListe(OnayStr[1], BWord, Adres);

    case (BWord) of
      _Enter:
        with (Liste[Nerede]^) do
          if (Ad <> '..') or (Ad <> CBosDizinStr) then
            if (Boolean(Deger and Directory)) then
              begin
                Release(EskiHeap);
                EskiHeap := nil;
                Gezgin(Adres + Istenen + '\', BWord);
              end
            else
              BWord := _NoKey;
      _F2:
        begin
          BWord := _Alt_X;
          Istenen := Adres + Istenen;
        end;
    end;

  until (BasilanArastir(BWord, CikisStr[1]));

  if (EskiHeap <> nil) then
  begin
    Release(EskiHeap);
    EskiHeap := nil;
  end;

end;


end.
