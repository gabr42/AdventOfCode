program AdventOfCode01;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Spring.Collections;

procedure Part1and2;
var
  tf: textfile;
  v1, v2: integer;
begin
  AssignFile(tf, 'h:\RAZVOJ\AdventOfCode\2024\AdventOfCode01.txt');
  Reset(tf);
  var l1 := TCollections.CreateSortedList<integer>;
  var l2 := TCollections.CreateSortedList<integer>;
  while not Eof(tf) do begin                                                                                          /
    Readln(tf, v1, v2);
    l1.Add(v1);
    l2.Add(v2);
  end;

  var sum := 0;
  for var v1v2 in TEnumerable.Zip<integer,integer>(l1, l2) do
    Inc(sum, Abs(v1v2.Value1 - v1v2.value2));
  Writeln('Part 1: ', sum);

  var ms1 := TCollections.CreateMultiSet<integer>(l1);
  var ms2 := TCollections.CreateMultiSet<integer>(l2);
  sum := 0;
  for var kv1 in ms1.Entries do
    Inc(sum, kv1.Item * ms2.ItemCount[kv1.Item]);
  Writeln('Part 2: ', sum);

  CloseFile(tf);
end;

begin
  try
    Part1and2;
    Write('> '); Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
