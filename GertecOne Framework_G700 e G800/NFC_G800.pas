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
  FMX.Memo,

  FMX.Objects;

type

  NFC_MODOS = (NFC_NONE, NFC_LEITURA_ID, NFC_LEITURA_MSG, NFC_ESCRITA, NFC_GRAVAR_LER);

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
    timerNFC: TTimer;
    lblMensagem2: TLabel;
    Label1: TLabel;
    lblMsgCartao: TLabel;
    ImageViewer2: TImageViewer;
    StyleBook1: TStyleBook;
    CbtnMsg: TColorButton;
    lblMsg: TLabel;
    mMsg: TMemo;

    procedure CbtnLerCartaoClick(Sender: TObject);
    procedure lblLerCartaoClick(Sender: TObject);
    procedure CbtnGravarCartaoClick(Sender: TObject);
    procedure lblGravarCartaoClick(Sender: TObject);
    procedure CbtnFormatarCartaoClick(Sender: TObject);
    procedure lblFormatarCartaoClick(Sender: TObject);
    procedure CbtnTesteCartaoClick(Sender: TObject);
    procedure lblTesteCartaoClick(Sender: TObject);
    procedure CtbMsgClick(Sender: TObject);
    procedure lblMsgClick(Sender: TObject);

    procedure FormKeyUp(Sender: TObject; var Key: Word; var Keychar: Char; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);

    procedure timerNFCTimer(Sender: TObject);
    procedure ExecuteNFC(NewNFCMode:NFC_MODOS);

    procedure MensagemEscolhaOpcao; //teste
    procedure MensagemAproximeCartao;
    procedure lblMsgCartaoClick(Sender: TObject); // teste


  private
    { Private declarations }
    procedure enablePanel;
    procedure disablePanel;
    procedure lerCartao;
    procedure gravarCartao;
    procedure formatarCartao;
    procedure testeCartao;
    procedure msgCartao;

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
uses
  EncdDecd;
{$R *.fmx}

//***********************************************************
procedure TfrmNfcG800.ExecuteNFC(NewNFCMode:NFC_MODOS);
begin
  nfc.ClearData;
  MensagemAproximeCartao;
  ModoNFC := NewNFCMode;

  case ModoNFC of
    NFC_ESCRITA:      NFC.setGravaMensagemURL(Edit1.Text, 'https://www.gertec.com.br');
    NFC_LEITURA_ID:   NFC.setLeituraID;
    NFC_LEITURA_MSG:  NFC.setLeituraMensagem;

    NFC_GRAVAR_LER:
    begin
      NFC.setGravaMensagemURL('GERTEC1000', 'https://www.gertec.com.br');
      NFC.setLeituraID;
      NFC.setLeituraMensagem;
    end;
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
     Edit1.Text := '';
  end;
end;
procedure TfrmNfcG800.enablePanel;
begin

    lblTextTitle.TextSettings.Font.Family := 'Arial';
    lblTextTitle.TextSettings.Font.Size:= 21;

    Panel1.Visible := True;

    if (Panel1.ControlsCount >= 1) and (Panel1.Controls[0] is TShape) then
    begin
      (Panel1.Controls[0] as TShape).Fill.Color := TAlphaColorRec.White;  // uses System.UITypes
    end;


    ImageViewer1.Visible := True;
    lblIdCartao.Visible := False;
    lblMsgCartao.Visible := False;
    lblTempo.Visible := False;
    mMsg.Visible := False;

end;
procedure TfrmNfcG800.disablePanel;
begin
  Panel1.Visible := False;
  Panel1.Height := 330;
  ImageViewer1.Visible := False;
  mMsg.Visible := False;

end;
//************************************************************
procedure TfrmNfcG800.msgCartao;
begin
   enablePanel;
   lblTextTitle.Text := 'Mensagem do Cartão';

   lblGravar.Visible := False;
   lblSub.Visible := False;

   ExecuteNFC(NFC_LEITURA_MSG);
   contador := 0;
end;
procedure TfrmNfcG800.lerCartao;
begin

  enablePanel;
  lblTextTitle.Text := 'Leitura do Cartão NFC';
  lblGravar.Visible := False;
  lblSub.Visible := False;


  ExecuteNFC(NFC_LEITURA_ID);
  contador := 0;
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

  ExecuteNFC(NFC_GRAVAR_LER);

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
procedure TfrmNfcG800.CtbMsgClick(Sender: TObject);
begin
  msgCartao;
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
procedure TfrmNfcG800.lblMsgClick(Sender: TObject);
begin
  msgCartao;
