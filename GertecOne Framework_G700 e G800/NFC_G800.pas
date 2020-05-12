unit NFC_G800;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Colors, FMX.Layouts, FMX.ExtCtrls,

  FMX.VirtualKeyboard,
  FMX.Platform;

type
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
    procedure CbtnLerCartaoClick(Sender: TObject);
    procedure lblLerCartaoClick(Sender: TObject);
    procedure CbtnGravarCartaoClick(Sender: TObject);
    procedure lblGravarCartaoClick(Sender: TObject);

    procedure FormKeyUp(Sender: TObject; var Key: Word; var Keychar: Char; Shift: TShiftState);
    procedure CbtnFormatarCartaoClick(Sender: TObject);
    procedure lblFormatarCartaoClick(Sender: TObject);
    procedure lblTesteCartaoClick(Sender: TObject);
    procedure CbtnTesteCartaoClick(Sender: TObject);

  private
    { Private declarations }
    procedure enablePanel;
    procedure disablePanel;
    procedure lerCartao;
    procedure gravarCartao;
    procedure formatarCartao;
    procedure testeCartao;
  public
    { Public declarations }
    procedure iniciaNFC(limpar: Boolean);
    function getLigado(): Boolean;
  end;

var
  frmNfcG800: TfrmNfcG800;
  ativoPanel:Boolean;
  contador: Integer;

implementation

{$R *.fmx}

//************************************************************
function TfrmNfcG800.getLigado;
begin
    result := ativoPanel;
end;
procedure TfrmNfcG800.iniciaNFC(limpar: Boolean);
begin
  if limpar then
  begin

  end else
  begin
    disablePanel;
  end;
end;
procedure TfrmNfcG800.enablePanel;
begin

    lblTextTitle.TextSettings.Font.Family := 'Arial';
    lblTextTitle.TextSettings.Font.Size:= 21;

    Panel1.Visible := True;

    ImageViewer1.Visible := True;
    lblIdCartao.Visible := False;
    lblTempo.Visible := False;

end;
procedure TfrmNfcG800.disablePanel;
begin
  Panel1.Visible := False;
  ImageViewer1.Visible := False;
end;
//************************************************************
procedure TfrmNfcG800.lerCartao;
begin

  enablePanel;
  lblTextTitle.Text := 'Leitura do Cartão NFC';
  lblGravar.Visible := False;
  lblSub.Visible := False;




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
            ativoPanel := True;
          end;


    end;

    inc(contador);

  end;

end;
end.
