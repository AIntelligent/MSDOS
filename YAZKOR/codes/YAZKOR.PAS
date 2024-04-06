{
  YAZILIM KORUYUCU (YAZKOR) EKLEY˜C˜ YARDIMCI ARACI
  Hakan Emre KARTAL
  hek@nula.com.tr
  25/07/2000

  Bu yardmc ara‡; geliŸtirdi§iniz programlarnzn
  izinsiz kopyalanmasn ”nleyen ve Ÿifre ile kullanlmasn
  sa§layan YAZILIM KORUYUCU eklentisini, belirledi§iniz
  ‡alŸabilir (EXE,COM) dosyalara kolayca eklemenizi sa§lar.

  Not: Bahsedilen YAZILIM KORUYUCU eklentisi, MS-DOS iŸletim sistemi
  i‡in geliŸtirilen programlar korumaktadr. YAZILIM KORUYUCU, daha
  sonraki yllarda MS-Windows 32bit ve 64bit i‡in uyarlanmŸ ve halen
  kullanlabilir durumdadr. Bu sebeple kasten bu kodlardan ‡kartlmŸtr.

  This helpful tool; It allows to easily added the YAZILIM KORUYUCU
  plug-in, which prevents your developed programs from being copied
  without permission and allows them to be used with a password,
  to the executable (EXE,COM) files you specify.

  Note: YAZILIM KORUYUCU plug-in in question protects programs developed
  by MS-DOS operating system. YAZILIM KORUYUCU was adapted for MS-Windows
  32bit and 64bit operating systems in later years and is still available.
  For this reason, it was deliberately omitted from these codes.

  Written by Hakan Emre KARTAL in Iskenderun/HATAY on 25/07/2000
}
uses
  DOS,
  Goruntu,
  Arastir,
  Tuslar,
  Sira,
  GrSakla,
  Cubuk;

const
  Hedef: string = '';
  B: Boolean = False;

function CBW(Hi, Lo: Byte): Word; assembler;
asm
        MOV     AH,[Hi]
        MOV     AL,[Lo]
end;

procedure Baslat(Sutun, Satir: Byte);
const
  CAltZeminRenk = $97;
  CBilgilerSatirBoy = 4;
  CTuslarRenk = $F0;
  CTusSatirBoy = 2;
  CTuslarUyariRenk = $FCF0;
  CTuslarStr = (
    '&Alt+X&-€kŸ &'#$19#$18'&-Yukar/AŸa§ &PgUp&/&Dn&-Sayfa Yukar/AŸa§ ' +
    '&Home&-˜lk &End&-Son'#13#10 +
    '&F1&-Yardim &F2&-Src &F5&-Hakknda &Ins&-˜Ÿaretle/Brak &Alt+T&-˜ptal'#13#10 +
    '&Alt+D&-Di§erlerini se‡ &Alt+H&-Hepsini se‡ &F3&-Dosyalar iŸle ' +
    '&Enter&-Dosyay iŸle'
  );

var
  CubukSatir: Byte;

begin

  GSakla(1, 1, 80, 25);

  Kursor(False);

  YanipSonme(False);

  EkranTemizle(CAltZeminRenk);

  GSutun := Sutun;
  GSatir := Satir;

  BaslikGoster('&YAZILIM KORUYUCU&, Uyarlama 1.03');

  CubukSatir := ((GSatir + CSayfaBoy) + 2);

  DegistirX(1, CubukSatir, 80, CBW(CAltZeminRenk, 196));

  Inc(CubukSatir, CBilgilerSatirBoy);

  DegistirX(1, CubukSatir, 80, CBW(CTuslarRenk, 196));

  Inc(CubukSatir);

  DoldurPen(
    1,
    CubukSatir,
    80,
    (CubukSatir + CTusSatirBoy),
    CBW(CTuslarRenk, 32)
  );

  GosterLn(CTuslarStr, 2, CubukSatir, CTuslarUyariRenk, goBelirt);

end;


procedure Bitir;
begin
  GGeriVer;
  YanipSonme(False);
  Kursor(True);
