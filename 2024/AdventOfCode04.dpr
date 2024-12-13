program AdventOfCode04;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes;

procedure Solve(sl: TStringList);
begin
  var maxX := Length(sl[0]);
  var maxY := sl.Count;
  sl.Insert(0, '');

  var count := 0;
  for var x := 1 to maxX do
    for var y := 1 to maxY do
      if sl[y][x] = 'X' then
        for var dx := -1 to 1 do
          for var dy := -1 to 1 do
            if (dx <> 0) or (dy <> 0) then
              if ((y + 3*dy) >= 1) and ((y + 3*dy) <= maxY) and ((x + 3*dx) >= 1) and ((x + 3*dx) <= maxX) then
                if (sl[y+dy][x+dx] = 'M') and (sl[y+2*dy][x+2*dx] = 'A') and (sl[y+3*dy][x+3*dx] = 'S') then
                  Inc(count);
  Writeln('Part 1: ', count);

  count := 0;
  for var x := 2 to maxX-1 do
    for var y := 2 to maxY-1 do
      if sl[y][x] = 'A' then begin
        var countMAS := 0;
        for var dx := -1 to 1 do
          for var dy := -1 to 1 do
            if (dx <> 0) and (dy <> 0) then
              if (sl[y+dy][x+dx] = 'M') and (sl[y-dy][x-dx] = 'S') then
                Inc(countMAS);
        if countMAS = 2 then
          Inc(count);
      end;
  Writeln('Part 2: ', count);
end;

begin
  var sl := TStringList.Create;
  try
    sl.LoadFromFile('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode04.txt');
    Solve(sl);
    Write('> '); Readln;
  finally FreeAndNil(sl); end;
end.
