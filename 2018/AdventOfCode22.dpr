program AdventOfCode22;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Types,
  System.SysUtils,
  System.Math,
  System.Generics.Collections,
  PriorityQueues in '..\DGPQueue\Source\PriorityQueues.pas',
  PriorityQueues.Detail in '..\DGPQueue\Source\PriorityQueues.Detail.pas';

type
  TRegion = record
    GeoIndex: integer;
    ErosionLevel: integer;
  end;
  
  TCave = class
  strict private
    FRegions: array of array of TRegion;
  strict protected
    function GetRegion(row, col: integer): TRegion; inline;
  public
    procedure Build(depth: integer; const bounds, target: TPoint);
    property Region[row,col: integer]: TRegion read GetRegion; default;
  end;

{ TCave }

procedure TCave.Build(depth: integer; const bounds, target: TPoint);
var
  row: integer;
  col: integer;
begin
  SetLength(FRegions, bounds.Y + 1, bounds.X + 1);
  for row := 0 to bounds.Y do
    for col := 0 to bounds.X do begin
      if row = 0 then begin
        if col = 0 then 
          FRegions[row,col].GeoIndex := 0
        else
          FRegions[row,col].GeoIndex := col * 16807;
      end
      else if col = 0 then 
        FRegions[row,col].GeoIndex := row * 48271
      else if (row = target.Y) and (col = target.X) then 
        FRegions[row,col].GeoIndex := 0
      else
        FRegions[row,col].GeoIndex := FRegions[row-1,col].ErosionLevel * FRegions[row,col-1].ErosionLevel;
      FRegions[row,col].ErosionLevel := (FRegions[row,col].GeoIndex + depth) mod 20183;
    end;
end;

function TCave.GetRegion(row, col: integer): TRegion;
begin
  Result := FRegions[row,col];
end;

{ main }

function PartA(depth: integer; const target: TPoint; showMap: boolean): integer;
var
  cave: TCave;
  row: integer;
  col: integer;
begin
  cave := TCave.Create;
  try
    cave.Build(depth, target, target);

    Result := 0;
    for row := 0 to target.Y do
      for col := 0 to target.X do 
        Inc(Result, cave[row,col].ErosionLevel mod 3);    
  finally
    FreeAndNil(cave);
  end;
end;

type
  TNode = record
    Location: TPoint;
    Tool    : integer;
    constructor Create(const ALoc: TPoint; ATool: integer);
  end;

  TMove = record
    Cost    : integer;
    Location: TPoint;
    Tool    : integer;
    constructor Create(ACost: integer; const ALoc: TPoint; ATool: integer);
  end;

{ TMove }

constructor TMove.Create(ACost: integer; const ALoc: TPoint; ATool: integer);
begin
  Cost := ACost;
  Location := ALoc;
  Tool := ATool;
end;

{ TNode }

constructor TNode.Create(const ALoc: TPoint; ATool: integer);
begin
  Location := ALoc;
  Tool := ATool;
end;

function Neighbours(const cave: TCave; const bounds: TPoint;
  const loc: TPoint; tool: integer): TArray<TMove>;
var
  dx, dy: integer;
  t: integer;
  moves: TList<TMove>;
begin
  moves := TList<TMove>.Create;
  try
    for dx := -1 to 1 do
      for dy := -1 to 1 do
        if ((dx = 0) xor (dy = 0))
           and ((loc.X + dx) >= 0) 
           and ((loc.Y + dy >= 0))
           and ((loc.X + dx) <= bounds.X)
           and ((loc.Y + dy) <= bounds.Y)
           and (tool <> (cave[loc.Y + dy, loc.X + dx].ErosionLevel mod 3))
        then
          moves.Add(TMove.Create(
            1,
            Point(loc.X + dx, loc.Y + dy),
            tool));

    for t := 0 to 2 do
      if (t <> tool)
         and (t <> (cave[loc.Y, loc.X].ErosionLevel mod 3))
      then
        moves.Add(TMove.Create(
          7,
          Point(loc.X, loc.Y),
          t));
    Result := moves.ToArray;
  finally
    FreeAndNil(moves);
  end;
end;

function PartB(depth: integer; const target: TPoint): integer;
var
  alt: integer;
  bounds: TPoint;
  cave: TCave;
  pq: PriorityQueue<TMove>;
  cost: TDictionary<TNode,integer>;
  move,move2: TMove;
  best: integer;
  node2: TNode;
begin
  cave := TCave.Create;
  try
    bounds := Point(target.X * 10, Round(target.Y * 1.5)); // guesswork; narrow and deep target location
    cave.Build(depth, bounds, target);

    // Dijkstra

    cost := TDictionary<TNode,integer>.Create;
    try
      pq := PriorityQueue<TMove>.Create;
      pq.Enqueue(TMove.Create(0, Point(0, 0), 1));
      cost.Add(TNode.Create(Point(0, 0), 1), 0);

      while pq.Count > 0 do begin
        move := pq.Dequeue;

        for move2 in Neighbours(cave, bounds, move.Location, move.Tool) do begin
          alt := move.Cost + move2.Cost;
          node2 := TNode.Create(move2.Location, move2.Tool);

          if not cost.TryGetValue(node2, best) then
            best := $FFFFFF; // high enough, I believe

          if alt < best then begin
            cost.AddOrSetValue(node2, alt);
            pq.Enqueue(TMove.Create(alt, move2.Location, move2.Tool));
          end;
        end;
      end;

      Result := cost[TNode.Create(target, 1)];
    finally
      FreeAndNil(cost);
    end;
  finally
    FreeAndNil(cave);
  end;
end;

begin
  try
    Assert(PartA(510, Point(10,10), true) = 114, 'PartA(510, (10,10)) <> 114');
    Writeln('PartA: ', PartA(4002, Point(5,746), false));

    Assert(PartB(510, Point(10,10)) = 45, 'PartB(510, (10,10)) <> 45');
    Writeln('PartB: ',  PartB(4002, Point(5,746)));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
