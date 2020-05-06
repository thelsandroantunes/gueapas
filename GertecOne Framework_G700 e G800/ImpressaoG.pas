unit ImpressaoG;

interface

uses
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
  FMX.Edit,
  FMX.Controls.Presentation,
  FMX.Layouts,
  FMX.TreeView,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,

  GEDIPrinter,    //Esta unit inicializa o Modulo de impressao para G800 e G700
  {$IFDEF __G800__}
  G800Interface,
  {$ELSE}
  G700Interface,
  {$ENDIF}

  Data.Bind.GenData,
  Data.Bind.EngExt,
  Fmx.Bind.DBEngExt,
  System.Rtti,
  System.Bindings.Outputs,
  Fmx.Bind.Editors,
  Data.Bind.Components,
  Data.Bind.ObjectScope, FMX.Colors, FMX.ListBox, FMX.EditBox, FMX.NumberBox,
  FMX.ComboTrackBar;

type
  TfrmImpressaoG = class(TForm)
    lbTitulo: TLabel;
    BtnItalico: TButton;
    BindingsList1: TBindingsList;
    LinkFillControlToField1: TLinkFillControlToField;
    PrototypeBindSource1: TPrototypeBindSource;
    ImageControl1: TImageControl;
    BtnSublinhado: TButton;
    BtnNegrito: TButton;
    Label4: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    cmdImage: TButton;
    cmdTexto: TButton;
    Size: TLabel;
    Font: TLabel;
    RdDireita: TRadioButton;
    RdCentro: TRadioButton;
    RdEsquerda: TRadioButton;
    lbTitulo2: TLabel;
    lblMensagem: TLabel;
    Edit1: TEdit;
    STATUS: TButton;
    cmdImpressaoG: TButton;
    cmdBarCode: TButton;
    CbtnNegrito: TColorButton;
    CbtnItalico: TColorButton;
    CbtnSublinhado: TColorButton;
    CbSize: TComboBox;
    CbFont: TComboBox;
    CbQrCode: TComboBox;
    CbBarCodeW: TComboBox;
    CbBarCodeH: TComboBox;
    PanelMessage: TPanel;
    btnOK: TButton;
    lblMsg: TLabel;
    lblMsgCode: TLabel;


    procedure cmdImpressaoGClick(Sender: TObject);
    procedure cmdBarCodeClick(Sender: TObject);

    procedure cmdImageClick(Sender: TObject);
    procedure cmdTextoClick(Sender: TObject);
    procedure RdEsquerdaChange(Sender: TObject);
    procedure RdCentroChange(Sender: TObject);
    procedure RdDireitaChange(Sender: TObject);
    procedure BtnNegritoClick(Sender: TObject);
    procedure BtnItalicoClick(Sender: TObject);
    procedure BtnSublinhadoClick(Sender: TObject);
    procedure STATUSClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);


  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmImpressaoG: TfrmImpressaoG;
  iCount:integer;
  pos: integer;
  neg: Boolean;
  ita: Boolean;
  sub: Boolean;
  textSize: Integer;
  bcHeight:integer;
  bcWidth:integer;


  const N_COLUNAS=32;
implementation

{$R *.fmx}
//==========================================
function CentralizaTraco(strTitulo:string;NColunas:integer):string;
var
i,iLen:integer;
strAux:string;
begin
  iLen:=(NColunas - length(strTitulo))div 2;
  if(NColunas <=0)then begin
    strAux:=strTitulo;
  end else begin

    strAux:='';
    for I := 1 to iLen do
      strAux:=strAux+'=';
    strAux:=strAux+strTitulo;
    for I := 1 to NColunas - iLen -length(strTitulo)do
      strAux:=strAux+'=';
  end;
  result:=strAux;

end;


//==========================================
procedure TfrmImpressaoG.BtnItalicoClick(Sender: TObject);
begin
  if CbtnItalico.Color = $FF000000 then
  begin
      CbtnItalico.Color:= $FF0000FF;
      ita:= True;
  end else begin
     CbtnItalico.Color := $FF000000;
     ita:= False;
  end;

