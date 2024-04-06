{  ===========================================================  }
{                                                               }
{       Borland PASCAL €alŸtrma Ktphanesi                   }
{       Klavye Kullanm Birimi                                  }
{                                                               }
{       Fikir, Kodlama, Programlama Hakan Emre KARTAL           }
{                                                               }
{  ===========================================================  }

{$F+,O+}

unit Tuslar;

interface

const

  KB_Escape     = $011B;
  KB_Back       = $0E08;

  KB_CtrlBack  = $0E7F;
  KB_CtrlDel   = $0600;
  KB_CtrlEnd   = $7500;
  KB_CtrlEnter = $1C0A;
  KB_CtrlHome  = $7700;
  KB_CtrlIns   = $0400;
  KB_CtrlLeft  = $7300;
  KB_CtrlPgDn  = $7600;
  KB_CtrlPgUp  = $8400;
  KB_CtrlPrtSc = $7200;
  KB_CtrlRight = $7400;

  KB_Delete    = $5300;
  KB_Down      = $5000;
  KB_End       = $4F00;
  KB_Enter     = $1C0D;
  KB_GrayMinus = $4A2D;
  KB_GrayPlus  = $4E2B;
  KB_Home      = $4700;
  KB_Insert    = $5200;
  KB_Left      = $4B00;

  KB_AltEqual  = $8300;
  KB_AltMinus  = $8200;
  KB_AltSpace  = $0200;

  KB_AltA      = $1E00;
  KB_AltB      = $3000;
  KB_AltC      = $2E00;
  KB_AltD      = $2000;
  KB_AltE      = $1200;
  KB_AltF      = $2100;
  KB_AltG      = $2200;
  KB_AltH      = $2300;
  KB_AltI      = $1700;
  KB_AltJ      = $2400;
  KB_AltK      = $2500;
  KB_AltL      = $2600;
  KB_AltM      = $3200;
  KB_AltN      = $3100;
  KB_AltO      = $1800;
  KB_AltP      = $1900;
  KB_AltQ      = $1000;
  KB_AltR      = $1300;
  KB_AltS      = $1F00;
  KB_AltT      = $1400;
  KB_AltU      = $1600;
  KB_AltV      = $2F00;
  KB_AltW      = $1100;
  KB_AltX      = $2D00;
  KB_AltY      = $1500;
  KB_AltZ      = $2C00;

  KB_NoKey     = $0000;

  KB_PgDn      = $5100;
  KB_PgUp      = $4900;
  KB_Right     = $4D00;
  KB_ShiftDel  = $0700;
  KB_ShiftIns  = $0500;
  KB_ShiftTab  = $0F00;
  KB_Tab       = $0F09;
  KB_Up        = $4800;
  KB_BackSpace = $0E08;

  KB_F1        = $3B00;
  KB_F2        = $3C00;
  KB_F3        = $3D00;
  KB_F4        = $3E00;
  KB_F5        = $3F00;
  KB_F6        = $4000;
  KB_F7        = $4100;
  KB_F8        = $4200;
  KB_F9        = $4300;
  KB_F10       = $4400;

  KB_Alt1      = $7800;
  KB_Alt2      = $7900;
  KB_Alt3      = $7A00;
  KB_Alt4      = $7B00;
  KB_Alt5      = $7C00;
  KB_Alt6      = $7D00;
  KB_Alt7      = $7E00;
  KB_Alt8      = $7F00;
  KB_Alt9      = $8000;
  KB_Alt0      = $8100;


  KB_ShiftF1   = $5400;
  KB_ShiftF2   = $5500;
  KB_ShiftF3   = $5600;
  KB_ShiftF4   = $5700;
  KB_ShiftF5   = $5800;
  KB_ShiftF6   = $5900;
  KB_ShiftF7   = $5A00;
  KB_ShiftF8   = $5B00;
  KB_ShiftF9   = $5C00;
  KB_ShiftF10  = $5D00;

  KB_CtrlF1    = $5E00;
  KB_CtrlF2    = $5F00;
  KB_CtrlF3    = $6000;
  KB_CtrlF4    = $6100;
  KB_CtrlF5    = $6200;
  KB_CtrlF6    = $6300;
  KB_CtrlF7    = $6400;
  KB_CtrlF8    = $6500;
  KB_CtrlF9    = $6600;
  KB_CtrlF10   = $6700;

  KB_AltF1     = $6800;
  KB_AltF2     = $6900;
  KB_AltF3     = $6A00;
  KB_AltF4     = $6B00;
  KB_AltF5     = $6C00;
  KB_AltF6     = $6D00;
  KB_AltF7     = $6E00;
  KB_AltF8     = $6F00;
  KB_AltF9     = $7000;
  KB_AltF10    = $7100;

  KB_Space     = $3920;

type
  TGorevBit = (gbIslev, gbGenel);

  TAyricalik = record
    Gorev: TGorevBit;
    Secilen: set of Byte;
  end;

  TOlay = record
    case Byte of
      0:(
        Gorev: TGorevBit;
        Hangisi: Byte
      );
      1:(
        Basilan: Word
      );
    end;

var
  Ayricalik: TAyricalik;

function KeybOlay(var Olay: TOlay): Boolean;

implementation

uses DOS;

function KeybOlay(var Olay: TOlay): Boolean;
var
  Regs: Registers;
begin
  with (Regs) do
  begin
    AH := $01;
    Intr($16, Regs);
    if ((Flags and FZero) = FZero) then
      begin
        AH := $00;
        Intr($16, Regs);
        with (Olay) do
        begin
          Basilan := Regs.AX;
          if (Gorev <> gbIslev) then
          begin
            Basilan := Swap(Basilan);
            Gorev := gbGenel;
          end;
        end;
      end
    else
      Word(Olay) := KB_NoKey;
  end;
  KeybOlay := False;
  if (Olay.Basilan <> KB_NoKey) then
    with (Ayricalik) do
      KeybOlay := (Olay.Gorev = Gorev) and (Olay.Hangisi in Secilen);
end;

begin
  FillChar(Ayricalik, SizeOf(Ayricalik), 0);
end.