end;


procedure DizinBilgisiGoster(Adres: string);
const
  CFaalDizinRenk = $9A;
  CDizinBilgiRenk = $979E;
  CAdresStrBoy = 78;
begin

  if (Length(Adres) > CAdresStrBoy) then
    Adres[0] := Chr(CAdresStrBoy);

  Goster(
    ChrEkle(' ', CAdresStrBoy, Adres, False),
    2,
    19,
    CFaalDizinRenk,
    goGoster
  );

  Goster(
    '&Toplam  &' +
    ChrEkle(' ', CBoyStrBoy, BoyStr(sDosya), True) + '& Dosya  &' +
    ChrEkle(' ', CBoyStrBoy, BoyStr(DizinBoy), True) + '& Byte  &' +
    ChrEkle(' ', CBoyStrBoy, BoyStr(sDizin), True) + '& Dizin',
    2, 20,
    CDizinBilgiRenk,
    goBelirt
  );

end;


procedure SecilenBilgisiGoster;
const
  CDizinBilgiRenk = $979B;
begin
  Goster(
    '&Se‡ilen &' +
    ChrEkle(' ', CBoyStrBoy, BoyStr(sSecilen), True) + '& Dosya  &' +
    ChrEkle(' ', CBoyStrBoy, BoyStr(SecilenBoy), True) + '& Byte',
    2,
    21,
    CDizinBilgiRenk,
    goBelirt
  );
end;


procedure GezginCalistir(var O: TOlay);
var
  S: string[CGorunenStrBoy];
begin
  SecilenBilgisiGoster;

  sp := (fKayit + fSayfa);

  Goster(
    '&' + ChrEkle('ú', 5, BoyStr(sListe), True) + '&:&' +
    ChrEkle('ú', 5, BoyStr(sP), True),
    68,
    ((GSatir + CSayfaBoy) + 2),
    $9F97,
    goBelirt
  );

  Renk := Liste[sP]^.Renk;

  S := BicimStr(Liste[sP]^);

  Goster(
    S,
    Succ(GSutun),
    Succ(GSatir + FSayfa),
    (clBlack * 16) + (Renk and $0F),
    goGoster
  );


  repeat
    KeybOlay(O);
  until (O.Basilan <> KB_NoKey);

  RenkGonder(
    Succ(GSutun),
    Succ(GSatir + FSayfa),
    Renk,
    (CGorunenStrBoy - CBoslukStrBoy)
  );

end;


procedure Hakkinda(Sutun, Satir: Byte);
const
  CEncokHakkindaStr = 6;

  HakkindaStr: array[1..CEncokHakkindaStr] of string[25] = (
    '&YAZILIM KORUYUCU',
    'Uyarlama 1.03',
    'Hakan Emre KARTAL',
    '25/07/2000',
    '˜skenderun/HATAY',
    'hek@nula.com.tr'
  );

  CHakkindaPEn = 32;
  CHakkindaPBoy = CEncokHakkindaStr;

  CHakkindaPenRenk = $6F;
  CHakkindaBaslikRenk = $F6;
  CHakkindaGolgeRenk = $60;

var
  I: Byte;
  O: TOlay;
begin

  GSakla(
    Sutun,
    Satir,
    ((Sutun + CHakkindaPEn) + 2),
    (((Satir + CHakkindaPBoy) * 2) + 1)
  );

  PeRenk := CHakkindaPenRenk;
  BsRenk := CHakkindaBaslikRenk;
  GoRenk := CHakkindaGolgeRenk;

  Baslik := 'HAKKINDA';

  Pencere(
    Sutun,
    Satir,
    (Sutun + CHakkindaPEn),
    (((Satir + CHakkindaPBoy) * 2) - 1),
    Std1Pen,
    True,
    poOrta,
    goDegistir
  );

  for I := 1 to CEncokHakkindaStr do
    Goster(
      HakkindaStr[I],
      Merkez(Sutun, (Sutun + CHakkindaPEn), Length(HakkindaStr[I])),
      ((I * 2) + Satir),
      $6F6B,
      goBelirt
    );

  Ayricalik.Gorev := gbGenel;
  Ayricalik.Secilen := [Lo(KB_Enter), Lo(KB_Space)];
  BitDeger := [cbTamam];
  CbKoy(
      (Sutun + 2),
      (((Satir + CHakkindaPBoy) * 2) - 2),
      $1FF6,
      O
    );

  GGeriVer;

