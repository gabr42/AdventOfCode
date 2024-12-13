program AdventOfCode09;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Math,
  Spring.Collections,
  GpStreams;

type
  TBlockInfo = record
    ID    : integer;
    Length: integer;
    constructor Create(AID, ALength: integer);
  end;

function Parse(const input: string): IList<TBlockInfo>;
begin
  Result := TCollections.CreateList<TBlockInfo>;
  var isData := true;
  var id := 0;
  for var ch in input do begin
    var len := string(ch).ToInteger;
    if isData or (len > 0) then begin
      var block := TBlockInfo.Create(IfThen(isData, id, -1), len);
      Result.Add(block);
    end;
    if isData and (len = 0) then
      Writeln('0-len file ', id);
    if isData then
      Inc(id);
    isData := not isData;
  end;
end;

procedure Solve(const input: string);
var
  blocks: IList<TBlockInfo>;
  emptyBlock: integer;

  function FindEmptyBlock: boolean;
  begin
    while blocks[emptyBlock].ID >= 0 do begin
      Inc(emptyBlock);
      if emptyBlock >= blocks.Count then
        Exit(false);
    end;
    Result := true;
  end;

begin
  blocks := Parse(input);
  emptyBlock := 0;
  while FindEmptyBlock do begin
    while blocks.Last.ID < 0 do
      blocks.Delete(blocks.Count - 1);
    if emptyBlock >= blocks.Count then
      break; //while
    var toMove := Min(blocks[emptyBlock].Length, blocks.Last.Length);
    blocks.Insert(emptyBlock, TBlockInfo.Create(blocks.Last.ID, toMove));
    Inc(emptyBlock);
    blocks[emptyBlock] := TBlockInfo.Create(blocks[emptyBlock].ID, blocks[emptyBlock].Length - toMove);
    if blocks[emptyBlock].Length = 0 then
      blocks.Delete(emptyBlock);
    blocks[blocks.Count - 1] := TBlockInfo.Create(blocks.Last.ID, blocks.Last.Length - toMove);
    if blocks.Last.Length = 0 then
      blocks.Delete(blocks.Count - 1);
  end;

  var sum1 := int64(0);
  var pos := 0;
  for var blk in blocks do
    for var _ := 1 to blk.Length do begin
      Inc(sum1, pos * blk.ID);
      Inc(pos);
    end;

  Writeln('Part 1: ', sum1);
end;

procedure Solve2(const input: string);
var
  blocks: IList<TBlockInfo>;

  function FindLeftmostEmpty(length: integer): integer;
  begin
    for var iBlock := 0 to blocks.Count - 1 do
      if (blocks[iBlock].ID < 0) and (blocks[iBlock].Length >= length) then
        Exit(iBlock);
    Result := -1;
  end;

var
  iEmpty: integer;

begin
  blocks := Parse(input);

  var iBlock := blocks.Count-1;
  while iBlock >= 0 do begin
    var block := blocks[iBlock];
    if block.ID < 0 then begin
      Dec(iBlock);
      continue; //while
    end;
    iEmpty := FindLeftmostEmpty(block.Length);
    if (iEmpty < 0) or (iEmpty >= iBlock) then
      Dec(iBlock)
    else begin
      if blocks[iEmpty].Length > blocks[iBlock].Length then begin
        blocks.Insert(iEmpty+1, TBlockInfo.Create(-1, blocks[iEmpty].Length - blocks[iBlock].Length));
        Inc(iBlock);
        blocks[iEmpty] := TBlockInfo.Create(-1, blocks[iBlock].Length);
      end;
      blocks.Exchange(iBlock, iEmpty);
      Dec(iBlock);
    end;
  end;

  var sum2 := int64(0);
  var pos := 0;
  for var blk in blocks do
    if blk.ID >= 0 then
      for var _ := 1 to blk.Length do begin
        Inc(sum2, pos * blk.ID);
        Inc(pos);
      end
    else
      Inc(pos, blk.Length);

  Writeln('Part 2: ', sum2);
end;

{ TBlockInfo }

constructor TBlockInfo.Create(AID, ALength: integer);
begin
  ID := AID;
  Length := ALength;
end;

begin
  var line: AnsiString;
  Assert(ReadFromFile('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode09.txt', line));

  Solve(string(line));
  Solve2(string(line));

  Write('> '); Readln;
end.
