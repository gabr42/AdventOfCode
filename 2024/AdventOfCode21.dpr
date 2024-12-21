program AdventOfCode21;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.Types, System.Math,
  Spring.Collections;

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

function Sequence(const num: string; const keypads: IList<IKeypad>): string;
begin
  var solutions := TCollections.CreateList<string>;
  solutions.Add(num);
  for var keypad in keypads do begin
    var nextSol := TCollections.CreateList<string>;
    for var s in solutions do begin
      var ssl := ShortestSeqList(s, keypad);
      for var seq in ssl do begin
        if (not nextSol.IsEmpty) and (Length(seq) < Length(nextSol.First)) then
          nextSol.Clear;
        nextSol.Add(seq);
      end;
    end;
    solutions := nextSol;
  end;

  Result := solutions.First;
end;

begin
  KeypadNum := InitKeypad('789/456/123/ 0A');
  KeypadCtrl := InitKeypad(' ^A/<v>');

  var sl := TStringList.Create;
  sl.LoadFromFile('h:\RAZVOJ\AdventOfCode\2024\AdventOfCode21.txt');
  var keypads := TCollections.CreateList<IKeypad>;
  keypads.Add(KeypadNum);
  keypads.Add(KeypadCtrl);
  keypads.Add(KeypadCtrl);
  var cost := 0;
  for var s in sl do
    Inc(cost, s.Remove(Length(s)-1, 1).ToInteger * Length(Sequence(s, keypads)));
  Writeln('Part 1: ', cost);

  sl.Free;

  Write('> '); Readln;
end.
