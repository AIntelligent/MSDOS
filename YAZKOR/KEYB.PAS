uses DOS;

var
  KeyWord: Word;

function Basilan(var Key: Byte): Boolean;
var
  Regs: Registers;
begin
  with Regs do
  begin
    repeat
      AH := 1;
      Intr($16, Regs);
    until ((Flags and FZero) <> FZero);
    AH := 0;
    Intr($16, Regs);
    KeyWord := AX;
    Key := AL;
    if (AL = 0) then
      begin
        Key := AH;
        Basilan := True;
      end
    else
      Basilan := False;
  end;
end;

var
  B: Boolean;
  Key: Byte;
begin
  B := Basilan(Key);
end.
