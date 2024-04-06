{  ==================================================  }
{                                                      }
{       Borland PASCAL Äalçütçrma KÅtÅphanesi          }
{       Satçr Menu Oluüturma Birimi                    }
{                                                      }
{       Fikir, Programlama: Hakan Emre KARTAL          }
{                                                      }
{  ==================================================  }

unit YatayTus;

interface

type
  TTuslarKod = (
    tkTamam,
    tkDegistir,
    tkIptal,
    tkOnce,
    tkSonra,
    tkYardim,
    tkCikis
  );

const
  CTamam = (1 shl Ord(tkTamam));
  CDegistir = (1 shl Ord(tkDegistir));
  CIptal = (1 shl Ord(tkIptal));
  COnce = (1 shl Ord(tkOnce));
  CSonra = (1 shl Ord(tkSonra));
  CYardim = (1 shl Ord(tkYardim));
  CCikis = (1 shl Ord(tkCikis));

function TusKoy(
           Deger,
           X,
           Y,
           GolgeRenk: Byte;
           Renk: Word;
           var OnayTablo;
           var TusGonderi: Word
         ): TTuslarKod;

implementation

uses Goruntu, Tuslar, Kelime, Cubuklar, SayiCvr, StrGiris;

function TusKoy(
           Deger,
           X,
           Y,
           GolgeRenk: Byte;
           Renk: Word;
           var OnayTablo;
           var TusGonderi: Word
         ): TTuslarKod;
const
  CTuslarStrBoy = 12;
  Tuslar: array[TTuslarKod] of string[CTuslarStrBoy] = (
    '  &T&amam   ',
    ' &D&eßiütir ',
    '  ò&p&tal   ',
    ' ô&n&ceki   ',
    ' S&o&nraki  ',
    '  Ya&r&dçm  ',
    '  Äç&k&çü   '
  );
  Karakterler: array[TTuslarKod] of Char = 'TDPNORK';
var
  Bas, Gonderi: Word;
  I,
  P: Byte;
  Tus,
  Cevir,
  Say,
  L: TTuslarKod;

{ Onaylanan tuüun hangisi oldußunu anlamak iáin bit deßeri test ediliyor }
  function Test: Boolean;
  begin
    Test := (Deger and (1 shl Ord(Tus)) <> 0);
  end;

  { Aktif olan tuülar ekranan listeleniyor }
  procedure TusListe;
  var
    C: TTuslarKod;
  begin
    I := 0;
    for C := tkTamam to tkCikis do
    begin
      Tus := C;
      if (Test) then
      begin
        GolgeCubuk(
          Tuslar[C],
          (X + I),
          Y,
          GolgeRenk,
          Renk
        );
        Inc(I, CTuslarStrBoy);
        Say := C;
      end;
    end;
  end;

  { Kullançlmayan tuülar geáiliyor }
  procedure TusGec(var T, C: TTuslarKod);
  var
    A, B: TTuslarKod;
  begin
    B := C;
    for A := B to tkCikis do
    begin
      Tus := A;
      if (Test) then
        Break
      else
        if (B < tkCikis) then
          Inc(B);
    end;
    C := B;
    T := A;
  end;

  procedure TusGosteri;
  begin
    if (Cevir < Say) then
      begin
        Inc(Cevir);
        Inc(I, CTuslarStrBoy);
      end
    else
      begin
        Cevir := tkTamam;
        I := 0;
      end;
  end;

begin
  TusListe;

  I := 0;

  Tus := tkTamam;
  Cevir := tkTamam;

  repeat

    TusGec(Tus, Cevir);

    Goster(BuyukHarfTurkce(Tuslar[Tus]), (X + I), Y, Swap(Renk), goBelirt);

    Bas := _NoKey;
    while (Bas = _NoKey) do Bas := Basilan;

    Gonderi := Girilen(OnayTablo, Bas);

    if (Gonderi <> 0) then
    begin
      TusGonderi := Gonderi;
      Bas := _Enter;
    end;

    P := Pos(UpCase(Chr(Bas)), Karakterler);
    if (P <> 0) then
    begin
      Tus := TTuslarKod(Pred(P));
      Bas := _Enter;
    end;

    Goster(Tuslar[Tus], (X + I), Y, Renk, goBelirt);

    case (Bas) of
      _Space, _Enter: Bas := _Enter;
      _Tab: TusGosteri;
    end;

  until (Bas = _Enter);

  TusKoy := Tus;
end;

end.