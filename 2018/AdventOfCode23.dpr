program AdventOfCode23;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.Generics.Defaults,
  System.Generics.Collections;

type
  TNanobot = record
    x, y, z, p: integer;
  end;

  TNanobots = TList<TNanobot>;

procedure LoadBots(bots: TNanobots; const fileName: string);
var
  bot: TNanobot;
  parts: TArray<string>;
  reader: TStreamReader;
begin
  reader := TStreamReader.Create(fileName);
  try
    while not reader.EndOfStream do begin
      parts := reader.ReadLine.Split(['<', ',', '>', '=']);
      bot.x := parts[2].ToInteger;
      bot.y := parts[3].ToInteger;
      bot.z := parts[4].ToInteger;
      bot.p := parts[7].ToInteger;
      bots.Add(bot);
    end;
  finally FreeAndNil(reader); end;
end;

function PartA(const fileName: string): integer;
var
  bot: TNanobot;
  bots: TNanobots;
  maxbot: TNanobot;
begin
  bots := TNanobots.Create;
  try
    LoadBots(bots, fileName);

    maxbot := bots[0];
    for bot in bots do
      if bot.p > maxbot.p then
        maxbot := bot;

    Result := 0;
    for bot in bots do
      if (Abs(bot.x-maxbot.x) + Abs(bot.y-maxbot.y) + Abs(bot.z-maxbot.z)) <= maxbot.p then
        Inc(Result);
  finally FreeAndNil(bots); end;
end;

procedure SortByX(bots: TNanobots);
begin
  bots.Sort(TComparer<TNanobot>.Construct(
    function (const left, right: TNanobot): integer
    begin
      Result := CompareValue(left.x, right.x);
    end));
end;

function PartB(const fileName: string): integer;
var
  bot: TNanobot;
  bots: TNanobots;
  best: TNanobot;
  right: integer;
  minBot: TNanobot;
  maxBot: TNanobot;
  dist: integer;
  x,y,z: integer;
  count: integer;
  cellDist: integer;
  target: integer;
begin
  bots := TNanobots.Create;
  try
    LoadBots(bots, fileName);

    minBot := bots[0];
    maxBot := bots[0];
    for bot in bots do begin
      if bot.x < minBot.x then minBot.x := bot.x;
      if bot.y < minBot.y then minBot.y := bot.y;
      if bot.z < minBot.z then minBot.z := bot.z;
      if bot.x > maxBot.x then maxBot.x := bot.x;
      if bot.y > maxBot.y then maxBot.y := bot.y;
      if bot.z > maxBot.z then maxBot.z := bot.z;
    end;

    // space subdivision
    // I'm pretty sure this can run into a local maximum, but whatever works ...

    dist := 1;
    while dist < Max(maxBot.x + maxBot.p - minBot.x + minBot.p,
                     Max(maxBot.y + maxBot.p - minBot.y + minBot.p,
                         maxBot.z + maxBot.p - minBot.z + minBot.p))
    do
      dist := dist * 2;
    dist := dist div 2;

    repeat
      target := 0;
      x := minBot.x;
      while x <= maxBot.x do begin
        y := minBot.y;
        while y <= maxBot.y do begin
          z := minBot.z;
          while z <= maxBot.z do begin
            count := 0;

            for bot in bots do begin
              cellDist := Abs(x - bot.x) + Abs(y - bot.y) + Abs(z - bot.z);
              if (celldist - bot.p) < dist then
                Inc(count);
            end;

            if (count > target) or
               ((count = target) and ((Abs(x) + Abs(y) + Abs(z)) < best.p))
            then begin
              target := count;
              best.x := x;
              best.y := y;
              best.z := z;
              best.p := Abs(x) + Abs(y) + Abs(z);
            end;

            Inc(z, dist);
          end;
          Inc(y, dist);
        end;
        Inc(x, dist);
      end;

      if dist = 1 then
        Exit(best.p)
      else begin
        minBot.x := best.x - dist; maxBot.x := best.x + dist;
        minBot.y := best.y - dist; maxBot.y := best.y + dist;
        minBot.z := best.z - dist; maxBot.z := best.z + dist;
        dist := dist div 2;
      end;
    until false;

  finally FreeAndNil(bots); end;
end;

begin
  try
//    Assert(PartA('..\..\AdventOfCode23test.txt') = 7, 'PartA(test) <> 7');
//    Writeln('PartA: ', PartA('..\..\AdventOfCode23.txt'));

    Assert(PartB('..\..\AdventOfCode23test2.txt') = 36, 'PartB(test) <> 36)');
    Writeln('PartB: ', PartB('..\..\AdventOfCode23.txt'));

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
