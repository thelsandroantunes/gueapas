unit uNFCId;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls,
  // JavaInterfaces,
  Androidapi.Helpers,
  G700NFC;

type
  TfrmNFCid = class(TForm)
    lblMensagem: TLabel;
    btnIdCartao: TButton;
    Timer1: TTimer;
    lblLeitura: TLabel;
    lblCartaoId: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnIdCartaoClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

    procedure mensagemAproximeCartao;
    procedure mensagemEscolhaOpcao;

     procedure ativaCartao;
  private
    { Private declarations }
  public
    { Public declarations }
    ok:Boolean;
    cont:Integer;
    ant: string;
    atual: string;
    aux: string;

    procedure setOK(verifica:Boolean);
    procedure teste(id: string);

  end;

var
  frmNFCid: TfrmNFCid;
  GertecNFC : TG700NFC;
implementation

{$R *.fmx}

procedure TfrmNFCid.setOK(verifica:Boolean);
begin

  lblLeitura.Visible := False;
  lblCartaoId.Visible := False;
  lblMensagem.Visible := True;
  cont:=0;

  ok := verifica;

end;

procedure TfrmNFCid.teste(id:string);
begin
  if ok then
  else begin
    ativaCartao;
  end;

end;

procedure TfrmNFCid.mensagemAproximeCartao;
begin
  if ok then
  begin

    lblMensagem.text := 'Aproxime o cart�o';
    lblMensagem.TextSettings.FontColor:=$FF000000;
    lblMensagem.Font.Size:=30;

  end else begin

    lblMensagem.text := 'Aproxime  o  cart�o  da  leitora';
    lblMensagem.TextSettings.FontColor:= $FF808080;
    lblMensagem.Font.Size:=16;
    lblLeitura.Font.Size:=16;
    lblCartaoId.Font.Size:=16;

  end;

end;

procedure TfrmNFCid.mensagemEscolhaOpcao;
begin
  if ok then
  begin

    lblMensagem.text := 'Escolha uma op��o';
    lblMensagem.TextSettings.FontColor:=$FF000000;
    lblMensagem.Font.Size:=30;

  end;
end;

procedure TfrmNFCid.btnIdCartaoClick(Sender: TObject);
begin

  mensagemAproximeCartao;
  GertecNFC.setLeituraID;
  Timer1.Enabled := true;

end;

//******************************************************
 procedure TfrmNFCid.ativaCartao;
begin
  GertecNFC.PowerOn;
  mensagemAproximeCartao;
  GertecNFC.setLeituraID;
  Timer1.Enabled := true;

end;
//******************************************************
procedure TfrmNFCid.FormActivate(Sender: TObject);
begin

  if(GertecNFC = nil)then begin
    GertecNFC := TG700NFC.Create();
    GertecNFC.setLeituraID;
  end;

  //EnableForegroundDispatch
  GertecNFC.PowerOn;

  if ok then begin
    btnIdCartao.Visible:=True;
    mensagemEscolhaOpcao;
  end else begin
    btnIdCartao.Visible:=False;
    mensagemAproximeCartao;
  end;

  Timer1.Enabled := true;

end;


procedure TfrmNFCid.FormCreate(Sender: TObject);
begin
//G700NFC := TG700NFC.Create(lblMensagem);
end;

procedure TfrmNFCid.Timer1Timer(Sender: TObject);
var
  lValid   : Boolean;
  idCartao : String;
  i,idxCartao:integer;
begin
  Timer1.Enabled := False;
  idCartao := GertecNFC.retornaIdCartao;


  if( not idCartao.IsEmpty) then begin

    Inc(cont);

    if ok then
    begin
      lblMensagem.Visible := True;

      ShowMessage('ID do cart�o   : ' + GertecNFC.retornaIdCartao+#13#10'ID do cart�o(Hex): ' + GertecNFC.retornaIdCartaoHex+#13#10);
      mensagemEscolhaOpcao;

    end else begin

      lblMensagem.Visible := False;

      lblLeitura.BeginUpdate;
        lblLeitura.Visible := True;
        lblLeitura.Text := 'Leitura: ' + IntToStr(cont);
      lblLeitura.EndUpdate;

      lblCartaoId.BeginUpdate;
        lblCartaoId.Visible := True;
        lblCartaoId.Text := 'ID do cart�o: ' + GertecNFC.retornaIdCartao;
      lblCartaoId.EndUpdate;

    end;

    GertecNFC.LimpaIdCartao;

    teste(idCartao);

  end else begin

    Timer1.Enabled := True;
  end;

end;

end.
