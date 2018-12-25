program AdventOfCode24;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  System.Math,
  System.RegularExpressions,
  System.Generics.Defaults,
  System.Generics.Collections;

type
  TWeapon = (wRadiation, wBludgeoning, wFire, wSlashing, wCold);
  TWeapons = set of TWeapon;

  TGroup = class
    Count       : integer;
    HitPoints   : integer;
    Immunities  : TWeapons;
    Weaknesses  : TWeapons;
    AttackDamage: integer;
    Weapon      : TWeapon;
    Initiative  : integer;
    IsDefender  : boolean;
    Target      : TGroup;
    function EffectivePower: integer;
  end;

  TBattle = class
  strict private
    FArmy: TObjectList<TGroup>;
  strict protected
    function AttackDamage(attacker, defender: TGroup): integer;
    procedure ExecuteAttacks;
    function HasBothSides: boolean;
    function MapWeapon(const name: string): TWeapon;
    procedure MapWeapons(const list: string; var immunities, weaknesses: TWeapons);
    procedure Read(reader: TStreamReader; isDefender: boolean; boost: integer);
    procedure RunFight;
    procedure SelectTargets;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Run(var defenderWins, attackerWins: boolean; var total: integer);
    function TotalUnits: integer;
    procedure Load(const fileName: string; boost: integer);
  end;

{ TGroup }

function TGroup.EffectivePower: integer;
begin
  Result := Count * AttackDamage;
end;

{ TBattle }

function TBattle.AttackDamage(attacker, defender: TGroup): integer;
begin
  if attacker.Weapon in defender.Immunities then
    Result := 0
  else if attacker.Weapon in defender.Weaknesses then
    Result := 2 * attacker.EffectivePower
  else
    Result := attacker.EffectivePower;
end;

constructor TBattle.Create;
begin
  inherited Create;
  FArmy := TObjectList<TGroup>.Create;
end;

destructor TBattle.Destroy;
begin
  FreeAndNil(FArmy);
  inherited;
end;

procedure TBattle.ExecuteAttacks;
var
  i: integer;
  attack: integer;
begin
  FArmy.Sort(TComparer<TGroup>.Construct(
    function (const left, right: TGroup): integer
    begin
      Result := - CompareValue(left.Initiative, right.Initiative);
    end));

  for i := 0 to FArmy.Count - 1 do begin
    if FArmy[i].Target = nil then
      continue; // for

    attack := Min(FArmy[i].Target.Count, AttackDamage(FArmy[i], FArmy[i].Target) div FArmy[i].Target.HitPoints);
    FArmy[i].Target.Count := FArmy[i].Target.Count - attack;
  end;

  for i := FArmy.Count - 1 downto 0 do
    if FArmy[i].Count <= 0 then
      FArmy.Delete(i);
end;

function TBattle.HasBothSides: boolean;
var
  i: integer;
begin
  Result := false;
  if FArmy.Count > 1 then
    for i := 1 to FArmy.Count - 1 do
      if FArmy[0].IsDefender <> FArmy[i].IsDefender then
        Exit(true);
end;

procedure TBattle.Load(const fileName: string; boost: integer);
var
  reader: TStreamReader;
begin
  reader := TStreamReader.Create(fileName);
  try
    Read(reader, true, boost);
    Read(reader, false, 0);
  finally FreeAndNil(reader); end;
end;

function TBattle.MapWeapon(const name: string): TWeapon;
begin
  if SameText(name, 'radiation') then
    Result := wRadiation
  else if SameText(name, 'bludgeoning') then
    Result := wBludgeoning
  else if SameText(name, 'fire') then
    Result := wFire
  else if SameText(name, 'slashing') then
    Result := wSlashing
  else if SameText(name, 'cold') then
    Result := wCold
  else
    raise Exception.CreateFmt('Unknown weapon: %s', [name]);
end;

procedure TBattle.MapWeapons(const list: string; var immunities,
  weaknesses: TWeapons);
var
  parts: TArray<string>;
  topic: string;
  weapons: TWeapons;
  i: Integer;
begin
  immunities := [];
  weaknesses := [];
  for topic in list.Split([';']) do begin
    weapons := [];
    parts := topic.Trim.Split([' ', ', ']);
    for i := 2 to High(parts) do
      weapons := weapons + [MapWeapon(parts[i])];
    if SameText(parts[0], 'weak') then
      weaknesses := weapons
    else
      immunities := weapons;
  end;
end;

procedure TBattle.Read(reader: TStreamReader; isDefender: boolean; boost: integer);
var
  group: TGroup;
  regex: TRegex;
  s: string;
  immunities, weaknesses: TWeapons;
  offs: integer;
