unit Kuyruk;

interface

type
  TGezgin = function(const Dugum, Paket: Pointer): Boolean;
  TBosalt = procedure(Dugum: Pointer);

function YeniKuyruk: Pointer;
function KuyrugaEkle(Kuyruk, Dugum: Pointer): Pointer;
function KuyruktanAl(Kuyruk: Pointer; var Dugum: Pointer): Boolean;
function KuyruguGez(Kuyruk: Pointer; Gezgin: TGezgin; Paket: Pointer): Integer;
function KuyrukOgeSayisi(Kuyruk: Pointer): Integer;
function KuyrukBosMu(const Kuyruk: Pointer): Boolean;
procedure KuyrukSil(var Kuyruk: Pointer; Bosalt: TBosalt);

implementation

type
  PDugum = ^TDugum;
  TDugum = packed record
    Sonraki: PDugum;
  end;

  PKuyruk = ^TKuyruk;
  TKuyruk = packed record
    Bas, Son: PDugum;
  end;

function YeniKuyruk: Pointer;
var
  P: PKuyruk;
begin
  New(P);

  P^.Bas := nil;
  P^.Son := nil;

  YeniKuyruk := P;
end;

function KuyrugaEkle(Kuyruk, Dugum: Pointer): Pointer;
begin
  PDugum(Dugum)^.Sonraki := nil;

  if (PKuyruk(Kuyruk)^.Bas <> nil) then
    PKuyruk(Kuyruk)^.Son^.Sonraki := Dugum
  else
    PKuyruk(Kuyruk)^.Bas := Dugum;

  PKuyruk(Kuyruk)^.Son := Dugum;
end;


function KuyruktanAl(Kuyruk: Pointer; var Dugum: Pointer): Boolean;
var
  B: Boolean;
begin
  B := (PKuyruk(Kuyruk)^.Bas <> nil);

  if (B) then
  begin
    Dugum := PKuyruk(Kuyruk)^.Bas;

    PKuyruk(Kuyruk)^.Bas := PDugum(Dugum)^.Sonraki;

    PDugum(Dugum)^.Sonraki := nil;
  end;

  KuyruktanAl := B;
end;

function KuyruguGez(Kuyruk: Pointer; Gezgin: TGezgin; Paket: Pointer) : Integer;
var
  I: Integer;
  P: PDugum;
begin
  I := 0;

  if (@Gezgin <> nil) then
  begin
    P := PKuyruk(Kuyruk)^.Bas;

    while ((P <> nil) and Gezgin(P, Paket)) do
    begin
      Inc(I);
      P := P^.Sonraki;
    end;
  end;

  KuyruguGez := I;
end;

function KuyrukOgeSayisi(Kuyruk: Pointer): Integer;
var
  I: Integer;
  P: PDugum;
begin
  I := 0;
  P := PKuyruk(Kuyruk)^.Bas;

  while (P <> nil) do
  begin
    Inc(I);
    P := P^.Sonraki;
  end;

  KuyrukOgeSayisi := I;
end;

function KuyrukBosMu(const Kuyruk: Pointer): Boolean;
begin
  if (Kuyruk <> nil) then
    KuyrukBosMu := (PKuyruk(Kuyruk)^.Bas = nil)
  else
    KuyrukBosMu := True;
end;

procedure KuyrukSil(var Kuyruk: Pointer; Bosalt: TBosalt);
var
  P: TKuyruk;
  D, S: PDugum;
begin
  P := PKuyruk(Kuyruk)^;

  PKuyruk(Kuyruk)^.Bas := nil;
  PKuyruk(Kuyruk)^.Son := nil;

  Dispose(Kuyruk);
  Kuyruk := nil;

  D := P.Bas;

  while (D <> nil) do
  begin
    S := D^.Sonraki;

    if (@Bosalt <> nil) then
      Bosalt(D)
    else
      Dispose(D);

    D := S;
  end;
end;

end.
