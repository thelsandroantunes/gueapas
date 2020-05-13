unit NFC_G800;

interface

uses
  NFCHelper,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Colors,
  FMX.Layouts,
  FMX.ExtCtrls,

  FMX.VirtualKeyboard,
  FMX.Platform,

  FMX.ScrollBox,
  FMX.Memo;

type

  NFC_MODOS = (NFC_NONE, NFC_LEITURA_ID, NFC_LEITURA_MSG, NFC_ESCRITA);

  TfrmNfcG800 = class(TForm)
    Edit1: TEdit;
    lblMensagem: TLabel;
    CbtnGravarCartao: TColorButton;
    CbtnTesteCartao: TColorButton;
    CbtnFormatarCartao: TColorButton;
    CbtnLerCartao: TColorButton;
    lblGravarCartao: TLabel;
    lblLerCartao: TLabel;
    lblFormatarCartao: TLabel;
    lblTesteCartao: TLabel;
    Panel1: TPanel;
    lblTextTitle: TLabel;
    ImageViewer1: TImageViewer;
    lblIdCartao: TLabel;
    lblTempo: TLabel;
    lblGravar: TLabel;
    lblSub: TLabel;
    StyleBook1: TStyleBook;
    timerNFC: TTimer;
    lblMensagem2: TLabel;
    Label1: TLabel;
    lblTxtCartao: TLabel;

    procedure CbtnLerCartaoClick(Sender: TObject);
    procedure lblLerCartaoClick(Sender: TObject);
    procedure CbtnGravarCartaoClick(Sender: TObject);
    procedure lblGravarCartaoClick(Sender: TObject);
    procedure CbtnFormatarCartaoClick(Sender: TObject);
    procedure lblFormatarCartaoClick(Sender: TObject);
    procedure CbtnTesteCartaoClick(Sender: TObject);
    procedure lblTesteCartaoClick(Sender: TObject);

    procedure FormKeyUp(Sender: TObject; var Key: Word; var Keychar: Char; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);

    procedure timerNFCTimer(Sender: TObject);
    procedure ExecuteNFC(NewNFCMode:NFC_MODOS);

    procedure MensagemEscolhaOpcao; //teste
    procedure MensagemAproximeCartao; // teste


  private
    { Private declarations }
    procedure enablePanel;
    procedure disablePanel;
    procedure lerCartao;
    procedure gravarCartao;
    procedure formatarCartao;
    procedure testeCartao;

    procedure ativaNFC;

  public
    { Public declarations }
    procedure iniciaNFC(limpar: Boolean);
    function getLigado(): Integer;
  end;

var
  frmNfcG800: TfrmNfcG800;
  NFC : TNFCHelper;
  ModoNFC:NFC_MODOS;
  ativoPanel:Integer;
  contador: Integer;


implementation

{$R *.fmx}

//***********************************************************
procedure TfrmNfcG800.ativaNFC;
begin
   //NFC := TNFCHelper.Create( lblMensagem, txtMensagem, txtUrl);
  NFC := TNFCHelper.Create;
  MensagemEscolhaOpcao;
end;
procedure TfrmNfcG800.ExecuteNFC(NewNFCMode:NFC_MODOS);
begin
  nfc.ClearData;
  MensagemAproximeCartao;
  ModoNFC := NewNFCMode;

  case ModoNFC of
    NFC_ESCRITA:        NFC.setGravaMensagemURL(Edit1.Text, 'https://www.gertec.com.br');
    NFC_LEITURA_ID:     NFC.setLeituraID;
    NFC_LEITURA_MSG:    NFC.setLeituraMensagem;
  end;

  timerNFC.Enabled := true;
end;

//************************************************************
function TfrmNfcG800.getLigado;
begin
    Result := ativoPanel;
end;
procedure TfrmNfcG800.iniciaNFC(limpar: Boolean);
var i: integer;
begin
  if limpar then
  begin
     //ShowMessage('TRUE');
  end else
  begin
    //ShowMessage('FALSE');
    disablePanel;
    for i := contador DownTo 1 do
     begin
        dec(contador);
     end;
     ativaNFC;
  end;
end;
procedure TfrmNfcG800.enablePanel;
begin

    lblTextTitle.TextSettings.Font.Family := 'Arial';
    lblTextTitle.TextSettings.Font.Size:= 21;

    Panel1.Visible := True;

    ImageViewer1.Visible := True;
    lblIdCartao.Visible := False;
    lblTxtCartao.Visible := False;
    lblTempo.Visible := False;

end;
procedure TfrmNfcG800.disablePanel;
begin
  Panel1.Visible := False;
  Panel1.Height := 330;
  ImageViewer1.Visible := False;

end;
//************************************************************
procedure TfrmNfcG800.lerCartao;
begin

  enablePanel;
  lblTextTitle.Text := 'Leitura do Cartão NFC';
  lblGravar.Visible := False;
  lblSub.Visible := False;

  Label1.Text := IntToStr(contador);

  contador := 0;
  ExecuteNFC(NFC_LEITURA_ID);

