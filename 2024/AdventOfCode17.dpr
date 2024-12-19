program AdventOfCode17;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.Math,
  Spring.Collections,
  FAB.Utils, GpStuff;

var
  Regs: array [0..2] of int64;
  Code: TArray<integer>;

procedure Init(const fileName: string);
begin
  var sl := TStringList.Create;
  sl.LoadFromFile(fileName);
  for var iReg := 0 to 2 do
    Regs[iReg] := sl[iReg].Split([':'])[1].TrimLeft.ToInteger;
  Code := TArray.Map<string,integer>(sl[4].Split([':'])[1].TrimLeft.Split([',']), StrToInt);
  Writeln('> ', sl[4].Split([':'])[1].TrimLeft);
  sl.Free;
end;

function Combo(val: integer): int64;
begin
  if (val >= 0) and (val <= 3) then
    Result := val
  else if (val >= 4) and (val <= 6) then
    Result := Regs[val-4]
  else
    raise ERangeError.Create('Unlucky number 7');
end;

function O(value: int64): string;
const
  OctalDigits: array[0..7] of Char = ('0','1','2','3','4','5','6','7');
begin
  // Handle special case of zero
  if Value = 0 then
    Exit('0');

  Result := '';
  while value > 0 do begin
    Result := Chr((value and 7) + Ord('0')) + Result;
    value := value shr 3;
  end;
end;

procedure Simulate;
begin
  var ip := 0;
  var outp := '';
  while (ip >= 0) and (ip <= (Length(Code)-2)) do begin
    var outpl := '';
    case Code[ip] of
      0: Regs[0] := Trunc(Regs[0] / Power(2, Combo(Code[ip+1])));
      1: Regs[1] := Regs[1] XOR Code[ip+1];
      2: Regs[1] := Combo(Code[ip+1]) mod 8;
      3: if Regs[0] <> 0 then ip := Code[ip+1] - 2;
      4: Regs[1] := Regs[1] XOR Regs[2];
      5: begin outpl := (Combo(Code[ip+1]) mod 8).ToString; outp := AddToList(outp, ',', outpl); end;
      6: Regs[1] := Trunc(Regs[0] / Power(2, Combo(Code[ip+1])));
      7: Regs[2] := Trunc(Regs[0] / Power(2, Combo(Code[ip+1])));
    end;
    ip := ip + 2;
  end;
  Writeln('Part 1: ', outp);
end;

//2,4,   B := A mod 8;
//1,1,   B := B XOR 1;
//7,5,   C := Trunc(A / 2^B);
//4,6,   B := B XOR C;
//0,3,   A := Trunc(A / 2^3);
//1,4,   B := B XOR 4;
//5,5,   OUT B mod 8;
//3,0    IF A <> 0 GOTO 0

procedure Simulate2(start: int64);
var
  a,b,c: int64;
begin
  a := start;
  var outp := '';
  repeat
    B := A mod 8; // b = 0..7
    B := B xor 1;
    C := A div Round(Power(2, B));
    C := C mod 8;
    B := B xor C;
    B := B xor 4;
    outp := AddToList(outp, ',', (B mod 8).ToString);
    A := A div 8;
//    Writeln(O(A), ' ', O(B), ' ', O(C));
  until A = 0;
  Writeln('Part 2: ', outp);
end;

function RecreateA(const sequence: TArray<int64>): int64;
var
  cand, outCand: IList<int64>;
begin
  cand := TCollections.CreateList<int64>;
  cand.Add(0);
  for var iSeq := High(sequence) downto Low(sequence) do begin
    outCand := TCollections.CreateList<int64>;
    for var el in cand do
      for var A := 8*el to 8*el + 7 do begin
        var B := A mod 8;
        B := B xor 1;
        var C := A div Round(Power(2, B));
        C := C mod 8;
        B := B xor C;
        B := B xor 4;
        if (B mod 8) = sequence[iSeq] then
          if (A <> 0) or (el <> 0) then //last element can't be 0
            outCand.Add(A);
      end;
    cand := outCand;
  end;
  Result := cand.First;
  Writeln('Part 2: ', Result);
end;

begin
  Init('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode17.txt');
  Simulate;
  Simulate2(28066687); // test implementation
  Simulate2(RecreateA(TArray<int64>.Create(7,3,0,5,7,1,4,0,5)));
  Simulate2(RecreateA(TArray<int64>.Create(2,4,1,1,7,5,4,6,0,3,1,4,5,5,3,0)));
  Write('> '); Readln;
end.
