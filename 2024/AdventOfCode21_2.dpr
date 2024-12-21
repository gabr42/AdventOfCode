program AdventOfCode21_2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.Types, System.Math,
  System.Generics.Defaults,
  Spring, Spring.Collections;

type
  IKeypad = IBidiDictionary<char, TPoint>;

var
  KeypadNum: IKeypad;
  KeypadCtrl: IKeypad;

function InitKeypad(const layout: string): IKeypad;
begin
  Result := TCollections.CreateBidiDictionary<char, TPoint>;
  var y := 0;
  for var line in layout.Split(['/'], TStringSplitOptions.ExcludeEmpty) do begin
    for var x := 1 to Length(line) do
      if line[x] <> ' ' then
        Result[line[x]] := Point(x - 1, y);
    Inc(y);
  end;
end;

function GetMoves(const posFrom, posTo: TPoint; const keypad: IKeypad): IEnumerable<string>;
var
  moves: IList<string>;

  procedure CheckMoves(const posFrom, posTo: TPoint; const keys: string);
  begin
    if posFrom = posTo then begin
      moves.Add(keys);
      Exit;
    end;

    if not keypad.Inverse.ContainsKey(posFrom) then
      Exit;

    if posFrom.x < posTo.x then
      CheckMoves(posFrom + Point(1, 0), posTo, keys + '>');
    if posFrom.x > posTo.x then
      CheckMoves(posFrom + Point(-1, 0), posTo, keys + '<');
    if posFrom.y < posTo.y then
      CheckMoves(posFrom + Point(0, 1), posTo, keys + 'v');
    if posFrom.y > posTo.y then
      CheckMoves(posFrom + Point(0, -1), posTo, keys + '^');
  end;

begin
  moves := TCollections.CreateList<string>;
  CheckMoves(posFrom, posTo, '');
  Result := moves;
end;

function ShortestSeqList(const seq: string; const keypad: IKeypad): IEnumerable<string>;
begin
  var startPos := keypad['A'];
  var seqList := TCollections.CreateList<string>;
  seqList.Add('');
  for var ch in seq do begin
    var moves := GetMoves(startPos, keypad[ch], keypad);
    var newList := TCollections.CreateList<string>;
    for var seq1 in seqList do
      for var seq2 in moves do
        newList.Add(seq1+seq2+'A');
    startPos := keypad[ch];
    seqList := newList;
  end;

  Result := seqList;
end;

function SeqCost(const seq: string; const keypad: IKeypad): int64;
begin
  Result := 0;
  var prevCh := 'A';
  for var ch in seq do begin
    var pt1 := keypad[prevCh];
    var pt2 := keypad[ch];
    Result := Result + Abs(pt1.x - pt2.x) + Abs(pt1.y - pt2.y);
    prevCh := ch;
  end;
end;

function NumRepeats(const seq: string): int64;
begin
  Result := 0;
  for var i := 2 to Length(seq) do
    if seq[i] = seq[i-1] then
      Inc(Result);
end;

function Sequences(const num: string; const keypad: IKeypad): IEnumerable<string>;
begin
  var solutions := TCollections.CreateList<string>;
  solutions.Add(num);
  var outSeq := TCollections.CreateList<string>;
  for var s in solutions do begin
    var ssl := ShortestSeqList(s, keypad);
    for var seq in ssl do begin
      if (not outSeq.IsEmpty) and (Length(seq) < Length(outSeq.First)) then
        outSeq.Clear;
      outSeq.Add(seq);
    end;
  end;
  Result := outSeq;
end;

var
  CheapMemos: TArray<IDictionary<string, int64>>;

function Cheapest(const seq: string; level: int64; const keypad: IKeypad): int64;
begin
  if level = 0 then
    Exit(Length(seq));

  var _result: int64;
  if CheapMemos[level].TryGetValue(seq, _result) then
    Exit(_result);

  Result := int64(0);
  for var subSeq in seq.Split(['A'], TStringSplitOptions.ExcludeLastEmpty) do begin
    var minSubSeq := int64(0);
    var cheap := int64(0);
    for var s in Sequences(subSeq + 'A', keypad) do begin
      var ch := Cheapest(s, level - 1, KeypadCtrl);
      if (cheap = 0) or (ch < cheap) then
        cheap := ch;
    end;
    Result := Result + cheap;
  end;

  CheapMemos[level][seq] := Result;
end;

begin
  KeypadNum := InitKeypad('789/456/123/ 0A');
  KeypadCtrl := InitKeypad(' ^A/<v>');
  SetLength(CheapMemos, 27);
  for var i := Low(CheapMemos) to High(CheapMemos) do
    CheapMemos[i] := TCollections.CreateDictionary<string, int64>;
  var sl := TStringList.Create;
  sl.LoadFromFile('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode21.txt');

  var cost: int64 := 0;
  for var s in sl do
    Inc(cost, s.Remove(Length(s)-1, 1).ToInt64 * Cheapest(s, 3, KeypadNum));

  Writeln('Part 1: ', cost);

  cost := 0;
  for var s in sl do
    Inc(cost, s.Remove(Length(s)-1, 1).ToInt64 * Cheapest(s, 26, KeypadNum));

  Writeln('Part 2: ', cost);

  sl.Free;

  Write('> '); Readln;
end.
