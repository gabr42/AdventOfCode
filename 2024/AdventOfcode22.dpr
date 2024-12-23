program AdventOfcode22;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes,
  Spring.Collections;

var
  Aggregate: IDictionary<cardinal, integer>;

function NextPseudo(num, steps: integer): integer;
var
  diffs: cardinal;
begin
  diffs := 0;
  var prev := 0;
  var _num := int64(num);
  var seen := TCollections.CreateSet<cardinal>;
  for var step := 1 to steps do begin
    _num := (_num XOR _num * 64) mod 16777216;
    _num := (_num XOR _num div 32) mod 16777216;
    _num := (_num XOR _num * 2048) mod 16777216;
    var diff := (_num mod 10) - prev + 10;
    diffs := ((diffs AND $00FFFFFF) SHL 8) OR (diff AND $FF);
    prev := _num mod 10;
    if (step >= 4) and (not seen.Contains(diffs)) then begin
      Aggregate[diffs] := Aggregate.GetValueOrDefault(diffs) + prev;
      seen.Add(diffs);
    end;
  end;
  Result := _num;
end;

begin
  Aggregate := TCollections.CreateDictionary<cardinal, integer>;
  var sl := TStringList.Create;
  sl.LoadFromFile('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode22.txt');
  var sum := int64(0);
  for var s in sl do
    Inc(sum, NextPseudo(s.ToInteger, 2000));
  Writeln('Part 1: ', sum);
  Writeln('Part 2: ', Aggregate.Values.Ordered.Last);
  sl.Free;
  Write('> '); Readln;
end.
