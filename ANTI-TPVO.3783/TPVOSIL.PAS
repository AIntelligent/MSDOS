{$I+}

uses Crt, Dos;

{
  TPVOSIL/ANTI-TPVO
  Hakan Emre KARTAL
  hek@nula.com.tr
  Iskenderun/HATAY
  19/10/1998

  TPVO.3783 dosya virusunu belirtilen surucudeki tum dizin ve alt -
  dizinlerde arar. Buldugu viruslu dosyalari temizler. Eger virus -
  bellekte aktif ise kullaniciyi uyarir ve isleme baslamaz.

  It searches for the TPVO.3783 file virus in all directies and -
  subdirectories on the target drive. It cleans the infected files -
  it finds. If the virus is active in memory, it warns the user -
  and stops the process.

  Written by Hakan Emre KARTAL in Iskenderun/HATAY on 18/10/1998
}

const
  ParagrafBoy = $0200;
  KayanOfs = $103;
  BufferPozisyon = $0E87;
  StackPozisyon = $0E95;
  CodePozisyon = $0E9B;
  BelirtecBoy = $0C;

type
  TDosyalar = (COM, EXE);
  TBelirtec = array[1..(BelirtecBoy * SizeOf(Word))] of Char;
  TVirusBaslik = record
    case Byte of
      0:(W: array[1..BelirtecBoy] of Word);
      1:(C: TBelirtec);
    end;

const
  BaslikBoy = SizeOf(TVirusBaslik);
  Belirtec: TBelirtec = #$0E#$1F#$E8#$00 +
                        #$00#$5E#$83#$EE +
                        #$05#$56#$06#$B8 +
                        #$7F#$18#$BB#$53 +
                        #$44#$CD#$21#$81 +
                        #$FB#$A1#$87#$75;

  Arananlar: string = 'EXECOMDLLPRGOVROVLFONTTFFOTCPLDRV3863GR2GRCNFMOD';

  AcilisStr = #13#10#13#10'ANTi-TPVO.3783, uyarlama 1.0,1998'^J^M +
              'Hakan Emre KARTAL, Iskenderun/HATAY, 19/EKiM/1998'^J^M;

{$F+}

procedure HataliCikis;
begin
  ErrorAddr := nil;
  ExitCode := 0;
  WriteLn(^J^M'Bir hata olustu. Ltfen kontrol edip tekrar deneyiniz...');
end;

{$F-}

var
  VBaslik: TVirusBaslik;
  VBelirtec: TBelirtec;
  Hedef: file;
  Sayac: Word;
  Nesne: TDosyalar;
  Temizlenen, Viruslu,
  Toplam, P: Longint;

function Kontrol: Boolean;
begin
  Kontrol := (VBelirtec = Belirtec);
end;

function Onay: Boolean;
var
  Ch: Char;
