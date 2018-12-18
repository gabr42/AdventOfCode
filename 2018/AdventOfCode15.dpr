program AdventOfCode15;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Winapi.Windows,
  System.Types,
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  System.Generics.Defaults,
  System.Generics.Collections;

const
  CMaxBattlegroundSize = 32;

type
  TBattleground = class
  strict private type
    TArmy = (arGoblins, arElves);
    TCompany = class
      Location    : TPoint;
      Army        : TArmy;
      HitPoints   : integer;
      AttackPoints: integer;
    end;
    TCell = record
      Company : TCompany;
      CellType: AnsiChar;
      PrevPath: TPoint;
    end;
    TLayout = array [1..CMaxBattlegroundSize, 1..CMaxBattlegroundSize] of TCell;
  strict private
    FCompareInReadingOrder: IComparer<TPoint>;
    FNumGoblins: integer;
    FNumElves: integer;
    FLayout: TLayout;
    FSize: TPoint;
  strict protected
    function CellTypeAround(const layout: TLayout; const loc: TPoint;
      cellType: AnsiChar): TArray<TPoint>;
    procedure Die(company: TCompany);
    procedure Fight(company: TCompany);
    procedure FindBestMove(company: TCompany; var moveTo: TPoint);
    function IsEnemyAround(const loc: TPoint; army: TArmy): boolean;
    procedure MoveCompany(company: TCompany; const moveTo: TPoint);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure Dump;
    function HasEnded: boolean;
    procedure Load(const fileName: string; elvesAttackPower: integer);
    function RemainingHitPoints: integer;
    procedure Turn(var interrupted: boolean);
    property NumGoblins: integer read FNumGoblins;
    property NumElves: integer read FNumElves;
    property Size: TPoint read FSize write FSize;
  end;

{ TBattleground }

procedure TBattleground.AfterConstruction;
begin
  inherited;
  FCompareInReadingOrder := TComparer<TPoint>.Construct(
    function (const left, right: TPoint): integer
    begin
      if left.Y < right.Y then
        Result := -1
      else if left.Y > right.Y then
        Result := 1
      else if left.X < right.X then
        Result := -1
      else if left.X > right.X then
        Result := 1
      else
        Result := 0;
    end);
end;

procedure TBattleground.BeforeDestruction;
var
  col: integer;
  row: integer;
begin
  for row := 1 to Size.Y do
    for col := 1 to Size.X do
      if assigned(FLayout[row, col].Company) then
        FLayout[row, col].Company.Free;
  inherited;
end;

function TBattleground.CellTypeAround(const layout: TLayout;
  const loc: TPoint; cellType: AnsiChar): TArray<TPoint>;
var
  outPos: integer;
begin // results are returned in "reading order"
  SetLength(Result, 4);
  outPos := 0;
  if layout[loc.Y - 1, loc.X].CellType = cellType then begin
    Result[outPos] := Point(loc.X, loc.Y - 1);
    Inc(outPos);
  end;
  if layout[loc.Y, loc.X - 1].CellType = cellType then begin
    Result[outPos] := Point(loc.X - 1, loc.Y);
    Inc(outPos);
  end;
  if layout[loc.Y, loc.X + 1].CellType = cellType then begin
    Result[outPos] := Point(loc.X + 1, loc.Y);
    Inc(outPos);
  end;
  if layout[loc.Y + 1, loc.X].CellType = cellType then begin
    Result[outPos] := Point(loc.X, loc.Y + 1);
    Inc(outPos);
  end;
  SetLength(Result, outPos);
end;

procedure TBattleground.Die(company: TCompany);
begin
  FLayout[company.Location.Y, company.Location.X].Company := nil;
  FLayout[company.Location.Y, company.Location.X].CellType := '.';
  if company.Army = arGoblins then
    Dec(FNumGoblins)
  else
    Dec(FNumElves);
  company.Free;
end;

procedure TBattleground.Dump;
var
  col: integer;
  row: integer;
begin
  for row := 1 to Size.Y do begin
    for col := 1 to Size.X do
      Write(FLayout[row, col].CellType);
    Write(' ');
    for col := 1 to Size.X do
      if assigned(FLayout[row, col].Company) then
        Write(FLayout[row, col].Company.HitPoints, ' ');
    Writeln;
  end;
end;

procedure TBattleground.Fight(company: TCompany);
var
  chosen: TCompany;
  enemies: TArray<TPoint>;
  i: integer;
