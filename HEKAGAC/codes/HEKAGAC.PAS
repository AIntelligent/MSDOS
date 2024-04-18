program HEKAgac(Input, Output);

uses
  Crt,
  DOS,
  Kuyruk,
  Tarayici;

const
  KOMUT_YARDIM          = '/H';
  KOMUT_HAKKINDA        = '/A';
  KOMUT_RAPOR           = '/R';
  KOMUT_AYRINTILI_RAPOR = '/E';

function ProgAd: string;
var
  S: string;
  I, J, L: Integer;
begin
  S := ParamStr(0);
  I := Length(S);

  while ((I > 0) and (S[ I ] <> '.')) do Dec(I);

  L := 0;
  J := 1;

  while ((I > 1) and (S[(I - 1)] <> '\')) do
  begin
    Dec(I);
    Inc(L);
  end;

  ProgAd := Copy(S, I, L );
end;

procedure Hakkinda;
begin
  WriteLn('HEK DiZiN AGAC, uyarlama 1.0,1996' );
  WriteLn('Hakan Emre KARTAL, Iskenderun/HATAY, 23/11/1996');
  WriteLn;
  WriteLn('https://github.com/AIntelligent, hek@nula.com.tr');
  WriteLn;
end;

procedure Yardim;
begin
  WriteLn('*** YARDIM:');
  WriteLn;
  WriteLn('Ne Yapar?');
  WriteLn;
  WriteLn('':SEKME_BOSLUK, 'Bu program belirtilen dizin ve alt dizinlerinin');
  WriteLn('':SEKME_BOSLUK, 'haritasini baglanti agaci seklinde goruntuler.');
  WriteLn;
  WriteLn('Nasil Kullanilir?');
  WriteLn;
  WriteLn('':SEKME_BOSLUK, ProgAd, ' [HedefYol] ', KOMUT_HAKKINDA, ' ',
           KOMUT_YARDIM, ' ', KOMUT_RAPOR, ' ', KOMUT_AYRINTILI_RAPOR );
  WriteLn;
  WriteLn('Komutlar ve Anlamlari:' );
  WriteLn;
  WriteLn('':SEKME_BOSLUK, 'HedefYol: Goruntulenmek istenilen dizin yoludur.' );
  WriteLn('':SEKME_BOSLUK, '          Not: Eger yol belirtilmezse, ',
          'aktif calisma dizini goruntulenir.' );
  WriteLn;
  WriteLn('':SEKME_BOSLUK, KOMUT_HAKKINDA,
          ': Bu program hakkinda bilgi goruntuler.');
  WriteLn('':SEKME_BOSLUK, KOMUT_YARDIM,
          ': Su an baktiginiz bilgileri goruntuler.');
  WriteLn('':SEKME_BOSLUK, KOMUT_RAPOR,
          ': Hedef yol hakkinda genel raporu goruntuler.');
  WriteLn('':SEKME_BOSLUK, KOMUT_AYRINTILI_RAPOR,
          ': Hedef yol hakkinda ayrintili ',
          'raporu goruntuler.');
  WriteLn('':SEKME_BOSLUK, '    Not: Bu komut sadece ', KOMUT_RAPOR,
          ' komutu ile birlikte kullanilabilir.');
  WriteLn;
end;

function DizinMi(Yol: string): Boolean;
var
  SR: SearchRec;
  I: Integer;
begin
  if (3 > Length(Yol)) then
  begin
    DizinMi := False;
    Exit;
  end;

  I := 0;
  while (Yol[Length(Yol) - I] = '.') do Inc(I);

  Yol[0] := Chr(Ord(Yol[0]) - I);

  if (Yol[Length(Yol)] <> '\') then
    Yol := Yol + '\';

  Inc(I, Ord(I = 0));

  while (I > 0) do
  begin
    Yol := Yol + '.';
    Dec(I);
  end;

  FindFirst(Yol, Directory, SR);
  DizinMi := DOSError = 0;
end;

var
  I: Integer;
  S: string;

procedure BuyukHarfeCevir;
var
  I: Integer;
begin
  for I := 1 to Length(S) do
    S[I] := UpCase(S[I]);
end;

begin
  for I := 1 to ParamCount do
  begin
    S := ParamStr(I);
    BuyukHarfeCevir;

    if (S = KOMUT_YARDIM) then
    begin
      Yardim;
      Exit;
    end;

    if (S = KOMUT_HAKKINDA) then
    begin
      Hakkinda;
      Exit;
    end;

    if (S = KOMUT_RAPOR) then
      RaporGoster := True
    else if (S = KOMUT_AYRINTILI_RAPOR) then
      AyrintiGoster := True
    else if (DizinMi(S)) then
      HedefYol := S
    else
      begin
        WriteLn( 'Hatali komut: ', S);
        Halt(1);
      end;
  end;

  if (HedefYol = '') then
    GetDir(0, HedefYol);

  Tara;

  if (RaporGoster) then
    Rapor;
end.
