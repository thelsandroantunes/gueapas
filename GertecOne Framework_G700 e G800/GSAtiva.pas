unit GSAtiva;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit;

type
  TfrmGSAtiva = class(TForm)
    Panel1: TPanel;
    StyleBook1: TStyleBook;
    lblCNPJ: TLabel;
    lblAtivaSat: TLabel;
    lblCodigo: TLabel;
    btnAtivaSat: TButton;
    edtCNPJ: TEdit;
    edtAtivaSat: TEdit;
    edtCodigo: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGSAtiva: TfrmGSAtiva;

implementation

{$R *.fmx}

end.
