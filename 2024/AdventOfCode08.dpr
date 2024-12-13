program AdventOfCode08;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Types, System.Classes,
  Spring.Collections;

var
  Map: TStringList;
  MapDim: TPoint;
  Antinodes: TArray<TArray<char>>;
  Antennas: IMultiMap<char, TPoint>;
  NumAnti: integer;

procedure Load(const fileName: string);
begin
  Map := TStringList.Create;
  Map.LoadFromFile(fileName);
  Map.Insert(0, '');
  MapDim := Point(Length(Map[1]), Map.Count-1);
  SetLength(Antinodes, MapDim.Y+1, MapDim.X+1);
  NumAnti := 0;
end;

procedure EnumAntennas;
begin
  Antennas := TCollections.CreateHashMultiMap<char, TPoint>;
  for var y := 1 to MapDim.Y do
    for var x := 1 to MapDim.X do
      if Map[y][x] <> '.' then
        Antennas.Add(Map[y][x], Point(x, y));
end;

function TryAdd(const pt: TPoint): boolean;
begin
  Result := (pt.x >= 1) and (pt.x <= MapDim.X)
            and (pt.y >= 1) and (pt.y <= MapDim.Y);
  if Result then begin
    if Antinodes[pt.y][pt.x] <> 'a' then begin
      Antinodes[pt.y][pt.x] := 'a';
      Inc(NumAnti);
    end;
  end;
end;

procedure CreateAntiNodes(const locations: IReadOnlyCollection<TPoint>);
begin
  for var p1 in locations do
    for var p2 in locations do
      if p1 <> p2 then begin
        var diff := p2 - p1;
        TryAdd(p1 - diff);
        TryAdd(p2 + diff);
      end;
end;

procedure CreateAntiNodes2(const locations: IReadOnlyCollection<TPoint>);

  procedure TryAddMany(pt, diff: TPoint);
  begin
    while TryAdd(pt+diff) do
      pt := pt + diff;
  end;

begin
  for var p1 in locations do
    for var p2 in locations do
      if p1 <> p2 then begin
        TryAddMany(p1, p1-p2);
        TryAddMany(p2, p2-p1);
      end;
end;

function CountAA: integer;
begin
  Result := 0;
  for var y := 1 to MapDim.Y do
    for var x := 1 to MapDim.X do
      if (Antinodes[y][x] = 'a') or (Map[y][x] <> '.') then
        Inc(Result);
end;

procedure PrintAntinodes;
begin
  for var y := 1 to MapDim.Y do begin
    for var x := 1 to MapDim.X do
      if Antinodes[y][x] = 'a' then
        Write('a')
      else
        Write(Map[y][x]);
    Writeln;
  end;
end;

procedure Solve;
begin
  EnumAntennas;
  for var at in Antennas.Keys do
    CreateAntiNodes(Antennas[at]);

//  PrintAntinodes;
  Writeln('Part 1: ', NumAnti);

  for var at in Antennas.Keys do
    CreateAntiNodes2(Antennas[at]);
  Writeln('Part 2: ', CountAA);
end;

begin
  try
    Load('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode08.txt');
    Solve;
    Write('> '); Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