end;

procedure Yardim(Sutun, Satir: Byte);
const
  CEncokYardimStr = 4;

  YardimStr: array[1..CEncokYardimStr] of string[58] = (
    'Bu yardmc ara‡; geliŸtirdi§iniz programlarnzn',
    'izinsiz kopyalanmasn ”nleyen ve Ÿifre ile kullanlmasn',
    'sa§layan &YAZILIM KORUYUCU& eklentisini, belirledi§iniz',
    '‡alŸabilir (EXE,COM) dosyalara kolayca eklemenizi sa§lar.'
  );

  CYardimPEn = 61;
  CYardimPBoy = CEncokYardimStr;

  CYardimPenRenk = $2F;
  CYardimBaslikRenk = $F2;
  CYardimGolgeRenk = $20;

var
  I: Byte;
  O: TOlay;
begin

  GSakla(
    Sutun,
    Satir,
    ((Sutun + CYardimPEn) + 2),
    (((Satir + CYardimPBoy) * 2) + 2)
  );

  PeRenk := CYardimPenRenk;
  BsRenk := CYardimBaslikRenk;
  GoRenk := CYardimGolgeRenk;

  Baslik := ' YARDIM ';

  Pencere(
    Sutun,
    Satir,
    (Sutun + CYardimPEn),
    ((Satir + CYardimPBoy) + 4),
    Std1Pen,
    True,
    poOrta,
    goDegistir
  );

  for I := 1 to CEncokYardimStr do
    Goster(
      YardimStr[I],
      Sutun + 2,
      (I + Satir + 1),
      $2E2F,
      goBelirt
    );

  Ayricalik.Gorev := gbGenel;
  Ayricalik.Secilen := [Lo(KB_Enter), Lo(KB_Space), Lo(KB_Escape)];
  BitDeger := [cbTamam];
  CbKoy((Sutun + 2), Pred(Satir + CYardimPBoy * 2), $1FF0, O);

  GGeriVer;

end;

procedure Isle(Secilen: string);
const
  CSecilenPSatir = 10;
  CSecilenPSutun = 5;
  CSecilenPEn = 70;
  CSecilenPBoy = 5;
var
  I: Byte;
  O: TOlay;
begin

  GSakla(CSecilenPSutun, CSecilenPSatir, CSecilenPEn, CSecilenPBoy);

  PeRenk := $4F;
  BsRenk := $F4;
  GoRenk := $40;

  Baslik := ' ˜LENECEK DOSYA ';

  Pencere(
      CSecilenPSutun,
      CSecilenPSatir,
      CSecilenPSutun + CSecilenPEn,
      CSecilenPSatir + CSecilenPBoy,
      Std1Pen,
      True,
      poSol,
      goDegistir
    );

  Goster(
      '&Se‡ilen&: ' + Secilen,
      CSecilenPSutun + 2,
      CSecilenPSatir + 2, $4E4F,
      goBelirt
    );

  Ayricalik.Gorev := gbGenel;
  Ayricalik.Secilen := [Lo(KB_Enter), Lo(KB_Space), Lo(KB_Escape)];
  BitDeger := [cbTamam];
  CbKoy(
      CSecilenPSutun + 2,
      CSecilenPSatir + CSecilenPBoy - 1,
      $1FF0,
      O
    );

  GGeriVer;

end;

function SurucuSec(Sutun, Satir: Byte): Char;
const
  CPenRenk = $F5;
  CBaslikRenk = $5F;
  CGolgeRenk = $70;
  CSurucuSayisi = 4;
  CSuruculerRenk = $5FF5;

var
  O: TOlay;
  L: Byte;

