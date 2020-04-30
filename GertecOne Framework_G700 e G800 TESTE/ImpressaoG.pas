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
  Data.Bind.ObjectScope;

type
  TfrmImpressaoG = class(TForm)
    lbTitulo: TLabel;
    STATUS: TButton;
    Edit1: TEdit;
    lblMensagem: TLabel;
    lbTitulo2: TLabel;
    RadioButton1: TRadioButton;
    RdCentro: TRadioButton;
    RdDir: TRadioButton;
    Font: TLabel;
    TreeView1: TTreeView;
    Size: TLabel;
    cmdTexto: TButton;
    cmdImage: TButton;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    TreeView3: TTreeView;
    TreeView4: TTreeView;
    TreeView5: TTreeView;
    cmdBarCode: TButton;
    cmdImpressaoG: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    ListView1: TListView;
    PrototypeBindSource1: TPrototypeBindSource;
    BindingsList1: TBindingsList;
    LinkFillControlToField1: TLinkFillControlToField;
    ImageControl1: TImageControl;

    procedure FormCreate(Sender: TObject);
    procedure cmdImpressaoGClick(Sender: TObject);
    procedure cmdBarCodeClick(Sender: TObject);
    procedure cmdTextoClick(Sender: TObject);
    procedure cmdImageClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmImpressaoG: TfrmImpressaoG;

  iCount:integer;

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

begin



end;

//==========================================
procedure TfrmImpressaoG.FormCreate(Sender: TObject);

begin
  iCount:=0;
  {$IFDEF __G800__}
  cmdImpressaoG.Text:='Teste Impressao - TSG800';
  {$ELSE}
  cmdImpressaoG.Text:='Teste Impressao - GPOS700';
  {$ENDIF}

end;


end.


