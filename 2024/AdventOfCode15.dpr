program AdventOfCode15;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.Types, System.Math,
  Spring.Collections;

var
  Grid: TArray<TArray<char>>;
  Grid2: TArray<TArray<char>>;
  MaxX, MaxY: integer;
  Moves: string;
  Robot: TPoint;
  Steps: IDictionary<char, TPoint>;
  BO: IDictionary<char, TPoint>;

procedure Read(const fileName: string);
begin
  Steps := TCollections.CreateDictionary<char, TPoint>;
  Steps['<'] := Point(-1, 0);
  Steps['^'] := Point(0, -1);
  Steps['>'] := Point(1, 0);
  Steps['v'] := Point(0, 1);

  BO := TCollections.CreateDictionary<char, TPoint>;
  BO[']'] := Point(-1, 0);
  BO['['] := Point(1, 0);

  var map2 := TCollections.CreateDictionary<char, string>;
  map2['#'] := '##';
  map2['.'] := '..';
  map2['O'] := '[]';
  map2['@'] := '@.';

  var sl := TStringList.Create;
  sl.LoadFromFile(fileName);
  for MaxY := 0 to sl.Count - 1 do begin
    if sl[MaxY] = '' then begin
      MaxX := Length(sl[0]);
      SetLength(Grid, MaxX, MaxY);
      for var x := 0 to MaxX - 1 do
        for var y := 0 to MaxY - 1 do begin
          Grid[x, y] := sl[y][x+1];
          if Grid[x, y] = '@' then
            Robot := Point(x, y);
        end;
      SetLength(Grid2, 2 * MaxX, MaxY);
      for var x := 0 to MaxX - 1 do
        for var y := 0 to MaxY - 1 do begin
          Grid2[2*x, y] := map2[Grid[x, y]][1];
          Grid2[2*x+1, y] := map2[Grid[x, y]][2];
        end;
      Moves := '';
      for var m := MaxY + 1 to sl.Count - 1 do
        Moves := Moves + sl[m];
      break; //for d
    end;
  end;
  FreeAndNil(sl);
end;

procedure PrintGrid;
begin
  for var y := 0 to MaxY - 1 do begin
    for var x := 0 to MaxX - 1 do
      Write(Grid[x, y]);
    Writeln;
  end;
  Writeln;
end;

procedure PrintGrid2;
begin
  for var y := 0 to MaxY - 1 do begin
    for var x := 0 to MaxX*2 - 1 do
      Write(Grid2[x, y]);
    Writeln;
  end;
  Writeln;
end;

function FindSpace(r, dr: TPoint; var sp: TPoint): boolean;
begin
  sp := r + dr;
  while not CharInSet(Grid[sp.x, sp.y], ['#', '.']) do
    sp := sp + dr;
  Result := Grid[sp.x, sp.y] = '.';
end;

procedure Solve;
var
  sp: TPoint;
begin
//  PrintGrid;
  for var ch in Moves do begin
    if FindSpace(Robot, Steps[ch], sp) then begin
      while sp <> Robot do begin
        var nx := sp - Steps[ch];
        Grid[sp.x, sp.y] := Grid[nx.x, nx.y];
        sp := nx;
      end;
      Grid[Robot.x, Robot.y] := '.';
      Robot := Robot + Steps[ch];
//      PrintGrid;
    end;
  end;

  var sum1 := 0;
  for var y := 0 to MaxY - 1 do
    for var x := 0 to MaxX - 1 do
      if Grid[x, y] = 'O' then
        Inc(sum1, 100 * y + x);
  Writeln('Part 1: ', sum1);
end;

function FindSpace2(const r, dr: TPoint; dep: integer; var maxDep: integer): boolean;
begin
  var nr := r + dr;
  if Grid2[nr.x, nr.y] = '.' then begin
    maxDep := Max(maxDep, dep+1);
    Exit(true);
  end
  else if Grid2[nr.x, nr.y] = '#' then
    Exit(false)
  else if dr.y = 0 then
    Exit(FindSpace2(nr, dr, dep + 1, maxDep))
  else
    Exit(FindSpace2(nr, dr, dep + 1, maxDep) and FindSpace2(nr + BO[Grid2[nr.x, nr.y]], dr, dep + 1, maxDep));
end;

procedure Push(pt, d: TPoint; dep: integer);
begin
  if dep = 0 then
    Exit;

  var npt := pt + d;
  if Grid2[npt.x, npt.y] = '#' then
    Exit;
  if Grid2[npt.x, npt.y] = '.' then begin
    Grid2[npt.x, npt.y] := Grid2[pt.x, pt.y];
    Exit;
  end;
  if d.y = 0 then begin
    Push(npt, d, dep - 1);
    Grid2[npt.x, npt.y] := Grid2[pt.x, pt.y];
  end
  else begin
    var npt2 := npt + BO[Grid2[npt.x, npt.y]];
    Push(npt, d, dep - 1);
    Push(npt2, d, dep - 1);
    Grid2[npt.x, npt.y] := Grid2[pt.x, pt.y];
    Grid2[npt2.x, npt2.y] := '.';
  end;
end;

procedure Solve2;
begin
//  PrintGrid2;
  Robot.x := 2 * Robot.x;
  for var ch in Moves do begin
    var dep: integer;
    if FindSpace2(Robot, Steps[ch], 0, dep) then begin
      Push(Robot, Steps[ch], dep);
      Grid2[Robot.x, Robot.y] := '.';
      Robot := Robot + Steps[ch];
    end;
//    PrintGrid2;
  end;

  var sum2 := 0;
  for var y := 0 to MaxY - 1 do
    for var x := 0 to 2*MaxX - 1 do
      if Grid2[x, y] = '[' then
        Inc(sum2, 100 * y + x);
  Writeln('Part 2: ', sum2);
end;

begin
  Read('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode15.txt');
//  Solve;
  Solve2;
  Write('> '); Readln;
end.