begin

  L := Succ((Length(TusBitStr[cbSrcA]) * CSurucuSayisi) + CSurucuSayisi);


  GSakla(
    Pred(Sutun),
    Pred(Satir),
    ((Sutun + L) + 2),
    (Satir + 3)
  );

  Baslik := 'Srcy se‡iniz.';
  PeRenk := CPenRenk;
  BsRenk := CBaslikRenk;
  GoRenk := CGolgeRenk;
  Pencere(
    Pred(Sutun),
    Pred(Satir),
    (Sutun + L),
    (Satir + 2),
    Std1Pen,
    True,
    poSol,
    goDegistir
  );

  Ayricalik.Gorev := gbGenel;
  Ayricalik.Secilen := [Lo(KB_Enter), Lo(KB_Space)];

  BitDeger := [cbSrcA, cbSrcC, cbSrcD, cbSrcE];
  SurucuSec := (
    Chr(
      (
        Ord(
          CbKoy(
            Succ(Sutun),
            Succ(Satir),
            CSuruculerRenk,
            O
          )
        ) - Ord(cbSrcA)
      ) + Ord('A')
    )
  );

  if (Hi(O.Basilan) = Lo(KB_Escape)) then
    SurucuSec := #255;

  GGeriVer;

end;

var
  Surucu: Char;
  O: TOlay;

{$F+}
{ Hedeflenen dosyalar dŸndakiler ge‡ilecek }
function HedefSuzgec(const Bulunan: SearchRec): Boolean;

  function UzantiAl: string;
  var
    i: Integer;
  begin
    with Bulunan do
    begin
      i := Pos( '.', Name);
      UzantiAl := Copy( Name, i + 1, Length(Name) - i);
    end;
  end;

  function OzellikSarti: Boolean;
  begin
    with Bulunan do
      OzellikSarti := (((Attr and SysFile) = SysFile)
                        or ((Attr and Hidden) = Hidden)
                        or ((Attr and ReadOnly) = ReadOnly));
  end;

  function UzantiSarti: Boolean;
  begin
    UzantiSarti := (Pos(UzantiAl, 'EXECOM') = 0);
  end;

begin
  with Bulunan do
    if ((Attr and Directory) <> Directory) then
      HedefSuzgec := OzellikSarti or UzantiSarti
    else
      HedefSuzgec := False;
end;
{$F-}

begin
  Suzgec := HedefSuzgec;

  Hedef := ParamStr(1);
  if (Hedef = '') then
  begin
    GetDir(0, Hedef);
    Inc(Hedef[0]);
    Hedef[Length(Hedef)] := '\';
  end;

  Baslat(2, 2);

  repeat

    Gezgin(Hedef);

    GezginBaslat;

    DizinBilgisiGoster(Hedef);

    repeat

      GezginCalistir(O);

      GezginGorev(O);

      case (O.Gorev) of

        gbGenel:
          case (O.Hangisi) of
            Lo(KB_Enter):
              with (Liste[sP]^) do
                if (Ad = CBirDizinUsteStr) then
                  Hedef := BirOncekiDizinAdi(Hedef)
                else if Boolean(Ozellik and $10) and (Ad <> CBosDizinStr) then
                  Hedef := BirDizineGir(Hedef, Liste[sP]^.Ad)
                else
                  Isle(Hedef + Liste[sP]^.Ad);
          end;
        gbIslev:
          case (O.Hangisi) of
            Hi(KB_F1): Yardim(10, 9);
            Hi(KB_F5): Hakkinda(24, 5);
            Hi(KB_F2):
              begin
                Surucu := SurucuSec(5, 10);
                if (Hedef[1] <> Surucu) and (Surucu <> #255) then
                begin
                  Hedef := Surucu + ':\';
                  O.Basilan := Swap(KB_Enter);
                end;
              end;
            Hi(KB_F3): Write(^G);
          end;
      end;

    until (O.Basilan = KB_AltX) or (Hi(O.Basilan) = Lo(KB_Enter));

    ListeBosalt;

  until (O.Basilan = KB_AltX);

  Bitir;

end.
