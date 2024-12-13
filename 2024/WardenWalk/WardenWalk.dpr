program WardenWalk;

uses
  Vcl.Forms,
  wwMain in 'wwMain.pas' {frmWardenWalk};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmWardenWalk, frmWardenWalk);
  Application.Run;
end.
