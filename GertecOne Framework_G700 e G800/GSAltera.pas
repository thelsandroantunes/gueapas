unit GSAltera;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.Edit, FMX.StdCtrls, FMX.Controls.Presentation;

type
  TfrmGSAltera = class(TForm)
    Panel1: TPanel;
    lblAtual: TLabel;
    lblNovo: TLabel;
    lblConfirma: TLabel;
    btnAlterar: TButton;
    edtCNPJ: TEdit;
    edtAtivaSat: TEdit;
    edtCodigo: TEdit;
    CboxTipoCod: TComboBox;
    lblTipoCod: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGSAltera: TfrmGSAltera;

implementation

{$R *.fmx}

end.
