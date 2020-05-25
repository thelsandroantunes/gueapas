unit GSConfig;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.ListBox;

type
  TfrmGSConfig = class(TForm)
    Panel1: TPanel;
    StyleBook1: TStyleBook;
    edtCodAtivacao: TEdit;
    lblCodAtivacao: TLabel;
    lblTipoRede: TLabel;
    CboxTipo: TComboBox;
    lblIP: TLabel;
    lblMask: TLabel;
    lblGet: TLabel;
    edtIP: TEdit;
    edtMask: TEdit;
    edtGet: TEdit;
    edtPorta: TEdit;
    lblPorta: TLabel;
    edtProxyIP: TEdit;
    lblProxyIP: TLabel;
    CboxProxy: TComboBox;
    lblProxy: TLabel;
    CboxDNS: TComboBox;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    edtUser: TEdit;
    lblUser: TLabel;
    edtPassword: TEdit;
    lblPassword: TLabel;
    btnEnviar: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGSConfig: TfrmGSConfig;

implementation

{$R *.fmx}

end.
