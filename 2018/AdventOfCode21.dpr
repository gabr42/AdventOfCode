program AdventOfCode21;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Generics.Collections;

function PartA: integer;
var
  a,b,c,d,e: integer;
begin
  // disasslembled, reorganized code; see AdventOfCode21.xlsx

  a := 0; b := 0; c := 0; d := 0; e := 0;

  repeat {1}
    b := d OR $10000;
    d := 678134;

    repeat {2}
      e := b AND $FF;
      d := (((d + e) AND $FFFFFF) * 65899) AND $FFFFFF;
      if b < 256 then
        break; //repeat {2}
      e := 0;

      repeat {3}
        c := (e + 1) SHL 8;
        if c > b then begin
          b := e;
          break; //repeat {3}
        end
        else
          e := e + 1
      until false;

    until false;

//    if d = a then
//      Halt;

    Exit(d);

  until false;
end;

function PartB: integer;
var
  a,b,c,d,e: integer;
  lastd: integer;
  hash: TDictionary<integer,boolean>;
begin
  // disasslembled, reorganized code; see AdventOfCode21.xlsx

  hash := TDictionary<integer,boolean>.Create;
  try
    lastd := 0;

    a := 0; b := 0; c := 0; d := 0; e := 0;

    repeat {1}
      b := d OR $10000;
      d := 678134;

      repeat {2}
        e := b AND $FF;
        d := (((d + e) AND $FFFFFF) * 65899) AND $FFFFFF;
        if b < 256 then
          break; //repeat {2}
        e := 0;

        repeat {3}
          c := (e + 1) SHL 8;
          if c > b then begin
            b := e;
            break; //repeat {3}
          end
          else
            e := e + 1
        until false;

      until false;

  //    if d = a then
  //      Halt;

      if hash.ContainsKey(d) then
        Exit(lastd);

      hash.Add(d, true);
      lastd := d;

    until false;

  finally FreeAndNil(hash); end;
end;

begin
  try
    Writeln(PartA);
    Writeln(PartB);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
