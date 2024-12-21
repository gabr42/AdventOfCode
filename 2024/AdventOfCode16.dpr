program AdventOfCode16;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Types,
  System.Classes,
  System.Math,
  System.Generics.Defaults,
  Spring.Collections;

const
  CDirCostMap = '<^>v';
  CRevDirCostMap = '>v<^';

type
  TDirCostArr = array [1..4] of integer;

var
  Grid: TStringList;
  StartPos, EndPos: TPoint;
  StartDirection: TPoint;
  GridCost: TArray<TArray<TDirCostArr>>;

type
  TStringListArray = class helper for TStringList
  protected
    function  GetCell(const pt: TPoint): char;
    procedure SetCell(const pt: TPoint; const value: char);
  public
    property Cell[const pt: TPoint]: char read GetCell write SetCell; default;
  end;

{ TStringListArray }

function TStringListArray.GetCell(const pt: TPoint): char;
begin
  Result := Strings[pt.y][pt.x];
end;

procedure TStringListArray.SetCell(const pt: TPoint; const value: char);
begin
  var s := Strings[pt.y];
  s[pt.x] := value;
  Strings[pt.y] := s;
end;

procedure Load(const fileName: string);
begin
  Grid := TStringList.Create;
  Grid.LoadFromFile(fileName);
  StartPos := Point(2, Grid.Count - 2);
  EndPos := Point(Length(Grid.Strings[1]) - 1, 1);
  StartDirection := Point(1, 0);
end;

type
  TCandidate = packed record
    Position   : TPoint;
    Direction  : TPoint;
    Path       : string;
    WasRotation: boolean;
    constructor Create(const APos, ADir: TPoint; const APath: string; AWasRot: boolean);
  end;

constructor TCandidate.Create(const APos, ADir: TPoint; const APath: string; AWasRot: boolean);
begin
  Position := APos;
  Direction := ADir;
  Path := APath;
  WasRotation := AWasRot;
end;

procedure Solve;
var
  values: IReadOnlyCollection<TCandidate>;
begin
  var moveChar := TCollections.CreateBidiDictionary<TPoint, char>;
  moveChar[Point(1, 0)] := '>';
  moveChar[Point(-1, 0)] := '<';
  moveChar[Point(0, -1)] := '^';
  moveChar[Point(0, 1)] := 'v';

  SetLength(GridCost, Length(Grid.Strings[1])+1, Grid.Count);
  for var y := 0 to Grid.Count -1 do
    for var x := 0 to Length(Grid.Strings[1]) do
      for var d := 1 to 4 do
        GridCost[x, y, d] := 0;

  var candidates := TCollections.CreateSortedMultiMap<integer, TCandidate>;
  var cand := TCandidate.Create(StartPos, StartDirection, '', false);
  var cost := 0;
  var minCost := 0;
  var minPaths := TCollections.CreateList<string>;
  candidates.Add(cost, cand);

  repeat
    var kv := candidates.First;
    cost := kv.Key;
    if (minCost > 0) and (cost > (minCost + 1)) then
      break; // repeat
    cand := kv.Value;
    candidates.Remove(cost, cand);
    if (cand.Position + cand.Direction) = EndPos then begin
      minPaths.Add(cand.Path + moveChar[cand.Direction]);
      minCost := cost + 1;
    end
    else begin
      if Grid[cand.Position + cand.Direction] = '.' then begin
        var np := cand.Position + cand.Direction;
        var c1 := GridCost[np.x, np.y, CDirCostMap.IndexOf(moveChar[cand.Direction]) + 1];
        var c2 := GridCost[np.x, np.y, CRevDirCostMap.IndexOf(moveChar[cand.Direction]) + 1];

        if ((c1 = 0) or (c1 > cost)) and ((c2 = 0) or (c2 > cost)) then begin
          GridCost[np.x, np.y, CDirCostMap.IndexOf(moveChar[cand.Direction]) + 1] := cost + 1;
          candidates.Add(cost + 1, TCandidate.Create(np, cand.Direction, cand.Path + moveChar[cand.Direction], false));
        end;
      end;
      if not cand.WasRotation then begin
        var rot := Point(cand.Direction.y, - cand.Direction.x);
        if Grid[cand.Position + rot] = '.' then
          candidates.Add(cost + 1000, TCandidate.Create(cand.Position, rot, cand.Path, true));
        rot := Point(- cand.Direction.y, cand.Direction.x);
        if Grid[cand.Position + rot] = '.' then
          candidates.Add(cost + 1000, TCandidate.Create(cand.Position, rot, cand.Path, true));
      end;
    end;
  until false;

  Writeln('Part 1: ', minCost + 1);

  Writeln(candidates.Count, ' candidates');
  Writeln(minPaths.Count, ' best paths');

  for var s in minPaths do begin
    var pos := StartPos;
    for var ch in s do begin
      pos := pos + moveChar.Inverse[ch];
      Grid[pos] := 'O';
    end;
  end;
  Grid[StartPos] := 'O';

  var sum2 := 0;
  for var y := 0 to Grid.Count -1 do begin
    for var x := 1 to Length(Grid.Strings[1]) do
      if Grid[Point(x, y)] = 'O' then
        Inc(sum2);
  end;
  Writeln('Part 2: ', sum2);
end;

begin
  Load('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode16.txt');
  Solve;
  Write('> '); Readln;
end.
