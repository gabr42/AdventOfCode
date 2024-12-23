program AdventOfCode23;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.Math,
  Spring.Collections;

var
  Comp: ISet<string>;
  Net: IMultiMap<string,string>;

procedure Load(const fileName: string);
begin
  Comp := TCollections.CreateSortedSet<string>;
  Net := TCollections.CreateMultiMap<string,string>;
  var sl := TStringList.Create;
  sl.LoadFromFile(fileName);
  for var s in sl do begin
    var p := s.Split(['-']);
    Net.Add(p[0], p[1]);
    Net.Add(p[1], p[0]);
    Comp.Add(p[0]);
    Comp.Add(p[1]);
  end;
  sl.Free;
end;

function Connected(const c1, c2: string): boolean;
begin
  Result := Net[c1].Contains(c2);
end;

procedure Part1;
begin
  var count := 0;
  for var c1 in Comp do
    if c1.StartsWith('t') then
      for var c2 in Comp do
        if (not c2.StartsWith('t')) or (c2 > c1) then
          for var c3 in Comp do
            if (c3 > c2) and ((not c3.StartsWith('t')) or (c3 > c1)) then
              if Connected(c1, c2) and Connected(c2, c3) and Connected(c3, c1) then
                Inc(count);
  Writeln('Part 1: ', count);
end;

function IsClique(const cliq: TArray<string>): boolean;
begin
  Result := true;
  for var i := 0 to High(cliq) do
    for var j := i+1 to High(cliq) do
      if not Net[cliq[i]].Contains(cliq[j]) then
        Exit(false);
end;

procedure Part2;
begin
  var cliq := TCollections.CreateSet<string>;
  for var c1 in Comp do begin
    var n1 := Net[c1];
    for var c2 in n1 do
      if c2 > c1 then begin
        cliq.Clear;
        cliq.Add(c1);
        cliq.Add(c2);
        for var c3 in Net[c2] do
          if n1.Contains(c3) then
            cliq.Add(c3);
        if (cliq.Count = 13) and IsClique(cliq.ToArray) then begin
          Writeln('Part 2: ' + string.Join(',', cliq.Ordered.ToArray));
          Exit;
        end;
      end;
  end;
end;

var
  MaxBK: integer;

procedure BronKerbosch(R, P, X: IEnumerable<string>);
var
  nu: IReadOnlyCollection<string>;
begin
  if P.IsEmpty and X.IsEmpty then begin
    if R.Count > MaxBK then begin
      Writeln('Bron-Kerbosch: ', string.Join(',', R.Ordered.ToArray));
      MaxBK := R.Count;
    end;
    Exit;
  end;

  if (P.Count + R.Count) < MaxBK then
    Exit;

  if P.IsEmpty then
    nu := Net[X.First]
  else
    nu := Net[P.First];
  for var v in P do begin
    if nu.Contains(v) then
      continue; //for v
    var setv := TCollections.CreateList<string>;
    setv.Add(v);
    BronKerbosch(R.Union(setv), P.Intersect(Net[v]), X.Intersect(Net[v]));
    P := P.Exclude(setv);
    X := X.Union(setv);
  end;
end;

begin
  Load('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode23.txt');
  Part1;
  Part2;
  MaxBK := 3;
  BronKerbosch(TCollections.CreateSet<string>, Comp, TCollections.CreateSet<string>);
  Write('> '); Readln;
end.