end;

procedure TfrmImpressaoG.BtnNegritoClick(Sender: TObject);

begin

  if CbtnNegrito.Color = $FF000000 then
     begin
        CbtnNegrito.Color := $FF0000FF;
        neg:=True;
  end else begin
     CbtnNegrito.Color := $FF000000;
     neg:=False;
  end;

end;

procedure TfrmImpressaoG.btnOKClick(Sender: TObject);
begin
lblMsg.Visible := False;
  lblMsgCode.Visible := False;
  PanelMessage.Visible := False;
  btnOK.Visible := False;
end;

procedure TfrmImpressaoG.BtnSublinhadoClick(Sender: TObject);
begin
  if CbtnSublinhado.Color = $FF000000 then
    begin
        CbtnSublinhado.Color := $FF0000FF;
        sub:=True;
  end else begin
     CbtnSublinhado.Color := $FF000000;
     sub:=False;
  end;

end;

procedure TfrmImpressaoG.cmdBarCodeClick(Sender: TObject);
var
qrCode2:string;

code128:string;
ean8:string;
ean13:string;
pdf417:string;

i:integer;
begin

  if CbBarCodeH.ItemIndex =0then
    begin
    bcHeight:=280;
  end else if CbBarCodeH.ItemIndex = 1 then
  begin
    bcHeight:=10;
  end else if CbBarCodeH.ItemIndex = 2 then
    begin
        bcHeight:=40;
  end else if CbBarCodeH.ItemIndex = 3 then
    begin
        bcHeight:=80;
  end else if CbBarCodeH.ItemIndex = 4 then
    begin
        bcHeight:=120;
  end else if CbBarCodeH.ItemIndex = 5 then
    begin
        bcHeight:=160;
  end else if CbBarCodeH.ItemIndex = 6 then
    begin
        bcHeight:=200;
  end else if CbBarCodeH.ItemIndex = 7 then
    begin
        bcHeight:=240;
  end else if CbBarCodeH.ItemIndex = 8 then
    begin
        bcHeight:=320;
  end else if CbBarCodeH.ItemIndex = 9 then
    begin
        bcHeight:=380;
  end;

if CbBarCodeW.ItemIndex = 0 then
    begin
    bcWidth:=280;
  end else if CbBarCodeW.ItemIndex= 1 then
  begin
    bcWidth:=10;
  end else if CbBarCodeW.ItemIndex= 2 then
    begin
        bcWidth:=40;
  end else if CbBarCodeW.ItemIndex= 3 then
    begin
        bcWidth:=80;
  end else if CbBarCodeW.ItemIndex= 4 then
    begin
        bcWidth:=120;
  end else if CbBarCodeW.ItemIndex= 5 then
    begin
        bcWidth:=160;
  end else if CbBarCodeW.ItemIndex = 6 then
    begin
        bcWidth:=200;
  end else if CbBarCodeW.ItemIndex =7 then
    begin
        bcWidth:=240;
  end else if CbBarCodeW.ItemIndex= 8 then
    begin
        bcWidth:=320;
  end else if CbBarCodeW.ItemIndex= 9 then
    begin
        bcWidth:=380;
  end;
  //========= QRCODE
  qrCode2:='';
  for i := 1 to 5 do qrCode2:=qrCode2+'12345678901234567890';

  code128:='12345678901234567890';
  ean8:='0123456';
  ean13:='7891234567895';
  pdf417:='000311111136511111125211111155';

  if CbQrCode.ItemIndex = 0 then
    begin
    GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.QR_CODE,bcHeight, bcWidth, qrCode2);
  end else if CbQrCode.ItemIndex = 1 then
    begin
    GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.CODE_128,bcHeight, bcWidth, code128);
  end else if CbQrCode.ItemIndex = 2 then
    begin
    GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.EAN_8,bcHeight, bcWidth, ean8);
  end else if CbQrCode.ItemIndex = 3 then
    begin
    GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.EAN_13,bcHeight, bcWidth, ean13);
  end else if CbQrCode.ItemIndex = 4 then
    begin
    GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.PDF_417,bcHeight, bcWidth, pdf417);
  end;



  GertecPrinter.printBlankLine(150);
  GertecPrinter.printOutput;
