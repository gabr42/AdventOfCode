program AdventOfCode18;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Types, System.Classes,
  Spring.Collections;

function Load(const fileName: string): IList<TPoint>;
begin
  var list := TCollections.CreateList<TPoint>;
  var sl := TStringList.Create;
  sl.LoadFromFile(fileName);
  for var s in sl do begin
    var p := s.Split([',']);
    list.Add(Point(p[0].ToInteger, p[1].ToInteger));
  end;
  sl.Free;
  Result := list;
end;

function Solve(MaxXY: integer; Drops: IEnumerable<TPoint>): integer;
var
  grid: TArray<TArray<boolean>>;
begin
  SetLength(grid, MaxXY + 3, MaxXY + 3);
  for var pt in Drops do
    grid[pt.x+1, pt.y+1] := true;
  for var d := 0 to MaxXY+2 do begin
    grid[0, d] := true;
    grid[MaxXY + 2, d] := true;
    grid[d, 0] := true;
    grid[d, MaxXY + 2] := true;
  end;
  var EndP := Point(MaxXY + 1, MaxXY + 1);

  grid[1, 1] := true;
  var gen := TCollections.CreateList<TPoint>;
  gen.Add(Point(1, 1));

  Result := 0;
  var cost := 0;
  while not gen.IsEmpty do begin
    var nextGen := TCollections.CreateList<TPoint>;
    Inc(cost);
    for var pt in gen do
      for var dx := -1 to 1 do
        for var dy := -1 to 1 do
          if (dx = 0) xor (dy = 0) then begin
            var nx := pt + Point(dx, dy);
            if not grid[nx.x, nx.y] then begin
              grid[nx.x, nx.y] := true;
              if nx = EndP then
                Exit(cost);
              nextGen.Add(nx);
            end;
          end;
    gen := nextGen;
  end;
end;

procedure Solve2(MaxXY, Safe: integer; Drops: IList<TPoint>);
begin
  for var i := Safe + 1 to Drops.Count - 1 do
    if Solve(MaxXY, Drops.Take(i)) = 0 then begin
      Writeln('Part 2: ', Drops[i-1].x, ',', Drops[i-1].y);
      Exit;
    end;
end;

begin
//  Writeln('Part 1 test: ', Solve(6, Load('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode18test.txt').Take(12)));
  Writeln('Part 1: ', Solve(70, Load('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode18.txt').Take(1024)));
//  Solve2(6, 12, Load('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode18test.txt'));
  Solve2(70, 1024, Load('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode18.txt'));
  Write('> '); Readln;
end.