begin
  Write(#13#10'Dosyada TPVO virs bulundu !!!');
  Write(#13#10'Temizlensin mi ? (E)vet - (H)ayir: ');
  repeat Ch := (UpCase(ReadKey)); until (Ch in ['E', 'H']);
  Onay := (Ch = 'E');
end;

procedure TemizleCOM;
var
  COM: record
    Komut: Char;
    Adres: Word;
  end;
begin
  if (FileSize(Hedef) > BaslikBoy) then
  begin
    Move(VBaslik.C, COM, SizeOf(COM));
    P := COM.Adres;
    Inc(P, +3);
    Seek(Hedef, P);
    BlockRead(Hedef, VBelirtec, BaslikBoy, Sayac);
    if (Kontrol) and (Sayac >= BaslikBoy) and (COM.Komut = #$E9) then
    begin
      if (Onay) then
      begin
        FileMode := 2;
        Close(Hedef);
        SetFAttr(Hedef, Archive);
        Reset(Hedef, 1);

        Seek(Hedef, (P + BufferPozisyon));
        BlockRead(Hedef, COM, SizeOf(COM));

        Seek(Hedef, +0);

        BlockWrite(Hedef, COM, 3);

        Seek(Hedef, P);
        Truncate(Hedef);

        Inc(Temizlenen);

        Write(' TEMiZLENDi'^J^M);
      end;
      Inc(Viruslu);
    end;
  end;
end;

procedure TemizeEXE;
begin
  P := (Longint(VBaslik.W[5]) + Longint(VBaslik.W[12]));
  P := ((P shl 4) + VBaslik.W[11]);
  Seek(Hedef, P);
  BlockRead(Hedef, VBelirtec, SizeOf(VBelirtec), Sayac);

  if (Kontrol) and (Sayac >= SizeOf(VBelirtec)) then
  begin
    if (Onay) then
    begin
      Close(Hedef);
      FileMode := 2;
      SetFAttr(Hedef, Archive);
      Reset(Hedef, 1);

      Seek(Hedef, (P + StackPozisyon));
      BlockRead(Hedef, VBaslik.W[8], 4);

      Seek(Hedef, (P + CodePozisyon));
      BlockRead(Hedef, VBaslik.W[11], 4);

      VBaslik.W[2] := (P mod ParagrafBoy);
      VBaslik.W[3] := (P shr 9);
      if (VBaslik.W[2] > 0) then Inc(VBaslik.W[3]);

      Seek(Hedef, +0);
      BlockWrite(Hedef, VBaslik, BaslikBoy);

      Seek(Hedef, P);
      Truncate(Hedef);

      Inc(Temizlenen);

      Write(' TEMiZLENDi'^J^M);
    end;
    Inc(Viruslu);
  end;
end;

procedure Temizle;
begin
  case Nesne of
    COM: TemizleCOM;
    EXE: TemizeEXE;
  end;
end;

function TPVOKontrol: Boolean;
var
  Regs: Registers;
begin
  Regs.AX := $187F;
  Regs.BX := $4453;
  MSDOS(Regs);
  TPVOKontrol := (Regs.BX = $87A1);
end;

procedure VirusAra(Yol: string);
begin
  Write(^M'Inceleniyor: ');
  TextAttr := $0E;
  Write(Yol);
  TextAttr := $07;
  ClrEol;

  Assign(Hedef, Yol);
  FileMode := 0;
  Reset(Hedef, 1);

  BlockRead(Hedef, VBaslik, BaslikBoy, Sayac);

  if (Sayac >= BaslikBoy) then
  begin
    Nesne := COM;
    if (VBaslik.W[1] = $5A4D) then Nesne := EXE;
    Temizle;
  end;
  Close(Hedef);
end;

procedure DosyaAra(Yol: string);
var
  P: Byte;
  S: string;
  Tara: SearchRec;
  B: Boolean;
begin
  S := '';
  FindFirst(Yol + '*.*', AnyFile, Tara);
  while (DOSError = 0) do
  begin
    with (Tara) do
    begin
      S := (Yol + Name + '\');
      B := (((Attr and Directory) <> 0) and (Name[1] <> '.'));
      if (B) then DosyaAra(S);
      P := Pos('.', Name);
      S := Copy(Name, (P + 1), (Length(Name) - P));
      if (Length(S) > 2) then
      begin
        P := Pos(S, Arananlar);
        if (P <> 0) then VirusAra((Yol + Name));
      end;
      Inc(Toplam);
    end;
    FindNext(Tara);
  end;
end;

procedure HedefListe;
begin
  Write(^M'Gecerli liste: ', Arananlar);
  ClrEOL;
end;

var
  Giris: string;
  Surucu: Char;
  I: Byte;
begin
  ClrScr;

  Temizlenen := 0;
  Toplam := 0;
  Viruslu := 0;

  WriteLn(AcilisStr);

  if (TPVOKontrol) then
  begin
    WriteLn('Bellekte TPVO virsne rastlandi!');
    Halt(0);
  end;

  Giris := '';

  for I := 1 to ParamCount do Giris := Giris + ParamStr(I);
  for I := 1 to Length(Giris) do Giris[I] := UpCase(Giris[I]);
  I := Pos(':', Giris);
  if (I = 0) then
  begin
    WriteLn('Src belirtilmedi.');
    WriteLn(#13#10'Kullanm TPVOSIL [Src]: /HEDEF');
    Halt(2);
  end;

  Surucu := Giris[(I - 1)];

  I := Pos('/', Giris);
  if (I <> 0) then
  begin
    Giris := Copy(Giris, (I + 1), (Length(Giris) - I));
    if (Giris = 'HEDEF') then
      repeat
        Giris := '';
        Write('Gecerli liste: ');
        HedefListe;
        WriteLn;
        Write(^H'Listeye eklenecek dosya uzantisi (EXE,COM,...): ');
        ReadLn(Giris);
        if (Length(Giris) > 3) then Giris[0] := #3;
        if (Giris <> '') then
        begin
          for I := 1 to Length(Giris) do Giris[I] := UpCase(Giris[I]);
          Arananlar := Arananlar + Giris;
        end;
        WriteLn;
      until (Giris = '');
  end;

  ExitProc := @HataliCikis;

  DosyaAra(Surucu + ':\');

  ExitProc := nil;

  GotoXY(1, WhereY);
  ClrEol;

  WriteLn('Toplam     (', Toplam:12, ') dosyadan;');
  WriteLn('Virsl    (', Viruslu:12, ') dosya bulundu,');
  WriteLn('Temizlenen (', Temizlenen:12, ') tane dosyadir.');
end.
