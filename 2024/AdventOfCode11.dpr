program AdventOfCode11;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Spring, Spring.Collections,
  GpStreams, FAB.Utils;

type
  TStoneFile = file of int64;

function Blink(const stones: IList<int64>): IList<int64>;
begin
  Result := TCollections.CreateList<int64>;
  Result.Capacity := stones.Count * 2;
  for var stone in stones do
    if stone = 0 then
      Result.Add(1)
    else begin
      var s := stone.ToString;
      if (Length(s) mod 2) = 0 then begin
        Result.Add(Copy(s, 1, Length(s) div 2).ToInt64);
        Result.Add(Copy(s, Length(s) div 2 + 1).ToInt64);
      end
      else
        Result.Add(stone * 2024);
    end;
end;

procedure Solve1(const data: TArray<int64>);
begin
  var gen := TCollections.CreateList<int64>(data);
  for var _ := 1 to 25 do
    gen := Blink(gen);
  Writeln('Part 1: ', gen.Count);
end;

var
  Memo: IDictionary<Tuple<int64,integer>, int64>;
  MemoHit, MemoMiss: integer;

function CountSplit(stone: int64; gensToGo: integer): int64;
var
  _count: int64;
begin
  var key := Tuple<int64,integer>.Create(stone, gensToGo);
  if Memo.TryGetValue(key, _count) then begin
    Inc(MemoHit);
    Exit(_count);
  end;

  if gensToGo = 0 then
    Result := 1
  else if stone = 0 then
    Result := CountSplit(1, gensToGo - 1)
  else begin
    var s := stone.ToString;
    if (Length(s) mod 2) = 0 then
      Result := CountSplit(Copy(s, 1, Length(s) div 2).ToInt64, gensToGo - 1)
              + CountSplit(Copy(s, Length(s) div 2 + 1).ToInt64, gensToGo - 1)
    else
      Result := CountSplit(stone * 2024, gensToGo - 1 );
  end;
  Inc(MemoMiss);
  Memo[key] := Result;
end;

procedure Solve2(const data: TArray<int64>);
begin
  Memo := TCollections.CreateDictionary<Tuple<int64,integer>,int64>;
  var sum2 := int64(0);
  for var stone in data do
    Inc(sum2, CountSplit(stone, 75));
  Writeln('Part 2: ', sum2);
  Writeln(MemoHit, ' / ', MemoMiss, ' = ', Round(100*MemoHit/(MemoHit+MemoMiss)), '%');
end;

var
  s: AnsiString;

begin
  Assert(ReadFromFile('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode11.txt', s));
  Solve1(TArray.Map<string,int64>(string(s).Split([' ']), StrToInt64));
  Solve2(TArray.Map<string,int64>(string(s).Split([' ']), StrToInt64));
  Write('> '); Readln;
end.
