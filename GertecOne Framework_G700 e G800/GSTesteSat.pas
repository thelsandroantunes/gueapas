unit GSTesteSat;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit;

type
  TfrmGSTesteSat = class(TForm)
    Panel1: TPanel;
    StyleBook1: TStyleBook;
    edtAtivaSat: TEdit;
    lblAtivaSat: TLabel;
    btnCancelaVenda: TButton;
    btnConsultaSessao: TButton;
    btnEnviaVenda: TButton;
    btnTesteFim: TButton;
    btnStatus: TButton;
    btnConsultaSat: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGSTesteSat: TfrmGSTesteSat;

implementation

{$R *.fmx}

end.
