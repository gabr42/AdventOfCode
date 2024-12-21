program AdventOfCode20;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.Types, System.Math,
  System.Generics.Defaults,
  Spring.Collections, Spring.Collections.Extensions;

var
  Grid: TArray<TArray<char>>;
  StartPos, EndPos: TPoint;
  MaxX, MaxY: integer;

procedure Load(const fileName: string);
begin
  var sl := TStringList.Create;
  sl.LoadFromFile(fileName);
  MaxX := Length(sl[0])-1;
  MaxY := sl.Count-1;
  SetLength(Grid, MaxX+1, MaxY+1);
  for var y := 0 to MaxY do
    for var x := 0 to MaxX do begin
      Grid[x, y] := sl[y][x+1];
      if Grid[x, y] = 'S' then
        StartPos := Point(x, y)
      else if Grid[x, y] = 'E' then begin
        EndPos := Point(x, y);
        Grid[x, y] := '.';
      end;
    end;
  sl.Free;
end;

type
  TState = record
    Position: TPoint;
    Visited: ISet<TPoint>;
    VisitedL: ISet<TPoint>;
    DidCheat: boolean;
    constructor Create(APos: TPoint; ADidCheat: boolean; AVisited: ISet<TPoint>);
    procedure Log;
  end;

function Walk: IList<TPoint>;
begin
  Result := TCollections.CreateList<TPoint>;
  var visited := TCollections.CreateSortedList<TPoint>;
  var pt := StartPos;
  var pt2 := Point(0, 0);
  while pt <> EndPos do begin
    Result.Add(pt);
    var f := false;
    for var dx := -1 to 1 do
      for var dy := -1 to 1 do
        if (not f) and ((dx = 0) xor (dy = 0)) then begin
          var nx := pt + Point(dx, dy);
          if (Grid[nx.x, nx.y] = '.') and (nx <> pt2) then begin
            pt2 := pt;
            pt := nx;
            f := true;
          end;
        end;
  end;
end;

function Cheat(walk: IList<TPoint>; saveAtLeast, cheatTime: integer): integer;
begin
  var cost := TCollections.CreateDictionary<TPoint, integer>;
  for var ii in TEnumerable.Zip<integer, TPoint>(TRangeIterator.Create(0, walk.Count), walk) do
    cost[ii.Value2] := ii.Value1;
  cost[EndPos] := walk.Count;

  Result := 0;
  for var pt in walk do begin
    var cost1 := cost[pt];
    for var dx := -cheatTime to cheatTime do
      for var dy := -cheatTime to cheatTime do
        if (Abs(dx) + Abs(dy)) <= cheatTime then begin
          var cost2 := cost.GetValueOrDefault(pt + Point(dx, dy));
          var save := (cost2 - cost1 - Abs(dx) - Abs(dy));
          if save >= saveAtLeast then begin
//            Writeln(pt.x, ' ', pt.y, ' => ', pt.x + dx, ' ', pt.y + dy, ': ', save);
            Inc(Result);
          end;
        end;
  end;
end;

procedure Solve(saveAtLeast: integer);
begin
  var fairWalk := Walk;
//  Writeln('Non-cheat: ', fairWalk.Count);
  Writeln('Part 1: ', Cheat(fairWalk, saveAtLeast, 2));
  Writeln('Part 2: ', Cheat(fairWalk, saveAtLeast, 20));
end;

{ TState }

constructor TState.Create(APos: TPoint; ADidCheat: boolean; AVisited: ISet<TPoint>);
begin
  Position := APos;
  Visited := AVisited;
  DidCheat := ADidCheat;
end;

procedure TState.Log;
begin
  Writeln(Position.x, ',', Position.y, ' [', DidCheat, '] ',
    string.Join('/',
      TEnumerable.Select<TPoint, string>(Visited,
        function(const pt: TPoint): string
        begin
          Result := Format('%d,%d', [pt.x, pt.y]);
        end).ToArray));
end;

begin
  Load('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode20.txt');
  Solve(100);
  Write('> '); Readln;
end.