end;
procedure TfrmNfcG800.gravarCartao;
begin

  enablePanel;
  lblTextTitle.Text := 'Gravar Cartão';
  lblGravar.Visible := True;
  lblGravar.Text := 'Toque na tag NFC no seu dispositivo';
  lblSub.Visible := False;
  Panel1.Height := 330;

  ExecuteNFC(NFC_ESCRITA);
  ExecuteNFC(NFC_LEITURA_MSG);
  contador := 0;

end;
procedure TfrmNfcG800.formatarCartao;
begin
  enablePanel;
  lblTextTitle.Text := 'Formatar Cartão';
  lblGravar.Visible := False;
  lblSub.Visible := False;
  contador := 0;
end;
procedure TfrmNfcG800.testeCartao;
begin
  enablePanel;
  lblTextTitle.Text := 'Gravar/Ler Cartão';
  lblGravar.Visible := True;
  lblGravar.Text := 'Aproxime o cartão';
  lblSub.Visible := True;
  Panel1.Height := 377;
  contador := 0;
end;
//************************************************************
procedure TfrmNfcG800.CbtnFormatarCartaoClick(Sender: TObject);
begin
  formatarCartao;
end;
procedure TfrmNfcG800.CbtnGravarCartaoClick(Sender: TObject);
begin
    gravarCartao;
end;
procedure TfrmNfcG800.CbtnLerCartaoClick(Sender: TObject);
begin
   lerCartao;

end;
procedure TfrmNfcG800.CbtnTesteCartaoClick(Sender: TObject);
begin
  testeCartao;
end;
procedure TfrmNfcG800.lblFormatarCartaoClick(Sender: TObject);
begin
  formatarCartao;
end;
procedure TfrmNfcG800.lblGravarCartaoClick(Sender: TObject);
begin
  gravarCartao;
end;
procedure TfrmNfcG800.lblLerCartaoClick(Sender: TObject);
begin
   lerCartao;

end;
procedure TfrmNfcG800.lblTesteCartaoClick(Sender: TObject);
begin
  testeCartao;
end;
//************************************************************
procedure TfrmNfcG800.FormCreate(Sender: TObject);
begin
  ativaNFC;
  contador := 0;
  ativoPanel := -1;
end;
procedure TfrmNfcG800.FormKeyUp(Sender: TObject; var Key: Word; var Keychar: Char; Shift: TShiftState);

var
  FService: IFMXVirtualKeyboardService;

begin

  if (Key = vkHardwareBack) then
  begin

    TplatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));

    if (Fservice <> nil) and (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState) then
    begin
          //Botao back pressionado e teclado visível...
          // (apenas fecha o teclado)

    end
    else
    begin
          // Botao back pressionado e teclado NÃO visível...
          if contador = 0 then
          begin

            Key := 0;
            disablePanel;
            ativoPanel := 0;

            MensagemEscolhaOpcao;

            end;

    end;

    inc(contador);

  end;

end;
procedure TfrmNfcG800.timerNFCTimer(Sender: TObject);
begin
  timerNFC.Enabled := false;

  case ModoNFC of

    NFC_LEITURA_ID:begin
      if(NFC.CardId = '')then begin
        timerNFC.Enabled := true;
      end else begin

        MensagemEscolhaOpcao;
        Panel1.Height := 410;

        lblIdCartao.Visible := True;
        lblIdCartao.Text := 'ID Cartão: ' + NFC.CardId+#13#10#10;
        lblTxtCartao.Visible := True;

        //lblTxtCartao.Text := 'teste: '+NFC.NFCMensagem;

        ShowMessage('Leitura com Sucesso!');

        lblTempo.Visible := True;

      end;

    end;

    NFC_LEITURA_MSG:begin
      if((NFC.NFCMensagem = '')and(NFC.NFCUrl = ''))then begin
        timerNFC.Enabled := true;
      end else begin

        MensagemEscolhaOpcao;

        if(NFC.NFCMensagem <> '')then  begin
          //txtMensagem.Lines.Clear;
          //txtMensagem.Lines.Add(NFC.NFCMensagem);
          lblTxtCartao.Text := NFC.NFCMensagem;
        end;

        //if(NFC.NFCUrl<>'')then
          //txtUrl.Text := NFC.NFCUrl;
        //ShowMessage('Mensagem' + #13#10 + NFC.NFCMensagem +#13#10#13#10 + 'Url:'#13#10+NFC.NFCUrl );
      end;
    end;

     NFC_ESCRITA:begin

      case nfc.NFCWriteStatus of
        NFC_WRITE_OK,
        NFC_WRITE_FAIL:MensagemEscolhaOpcao;
      end;

      case nfc.NFCWriteStatus of
        NFC_WRITE_OK:ShowMessage('Dados gravados com sucesso.');
        NFC_WRITE_FAIL:ShowMessage('Erro ao gravar mensagem no cartão.');
        else timerNFC.Enabled := true;
      end;

    end;


  end; //case

end;
//------------------------------------------------------------
procedure TfrmNfcG800.MensagemEscolhaOpcao;
begin

  ModoNFC := NFC_NONE;
  lblMensagem2.Text := 'Escolha uma opção.';
end;
procedure TfrmNfcG800.MensagemAproximeCartao;
begin
  lblMensagem2.Text := 'Aproxime o cartão.';
end;
//------------------------------------------------------------


end.
