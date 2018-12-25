program AdventOfCode25;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  TPoint = record
    x,y,z,w: integer;
    function Dist(const pt: TPoint): integer;
  end;

  TPoints = TArray<TPoint>;


function TPoint.Dist(const pt: TPoint): integer;
begin
  Result := Abs(pt.x - x) + Abs(pt.y - y) + Abs(pt.z - z) + Abs(pt.w - w);
end;

function ReadPoints(const fileName: string): TPoints;
var
  list: TList<TPoint>;
  parts: TArray<string>;
  pt: TPoint;
  reader: TStreamReader;
begin
  reader := TStreamReader.Create(fileName);
  try
    list := TList<TPoint>.Create;
    try
      while not reader.EndOfStream do begin
        parts := reader.ReadLine.Trim.Split([',']);
        pt.x := parts[0].ToInteger;
        pt.y := parts[1].ToInteger;
        pt.z := parts[2].ToInteger;
        pt.w := parts[3].ToInteger;
        list.Add(pt);
      end;
      Result := list.ToArray;
    finally FreeAndNil(list); end;
  finally FreeAndNil(reader); end;
end;

function FindComponents(const points: TPoints; maxDist: integer): integer;
var
  candidates: TList<integer>;
  clusters: TObjectList<TList<integer>>;
  i,j,k: integer;
begin
  // small number of points, a simple brute force will do

  clusters := TObjectList<TList<integer>>.Create;
  try
    candidates := TList<integer>.Create;
    try
      for i:= Low(points) to High(points) do begin
        candidates.Clear;
        for j := 0 to clusters.Count - 1 do
          for k in clusters[j] do
            if points[k].Dist(points[i]) <= maxDist then begin
              candidates.Add(j);
              break; //for k
            end;

        if candidates.Count = 0 then
          clusters[clusters.Add(TList<integer>.Create)].Add(i)
        else begin
          clusters[candidates[0]].Add(i);
          for j := candidates.Count - 1 downto 1 do begin
            clusters[candidates[0]].AddRange(clusters[candidates[j]]);
            clusters.Delete(candidates[j]);
          end;
        end;
      end;
    finally FreeAndNil(candidates); end;
    Result := clusters.Count;
  finally FreeAndNil(clusters); end;
end;

function PartA(const fileName: string): integer;
var
  points: TPoints;
begin
  points := ReadPoints(fileName);
  Result := FindComponents(points, 3);
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode25test1.txt') = 2, 'PartA(test1) <> 2');
    Assert(PartA('..\..\AdventOfCode25test2.txt') = 4, 'PartA(test1) <> 4');
    Assert(PartA('..\..\AdventOfCode25test3.txt') = 3, 'PartA(test1) <> 3');
    Assert(PartA('..\..\AdventOfCode25test4.txt') = 8, 'PartA(test1) <> 8');
    Writeln('PartA: ', PartA('..\..\AdventOfCode25.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
