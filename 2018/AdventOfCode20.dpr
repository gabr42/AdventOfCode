program AdventOfCode20;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Types,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  TBase = class
  strict private const
    CWall = '#';
    CRoom = '.';
    CDoorV = '|';
    CDoorH = '=';
    CStart = 'X';
  type
    THalfRow = TList<AnsiChar>;
    TQuadrant = TObjectList<THalfRow>;
  var
    FQuadrant: array [0..3] of TQuadrant;
    FBounds: TRect;
  strict protected
    function GetLocation(x, y: integer): AnsiChar;
    procedure SetLocation(x, y: integer; const value: AnsiChar);
    procedure MapPoint(x, y: integer; var quadrant: TQuadrant; var mx, my: integer);
    property Location[x, y: integer]: AnsiChar read GetLocation write SetLocation;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BuildMap(const regex: string);
    function CalcFurthest(const pt: TPoint; pathLimit: integer; var paths: integer): integer;
    procedure Dump;
  end;

{ TBase }

constructor TBase.Create;
var
  i: integer;
begin
  inherited Create;
  for i := Low(FQuadrant) to High(FQuadrant) do
    FQuadrant[i] := TQuadrant.Create;
end;

destructor TBase.Destroy;
var
  quad: TQuadrant;
begin
  for quad in FQuadrant do
    quad.Free;
  inherited;
end;

procedure TBase.BuildMap(const regex: string);
var
  ch: char;
  cx, cy: integer;
  locStack: TStack<TPoint>;
  bounds: TRect;
begin
  Location[0, 0] := CStart;

  locStack := TStack<TPoint>.Create;
  try
    cx := 0; cy := 0;
    for ch in regex do begin
      case ch of
        '^': ;
        '$':
          begin
            bounds := FBounds;
            bounds.Inflate(1, 1);
            for cx := bounds.Left to bounds.Right do begin
              Location[cx, bounds.Top] := CWall;
              Location[cx, bounds.bottom] := CWall;
            end;
            for cy := bounds.Top to bounds.Bottom do begin
              Location[bounds.Left, cy] := CWall;
              Location[bounds.Right, cy] := CWall;
            end;
            break; //for ch
          end;
        '(': locStack.Push(Point(cx,cy));
        ')':
          with locStack.Pop do begin
            cx := X;
            cy := Y;
          end;
        '|':
          begin
            with locStack.Peek do begin
              cx := X;
              cy := Y;
            end;
          end;
        'E':
          begin
            Location[cx + 1, cy] := CDoorV;
            Location[cx + 2, cy] := CRoom;
            Inc(cx, 2);
          end;
        'W':
          begin
            Location[cx - 1, cy] := CDoorV;
            Location[cx - 2, cy] := CRoom;
            Dec(cx, 2);
          end;
        'N':
          begin
            Location[cx, cy - 1] := CDoorH;
            Location[cx, cy - 2] := CRoom;
            Dec(cy, 2);
          end;
        'S':
          begin
            Location[cx, cy + 1] := CDoorH;
            Location[cx, cy + 2] := CRoom;
            Inc(cy, 2);
          end;
        else
          raise Exception.CreateFmt('Invalid regex char: %s', [ch]);
      end;
    end;

    Assert(locStack.Count = 0);
  finally FreeAndNil(locStack); end;
end;

function TBase.CalcFurthest(const pt: TPoint; pathLimit: integer; var paths: integer): integer;
var
  access: array of array of integer;
  accessible: TQueue<TPoint>;
  next: TPoint;
  maxDoors: integer;

  procedure Enter(newX, newY: integer);
  var
    accX, accY: integer;
  begin
    accX := newX - FBounds.Left;
    accY := newY - FBounds.Top;
    if access[accY, accX] > 0 then
      Exit;

    access[accY, accX] := access[next.Y - FBounds.Top, next.X - FBounds.Left] + 1;
    if access[accY, accX] > maxDoors then
      maxDoors := access[accY, accX];
    if access[accY, accX] > pathLimit then
      Inc(paths);
    accessible.Enqueue(Point(newX, newY));
  end;

var
  row,col: integer;

