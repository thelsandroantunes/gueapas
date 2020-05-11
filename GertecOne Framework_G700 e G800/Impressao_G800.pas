unit Impressao_G800;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.StdCtrls, FMX.Controls.Presentation,
  GEDIPrinter,

  //Esta unit inicializa o Modulo de impressao para G800
  {$IFDEF __G800__}
  G800Interface, Data.Bind.GenData, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  System.Rtti, System.Bindings.Outputs, FMX.Colors, FMX.ListBox,
  Data.Bind.Components, Data.Bind.ObjectScope
  {$ENDIF}

  ;

type
  TfrmImpressaoG800 = class(TForm)
    STATUS: TButton;
    PrototypeBindSource1: TPrototypeBindSource;
    BindingsList1: TBindingsList;
    LinkFillControlToField1: TLinkFillControlToField;
    ImageControl2: TImageControl;
    PanelMessage: TPanel;
    btnOK: TButton;
    lblMsg: TLabel;
    lblMsgCode: TLabel;
    CbBarCodeH: TComboBox;
    CbBarCodeW: TComboBox;
    CbQrCode: TComboBox;
    CbFont: TComboBox;
    CbSize: TComboBox;
    CbtnSublinhado: TColorButton;
    CbtnItalico: TColorButton;
    CbtnNegrito: TColorButton;
    cmdBarCode: TButton;
    cmdImpressaoG: TButton;
    Edit1: TEdit;
    lblMensagem: TLabel;
    lbTitulo2: TLabel;
    RdEsquerda: TRadioButton;
    RdCentro: TRadioButton;
    RdDireita: TRadioButton;
    Size: TLabel;
    cmdTexto: TButton;
    cmdImage: TButton;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    BtnNegrito: TButton;
    BtnSublinhado: TButton;
    ImageControl1: TImageControl;
    BtnItalico: TButton;
    lbTitulo: TLabel;
    Font: TLabel;

    procedure cmdTesteImpressaoClick(Sender: TObject);
    procedure STATUSClick(Sender: TObject);
    procedure BtnNegritoClick(Sender: TObject);
    procedure BtnItalicoClick(Sender: TObject);
    procedure BtnSublinhadoClick(Sender: TObject);
    procedure cmdImpressaoGClick(Sender: TObject);
    procedure cmdImageClick(Sender: TObject);
    procedure RdEsquerdaChange(Sender: TObject);
    procedure RdCentroChange(Sender: TObject);
    procedure RdDireitaChange(Sender: TObject);
    procedure cmdTextoClick(Sender: TObject);
    procedure cmdBarCodeClick(Sender: TObject);
  private
    { Private declarations }
    function CentralizaTraco(strTitulo:string;NColunas:integer):string;
  public
    { Public declarations }
    procedure CleanText(limpaText: Boolean);
  end;

var
  frmImpressaoG800: TfrmImpressaoG800;
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
procedure TfrmImpressaoG800.BtnItalicoClick(Sender: TObject);
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

procedure TfrmImpressaoG800.CleanText(limpaText: Boolean);
begin
   if limpaText then
  begin
    Edit1.Text := '';

    RdCentro.IsChecked:=False;
    RdDireita.IsChecked:=False;
    RdEsquerda.IsChecked:=False;

    CbFont.ItemIndex := 0;
    CbSize.ItemIndex := 0;

    CbtnNegrito.Color := $FF000000;
    CbtnItalico.Color  := $FF000000 ;
    CbtnSublinhado.Color := $FF000000;


    CbBarCodeW.ItemIndex := 0;
    CbBarCodeH.ItemIndex := 0;
    CbQrCode.ItemIndex := 0;

    Edit1.Text.Empty;

  end;
end;

procedure TfrmImpressaoG800.BtnNegritoClick(Sender: TObject);
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

procedure TfrmImpressaoG800.BtnSublinhadoClick(Sender: TObject);
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

function TfrmImpressaoG800.CentralizaTraco(strTitulo:string;NColunas:integer):string;
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
procedure TfrmImpressaoG800.cmdBarCodeClick(Sender: TObject);
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
  ean8:='01234565';
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

procedure TfrmImpressaoG800.cmdImageClick(Sender: TObject);
begin
  GertecPrinter.printImage( ImageControl1.Bitmap);
  GertecPrinter.printBlankLine(150);
  GertecPrinter.printOutput;
end;

procedure TfrmImpressaoG800.cmdImpressaoGClick(Sender: TObject);
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
    GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.EAN_8,120,120,'01234565');
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

procedure TfrmImpressaoG800.cmdTesteImpressaoClick(Sender: TObject);
var
i:integer;
qrCode:string;

begin

  try

    //=========

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

procedure TfrmImpressaoG800.cmdTextoClick(Sender: TObject);
var
TxtInput: string;

begin
if Edit1.Text = '' then
  begin
    ShowMessage('Digite um texto para imprimir');
  end else begin



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
end;

procedure TfrmImpressaoG800.RdCentroChange(Sender: TObject);
begin
   if RdCentro.Text = 'Centralizado' then
    begin
    pos:=0;

  end;
end;

procedure TfrmImpressaoG800.RdDireitaChange(Sender: TObject);
begin
if RdDireita.Text = 'Direita' then
    begin
    pos:=1;

  end;
end;

procedure TfrmImpressaoG800.RdEsquerdaChange(Sender: TObject);
begin
 if RdEsquerda.Text = 'Esquerda' then
    begin
    pos:=-1;

  end;
end;

procedure TfrmImpressaoG800.STATUSClick(Sender: TObject);
var
result: string;

begin
  result := GertecPrinter.StatusImpressora;

  ShowMessage( 'Status da Impressora'+#13#10#10 +result);
end;

end.
