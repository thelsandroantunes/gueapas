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
  Data.Bind.ObjectScope, FMX.Colors;

type
  TfrmImpressaoG = class(TForm)
    lbTitulo: TLabel;
    BtnItalico: TButton;
    BindingsList1: TBindingsList;
    LinkFillControlToField1: TLinkFillControlToField;
    PrototypeBindSource1: TPrototypeBindSource;
    ImageControl1: TImageControl;
    ListView1: TListView;
    BtnSublinhado: TButton;
    BtnNegrito: TButton;
    TreeView5: TTreeView;
    TreeView4: TTreeView;
    TreeView3: TTreeView;
    Label4: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    cmdImage: TButton;
    cmdTexto: TButton;
    Size: TLabel;
    TreeView1: TTreeView;
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
i:integer;
begin

  //========= QRCODE
  GertecPrinter.printBlankLine(20);
  GertecPrinter.printString(CentralizaTraco('[Codigo QRCode]',N_COLUNAS));
  GertecPrinter.printBlankLine(20);
  qrCode2:='';
  for i := 1 to 5 do qrCode2:=qrCode2+'12345678901234567890';
  GertecPrinter.DrawBarCode(TJGEDI_PRNTR_e_BarCodeType.JavaClass.QR_CODE,240,240,qrCode2);
  GertecPrinter.printBlankLine(150);
  GertecPrinter.printOutput;
end;


//==========================================
procedure TfrmImpressaoG.cmdImageClick(Sender: TObject);
begin
//========= IMAGE
  try
  GertecPrinter.printString(CentralizaTraco('[Iniciando Impressao Imagem]',N_COLUNAS));
  GertecPrinter.printOutput;
  GertecPrinter.printImage( ImageControl1.Bitmap);
  GertecPrinter.printBlankLine(50);
  GertecPrinter.printString(CentralizaTraco('[Fim Impressao Imagem]',N_COLUNAS));
  finally

  end;

end;


//==========================================
procedure TfrmImpressaoG.cmdImpressaoGClick(Sender: TObject);
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

procedure TfrmImpressaoG.cmdTextoClick(Sender: TObject);
var
TxtInput: String;

begin

  TxtInput := Edit1.Text;

  GertecPrinter.textSize := 30;

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

end.
