unit GerSat;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls,


  GSAtiva ,
  GSAssocia,
  GSTesteSat ,
  GSConfig  ,
  GSAltera  ,
  GSOutras
  ;

type
  TfrmGerSat = class(TForm)
    Panel1: TPanel;
    StyleBook1: TStyleBook;
    lblTitulo: TLabel;
    btnAtiva: TButton;
    btnAssocia: TButton;
    btnTesteSat: TButton;
    btnConfig: TButton;
    btnAltera: TButton;
    btnOutro: TButton;
    procedure btnAtivaClick(Sender: TObject);
    procedure btnAssociaClick(Sender: TObject);
    procedure btnTesteSatClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure btnAlteraClick(Sender: TObject);
    procedure btnOutroClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGerSat: TfrmGerSat;

implementation

{$R *.fmx}

procedure TfrmGerSat.btnAlteraClick(Sender: TObject);
begin
frmGSAltera.Show;
end;

procedure TfrmGerSat.btnAssociaClick(Sender: TObject);
begin
frmGSAssocia.Show;
end;

procedure TfrmGerSat.btnAtivaClick(Sender: TObject);
begin
frmGSAtiva.Show;
end;

procedure TfrmGerSat.btnConfigClick(Sender: TObject);
begin
frmGSConfig.Show;
end;

procedure TfrmGerSat.btnOutroClick(Sender: TObject);
begin
frmGSOutras.Show;
end;

procedure TfrmGerSat.btnTesteSatClick(Sender: TObject);
begin
frmGSTesteSat.Show;
end;

end.