end;
procedure TfrmNfcG800.lblTesteCartaoClick(Sender: TObject);
begin
  testeCartao;
end;
procedure TfrmNfcG800.lblMsgCartaoClick(Sender: TObject);
begin

end;

//************************************************************
procedure TfrmNfcG800.FormCreate(Sender: TObject);
begin
   //NFC := TNFCHelper.Create( lblMensagem, txtMensagem, txtUrl);
  NFC := TNFCHelper.Create;
  MensagemEscolhaOpcao;

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

      Panel1.Height := 433;

      if(NFC.CardId = '')then begin
        timerNFC.Enabled := true;
      end else begin

        MensagemEscolhaOpcao;

        lblIdCartao.Visible := True;
        lblIdCartao.Text := 'ID Cartão: ' + NFC.CardId+#13#10#10;

        lblTempo.Visible := True;
        lblTempo.Text := 'Tempo de Execução: ' + FloatToStr(StrToFloat(timerNFC.Interval.ToString)/1000) + 's';

        ShowMessage('Leitura com Sucesso! ');

      end;

    end;

    NFC_LEITURA_MSG:
    begin

      Panel1.Height := 433;

      if((NFC.NFCMensagem = '')and(NFC.NFCUrl = ''))then begin
        timerNFC.Enabled := true;
      end else begin

        MensagemEscolhaOpcao;

        if(NFC.NFCMensagem <> '')then  begin
          mMsg.Lines.Clear;
          mMsg.Lines.Add('Mensagem: ');
          mMsg.Lines.Add(NFC.NFCMensagem);
          //lblTxtCartao.Visible := True;
          //lblTxtCartao.Text := 'Mensagem: '+#13#10 + NFC.NFCMensagem;
        end;
        mMsg.Visible := True;
        //if(NFC.NFCUrl<>'')then
          //txtUrl.Text := NFC.NFCUrl;
        //ShowMessage('Mensagem' + #13#10 + NFC.NFCMensagem +#13#10#13#10 + 'Url:'#13#10+NFC.NFCUrl );
         ShowMessage('Cartão com Mensagem! ');
      end;
    end;

     NFC_ESCRITA:
     begin

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

    NFC_GRAVAR_LER:
    begin

      case nfc.NFCWriteStatus of
        NFC_WRITE_OK,
        NFC_WRITE_FAIL:MensagemEscolhaOpcao;
      end;

      timerNFC.Enabled := true;

       if(NFC.CardId <> '')then begin
        MensagemEscolhaOpcao;

        //lblIdCartao.Visible := True;
        lblIdCartao.Text := 'ID Cartão: ' + NFC.CardId+#13#10#10;

        //lblTempo.Visible := True;
        lblTempo.Text := 'Tempo de Execução: ' + FloatToStr(StrToFloat(timerNFC.Interval.ToString)/1000) + 's';

      end;

       if(NFC.NFCMensagem <> '')and(NFC.NFCUrl <> '')then begin

        mMsg.Lines.Clear;
        mMsg.Lines.Add(lblIdCartao.Text);
        mMsg.Lines.Add('Código Gravado: GERTEC1000');
        mMsg.Lines.Add(' ');
        mMsg.Lines.Add('Código ID: '+NFC.CardId);
        mMsg.Lines.Add('Leitura código: '+NFC.NFCMensagem);
        //lblTxtCartao.Visible := True;
        //lblTxtCartao.Text := 'Mensagem: '+#13#10 + NFC.NFCMensagem;
        mMsg.Lines.Add(' ');
        mMsg.Lines.Add('Tempo de Execução: ' + FloatToStr(StrToFloat(timerNFC.Interval.ToString)/1000) + 's');
        mMsg.Visible := True;
        //if(NFC.NFCUrl<>'')then
          //txtUrl.Text := NFC.NFCUrl;
        //ShowMessage('Mensagem' + #13#10 + NFC.NFCMensagem +#13#10#13#10 + 'Url:'#13#10+NFC.NFCUrl );
         ShowMessage('Gravar/Ler OK! ');
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
