object frmWardenWalk: TfrmWardenWalk
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Warden Walk'
  ClientHeight = 490
  ClientWidth = 426
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object lblCount: TLabel
    Left = 8
    Top = 435
    Width = 46
    Height = 15
    Caption = 'lblCount'
  end
  object sgGrid: TStringGrid
    Left = 8
    Top = 16
    Width = 409
    Height = 409
    ColCount = 16
    DefaultColWidth = 24
    FixedCols = 0
    RowCount = 16
    FixedRows = 0
    TabOrder = 0
    OnDrawCell = sgGridDrawCell
    OnMouseDown = sgGridMouseDown
  end
  object btnSave: TButton
    Left = 343
    Top = 431
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 1
    OnClick = btnSaveClick
  end
  object btnLoad: TButton
    Left = 343
    Top = 462
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 2
    OnClick = btnLoadClick
  end
  object btnClear: TButton
    Left = 184
    Top = 431
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 3
    OnClick = btnClearClick
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.wwdat'
    Filter = 'WardenWalk data file|*.wwdat'
    Left = 208
    Top = 272
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.wwdat'
    Filter = 'WardenWalk data files|*.wwdat'
    Left = 288
    Top = 264
  end
end
