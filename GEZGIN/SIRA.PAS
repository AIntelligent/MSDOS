unit Sira;

interface

uses Arastir;

type
  TSiraFunc = function(const K, H: PDosya): Boolean;

var
  FSira: TSiraFunc;

procedure SrDuzen(Baslangic, Bitis: Integer);

function SrTarihSaat(const K, H: PDosya): Boolean;
function SrBoy(const K, H: PDosya): Boolean;
function SrOzellik(const K, H: PDosya): Boolean;
function SrAd(const K, H: PDosya): Boolean;

implementation

uses DOS;

function SrAd(const K, H: PDosya): Boolean;
begin
  SrAd := (K^.Ad < H^.Ad);
end;

function SrOzellik(const K, H: PDosya): Boolean;
begin
  if ((K^.Ozellik and Directory) = Directory)
    and ((H^.Ozellik and Directory) = Directory) then
    SrOzellik := SrAd(K, H)
  else
    SrOzellik := K^.Ozellik < H^.Ozellik;
end;

function SrBoy(const K, H: PDosya): Boolean;
begin
  SrBoy := (K^.Boy > H^.Boy);
end;

function SrTarihSaat(const K, H: PDosya): Boolean;
begin
  SrTarihSaat := (K^.TarihSaat > H^.TarihSaat);
end;

procedure SrDuzen(Baslangic, Bitis: Integer);
var
  I, J: Integer;
  A, B: PDosya;
begin
  I := Baslangic;
  J := Bitis;

  B := Liste[((I + J) shr 1)];

  repeat

    while (FSira(Liste[I], B)) do
      Inc(I);

    while (FSira(B, Liste[J])) do
      Dec(J);

    if (I <= J) then
    begin

      A := Liste[I];

      Liste[I] := Liste[J];

      Liste[J] := A;

      Inc(I);

      Dec(J);
    end;

  until (I > J);

  if (Baslangic < J) then
    SrDuzen(Baslangic, J);

  if (I < Bitis) then
    SrDuzen(I, Bitis);

end;

begin
  FSira := nil;
end.