end;


//==========================================
procedure TfrmImpressaoG.cmdImageClick(Sender: TObject);
var
qr:string;
i:integer;
begin
//=========
  //=========
  GertecPrinter.FlagBold := True;
  GertecPrinter.textSize := 16;
  GertecPrinter.PrintString(ESQUERDA,'NOME DO ESTABELECIMENTO');
  GertecPrinter.FlagBold := False;
  GertecPrinter.textSize := 14;
  GertecPrinter.PrintString(ESQUERDA,'Endereço,101 - Bairro');
  GertecPrinter.PrintString(ESQUERDA,'São Paulo - SP - CEP 13.001-000');
  GertecPrinter.FlagBold := True;
  GertecPrinter.PrintString(ESQUERDA,'CNPJ: 11.222.333/0001-44');
  GertecPrinter.FlagBold := False;
  GertecPrinter.PrintString(ESQUERDA,'IE: 000.000.000.000');
  GertecPrinter.FlagSublinhado := True;
  GertecPrinter.PrintString(ESQUERDA,'IM:0.000.000-0                    ');
  GertecPrinter.textSize := 30;
  GertecPrinter.PrintString(CENTRALIZADO,'________________');

  GertecPrinter.FlagSublinhado := False;
  GertecPrinter.textSize := 16;
  GertecPrinter.FlagBold:=True;
  GertecPrinter.PrintString(CENTRALIZADO,'CUPOM FISCAL ELETRONICO-SAT');
  GertecPrinter.textSize := 14;
  GertecPrinter.FlagBold:=False;
  GertecPrinter.PrintString(ESQUERDA,'ITEM  CÓDIGO   DESCRIÇÃO');
  GertecPrinter.PrintString(ESQUERDA,'qtd   UN.  VL. UNIT(R$) ST  VL. ITEM(R$)');
  GertecPrinter.printBlankLine(15);
  GertecPrinter.PrintString(ESQUERDA,'001   1011213      NOME DO PRODUTO');
  GertecPrinter.FlagBold:=True;
  GertecPrinter.FlagSublinhado := True;

  GertecPrinter.PrintString(ESQUERDA,'  001.000UN    X     12,00 F1 A   25,00   ');

  GertecPrinter.FlagSublinhado := False;
  GertecPrinter.FlagBold:=True;
  GertecPrinter.FlagSublinhado := True;
  GertecPrinter.textSize := 30;
  GertecPrinter.PrintString(CENTRALIZADO,'________________');
    GertecPrinter.textSize := 14;
  GertecPrinter.PrintString(ESQUERDA,'TOTAL                           R$25,00');

  GertecPrinter.textSize := 10;
  GertecPrinter.PrintString(ESQUERDA,'Tributos Totais incidentes (Lei Federal 12.741/2012)   R$4,00');

  GertecPrinter.FlagSublinhado := False;
  GertecPrinter.FlagBold:=False;
  GertecPrinter.textSize := 14;
  GertecPrinter.PrintString(ESQUERDA,'N° 000000139   Série 1    01/01/2016 15:00:00');


  GertecPrinter.PrintString(CENTRALIZADO,'Consulte pela chave de acesso em ');
  GertecPrinter.PrintString(CENTRALIZADO,'http;//www.nfp.fazenda.sp.gov.br ');
  GertecPrinter.PrintString(CENTRALIZADO,'CHAVE DE ACESSO ');
  GertecPrinter.FlagBold:=True;
  GertecPrinter.textSize := 30;
  GertecPrinter.PrintString(CENTRALIZADO,'________________');


  GertecPrinter.FlagSublinhado := True;
  GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.CODE_128,20,20,'12345678901234567890');
  GertecPrinter.textSize := 30;
  GertecPrinter.PrintString(CENTRALIZADO,'________________');

  GertecPrinter.FlagSublinhado := False;
  GertecPrinter.textSize := 14;
  GertecPrinter.PrintString(CENTRALIZADO,'CONSUMIDOR NÃO IDENTIFICADO');
  GertecPrinter.PrintString(ESQUERDA ,'CPF: 000.000.000-00');
  GertecPrinter.printBlankLine(20);

  qr:='';
  for i := 1 to 5 do qr:=qr+'12345678901234567890';
  GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.QR_CODE,200,200,qr);



  GertecPrinter.printBlankLine(150);
  GertecPrinter.printOutput;

