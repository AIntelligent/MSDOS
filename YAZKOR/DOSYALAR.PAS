unit Dosyalar;

interface

uses DOS;

const
  CEncokDosya = 2048;

type
  PDosya = ^TDosya;
  TDosya = record
    Renk: Byte;
    Isaret: Boolean;
    Ozellik: Byte;
    TarihSaat,
    Boy: Longint;
    Ad: string[Succ(fsFileName + fsExtension)];
  end;

  PListe = array[1..CEncokDosya] of PDosya;

const
  CSizeOfTDosya = SizeOf(TDosya);

end.
