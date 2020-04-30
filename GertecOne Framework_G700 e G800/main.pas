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
  BarCode,
  Impressao,
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
  FMX.Barcode.DROID, FMX.Objects, FMX.Edit, IPPeerClient, IPPeerServer


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
    cmdQrCode: TColorButton;
    Label6: TLabel;
    Image5: TImage;
    ColorButton2: TColorButton;
    Label7: TLabel;
    Image6: TImage;
    ImageViewer1: TImageViewer;
    BitmapAnimation1: TBitmapAnimation;
    ImageViewer2: TImageViewer;
    imgCamera: TImage;
    Camera: TCameraComponent;
    ActionList1: TActionList;
    ShowShareSheetAction1: TShowShareSheetAction;
    txtLeitura: TLabel;
    TetheringAppProfile1: TTetheringAppProfile;
    lblResultadoLeitura: TEdit;

    procedure cmdCodigoBarrasClick(Sender: TObject);
    procedure cmdImpressaoClick(Sender: TObject);
    procedure cmdNFCClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmdNFCIdClick(Sender: TObject);
    procedure DesligaNFC;
    procedure CameraSampleBufferReady(Sender: TObject; const ATime: TMediaTime);
  private
    { Private declarations }

    // for the external library
    fFMXBarcode: TFMXBarcode;

    // for the native zxing.delphi library
    fScanManager: TScanManager;
    fScanInProgress: Boolean;
    fFrameTake: Integer;

    procedure GetImage();
    function AppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;

    procedure AtivaLeitura(tipo : TBarcodeFormat);
    procedure FinalizaLeitura;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

function TfrmMain.AppEvent(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
begin
  Result := False;
  case AAppEvent of
    TApplicationEvent.WillBecomeInactive, TApplicationEvent.EnteredBackground,
      TApplicationEvent.WillTerminate:
      begin
        Camera.Active := False;
        Result := True;
      end;
  end;
end;

procedure TfrmMain.AtivaLeitura(tipo : TBarcodeFormat);
begin

  if Assigned(fScanManager) then
    fScanManager.Free;

  fScanManager := TScanManager.Create(tipo,nil);

  Camera.Active := False;
  Camera.Kind := FMX.Media.TCameraKind.BackCamera;
  Camera.FocusMode := FMX.Media.TFocusMode.ContinuousAutoFocus;
  Camera.Quality := FMX.Media.TVideoCaptureQuality.HighQuality;

  //Ajuste empírico - TCameraComponent quality change when reactivated!
  Camera.FocusMode := FMX.Media.TFocusMode.ContinuousAutoFocus;
  Camera.Quality := FMX.Media.TVideoCaptureQuality.MediumQuality;
  Camera.Active := True;

end;

procedure TfrmMain.FinalizaLeitura;
begin
  Camera.Active := False;
  fScanManager.Free;
  fFMXBarcode.Free;
  fScanInProgress := False;
  Toast('Leitura feita com sucesso.');
end;


procedure TfrmMain.CameraSampleBufferReady(Sender: TObject;
  const ATime: TMediaTime);
begin
  TThread.Synchronize(TThread.CurrentThread, GetImage);
end;


procedure TfrmMain.GetImage;
var
  scanBitmap: TBitmap;
  ReadResult: TReadResult;

begin
  Camera.SampleBufferToBitmap(imgCamera.Bitmap, True);

  if (fScanInProgress) then
  begin
    exit;
  end;

  { This code will take every 2 frame. }
  inc(fFrameTake);
  if (fFrameTake mod 2 <> 0) then
  begin
    exit;
  end;

  scanBitmap := TBitmap.Create();
  scanBitmap.Assign(imgCamera.Bitmap);
  ReadResult := nil;

  TTask.Run(
    procedure
    begin
      try
        fScanInProgress := True;
        try
          ReadResult := fScanManager.Scan(scanBitmap);
        except
          on E: Exception do
          begin
            TThread.Synchronize(nil,
              procedure
              begin
                lblResultadoLeitura.Text := E.Message;
              end);

            exit;
          end;
        end;

        TThread.Synchronize(nil,
          procedure
          var
            Codigo:string;
          begin
            if (ReadResult <> nil) then
            begin
            //So registra mesmo codigo depois de 3 segundos
              if((Codigo<>UltimoCodigo)or(abs(time-UltimaHora)>3*SECOND))then begin
                UltimoCodigo := Codigo;
                UltimaHora:=Time;
                lblResultadoLeitura.Text := '('+inttostr(iCount)+') '+ReadResult.text;
                inc(iCount);
                Toast('Leitura com sucesso.');
                //FinalizaLeitura;
              end;
            end;
          end);
      finally
        ReadResult.Free;
        scanBitmap.Free;
        fScanInProgress := False;
      end;

    end);
end;



procedure TfrmMain.cmdCodigoBarrasClick(Sender: TObject);
begin
DesligaNFC;
frmBarCode.Show;
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
frmImpressaoG.Show;
end;

procedure TfrmMain.cmdNFCClick(Sender: TObject);
begin
//ShowMessage('NFC');
{$IFDEF __G800__}
frmNFC.Show;
{$ENDIF}
end;


procedure TfrmMain.cmdNFCIdClick(Sender: TObject);
begin
{$IFNDEF __G800__}
frmNFCid.Show;
{$ENDIF}
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
DeviceType :string;
begin
  DeviceType := JStringToString(TJBuild.JavaClass.MODEL);
  if(DeviceType ='Smart G800')then begin
    //ShowMessage('Smart G800');
    cmdNFC.Visible := True;
  end else begin//'GPOS700'
    //ShowMessage('NOT Smart G800');
    cmdNFC.Visible := false;
    cmdNFCId.Position.Y := cmdNFC.Position.Y;
  end;
  cmdNFCId.Visible := not cmdNFC.Visible;

end;

end.
