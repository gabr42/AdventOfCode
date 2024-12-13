program AdventOfCode06;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Types, System.Classes,
  Spring, Spring.Collections;

type
  TMoveInfo = record
    Rotate: char;
    Move: TPoint;
  end;

var
  Grid: TStringList;
  GuardPos: TPoint;
  Guard: char;
  Moves: IDictionary<char, TMoveInfo>;

function GetGrid(pt: TPoint): char;
begin
  Result := Grid[pt.y][pt.x];
end;

procedure SetGrid(pt: TPoint; ch: char);
begin
  var s := Grid[pt.y];
  s[pt.x] := ch;
  Grid[pt.y] := s;
end;

procedure Setup(const fileName: string);

  procedure MakeMove(dir, nextDir: char; dx, dy: integer);
  var
    mi: TMoveInfo;
  begin
    mi.Rotate := nextDir;
    mi.Move := Point(dx, dy);
    Moves[dir] := mi;
  end;

begin
  Grid.LoadFromFile(fileName);
  Grid.Add( StringOfChar('*', Length(Grid[0])));
  Grid.Insert(0, StringOfChar('*', Length(Grid[0])));
  Grid.Insert(0, '');
  for var i := 1 to Grid.Count - 1 do
    Grid[i] := '*' + Grid[i] + '*';

  for var y := 1 to Grid.Count - 1 do begin
    GuardPos.X := Pos('^', Grid[y]);
    if GuardPos.X > 0 then begin
      GuardPos.Y := y;
      break; //for
    end;
  end;
  Guard := '^';

  MakeMove('^', '>', 0, -1);
  MakeMove('>', 'v', 1, 0);
  MakeMove('v', '<', 0, 1);
  MakeMove('<', '^', -1, 0);
end;

procedure PrintGrid;
begin
  for var s in Grid do
    Writeln(s);
  Writeln;
end;

function Cycles(const blockAt: TPoint): boolean;
begin
  Result := false;
  var oldGrid := Grid; Grid := TStringList.Create; Grid.Assign(oldGrid);
  var oldGuardPos := GuardPos;
  var oldGuard := Guard;
  try

    var path := TCollections.CreateHashMultiMap<TPoint, char>;
    SetGrid(blockAt, '#');
    repeat
      var nextPos := GuardPos + Moves[Guard].Move;
      SetGrid(GuardPos, 'x');
      if GetGrid(nextPos) = '*' then
        break; //repeat
      if GetGrid(nextPos) = '#' then
        Guard := Moves[Guard].Rotate
      else begin
        GuardPos := nextPos;
        if path.Contains(GuardPos, Guard) then begin
          Exit(true);
        end;
        path.Add(GuardPos, Guard);
      end;
    until false;

  finally
    Guard := oldGuard;
    GuardPos := oldGuardPos;
    Grid.Free; Grid := oldGrid;
  end;
end;

procedure BruteForce2;
begin
  var sum2 := 0;
  for var x := 1 to Length(Grid[1]) do
    for var y := 1 to Grid.Count - 1 do
      if (GetGrid(Point(x, y)) = '.') and Cycles(Point(x, y)) then 
        Inc(sum2);
  Writeln('Part 2: ', sum2);
end;

procedure Solve;
begin
  repeat
    var nextPos := GuardPos + Moves[Guard].Move;
    SetGrid(GuardPos, 'X');
    if GetGrid(nextPos) = '*' then
      break; //repeat
    if GetGrid(nextPos) = '#' then
      Guard := Moves[Guard].Rotate
    else 
      GuardPos := nextPos;
  until false;

  var sum1 := 0;
  for var s in Grid do
    for var ch in s do
      if ch = 'X' then
        Inc(sum1);

  Writeln('Part 1: ', sum1);
end;

begin
  Grid := TStringList.Create;
  Moves := TCollections.CreateDictionary<char, TMoveInfo>;
  Setup('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode06.txt');
  BruteForce2;
  Solve;
  Grid.Free;
  Write('> '); Readln;
end.
