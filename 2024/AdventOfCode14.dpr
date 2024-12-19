program AdventOfCode14;


{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

procedure Solve(const fileName: string; w, h, steps: integer);
var
  tf: textfile;
  s: string;
  q: array [boolean, boolean] of integer;
begin
  var w2 := w div 2; //5
  var h2 := h div 2; //3
  FillChar(q, SizeOf(q), 0);
  Assign(tf, fileName);
  Reset(tf);
  while not Eof(tf) do begin
    Readln(tf, s);
    var p := s.Split([',', '=', ' ']);
    var x := (p[1].ToInteger + ((p[4].ToInteger + w) mod w) * steps) mod w;
    var y := (p[2].ToInteger + ((p[5].ToInteger + h) mod h) * steps + h) mod h;
    if (x <> w2) and (y <> h2) then
      q[x<w2, y<h2] := q[x<w2, y<h2] + 1;
  end;
  CloseFile(tf);

  Writeln('Part 1: ', q[false, false] * q[true, false] * q[false, true] * q[true, true]);
end;

begin
//  Solve('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode14test.txt', 11, 7, 100);
  Solve('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode14.txt', 101, 103, 100);
  Write('> '); Readln;
end.