end;


//==========================================
procedure TfrmImpressaoG.cmdImpressaoGClick(Sender: TObject);
var
i:integer;
qrCode:string;

begin

try

  //=========
  GertecPrinter.textSize := 20;
  GertecPrinter.printString(CentralizaTraco('[Iniciando Impressao Imagem]',N_COLUNAS));
  GertecPrinter.printOutput;
  GertecPrinter.printImage( ImageControl1.Bitmap);
  GertecPrinter.printBlankLine(50);
  GertecPrinter.printString(CentralizaTraco('[Fim Impressao Imagem]',N_COLUNAS));
  //=========
  GertecPrinter.FlagBold := True;
  GertecPrinter.textSize := 30;
  GertecPrinter.PrintString(CENTRALIZADO,'CENTRALIZADO');

  GertecPrinter.textSize := 40;
  GertecPrinter.PrintString(ESQUERDA,'ESQUERDA');

  GertecPrinter.textSize := 20;
  GertecPrinter.PrintString(DIREITA,'DIREITA');
  GertecPrinter.Alignment := CENTRALIZADO;

  GertecPrinter.PrintString(CentralizaTraco('[Escrita Negrito ('+inttostr(iCount)+')]',N_COLUNAS));
  GertecPrinter.printBlankLine(20);

  GertecPrinter.FlagBold := False;

  GertecPrinter.FlagItalico := True;
  GertecPrinter.PrintString(CentralizaTraco('[Escrita Italico ('+inttostr(iCount)+')]',N_COLUNAS));
  GertecPrinter.FlagItalico := False;

  GertecPrinter.printBlankLine(20);

  GertecPrinter.FlagSublinhado := True;
  GertecPrinter.PrintString(CentralizaTraco('[Escrita Sublinhado ('+inttostr(iCount)+')]',N_COLUNAS));
  GertecPrinter.FlagSublinhado := False;

  GertecPrinter.printBlankLine(20);

  //=========
  GertecPrinter.FlagBold := True;
  GertecPrinter.PrintString(CentralizaTraco('[Codigo Barras CODE 128]',N_COLUNAS));
  GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.CODE_128,120,120,'12345678901234567890');
  GertecPrinter.printBlankLine(20);
  //=========
  GertecPrinter.FlagBold := False;
  GertecPrinter.printString(CentralizaTraco('[Escrita Normal ('+inttostr(iCount)+')]',N_COLUNAS));
  GertecPrinter.printOutput;
  GertecPrinter.printString(CentralizaTraco('[BlankLine 50]',N_COLUNAS));
  GertecPrinter.printBlankLine(50);
  GertecPrinter.printString(CentralizaTraco('[Fim BlankLine 50]',N_COLUNAS));
  //=========
  GertecPrinter.printString(CentralizaTraco('[Codigo Barras EAN13]',N_COLUNAS));
  GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.EAN_13,120,120,'7891234567895');


   //=========
  GertecPrinter.printBlankLine(20);
  GertecPrinter.printString(CentralizaTraco('[Codigo Barras EAN8]',N_COLUNAS));
  GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.EAN_8,120,120,'0123456');
   //=========
  GertecPrinter.printBlankLine(20);
  GertecPrinter.printString(CentralizaTraco('[Codigo Barras PDF417]',N_COLUNAS));
  GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.PDF_417,280,280,'003311112355111122421111254');


  //========= QRCODE
  GertecPrinter.printBlankLine(20);
  GertecPrinter.printString(CentralizaTraco('[Codigo QRCode]',N_COLUNAS));
  GertecPrinter.printBlankLine(20);
  qrCode:='';
  for i := 1 to 5 do qrCode:=qrCode+'12345678901234567890';
  GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.QR_CODE,240,240,qrCode);
  GertecPrinter.printBlankLine(150);
  GertecPrinter.printOutput;

  inc(iCount);
