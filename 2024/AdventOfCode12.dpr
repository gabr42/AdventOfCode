program AdventOfCode12;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.Types,
  Spring, Spring.Collections;

type
  TLine = Tuple<TPoint,TPoint>;

var
  Grid: TArray<TArray<char>>;
  MaxX, MaxY: integer;

procedure Load(const fileName: string);
begin
  var sl := TStringList.Create;
  sl.LoadFromFile(fileName);
  MaxX := Length(sl[0]);
  MaxY := sl.Count;
  SetLength(Grid, MaxX + 2, MaxY + 2);
  for var x := 0 to MaxX + 1 do
    for var y := 0 to MaxY + 1 do
      Grid[x, y] := ' ';

  for var y := 0 to sl.Count-1 do
    for var x := 1 to Length(sl[y]) do
      Grid[x, y+1] := sl[y][x];

  sl.Free;
end;

procedure GetRegion(x, y: integer; const areas: ISet<TPoint>);
begin
  var area := Grid[x, y];
  Grid[x, y] := ' ';
  areas.Add(Point(x, y));
  for var dx := -1  to 1 do
    for var dy := -1 to 1 do
      if ((dx = 0) or (dy = 0)) and (Grid[x+dx, y+dy] = area) then
        GetRegion(x+dx, y+dy, areas);
end;

function Perimeter(const areas: ISet<TPoint>): ISet<TLine>;

  function Line(const area: TPoint; dx, dy: integer): TLine;

    function MakeLine(x1, y1, x2, y2: integer): TLine;
    begin
      Result := Tuple<TPoint,TPoint>.Create(Point(x1,y1), Point(x2,y2));
    end;

  begin
    if dx = -1 then
      Result := MakeLine(area.x, area.y, area.x, area.y+1)
    else if dx = 1 then
      Result := MakeLine(area.x+1, area.y, area.x+1, area.y+1)
    else if dy = -1 then
      Result := MakeLine(area.x, area.y, area.x+1, area.y)
    else if dy = 1 then
      Result := MakeLine(area.x, area.y+1, area.x+1, area.y+1);
  end;

begin
  Result := TCollections.CreateSortedSet<TLine>;
  for var area in areas do begin
    for var dx := -1  to 1 do
      for var dy := -1 to 1 do
        if (dx = 0) xor (dy = 0) then
          if not areas.Contains(Point(area.x+dx, area.y+dy)) then
            Result.Add(Line(area, dx, dy));
  end;
end;

function NumSides(const peri: ISet<TLine>): integer;

  function IsParallel(const line1, line2: TLine): boolean;
  begin
    Result := Abs(line1.Value1.x - line1.Value2.x) = Abs(line2.Value1.x - line2.Value2.x);
  end;

  function NotPoint(const line: TLine; const pt: TPoint): TPoint;
  begin
    if pt = line.Value1 then
      Result := line.Value2
    else
      Result := line.Value1;
  end;

begin
  Result := 0;
  while not peri.IsEmpty do begin
    var first := peri.First;
    var line := first;
    var pt := line.Value1;

    repeat
      peri.Remove(line);
      var next := peri.Where(
                    function (const line2: TLine): boolean
                    begin
                      Result := (pt = line2.Value1)
                             or (pt = line2.Value2);
                    end);
      if next.Count = 3 then begin
        // internal cross, DON'T continue in a straight line
        for var next2 in next do
          if not IsParallel(line, next2) then begin
            Inc(Result);
            line := next2;
            break; //for iNext
          end;
      end
      else if next.Count = 1 then begin
        if not IsParallel(next.First, line) then
          Inc(Result);
        line := next.First;
      end
      else begin
        Assert(next.Count = 0);
        if not IsParallel(line, first) then
          Inc(Result);
        break; //repeat
      end;
      pt := NotPoint(line, pt);
    until false;
  end;
end;

procedure Solve;
begin
  var sum1 := 0;
  var sum2 := 0;
  for var x := 1 to MaxX do
    for var y := 1 to MaxY do
      if Grid[x, y] <> ' ' then begin
        var areas := TCollections.CreateSortedSet<TPoint>;
        GetRegion(x, y, areas);
        var peri := Perimeter(areas);
        Inc(sum1, areas.Count * peri.Count);
        var sides := NumSides(peri);
//        Writeln(areas.Count, ' * ', sides, ' = ', areas.Count * sides);
        Inc(sum2, areas.Count * sides);
      end;
  Writeln('Part 1: ', sum1);
  Writeln('Part 2: ', sum2);
end;

begin
  Load('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode12.txt');
  Solve;
  Write('> '); Readln;
end.