begin
  SetLength(access, FBounds.Height + 1, FBounds.Width + 1); // zeroed

  maxDoors := 0;
  paths := 0;

  accessible := TQueue<TPoint>.Create;
  try
    next := Point(0, 0);
    Enter(0, 0);
    repeat
      next := accessible.Dequeue;
      if Location[next.X + 1, next.Y] = CDoorV then
        Enter(next.X + 2, next.Y);
      if Location[next.X - 1, next.Y] = CDoorV then
        Enter(next.X - 2, next.Y);
      if Location[next.X, next.Y - 1] = CDoorH then
        Enter(next.X, next.Y - 2);
      if Location[next.X, next.Y + 1] = CDoorH then
        Enter(next.X, next.Y + 2);
    until accessible.Count = 0;
  finally FreeAndNil(accessible); end;

  Result := maxDoors - 1;
end;

procedure TBase.Dump;
var
  row: integer;
  col: integer;
begin
  for row := FBounds.Top to FBounds.Bottom do begin
    for col := FBounds.Left to FBounds.Right do
      Write(Location[col, row]);
    Writeln;
  end;
  Writeln;
end;

function TBase.GetLocation(x, y: integer): AnsiChar;
var
  quad: TQuadrant;
  mx, my: integer;
begin
  MapPoint(x, y, quad, mx, my);
  if my >= quad.Count then
    raise Exception.CreateFmt('Y coordinate %d not found in quadrant', [my]);
  if mx >= quad[my].Count then
    raise Exception.CreateFmt('X coordinate %d not found in quadrant', [mx]);
  Result := quad[my][mx];
end;

procedure TBase.MapPoint(x, y: integer; var quadrant: TQuadrant;
  var mx, my: integer);
begin
  if y >= 0 then begin
    my := y;
    if x >= 0 then begin
      quadrant := FQuadrant[0];
      mx := x;
    end
    else begin
      quadrant := FQuadrant[1];
      mx := -x + 1;
    end;
  end
  else begin
    my := -y + 1;
    if x < 0 then begin
      quadrant := FQuadrant[2];
      mx := -x + 1;
    end
    else begin
      quadrant := FQuadrant[3];
      mx := x;
    end;
  end;
end;

procedure TBase.SetLocation(x,y: integer; const value: AnsiChar);
var
  half: THalfRow;
  quad: TQuadrant;
  col: integer;
  mx, my: integer;
begin
  MapPoint(x, y, quad, mx, my);

  while my >= quad.Count do begin
    half := THalfRow.Create;
    for col := 0 to mx do
      half.Add(CWall);
    quad.Add(half);
  end;
  half := quad[my];
  while mx >= half.Count do
    half.Add(CWall);

  half[mx] := value;

  if x > FBounds.Right then
    FBounds.Right := x;
  if x < FBounds.Left then
    FBounds.Left := x;
  if y < FBounds.Top then
    FBounds.Top := y;
  if y > FBounds.Bottom then
    FBounds.Bottom := y;
end;

{ main }

function PartAB(const input: string; pathLimit: integer; var paths: integer): integer;
var
  base: TBase;
  reader: TStreamReader;
begin
  base := TBase.Create;
  try
    if input[1] = '^' then begin
      base.BuildMap(input);
      base.Dump;
    end
    else begin
      reader := TStreamReader.Create(input);
      try
        base.BuildMap(reader.ReadLine);
      finally FreeAndNil(reader); end;
    end;
    Result := base.CalcFurthest(Point(0,0), pathLimit, paths);
  finally FreeAndNil(base); end;
end;

var
  paths: integer;

begin
  try
    Assert(PartAB('^WNE$', 1, paths) = 3, 'PartA(''^WNE$'') <> 3');
    Assert(paths = 3);
    Assert(PartAB('^ENWWW(NEEE|SSE(EE|N))$', 0, paths) = 10, 'PartA(''^ENWWW(NEEE|SSE(EE|N))$'') <> 10');
    Assert(PartAB('^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$', 0, paths) = 18, 'PartA(''^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$'') <> 18');
    Assert(PartAB('^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$', 0, paths) = 23, 'PartA(''^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$'') <> 23');
    Assert(PartAB('^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$', 0, paths) = 31, 'PartA(''^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$'') <> 31');
    Writeln('PartA: ', PartAB('..\..\AdventOfCode20.txt', 1000, paths));
    Writeln('PartB: ', paths);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.

