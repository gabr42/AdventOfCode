unit wwMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids,
  Spring.Collections, Vcl.StdCtrls;

type
  TMoveInfo = record
    Rotate: char;
    Move: TPoint;
  end;

  TfrmWardenWalk = class(TForm)
    sgGrid: TStringGrid;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    btnSave: TButton;
    btnLoad: TButton;
    lblCount: TLabel;
    btnClear: TButton;
    procedure btnClearClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgGridDrawCell(Sender: TObject; ACol, ARow: LongInt; Rect: TRect;
      State: TGridDrawState);
    procedure sgGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FGrid : TArray<TArray<char>>;
    FIsLoop: boolean;
    FMoves: IDictionary<char, TMoveInfo>;
  public
    procedure Clear;
    procedure RunSimulation;
    procedure Walk(x, y: integer; direction: char;
      var len: integer; var isLoop: boolean);
  end;

var
  frmWardenWalk: TfrmWardenWalk;

implementation

{$R *.dfm}

procedure TfrmWardenWalk.btnClearClick(Sender: TObject);
begin
  Clear;
  RunSimulation;
end;

procedure TfrmWardenWalk.btnLoadClick(Sender: TObject);
var
  tf: textfile;
  colCount, rowCount: integer;
  s: string;
begin
  if OpenDialog1.Execute then begin
    AssignFile(tf, OpenDialog1.FileName);
    Reset(tf);
    Readln(tf, colCount, rowCount);
    for var y := 0 to rowCount - 1 do begin
      Readln(tf, s);
      for var x := 0 to colCount - 1 do
        FGrid[x,y] := s[x+1];
    end;
    CloseFile(tf);
  end;
  RunSimulation;
end;

procedure TfrmWardenWalk.btnSaveClick(Sender: TObject);
var
  tf: textfile;
begin
  if SaveDialog1.Execute then begin
    AssignFile(tf, SaveDialog1.FileName);
    Rewrite(tf);
    Writeln(tf, sgGrid.ColCount, ' ', sgGrid.RowCount);
    for var y := 0 to sgGrid.RowCount - 1 do begin
      for var x := 0 to sgGrid.ColCount - 1 do
        Write(tf, FGrid[x, y]);
      Writeln(tf);
    end;
    CloseFile(tf);
  end;
end;

procedure TfrmWardenWalk.Clear;
begin
  for var x := 0 to sgGrid.ColCount - 1 do
    for var y := 0 to sgGrid.RowCount - 1 do
      FGrid[x,y] := ' ';
end;

procedure TfrmWardenWalk.FormCreate(Sender: TObject);

  procedure MakeMove(dir, nextDir: char; dx, dy: integer);
  var
    mi: TMoveInfo;
  begin
    mi.Rotate := nextDir;
    mi.Move := Point(dx, dy);
    FMoves[dir] := mi;
  end;

begin
  SetLength(FGrid, sgGrid.ColCount, sgGrid.RowCount);
  Clear;

  FMoves := TCollections.CreateDictionary<char, TMoveInfo>;
  MakeMove('^', '>', 0, -1);
  MakeMove('>', 'v', 1, 0);
  MakeMove('v', '<', 0, 1);
  MakeMove('<', '^', -1, 0);

  RunSimulation;
end;

procedure TfrmWardenWalk.RunSimulation;
var
  len: integer;
  isLoop: boolean;
begin
  for var x := 0 to sgGrid.ColCount - 1 do
    for var y := 0 to sgGrid.RowCount - 1 do
      if FGrid[x, y] <> '#' then
        FGrid[x, y] := ' ';
  FGrid[0, sgGrid.RowCount - 1] := 'X';

  len := 0;
  isLoop := false;
  Walk(0, sgGrid.RowCount - 1, '^', len, isLoop);
  FIsLoop := isLoop;
  lblCount.Caption := Format('%d (%.2d%%)', [len, Round(100 * len / (sgGrid.ColCount * sgGrid.RowCount))]);

  sgGrid.Invalidate;
end;

procedure TfrmWardenWalk.sgGridDrawCell(Sender: TObject; ACol, ARow: LongInt;
    Rect: TRect; State: TGridDrawState);
begin
  if FGrid[ACol, ARow] = '#' then
    sgGrid.Canvas.Brush.Color := clRed
  else if FGrid[ACol, ARow] <> 'X' then
    sgGrid.Canvas.Brush.Color := clWhite
  else if FIsLoop then
    sgGrid.Canvas.Brush.Color := clWebOrange
  else
    sgGrid.Canvas.Brush.Color := clGreen;
  sgGrid.Canvas.FillRect(Rect);
end;

procedure TfrmWardenWalk.sgGridMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
var
  CellCol, CellRow: longint;
begin
  sgGrid.MouseToCell(X, Y, CellCol, CellRow);

  if (CellCol = sgGrid.ColCount - 1) and (CellRow = 0) then
    Exit;
  if (CellCol < 0) or (CellCol >= sgGrid.ColCount)
     or (CellRow < 0) or (CellRow >= sgGrid.RowCount) then
    Exit;

  if FGrid[CellCol, CellRow] = '#' then
    FGrid[CellCol, CellRow] := ' '
  else
    FGrid[CellCol, CellRow] := '#';

  RunSimulation;
end;

procedure TfrmWardenWalk.Walk(x, y: integer; direction: char;
  var len: integer; var isLoop: boolean);
begin
  var path := TCollections.CreateHashMultiMap<TPoint, char>;
  var guardPos := Point(x, y);
  repeat
    var nextPos := guardPos + FMoves[direction].Move;
    FGrid[guardPos.x, guardPos.y] := 'X';
    Inc(len);
    if (nextPos.x < 0) or (nextPos.x >= sgGrid.ColCount)
       or (nextPos.y < 0) or (nextPos.y >= sgGrid.RowCount)
    then
      Exit;
    if FGrid[nextPos.x, nextPos.y] = '#' then
      direction := FMoves[direction].Rotate
    else begin
      guardPos := nextPos;
      if path.Contains(guardPos, direction) then begin
        isLoop := true;
        Exit;
      end;
      path.Add(guardPos, direction);
    end;
  until false;
end;

end.
