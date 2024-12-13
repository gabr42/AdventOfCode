program AdventOfCode02;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  FAB.Utils;

var
  tf: textfile;
  s: string;

  function Check1(const ai: TArray<integer>): boolean;
  begin
    Result := true;
    if ai[1] > ai[0] then begin
      for var i := 1 to High(ai) do
        if ((ai[i]-ai[i-1]) < 1) or ((ai[i]-ai[i-1]) > 3) then
          Exit(false)
    end
    else if ai[1] < ai[0] then begin
      for var i := 1 to High(ai) do
        if ((ai[i-1]-ai[i]) < 1) or ((ai[i-1]-ai[i]) > 3) then
          Exit(false)
    end
    else
      Exit(false);
  end;

  function Check2(const ai: TArray<integer>): boolean;
  begin
    var ai2 := Copy(ai);
    Result := false;
    if Check1(ai2) then
      Exit(true);
    for var i := 0 to High(ai2) do
      if Check1(TArray.Remove<integer>(ai2, i)) then
        Exit(true);
  end;

begin
  AssignFile(tf, 'h:\RAZVOJ\AdventOfCode\2024\AdventOfCode02.txt');
  Reset(tf);

  var safe1 := 0;
  var safe2 := 0;
  while not Eof(tf) do begin
    Readln(tf, s);
    var row := TArray.Map<string, integer>(s.Split([' ']), StrToInt);
    if Check1(row) then
      Inc(safe1);
    if Check2(row) then
      Inc(safe2);
  end;
  Writeln('Part 1: ', safe1);
  Writeln('Part 2: ', safe2);

  Write('> '); Readln;
  CloseFile(tf);
end.
