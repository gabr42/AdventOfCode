program AdventOfCode13;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

function Solve1(ax, ay, bx, by, px, py: int64): int64;
begin
//  m1 * ax + m2 * bx = px
//  m1 * ay + m2 * by = py
//  ---
//  m1 * ax * ay + m2 * bx * ay = px * ay
//  m1 * ay * ax + m2 * by * ax = py * ax
//  m2 (bx * ay - by * ax) = (px * ay - py * ax)
//  m2 = (px * ay - py * ax) / (bx * ay - by * ax)
//  m1 = (px - m2 * bx) / ax

  Result := 0;
  var p1: int64 := px * ay - py * ax;
  var d1: int64 := bx * ay - by * ax;
  var m2: int64 := Round(p1/d1);
  if p1 = d1 * m2 then begin
    p1 := px - m2 * bx;
    var m1: int64 := Round(p1/ax);
    if p1 = m1 * ax then
      Result := 3*m1 + m2;
  end;
end;

procedure Solve(const fileName: string);
var
  tf: textfile;
  sa, sb, sp: string;
begin
  var sum1 := int64(0);
  var sum2 := int64(0);

  AssignFile(tf, fileName);
  Reset(tf);
  while not Eof(tf) do begin
    Readln(tf, sa);
    Readln(tf, sb);
    Readln(tf, sp);
    if not Eof(tf) then
      Readln(tf);
    var pa := sa.Split(['+', ','], TStringSplitOptions.ExcludeEmpty);
    var pb := sb.Split(['+', ','], TStringSplitOptions.ExcludeEmpty);
    var pp := sp.Split(['=', ','], TStringSplitOptions.ExcludeEmpty);
    Inc(sum1, Solve1(pa[1].ToInteger, pa[3].ToInteger, pb[1].ToInteger, pb[3].ToInteger, pp[1].ToInteger, pp[3].ToInteger));
    Inc(sum2, Solve1(pa[1].ToInteger, pa[3].ToInteger, pb[1].ToInteger, pb[3].ToInteger, 10000000000000 + pp[1].ToInt64, 10000000000000 + pp[3].ToInt64));
  end;
  CloseFile(tf);

  Writeln('Part 1: ', sum1);
  Writeln('Part 2: ', sum2);
end;

begin
  Solve('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode13.txt');
  Write('> '); Readln;
end.
