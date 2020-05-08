unit Main;

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
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Colors,

  Androidapi.Jni.Net,       //Required
  Androidapi.JNI.JavaTypes, //Required
  Androidapi.Helpers,       //Required
  Androidapi.JNI.GraphicsContentViewText, //Required
  Androidapi.JNI.App,       //Required
  System.Messaging,         //Required
  System.JSON,               //Required
  Androidapi.JNI.OS,        //Required


  //Units do projeto
  //BarCode,
  CodigoDeBarraV2,
  CodigoDeBarras,
  //Impressao,
  ImpressaoG,
  {$IFDEF __G800__}
  uNFC
  {$ELSE}
  G700NFC,
  uNFCid,
  FMX.Ani,
  FMX.Layouts,
  FMX.ExtCtrls,

  System.Tether.Manager,
  System.Tether.AppProfile,
  System.Actions,

  Androidapi.JNI.Toast,

  FMX.ActnList,
  FMX.StdActns,
  FMX.MediaLibrary.Actions,
  FMX.Media,
  FMX.Platform,

  ZXing.BarcodeFormat,
  ZXing.ReadResult,
  ZXing.ScanManager,
  FMX.Barcode.DROID, FMX.Edit, IPPeerClient, IPPeerServer


  {$ENDIF}

  ;

type

TBarCodes = (QRCODE);


  TfrmMain = class(TForm)
    cmdImpressao: TColorButton;
    Label1: TLabel;
    Image3: TImage;
    cmdCodigoBarras: TColorButton;
    Label2: TLabel;
    Image1: TImage;
    cmdNFC: TColorButton;
    Label3: TLabel;
    Image2: TImage;
    cmdNFCId: TColorButton;
    Label4: TLabel;
    Image4: TImage;
    ImageControl1: TImageControl;
    Label5: TLabel;
    cmdCodBarraV2: TColorButton;
    Label6: TLabel;
    Image5: TImage;
    cmdNFCBc: TColorButton;
    Label7: TLabel;
    Image6: TImage;
    ImageViewer1: TImageViewer;
    BitmapAnimation1: TBitmapAnimation;
    ImageViewer2: TImageViewer;

    procedure cmdCodigoBarrasClick(Sender: TObject);
    procedure cmdImpressaoClick(Sender: TObject);
    procedure cmdNFCClick(Sender: TObject);
    procedure cmdCodBarraV2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmdNFCIdClick(Sender: TObject);
    procedure cmdNFCBcClick(Sender: TObject);   //32165465
    procedure DesligaNFC;


  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}


procedure TfrmMain.cmdCodigoBarrasClick(Sender: TObject);
begin
DesligaNFC;

if (frmCodBarra.getAtivoCamera = True) then
begin
   frmCodBarra.iniciaBarCode(False);
end else begin
   frmCodBarra.iniciaBarCode(True);
end;

frmCodBarra.Show;
end;

procedure TfrmMain.cmdCodBarraV2Click(Sender: TObject);
begin
DesligaNFC;
//frmBarCode.Show;
frmCodigoBarraV2.ok:= False;
frmCodigoBarraV2.Show;
end;

procedure TfrmMain.DesligaNFC;
begin
{$IFNDEF __G800__}
if(GertecNFC <> nil)then
  GertecNFC.PowerOff;
{$ENDIF}
end;

procedure TfrmMain.cmdImpressaoClick(Sender: TObject);
begin
//ShowMessage('Impressao');
DesligaNFC;
frmImpressaoG.PanelMessage.Visible:=False;
frmImpressaoG.CleanText(True);
frmImpressaoG.Show;
end;

procedure TfrmMain.cmdNFCClick(Sender: TObject);
begin
//ShowMessage('NFC');
{$IFDEF __G800__}
frmNFC.Show;
{$ENDIF}
end;

procedure TfrmMain.cmdNFCIdClick(Sender: TObject);   //1365465
begin
{$IFNDEF __G800__}
frmNFCid.ok:=True;
frmNFCid.Show;
{$ENDIF}
end;

procedure TfrmMain.cmdNFCBcClick(Sender: TObject);
begin
{$IFNDEF __G800__}
frmNFCid.ok:=False;
frmNFCid.Show;
{$ENDIF}
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
DeviceType :string;
begin




  DeviceType := JStringToString(TJBuild.JavaClass.MODEL);
  if(DeviceType = 'Smart G800')then begin
    //ShowMessage('Smart G800');
    cmdNFC.Visible := True;
  end else begin//'GPOS700'
    //ShowMessage('NOT Smart G800');
    cmdNFC.Visible := False;
    cmdNFCId.Position.Y := cmdNFC.Position.Y;
  end;
  cmdNFCId.Visible := not cmdNFC.Visible;

end;

end.
