unit Sira_;

interface

uses Arastir;

type
  TSiraFunc = function(const K, H: PDosya): Boolean;

var
  FSira: TSiraFunc;

procedure Sirala(Baslangic, Bitis: Integer);

function sOzellik(const K, H: PDosya): Boolean;
function sTarihSaat(const K, H: PDosya): Boolean;
function sBoy(const K, H: PDosya): Boolean;
function sAd(const K, H: PDosya): Boolean;

implementation

uses DOS;

function sAd;
begin
  sAd := (K^.Ad < H^.Ad);
end;

function sBoy;
begin
  sBoy := (K^.Boy > H^.Boy);
end;

function sTarihSaat;
begin
  sTarihSaat := (K^.TarihSaat > H^.TarihSaat);
end;

function sOzellik;
var
  A, B: Byte;
begin
  A := K^.Ozellik;
  B := H^.Ozellik;
  if ((A and Directory) = Directory) and ((B and Directory) = Directory) then
    sOzellik := sAd(H, K)
  else
    sOzellik := (A < B);
end;

procedure Sirala;
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
    Sirala(Baslangic, J);

  if (I < Bitis) then
    Sirala(I, Bitis);
end;

begin
  FSira := nil;
end.
