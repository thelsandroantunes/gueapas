unit GSAssocia;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit;

type
  TfrmGSAssocia = class(TForm)
    Panel1: TPanel;
    StyleBook1: TStyleBook;
    btnAtivaSat: TButton;
    edtSofHouse: TEdit;
    edtCNPJ: TEdit;
    edtAtivacao: TEdit;
    lblSofHouse: TLabel;
    lblCNPJ: TLabel;
    lblAtivacao: TLabel;
    edtAssinatura: TEdit;
    lblAssinatura: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGSAssocia: TfrmGSAssocia;

implementation

{$R *.fmx}

end.
