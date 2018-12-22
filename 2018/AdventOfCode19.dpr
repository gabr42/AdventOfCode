program AdventOfCode19;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.Generics.Collections;

type
  TTemplate = TProc<integer,integer,integer>;
  TInstruction = record
    Name: string;
    Sig : string;
    Exec: TTemplate;
  end;

  TInstructions = set of 0..15;

  TCPU = class
  strict private type
    TCommand = array [0..3] of integer;
  var
    FRegisters: array [0..6] of integer;
    FInstructions: TList<TInstruction>;
    FIP: integer;
    FIPReg: integer;
    FProgram: TList<TCommand>;
  strict protected
    procedure DefineInstruction(const name, signature: string; exec: TTemplate);
    function GetRegister(idx: integer): integer;
    procedure SetRegister(idx: integer; value: integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddProgram(inst: TArray<string>);
    procedure Run;
    property Register[idx: integer]: integer read GetRegister write SetRegister;
    property IPRegister: integer read FIPReg write FIPReg;
  end;

{ TCPU }

constructor TCPU.Create;
begin
  inherited Create;
  FInstructions := TList<TInstruction>.Create;
  DefineInstruction('addr', 'rrr', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] + FRegisters[b]; end);
  DefineInstruction('addi', 'rir', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] + b; end);
  DefineInstruction('mulr', 'rrr', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] * FRegisters[b]; end);
  DefineInstruction('muli', 'rir', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] * b; end);
  DefineInstruction('banr', 'rrr', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] AND FRegisters[b]; end);
  DefineInstruction('bani', 'rir', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] AND b; end);
  DefineInstruction('borr', 'rrr', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] OR FRegisters[b]; end);
  DefineInstruction('bori', 'rir', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] OR b; end);
  DefineInstruction('setr', 'rxr', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a]; end);
  DefineInstruction('seti', 'ixr', procedure (a, b, c: integer) begin FRegisters[c] := a; end);
  DefineInstruction('gtir', 'irr', procedure (a, b, c: integer) begin FRegisters[c] := IfThen(a > FRegisters[b], 1, 0); end);
  DefineInstruction('gtri', 'rir', procedure (a, b, c: integer) begin FRegisters[c] := IfThen(FRegisters[a] > b, 1, 0); end);
  DefineInstruction('gtrr', 'rrr', procedure (a, b, c: integer) begin FRegisters[c] := IfThen(FRegisters[a] > FRegisters[b], 1, 0); end);
  DefineInstruction('eqir', 'irr', procedure (a, b, c: integer) begin FRegisters[c] := IfThen(a = FRegisters[b], 1, 0); end);
  DefineInstruction('eqri', 'rir', procedure (a, b, c: integer) begin FRegisters[c] := IfThen(FRegisters[a] = b, 1, 0); end);
  DefineInstruction('eqrr', 'rrr', procedure (a, b, c: integer) begin FRegisters[c] := IfThen(FRegisters[a] = FRegisters[b], 1, 0); end);
  FProgram := TList<TCommand>.Create;
end;

destructor TCPU.Destroy;
begin
  FreeAndNil(FProgram);
  FreeAndNil(FInstructions);
  inherited;
end;

procedure TCPU.AddProgram(inst: TArray<string>);
var
  cmd: TCommand;
  i: Integer;
begin
  cmd[0] := -1;
  for i := 0 to 15 do
    if SameText(FInstructions[i].Name, inst[0]) then begin
      cmd[0] := i;
      break; //for i
    end;
  Assert(cmd[0] in [0..15]);

  for i := 1 to 3 do
    cmd[i] := inst[i].ToInteger;
    
  FProgram.Add(cmd);
end;

procedure TCPU.DefineInstruction(const name, signature: string; exec: TTemplate);
var
  inst: TInstruction;
begin
  inst.Name := name;
  inst.Sig := signature;
  inst.Exec := exec;
  FInstructions.Add(inst);
end;

function TCPU.GetRegister(idx: integer): integer;
begin
  Result := FRegisters[idx];
end;

procedure TCPU.Run;
var
  cmd: TCommand;
begin
  FIP := 0;
  while (FIP >= 0) and (FIP < FProgram.Count) do begin
    cmd := FProgram[FIP];
    FRegisters[FIPReg] := FIP;
    FInstructions[cmd[0]].Exec(cmd[1], cmd[2], cmd[3]);
    FIP := FRegisters[FIPReg];
    Inc(FIP);
  end;
end;

procedure TCPU.SetRegister(idx, value: integer);
begin
  FRegisters[idx] := value;
end;

{ main }

function PartA(const fileName: string): integer;
var
  cpu: TCPU;
  reader: TStreamReader;
begin
  cpu := TCPU.Create;
  try
    reader := TStreamReader.Create(fileName);
    try
      cpu.IPRegister := reader.ReadLine.Split([' '])[1].ToInteger;
      while not reader.EndOfStream do
        cpu.AddProgram(reader.ReadLine.Split([' ']));
    finally FreeAndNil(reader); end;
    cpu.Run;
    Result := cpu.Register[0];
  finally FreeAndNil(cpu); end;
end;

function PartB(initialR0: integer): integer;
var
  a,b,c,d,e: integer;
begin
  // disassembled and reformatted code; see AdventOfCode19.xlsx

  a := initialR0; b := 0; c := 0; d := 0; e := 0;

  c := 1030;

  if a = 1 then begin
    c := c + 10550400;
    a := 0;
  end;

//  e := 1;
//  repeat
//    d := 1;
//    repeat
//      if d * e = c then
//        a := a + e;
//      d := d + 1;
//    until d > c;
//    e := e + 1;
//  until e > c;

  // optimized commented-out part
  for e := 1 to Trunc(Sqrt(c)) do
    if (c mod e) = 0 then begin
      Inc(a, e);
      if e*e < c then
        Inc(a, c div e);
    end;

  Result := a;
end;

begin
  try
//    Assert(PartA('..\..\AdventOfCode19test.txt') = 6, 'PartA(test) <> 6');
//    Writeln('PartA: ', PartA('..\..\AdventOfCode19.txt'));

    Assert(PartB(0) = 1872, 'PartB(test) <> 1872');
    Writeln('PartB: ', PartB(1));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
