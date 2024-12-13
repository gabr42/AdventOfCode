program AdventOfCode10;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.Types,
  Spring.Collections;

var
  Grid: TArray<TArray<integer>>;
  MaxX, MaxY: integer;

procedure Load(const fileName: string);
begin
  var sl := TStringList.Create;
  sl.LoadFromFile(fileName);

  MaxX := Length(sl[0]);
  MaxY := sl.Count;
  SetLength(Grid, MaxX + 2, MaxY + 2);

  for var x := 0 to High(Grid) do begin
    Grid[x, 0] := 99;
    Grid[x, MaxY+1] := 99;
  end;
  for var y := 0 to High(Grid[0]) do begin
    Grid[0, y] := 99;
    Grid[MaxX+1, y] := 99;
  end;
  for var x := 1 to MaxX do
    for var y := 1 to MaxY do
      Grid[x, y] := string(sl[y-1][x]).ToInteger;

  sl.Free;
end;

function Ascend(x, y: integer; const tops: ISet<TPoint>; var routes: integer): boolean;
begin
  if Grid[x, y] = 9 then begin
    tops.Add(Point(x, y));
    Inc(routes);
    Exit(true);
  end;

  for var dx := -1 to 1 do
    for var dy := -1 to 1 do
      if ((dx = 0) or (dy = 0)) and (Grid[x+dx, y+dy] = (Grid[x, y] + 1)) then
        Ascend(x+dx, y+dy, tops, routes);
end;

procedure Solve;
var
  top: TPoint;
begin
  var sum1 := 0;
  var sum2 := 0;
  for var y := 1 to maxY do
    for var x := 1 to maxX do
      if Grid[x,y] = 0 then begin
        var tops := TCollections.CreateSet<TPoint>;
        var routes := 0;
        Ascend(x, y, tops, routes);
        Inc(sum1, tops.Count);
        Inc(sum2, routes);
      end;
  Writeln('Part 1: ', sum1);
  Writeln('Part 1: ', sum2);
end;

begin
  Load('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode10.txt');

  Solve;

  Write('> '); Readln;
end.