except
    on e: exception do begin
      GertecPrinter.printReInit;
      ShowMessage('Erro Impressao=>'+e.Message);

  end;
end;
end;


//==========================================
procedure TfrmImpressaoG.cmdTextoClick(Sender: TObject);
var
TxtInput: string;

begin



  if CbFont.ItemIndex = 0 then
    begin
    GertecPrinter.TextFamily := 0;
  end else if CbFont.ItemIndex = 1 then
    begin
    GertecPrinter.TextFamily := 1;
  end else if CbFont.ItemIndex = 2 then
    begin
    GertecPrinter.TextFamily := 2;
  end else if CbFont.ItemIndex = 3 then
    begin
    GertecPrinter.TextFamily := 3;
  end else if CbFont.ItemIndex = 4 then
    begin
    GertecPrinter.TextFamily := 4;
  end;



  TxtInput := Edit1.Text;

  if CbSize.ItemIndex = 0 then
    begin
    textSize:=60;
  end else if CbSize.ItemIndex = 1 then
    begin
    textSize:=20;
  end else if CbSize.ItemIndex = 2 then
    begin
    textSize:=30;
  end else if CbSize.ItemIndex = 3 then
    begin
    textSize:=40;
  end else if CbSize.ItemIndex = 4 then
    begin
    textSize:=50;
  end else if CbSize.ItemIndex = 5 then
    begin
    textSize:=70;
  end else if CbSize.ItemIndex = 6 then
    begin
    textSize:=80;
  end else if CbSize.ItemIndex = 7 then
    begin
    textSize:=90;
  end else if CbSize.ItemIndex = 8 then
    begin
    textSize:=100;
  end;

  GertecPrinter.textSize := textSize;

  if neg then
    begin
      GertecPrinter.FlagBold := True;
  end else begin
      GertecPrinter.FlagBold := False;
  end;

  if ita then
    begin
      GertecPrinter.FlagItalico := True;
  end else begin
      GertecPrinter.FlagItalico := False;
  end;

  if sub then
  begin
        GertecPrinter.FlagSublinhado := True;
  end else begin
       GertecPrinter.FlagSublinhado := False;
  end;

  if pos = 0 then
    begin

      GertecPrinter.PrintString(CENTRALIZADO,TxtInput);

  end

  else if pos = -1 then
    begin

      GertecPrinter.PrintString(ESQUERDA,TxtInput);

  end

  else if pos = 1 then
    begin

      GertecPrinter.PrintString(DIREITA,TxtInput);

  end else
    begin
      GertecPrinter.PrintString(CENTRALIZADO,TxtInput);
  end;

  GertecPrinter.printBlankLine(150);
  GertecPrinter.printOutput;

end;

procedure TfrmImpressaoG.RdCentroChange(Sender: TObject);
begin
     if RdCentro.Text = 'Centralizado' then
    begin
    pos:=0;

  end;
end;

procedure TfrmImpressaoG.RdDireitaChange(Sender: TObject);
begin
 if RdDireita.Text = 'Direita' then
    begin
    pos:=1;

  end;
end;

procedure TfrmImpressaoG.RdEsquerdaChange(Sender: TObject);
begin

  if RdEsquerda.Text = 'Esquerda' then
    begin
    pos:=-1;

  end;

end;

procedure TfrmImpressaoG.STATUSClick(Sender: TObject);
begin
  lblMsg.Visible := True;
  lblMsgCode.Visible := True;
  PanelMessage.Visible := True;
  btnOK.Visible := True;

end;

end.
