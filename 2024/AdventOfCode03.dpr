program AdventOfCode03;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.RegularExpressions,
  GpStuff, GpStreams;

var
  data: AnsiString;

procedure Solve(const data: string);
begin
	var regex := TRegEx.Create('mul\((\d{1,3}),(\d{1,3})\)');
	var match := regex.Match(data);
  var sum := 0;
	while match.Success do begin
    Inc(sum, match.Groups[1].Value.ToInteger * match.Groups[2].Value.ToInteger);
		match := match.NextMatch;
	end;
  Writeln('Part 1: ', sum);

  regex := TRegEx.Create('mul\((\d{1,3}),(\d{1,3})\)|don''t\(\)|do\(\)');
	match := regex.Match(data);
  sum := 0;
  var iff := true;
	while match.Success do begin
    if match.Groups[0].Value = 'do()' then
      iff := true
    else if match.Groups[0].Value = 'don''t()' then
      iff := false
    else if iff then
      Inc(sum, match.Groups[1].Value.ToInteger * match.Groups[2].Value.ToInteger);
		match := match.NextMatch;
	end;
  Writeln('Part 2: ', sum);
end;

begin
  Assert(ReadFromFile('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode03.txt', data));
  Solve(string(data));
  Write('> '); Readln;
end.
