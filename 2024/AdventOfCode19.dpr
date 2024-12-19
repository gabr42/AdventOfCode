program AdventOfCode19;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Spring, Spring.Collections;

var
  Patterns: IMultiMap<char, string>;

function CountSolutions(const towel: string): int64;
var
  memo: IDictionary<int64, int64>;

  function _CountSolutions(fromChar: int64): int64;

    function ComparePat(const pat: string): boolean;
    begin
      Result := true;
      var endPos := fromChar + Length(pat) - 1;
      if endPos > Length(towel) then
        Exit(false);
      for var iCh := fromChar to endPos do
        if pat[iCh-fromChar+1] <> towel[iCh] then
          Exit(false);
    end;

  begin
    if fromChar = (Length(towel) + 1) then
      Exit(1);

    var _result: int64;
    if memo.TryGetValue(fromChar, _result) then
      Exit(_result);

    Result := 0;
    for var pat in Patterns[towel[fromChar]] do begin
      if ComparePat(pat) then begin
        var cr := _CountSolutions(fromChar + Length(pat));
        if cr > 0 then
          Result := Result + cr;
      end;
    end;
    memo[fromChar] := Result;
  end;

begin
  memo := TCollections.CreateDictionary<int64, int64>;
  Result := _CountSolutions(1);
end;

procedure Solve1(const fileName: string);
var
  tf: textfile;
  s: string;
begin
  Patterns := TCollections.CreateMultiMap<char, string>;

  AssignFile(tf, fileName);
  Reset(tf);
  repeat
    Readln(tf, s);
    for var pat in s.Split([',', ' '], TStringSplitOptions.ExcludeEmpty) do
      Patterns.Add(pat[1], pat);
  until s = '';

  var valid := 0;
  var count := int64(0);
  while not Eof(tf) do begin
    Readln(tf, s);
    Writeln(s);
    var c := CountSolutions(s);
    if c > 0 then
      Inc(valid);
    Inc(count, c);
  end;

  CloseFile(tf);
  Writeln('Part 1: ', valid);
  Writeln('Part 2: ', count);
end;

begin
  Solve1('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode19.txt');
  Write('> '); Readln;
end.