begin
  regex := TRegex.Create('(\d*?) units each with (\d*?) hit points (\((.*?)\)|)\s?with an attack that does (\d*?) (.*?) damage at initiative (\d*)');

  reader.ReadLine;
  while not reader.EndOfStream do begin
    s := reader.ReadLine;
    if s.Trim = '' then
      break; //while

  	with regex.Match(s) do begin
      group := TGroup.Create;
      group.Count := Groups[1].Value.ToInteger;
      group.HitPoints := Groups[2].Value.ToInteger;
      MapWeapons(Groups[4].Value, immunities, weaknesses);
      group.Immunities := immunities;
      group.Weaknesses := weaknesses;
      group.AttackDamage := Groups[5].Value.ToInteger + boost;
      group.Weapon := MapWeapon(Groups[6].Value);
      group.Initiative := Groups[7].Value.ToInteger;
      group.IsDefender := isDefender;
      FArmy.Add(group);
    end;
  end;
end;

procedure TBattle.Run(var defenderWins, attackerWins: boolean; var total: integer);
var
  oldCount: integer;
begin
  while HasBothSides do begin
    total := TotalUnits;
    oldCount := FArmy.Count;
    RunFight;
    if (oldCount = FArmy.Count) and (total = TotalUnits) then begin
      defenderWins := false;
      attackerWins := false;
      Exit;
    end;
  end;
  defenderWins := FArmy[0].IsDefender;
  attackerWins := not defenderWins;
  total:= TotalUnits;
end;

procedure TBattle.RunFight;
begin
  SelectTargets;
  ExecuteAttacks;
end;

procedure TBattle.SelectTargets;
var
  selected: TArray<boolean>;
  i: integer;
  j: integer;
  dam: integer;
  bestDam: integer;
  bestIdx: integer;
begin
  FArmy.Sort(TComparer<TGroup>.Construct(
    function (const left, right: TGroup): integer
    begin
      Result := - CompareValue(left.EffectivePower, right.EffectivePower);
      if Result = 0 then
        Result := - CompareValue(left.Initiative, right.Initiative);
    end));

  SetLength(selected, FArmy.Count);

  for i := 0 to FArmy.Count - 1 do begin
    bestDam := -1;
    bestIdx := -1;
    for j := 0 to FArmy.Count - 1 do begin
      if (i = j) or (FArmy[i].IsDefender = FArmy[j].IsDefender) or selected[j] then
        continue; //for j
      dam := AttackDamage(FArmy[i], FArmy[j]);
      if (dam > 0)
         and (dam > bestDam)
         or ((dam = bestDam)
             and ((FArmy[j].EffectivePower > FArmy[bestIdx].EffectivePower)
                  or ((FArmy[j].EffectivePower = FArmy[bestIdx].EffectivePower)
                      and (FArmy[j].Initiative > FArmy[bestIdx].Initiative))))
      then begin
        bestDam := dam;
        bestIdx := j;
      end;
    end;
    if bestIdx >= 0 then begin
      selected[bestIdx] := true;
      FArmy[i].Target := FArmy[bestIdx];
    end
    else
      FArmy[i].Target := nil;
  end;
end;

function TBattle.TotalUnits: integer;
var
  group: TGroup;
begin
  Result := 0;
  for group in FArmy do
    Result := Result + group.Count;
end;

{ main }

function PartA(const fileName: string): integer;
var
  battle: TBattle;
  defenderWins: boolean;
  attackerWins: boolean;
begin
  battle := TBattle.Create;
  try
    battle.Load(fileName, 0);
    battle.Run(defenderWins, attackerWins, Result);
  finally FreeAndNil(battle); end;
end;

procedure RunBattle(const fileName: string; boost: integer; var totalUnits: integer;
  var defenderWins, attackerWins: boolean);
var
  battle: TBattle;
begin
  battle := TBattle.Create;
  try
    battle.Load(fileName, boost);
    battle.Run(defenderWins, attackerWins, totalUnits);
  finally FreeAndNil(battle); end;
end;

function PartB(const fileName: string): integer;
var
  low, mid, high: integer;
  defenderWins, attackerWins: boolean;
begin
  low := 0;
  RunBattle(fileName, low, Result, defenderWins, attackerWins);
  if defenderWins then
    Exit;

  // Let's hope that the transition from "attacker wins" to "defender wins"
  // is smooth and stable. Otherwise the whole bisecting idea is invalid.

  high := 10;
  repeat
    RunBattle(fileName, high, Result, defenderWins, attackerWins);
    if defenderWins then
      break;
    low := high;
    high := high * 10;
  until false;

  while (high - low) > 1 do begin
    mid := (low + high) div 2;
    RunBattle(fileName, mid, Result, defenderWins, attackerWins);
    if defenderWins then
      high := mid
    else // stalemate is treated as a loss
      low := mid;
  end;

  if low = mid then
    RunBattle(fileName, high, Result, defenderWins, attackerWins);
  Assert(defenderWins);
end;

begin
  try
//    Assert(PartA('..\..\AdventOfCode24test.txt') = 5216, 'PartA(test) <> 5216');
//    Writeln('PartA: ', PartA('..\..\AdventOfCode24.txt'));
//
//    Assert(PartB('..\..\AdventOfCode24test.txt') = 51, 'PartB(test) <> 51');
    Writeln('PartB: ', PartB('..\..\AdventOfCode24.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
//  Write('> '); Readln;
end.