begin
  enemies := CellTypeAround(FLayout, company.Location,
    AnsiChar(IfThen(company.Army = arGoblins, 'E', 'G')[1]));
  if Length(enemies) = 0 then
    Exit;
  chosen := FLayout[enemies[0].Y, enemies[0].X].Company;
  for i := 1 to High(enemies) do
    if FLayout[enemies[i].Y, enemies[i].X].Company.HitPoints < chosen.HitPoints then
      chosen := FLayout[enemies[i].Y, enemies[i].X].Company;
  chosen.HitPoints := chosen.HitPoints - company.AttackPoints;
  if chosen.HitPoints <= 0 then
    Die(chosen);
end;

procedure TBattleground.FindBestMove(company: TCompany; var moveTo: TPoint);
var
  flood: TLayout;
  next: TList<TPoint>;

  procedure AddToPath(const prevPt, nextPt: TPoint);
  begin
    flood[nextPt.Y, nextPt.X].PrevPath := prevPt;
    next.Add(nextPt);
    flood[nextPt.Y, nextPt.X].CellType := '*';
  end;

  function FindFirstStep(pt: TPoint): TPoint;
  begin
    Result := pt;
    while flood[Result.Y, Result.X].PrevPath <> company.Location do
      Result := flood[Result.Y, Result.X].PrevPath;
  end;

var
  enemyFound: boolean;
  curr: TPoint;
  current: TList<TPoint>;
  potentials: TList<TPoint>;
  pt: TPoint;

begin
  flood := FLayout;

  moveTo := Point(0, 0);
  if not IsEnemyAround(company.Location, company.Army) then begin
    potentials := TList<TPoint>.Create;
    try
      current := TList<TPoint>.Create;
      try
        next := TList<TPoint>.Create;
        try
          for pt in CellTypeAround(flood, company.Location, '.') do
            AddToPath(company.Location, pt);

          enemyFound := false;
          while (next.Count > 0) and (not enemyFound) do begin
            current.Clear;
            current.AddRange(next);
            next.Clear;

            for curr in current do begin
              if IsEnemyAround(curr, company.Army) then begin
                enemyFound := true;
                potentials.Add(curr);
              end
              else
                for pt in CellTypeAround(flood, curr, '.') do
                  AddToPath(curr, pt);
            end;
          end;
        finally FreeAndNil(next); end;
      finally FreeAndNil(current); end;

      if potentials.Count > 0 then begin
        potentials.Sort(FCompareInReadingOrder);
        moveTo := FindFirstStep(potentials[0]);
      end;
    finally FreeAndNil(potentials); end;
  end;
end;

function TBattleground.HasEnded: boolean;
begin
  Result := (FNumGoblins = 0) or (FNumElves = 0);
end;

function TBattleground.IsEnemyAround(const loc: TPoint; army: TArmy): boolean;

  function Check(dRow, dCol: integer): boolean;
  begin
    Result := false;
    if assigned(FLayout[loc.Y + dRow, loc.X + dCol].Company)
       and (FLayout[loc.Y + dRow, loc.X + dCol].Company.Army <> army)
    then
      Exit(true);
  end;

begin
  Result := Check(-1, 0) or Check(0, -1) or Check(0, 1) or Check(1, 0);
end;

procedure TBattleground.Load(const fileName: string; elvesAttackPower: integer);
var
  company: TCompany;
  i: integer;
  reader: TStreamReader;
  s: string;
begin
  reader := TStreamReader.Create(fileName);
  try
    FSize := Point(0, 0);
    while not reader.EndOfStream do begin
      FSize := Point(FSize.X, FSize.Y + 1);
      s := reader.ReadLine;
      if FSize.X = 0 then
        FSize := Point(Length(s), FSize.Y)
      else
        Assert(FSize.X = Length(s));
      for i := 1 to Length(s) do begin
        FLayout[FSize.Y, i].CellType := AnsiChar(s[i]);
        if CharInSet(s[i], ['E', 'G']) then begin
          company := TCompany.Create;
          company.Location := Point(i, FSize.Y);
          if s[i] = 'E' then begin
            company.Army := arElves;
            company.AttackPoints := elvesAttackPower;
            Inc(FNumElves);
          end
          else begin
            company.Army := arGoblins;
            company.AttackPoints := 3;
            Inc(FNumGoblins);
          end;
          company.HitPoints := 200;
          FLayout[FSize.Y, i].Company := company;
        end;
      end;
    end;
  finally FreeAndNil(reader); end;
end;

procedure TBattleground.MoveCompany(company: TCompany; const moveTo: TPoint);
begin
  FLayout[moveTo.Y, moveTo.X] := FLayout[company.Location.Y, company.Location.X];
  FLayout[company.Location.Y, company.Location.X].Company := nil;
  FLayout[company.Location.Y, company.Location.X].CellType := '.';
  company.Location := moveTo;
end;

function TBattleground.RemainingHitPoints: integer;
var
  col: integer;
  row: integer;
