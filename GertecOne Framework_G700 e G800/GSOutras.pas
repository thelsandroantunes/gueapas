unit GSOutras;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation;

type
  TfrmGSOutras = class(TForm)
    Panel1: TPanel;
    edtAtivaSat: TEdit;
    lblAtivaSat: TLabel;
    btnVerificaVersao: TButton;
    btnAtualSof: TButton;
    btnExtrairLog: TButton;
    btnDesbSat: TButton;
    btnBloquearSat: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGSOutras: TfrmGSOutras;

implementation

{$R *.fmx}

end.
