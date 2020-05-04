unit BarcodeV2;

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
  IPPeerClient,
  IPPeerServer,
  System.Tether.Manager,
  System.Tether.AppProfile,
  System.Actions,
  Androidapi.JNI.Toast,
  FMX.ActnList,
  FMX.StdActns,
  FMX.MediaLibrary.Actions,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Media,
  FMX.Layouts,
  FMX.ExtCtrls,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Platform,
  ZXing.BarcodeFormat,
  ZXing.ReadResult,
  ZXing.ScanManager,
  FMX.Barcode.DROID, FMX.Objects, FMX.Edit;

const
  SECOND = 1/86400;

type

TBarCodes = (EAN8, EAN13, QRCODE, AUTO);

  TfrmBarCodeV2 = class(TForm)
    Label1: TLabel;
    TetheringAppProfile1: TTetheringAppProfile;
    ActionList1: TActionList;
    ShowShareSheetAction1: TShowShareSheetAction;
    btnFlash: TButton;
    ImageControl1: TImageControl;
    txtLeitura: TLabel;
    Camera: TCameraComponent;
    btnAuto: TButton;
    btnQrCode: TButton;
    btnEan13: TButton;
    lblResultadoLeitura: TEdit;
    imgCamera: TImage;
    btnEan8: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CameraSampleBufferReady(Sender: TObject; const ATime: TMediaTime);

    procedure btnQrCodeClick(Sender: TObject);

    procedure btnFlashClick(Sender: TObject);
    procedure btnEan8Click(Sender: TObject);
    procedure btnEan13Click(Sender: TObject);
    procedure btnAutoClick(Sender: TObject);
  private
    { Private declarations }

    // for the external library
    fInProgress: boolean;
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
  frmBarCodeV2: TfrmBarCodeV2;

implementation

{$R *.fmx}

uses System.Threading;

var lFlash : Boolean;
    iCount:integer;
    UltimoCodigo:string;
    UltimaHora:TDateTime;



function TfrmBarCodeV2.AppEvent(AAppEvent: TApplicationEvent;
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

procedure TfrmBarCodeV2.AtivaLeitura(tipo : TBarcodeFormat);
begin

  if Assigned(fScanManager) then
    fScanManager.Free;

  fScanManager := TScanManager.Create(tipo,nil);

  Camera.Active := False;
  Camera.Kind := FMX.Media.TCameraKind.BackCamera;
  Camera.FocusMode := FMX.Media.TFocusMode.ContinuousAutoFocus;
  Camera.Quality := FMX.Media.TVideoCaptureQuality.HighQuality;

  //Ajuste emp�rico - TCameraComponent quality change when reactivated!
  Camera.FocusMode := FMX.Media.TFocusMode.ContinuousAutoFocus;
  Camera.Quality := FMX.Media.TVideoCaptureQuality.MediumQuality;
  Camera.Active := True;

end;

procedure TfrmBarCodeV2.btnFlashClick(Sender: TObject);
begin
  if Camera.HasTorch then
    begin
      if lFlash then
        begin
          Camera.TorchMode := FMX.Media.TTorchMode.ModeOff;
          btnFlash.Text := 'Ligar Flash';
          lFlash := False;
        end
      else
        begin
          Camera.TorchMode := FMX.Media.TTorchMode.ModeOn;
          btnFlash.Text := 'Desligar Flash';
          lFlash := True;
        end;
    end
  else
    Toast('N�o existe FLASH neste aparelho!');

end;

procedure TfrmBarCodeV2.btnEan8Click(Sender: TObject);
begin
  AtivaLeitura(TBarcodeFormat.EAN_8);
  txtLeitura.Text := 'Leitura de EAN8';
end;

procedure TfrmBarCodeV2.btnEan13Click(Sender: TObject);
begin
  AtivaLeitura(TBarcodeFormat.EAN_13);
  txtLeitura.Text := 'Leitura de EAN13';
end;

procedure TfrmBarCodeV2.btnQrCodeClick(Sender: TObject);
begin
  AtivaLeitura(TBarcodeFormat.QR_CODE);
  txtLeitura.Text := 'Leitura de QrCode';
end;

procedure TfrmBarCodeV2.btnAutoClick(Sender: TObject);
begin
  AtivaLeitura(TBarcodeFormat.Auto);
  txtLeitura.Text := 'Leitura de todos os tipos';
end;

procedure TfrmBarCodeV2.FinalizaLeitura;
begin
  Camera.Active := False;
  fScanManager.Free;
  fFMXBarcode.Free;
  fScanInProgress := False;
  Toast('Leitura feita com sucesso.');
end;

procedure TfrmBarCodeV2.CameraSampleBufferReady(Sender: TObject;
  const ATime: TMediaTime);
begin
  TThread.Synchronize(TThread.CurrentThread, GetImage);
end;

procedure TfrmBarCodeV2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not fInProgress;
end;

procedure TfrmBarCodeV2.FormCreate(Sender: TObject);
var
  AppEventSvc: IFMXApplicationEventService;
begin

  lFlash := False;
  iCount:=1;

  UltimoCodigo:='';
  UltimaHora:=time;

  if TPlatformServices.Current.SupportsPlatformService
     ( IFMXApplicationEventService, IInterface(AppEventSvc)) then
     begin
       AppEventSvc.SetApplicationEventHandler(AppEvent);
     end;

  fFrameTake := 0;
  fInProgress := False;

end;

procedure TfrmBarCodeV2.FormDestroy(Sender: TObject);
begin
  fScanManager.Free;
  fFMXBarcode.Free;
end;

procedure TfrmBarCodeV2.GetImage;
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

end.
