program Anti3Virus(Input, Output);
{
  ANTI TPVI3783-TRAKIA561-OXANA, uyarlama 1.1
  Hakan Emre KARTAL
  hek@nula.com.tr
  Iskenderun/HATAY
  21/10/1999
}
uses Crt, Dos;

type
  TBaslik = record
    Imza: array[Boolean] of Char;
    ParaBoy,
    ParaSayi,
    DonusTabloNo,
    ParaBaslikBoy,
    EnAzEksPara,
    EnCokEksPara,
    SS,
    SP,
    DonusTabloBoy,
    IP,
    CS: Word;
  end;

  TVirusChar = array[1..SizeOf(TBaslik)] of Char;

  PAntiVirus = ^TAntiVirus;
  TAntiVirus = record
    Ad: string[30];
    VirusChar: TVirusChar;
    OrjBuff,
    OrjStack,
    OrjBaslangic: Longint;
    BaslaCOM,
    ParaKayma,
    SayfaKayma: Word;
    COMBuffBoy: Byte;
    Sonra: PAntiVirus;
  end;

  TAntiProc = procedure(Anti: PAntiVirus; var Baslik: TBaslik);

const
  AntiVirusBoy = SizeOf(TAntiVirus) - SizeOf(Pointer);
  BaslikBoy = SizeOf(TBaslik);
  AdresBoy = SizeOf(Word);
  VirusCharBoy = SizeOf(TVirusChar);
  ParagrafBoy = 512;

  CharTPVO3783 = (
    #$0E#$1F#$E8#$00#$00#$5E#$83#$EE#$05#$56#$06#$B8 +
    #$7F#$18#$BB#$53#$44#$CD#$21#$81#$FB#$A1#$87#$75
  );

  CharTrakia561 = (
    #$E8#$FD#$02#$B8#$88#$42#$CD#$21#$3D#$88#$42#$74 +
    #$03#$E8#$5A#$02#$E8#$A0#$02#$2E#$81#$BE#$27#$04
  );

  CharOxana = (
    #$06#$1E#$06#$E8#$00#$00#$5D#$B8#$43#$43#$CD#$21 +
    #$3D#$34#$34#$75#$02#$EB#$3B#$8C#$C0#$48#$8E#$C0
  );

  AntiTPVO3783: TAntiVirus = (
    Ad:           'TPVO.3783';   { Aranan virs }
    VirusChar:    CharTPVO3783;  { Virsn imzas }
    OrjBuff:      $0E87;         { Kontrol alan nereden baŸlyor }
    OrjStack:     $0E95;         { Asl SS:SP nereden baŸlyor }
    OrjBaslangic: $0E9B;         { Asl CS:IP nereden baŸlyor }
    BaslaCOM:     $0003;         { COM dosyada imza s‡ramadan ka‡ bayt sonra }
    ParaKayma:    $0000;         { EXE ve COM dosyann OFS'unda kayma varm }
    SayfaKayma:   $0000;         { EXE dosyann OFS'unda kayma var m }
    COMBuffBoy:   $0003;         { COM dosyaya ka‡ byte ekleme yapar }
    Sonra:        nil
  );

  AntiTrakia561: TAntiVirus = (
    Ad:           'TRAK˜A.561';
    VirusChar:    CharTrakia561;
    OrjBuff:      $0427;
    OrjStack:     $0420;
    OrjBaslangic: $041C;
    BaslaCOM:     $0003;
    ParaKayma:    $0003;
    SayfaKayma:   $000A;
    COMBuffBoy:   $0003;
    Sonra:        @AntiTPVO3783
  );

  AntiOxana: TAntiVirus = (
    Ad:           'OXANA';
    VirusChar:    CharOxana;
    OrjBuff:      $0227;
    OrjStack:     $0220;
    OrjBaslangic: $021C;
    BaslaCOM:     $0003;
    ParaKayma:    $0006;
    SayfaKayma:   $000A;
    COMBuffBoy:   $0003;
    Sonra:        @AntiTrakia561
  );

  AntiVirus: PAntiVirus = @AntiOxana;

  { Dosylar i‡inden sadece baklacak olanlar }
  Aranacaklar: string = 'COMDLLDRVEXEPRGOVLOVR';

  { BaŸka bir virs bulaŸmŸ m ? }
  VirusDevam: Boolean = False;

  Acilis = (
    'ANTi TPVO.3783 TRAK˜A.561 OXANA, uyarlama 1.1'#13#10#13#10 +
    'Hakan Emre KARTAL, hek@nula.com.tr'#13#10 +
    '21/10/1998 - Iskenderun/HATAY'#13#10
  );

var
  Hasta: file;
  Bulunan, Silinen,
  Toplam, P: Longint;
  HastaImza: TVirusChar;
  HastaBaslik: TBaslik;
  Sayac: Word;
  HataKod: Integer;

function CharKontrol(Virus: TVirusChar): Boolean;
begin
  CharKontrol := (Virus = HastaImza);
end;

function GenelKontrol(Virus: TVirusChar): Boolean;
begin
  GenelKontrol := (CharKontrol(Virus) and (Sayac >= VirusCharBoy));
end;

function OnayBekle(VirusAdi: string): Boolean;
var
  Ch: Char;
  Y: Byte;
begin
  Y := WhereY;
  WriteLn;
  Write('!!!DiKKAT!!!: ''');
  TextColor(LightRed);
  Write(VirusAdi);
  TextColor(LightGray);
  Write(''' bulundu ! '^J^M);
  Write('Temizlensin mi ? (');
  TextColor(LightCyan);
  Write('E');
  TextColor(LightGray);
  Write(')vet - (');
  TextColor(LightCyan);
  Write('H');
  TextColor(LightGray);
  Write(')ayir: ');
  repeat Ch := UpCase(ReadKey); until (Ch in ['E', 'H']);
  OnayBekle := (Ch = 'E');
  GotoXY(1, Y);
  DelLine;
  DelLine;
end;

procedure VirusIcinAc;
begin
  Close(Hasta);
  FileMode := $02;
  SetFAttr(Hasta, Archive);
  Reset(Hasta, 1);
end;

procedure VirusSayac;
begin
  ClrEOL;
  Write('TEMiZLENDi'#13#10);
  ClrEOL;
  Inc(Silinen);
end;

procedure BaslikYaz(var Baslik: TBaslik; Boy: Byte);
begin
  Seek(Hasta, +0);
  BlockWrite(Hasta, Baslik, Boy);
end;

procedure VirusAt(Pozisyon: Longint);
begin
  Seek(Hasta, Pozisyon);
  Truncate(Hasta);

  VirusSayac;
end;

function DosyaSonu(A, B, C: Word): Longint;
var
  Adres: Longint;
begin
  Adres := Longint(A) + Longint(B);
  Adres := ((Adres * Longint(16)) + Longint(C));
  DosyaSonu := Adres;
end;

{$F+}

procedure AraSilCOM(Anti: PAntiVirus; var Baslik: TBaslik);
begin
  VirusDevam := False;
  if (FileSize(Hasta) > BaslikBoy) then
    with (Baslik) do
      if (Imza[False] = #$E9) then
        with (Anti^) do
        begin
          P := 0;
          Move(Imza[True], P, AdresBoy);

          Seek(Hasta, (P + BaslaCOM));
          BlockRead(Hasta, HastaImza, VirusCharBoy, Sayac);

          if (GenelKontrol(VirusChar)) then
          begin
            Inc(Bulunan);
            if (OnayBekle(Ad)) then
            begin
              VirusIcinAc;

              Seek(Hasta, (((P + OrjBuff) + BaslaCOM) + ParaKayma));
              BlockRead(Hasta, Baslik, COMBuffBoy, Sayac);

              BaslikYaz(Baslik, COMBuffBoy);
              VirusAt((P + BaslaCOM));

              VirusDevam := True;
            end
          end;
        end;
end;

procedure AraSilEXE(Anti: PAntiVirus; var Baslik: TBaslik);
begin
  VirusDevam := False;
  with (Baslik) do
  begin
    P := DosyaSonu(ParaBaslikBoy, CS, IP);
    Seek(Hasta, P);
    BlockRead(Hasta, HastaImza, VirusCharBoy, Sayac);

    with (Anti^) do
      if (GenelKontrol(VirusChar)) then
      begin
        Inc(Bulunan);
        if (OnayBekle(Ad)) then
        begin
          Inc(Bulunan);

          VirusIcinAc;

          { Orjinal SS:SP yerine konuldu. }
          Seek(Hasta, ((P + OrjStack) + ParaKayma));
          BlockRead(Hasta, SS, SizeOf(Longint));

          { Orjinal CS:IP yerine konuldu. }
          Seek(Hasta, ((P + OrjBaslangic) + ParaKayma));
          BlockRead(Hasta, IP, SizeOf(Longint));

          ParaBoy := ((P mod ParagrafBoy) - SayfaKayma);
          ParaSayi := (P shr 9);
          if (ParaBoy > +0) then Inc(ParaSayi);

          BaslikYaz(Baslik, BaslikBoy);
          VirusAt((P - SayfaKayma));

          VirusDevam := True;
        end
      end;
    end;
end;

{$F-}

procedure Arastir(Yol: string);
var
  AntiProc: TAntiProc;
  PtrAnti: PAntiVirus;

  procedure Calistir;
  begin
    PtrAnti := AntiVirus;
    while (PtrAnti <> nil) do
    begin
      AntiProc(PtrAnti, HastaBaslik);
      PtrAnti := PtrAnti^.Sonra;
      if (VirusDevam) then Calistir;
    end;
  end;

begin
  Inc(Toplam);
  Write(#13'Arastiriliyor: ');

  TextColor(Yellow);

  Write(Yol);

  TextColor(LightGray);

  ClrEOL;

  FileMode := 0;

  Assign(Hasta, Yol);
  Reset(Hasta, 1);

  if (FileSize(Hasta) > BaslikBoy) then
  begin
    BlockRead(Hasta, HastaBaslik, BaslikBoy, Sayac);
    if (Sayac >= BaslikBoy) then
    begin
      AntiProc := AraSilCOM;
      if (HastaBaslik.Imza = 'MZ') then AntiProc := AraSilEXE;

      Calistir;

    end;
  end;

  Close(Hasta);
end;

procedure DosyaAra(Yol: string);
var
  P: Byte;
  S: string;
  Ara: SearchRec;
  B: Boolean;
begin
  S := '';
  FindFirst(Yol + '*.*', AnyFile, Ara);
  while (DOSError = 0) do
  begin
    with (Ara) do
    begin
      B := (((Attr and Directory) <> 0) and (Name[1] <> '.'));
      if (B) then DosyaAra(Yol + Name + '\');
      P := Pos('.', Name);
      S := Copy(Name, (P + 1), (Length(Name) - P));
      if (Length(S) = 3) then
      begin
        P := Pos(S, Aranacaklar);
        if (P <> 0) and ((Attr and Directory) = 0) then Arastir(Yol + Name);
      end;
    end;

    FindNext(Ara);
  end;
end;

{$F+}

procedure HataliCikis;
begin
  ErrorAddr := nil;
  ExitCode := 0;

  WriteLn;

  case DOSError of
      2: WriteLn('Dosya bulunamiyor');
      3: WriteLn('Yol bulunamiyor');
     15: WriteLn('Hatali surucu numarasi');
     18: WriteLn('Hic dosya bulunamadi');
    100: WriteLn('Disk okuma hatasi');
    101: WriteLn('Disk yazma hatasi');
    150: WriteLn('Disk salt okunur');
    152: WriteLn('Surucu okunamiyor');
    158: WriteLn('Sektor bulunamiyor');
    162: WriteLn('Donanimsal bir sorun');
    202: WriteLn('Genel bellek hatasi');
  end;
end;

{$F-}

var
  Surucu: string;

begin
  Toplam := 0;
  Bulunan := 0;
  Silinen := 0;

  CheckBreak := False;

  ClrScr;

  WriteLn(Acilis);

  Surucu := ParamStr(1);
  Surucu[1] := UpCase(Surucu[1]);

  if ((ParamCount > 0) and (Surucu[1] in ['A'..'Z'])) then
  begin
    ExitProc := @HataliCikis;

    DosyaAra(Surucu + ':\');

    ExitProc := @HataliCikis;

    if (DOSError = 18) then
    begin
      ExitProc := nil;

      GotoXY(1, WhereY);
      ClrEol;
      WriteLn('      Taranan (', Toplam:12, ') dosyada; ');
      WriteLn('toplam (', Bulunan:12, ') tane virus bulundu ve,');
      WriteLn('    temizlenen (', Silinen:12, ') tanedir.');
    end;
  end else WriteLn('Kullanim: ANTI3.EXE [Surucu]');

  CheckBreak := True;
end.
