program AdventOfCode05;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Spring.Collections,
  FAB.Utils;

var
  Rules: IMultiMap<integer, integer>;
  Orders: IList<TArray<integer>>;

procedure ReadData(const fileName: string);
var
  tf: textfile;
  ln: string;
begin
  Rules := TCollections.CreateHashMultiMap<integer,integer>;
  AssignFile(tf, fileName);
  Reset(tf);
  repeat
    Readln(tf, ln);
    if ln = '' then
      break;
    var parts := ln.Split(['|']);
    Rules.Add(parts[0].ToInteger, parts[1].ToInteger);
  until false;

  Orders := TCollections.CreateList<TArray<integer>>;
  while not Eof(tf) do begin
    Readln(tf, ln);
    Orders.Add(TArray.Map<string,integer>(ln.Split([',']), StrToInt));
  end;
  CloseFile(tf);
end;

function IsValidPart1(const order: TArray<integer>): boolean;
begin
  Result := true;
  for var i := 0 to High(order)-1 do
    for var j := i+1 to High(order) do
      if Rules.Contains(order[j], order[i]) then
        Exit(false);
end;

function GetPart2(const order: TArray<integer>): integer;
begin
  var o := Copy(order);
  for var i := 0 to High(order)-1 do
    for var j := i+1 to High(order) do
      if Rules.Contains(order[j], order[i]) then begin
        var tmp := order[j];
        order[j] := order[i];
        order[i] := tmp;
      end;

  Result := order[High(order) div 2];
end;

procedure Solve;
begin
  var sum1 := 0;
  var sum2 := 0;
  for var order in Orders do
    if IsValidPart1(order) then
      Inc(sum1, order[High(order) div 2])
    else
      Inc(sum2, GetPart2(order));
  Writeln('Part 1: ', sum1);
  Writeln('Part 2: ', sum2);
end;

begin
  ReadData('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode05.txt');
  Solve;
  Write('> '); Readln;
end.