begin
  Result := 0;
  for row := 1 to Size.Y do
    for col := 1 to Size.X do
      if assigned(FLayout[row,col].Company) then
        Inc(Result, FLayout[row,col].Company.HitPoints);
end;

procedure TBattleground.Turn(var interrupted: boolean);
var
  col: integer;
  company: TCompany;
  location: TPoint;
  moveTo: TPoint;
  row: integer;
  units: TList<TPoint>;
begin
  interrupted := false;
  units := TList<TPoint>.Create;
  try
    for row := 1 to Size.Y do
      for col := 1 to Size.X do
        if assigned(FLayout[row,col].Company) then
          units.Add(Point(col, row));

    for location in units do begin
      company := FLayout[location.Y, location.X].Company;
      if not assigned(company) then // may have just been killed
        continue;
      if HasEnded then begin
        interrupted := true;
        Exit;
      end;

      FindBestMove(company, moveTo);
      if moveTo <> Point(0, 0) then
        MoveCompany(company, moveTo);
      Fight(company);
    end;
  finally FreeAndNil(units); end;
end;

{ main }

function RunBattle(const fileName: string; animate: boolean;
  elvesAttackPower: integer; stopIfElfDies: boolean; var elvesDied: boolean): integer;
var
  battle: TBattleground;
  interrupted: boolean;
  step: integer;
  newPos: TCoord;
  numElves: integer;
begin
  elvesDied := false;
  battle := TBattleground.Create;
  try
    battle.Load(fileName, elvesAttackPower);
    numElves := battle.NumElves;
    if animate then begin
      battle.Dump;
      Readln;
    end;
    step := 0;
    repeat
      Inc(step);
      battle.Turn(interrupted);
      if animate then begin
        NewPos.X := 0;
        NewPos.Y := 0;
        SetConsoleCursorPosition(TTextRec(Output).Handle, NewPos);
        Writeln(step);
        battle.Dump;
      end;
      if stopIfElfDies and (numElves <> battle.NumElves) then begin
        elvesDied := true;
        interrupted := true;
      end;
    until interrupted;
    Result := (step - 1) * battle.RemainingHitPoints;
  finally FreeAndNil(battle); end;
end;

function PartA(const fileName: string; animate: boolean = false): integer;
var
  elvesDied: boolean;
begin
  Result := RunBattle(fileName, false {animate}, 3, false, elvesDied);
end;

function PartB(const fileName: string; animate: boolean = false): integer;
var
  elvesDied: boolean;
  mid: integer;
  minElfAttack: integer;
  maxElfAttack: integer;
begin
  minElfAttack := 4;
  Result := RunBattle(fileName, false, minElfAttack, true, elvesDied);
  if not elvesDied then
    Exit;

  repeat
    maxElfAttack := minElfAttack + 10;
    Result := RunBattle(fileName, false, maxElfAttack, true, elvesDied);
    if elvesDied then
      minElfAttack := maxElfAttack
    else
      break; //repeat
  until false;

  while (minElfAttack + 1) < maxElfAttack do begin
    mid := (maxElfAttack + minElfAttack) div 2;
    Result := RunBattle(fileName, false, mid, true, elvesDied);
    if elvesDied then
      minElfAttack := mid
    else
      maxElfAttack := mid;
  end;

  Result := RunBattle(fileName, false {animate}, minElfAttack + 1, true, elvesDied);
  Assert(not elvesDied);
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode15test1.txt') = 27730, 'PartA(test1) <> 27730');
    Assert(PartA('..\..\AdventOfCode15test2.txt') = 36334, 'PartA(test2) <> 36334');
    Assert(PartA('..\..\AdventOfCode15test3.txt') = 39514, 'PartA(test3) <> 39514');
    Assert(PartA('..\..\AdventOfCode15test4.txt') = 27755, 'PartA(test4) <> 27755');
    Assert(PartA('..\..\AdventOfCode15test5.txt') = 28944, 'PartA(test5) <> 28944');
    Assert(PartA('..\..\AdventOfCode15test6.txt') = 18740, 'PartA(test6) <> 18740');
    Writeln('PartA: ', PartA('..\..\AdventOfCode15.txt', true));

    Assert(PartB('..\..\AdventOfCode15test1.txt') =  4988, 'PartB(test1) <> 4988');
    Assert(PartB('..\..\AdventOfCode15test3.txt') = 31284, 'PartB(test3) <> 31284');
    Assert(PartB('..\..\AdventOfCode15test4.txt') =  3478, 'PartB(test4) <> 3478');
    Assert(PartB('..\..\AdventOfCode15test5.txt') =  6474, 'PartB(test5) <> 6474');
    Assert(PartB('..\..\AdventOfCode15test6.txt') =  1140, 'PartB(test6) <> 1140');
    Writeln('PartB: ', PartB('..\..\AdventOfCode15.txt', true));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
