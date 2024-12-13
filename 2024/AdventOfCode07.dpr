program AdventOfCode07;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Math,
  Spring.Collections;

var
  Equations: IDictionary<int64, IStack<int64>>;

procedure Read(const fileName: string);
var
  tf: textfile;
  s: string;
begin
  Equations := TCollections.CreateDictionary<int64, IStack<int64>>;

  AssignFile(tf, fileName);
  Reset(tf);
  while not Eof(tf) do begin
    Readln(tf, s);
    var parts := s.Split([':', ' '], TStringSplitOptions.ExcludeEmpty);
    var nums := TCollections.CreateStack<int64>;
    for var i := 1 to High(parts) do
      nums.Push(parts[i].ToInt64);
    Equations[parts[0].ToInt64] := nums;
  end;
  CloseFile(tf);
end;

function CanSolve(res: int64; ops: IStack<int64>): boolean;
begin
  if ops.Count = 1 then
    Exit(res = ops.Peek);

  var op := ops.Pop;
  try
    if (res >= op) and CanSolve(res - op, ops) then
      Exit(true);

    if ((res mod op) = 0) and CanSolve(res div op, ops) then
      Exit(true);

    Result := false;
  finally ops.Push(op); end;
end;

function CanSolve2(res: int64; ops: IStack<int64>): boolean;
begin
  if ops.Count = 1 then
    Exit(res = ops.Peek);

  var op := ops.Pop;
  try
    if (res >= op) and CanSolve2(res - op, ops) then
      Exit(true);

    if ((res mod op) = 0) and CanSolve2(res div op, ops) then
      Exit(true);

    var lenOp := Length(op.ToString);
    res := res - op;
    while (lenOp > 0) do begin
      if (res mod 10) <> 0 then
        Exit(false);
      res := res div 10;
      Dec(lenOp);
    end;
    Result := CanSolve2(res, ops);
  finally ops.Push(op); end;
end;

procedure Solve;
begin
  var sum1 := int64(0);
  var sum2 := int64(0);
  for var eq in Equations do begin
    if CanSolve(eq.Key, eq.Value) then
      Inc(sum1, eq.Key);
    if CanSolve2(eq.Key, eq.Value) then
      Inc(sum2, eq.Key);
  end;
  Writeln('Part 1: ', sum1);
  Writeln('Part 2: ', sum2);
end;

begin
  Read('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode07.txt');
  Solve;
  Write('> '); Readln;
end.
