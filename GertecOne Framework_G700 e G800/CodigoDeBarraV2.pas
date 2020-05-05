unit CodigoDeBarraV2;

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
  FMX.Barcode.DROID, FMX.Objects, FMX.Edit, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;

const
  SECOND = 1/86400;

type

TBarCodes = (EAN8, EAN13, QRCODE, AUTO);

  TfrmCodigoBarraV2 = class(TForm)
    ActionList1: TActionList;
    Camera: TCameraComponent;
    ShowShareSheetAction1: TShowShareSheetAction;
    TetheringAppProfile1: TTetheringAppProfile;
    imgCamera: TImage;
    lblResultadoLeitura: TEdit;
    Label1: TLabel;
    txtLeitura: TLabel;
    btnFlash: TButton;
    ListView1: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CameraSampleBufferReady(Sender: TObject; const ATime: TMediaTime);

    procedure btnFlashClick(Sender: TObject);
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
  frmCodigoBarraV2: TfrmCodigoBarraV2;
  barCodeTitle: string;

implementation

{$R *.fmx}


uses System.Threading;

var lFlash : Boolean;
    iCount:integer;
    UltimoCodigo:string;
    UltimaHora:TDateTime;


function TfrmCodigoBarraV2.AppEvent(AAppEvent: TApplicationEvent;
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

procedure TfrmCodigoBarraV2.AtivaLeitura(tipo : TBarcodeFormat);
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

procedure TfrmCodigoBarraV2.btnFlashClick(Sender: TObject);
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
    Toast('Não existe FLASH neste aparelho!');

end;

procedure TfrmCodigoBarraV2.FinalizaLeitura;
begin
  Camera.Active := False;
  fScanManager.Free;
  fFMXBarcode.Free;
  fScanInProgress := False;
  Toast('Leitura feita com sucesso.');
end;

procedure TfrmCodigoBarraV2.CameraSampleBufferReady(Sender: TObject;
  const ATime: TMediaTime);
begin
  TThread.Synchronize(TThread.CurrentThread, GetImage);
end;

procedure TfrmCodigoBarraV2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not fInProgress;
end;

procedure TfrmCodigoBarraV2.FormCreate(Sender: TObject);
var
  AppEventSvc: IFMXApplicationEventService;
begin

  AtivaLeitura(TBarcodeFormat.CODABAR);
  txtLeitura.Text := 'Leitura de Tudo';

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

procedure TfrmCodigoBarraV2.FormDestroy(Sender: TObject);
begin
  fScanManager.Free;
  fFMXBarcode.Free;
end;

procedure TfrmCodigoBarraV2.GetImage;
var
  scanBitmap: TBitmap;
  ReadResult: TReadResult;
  ItemAdd : TListViewItem;

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

                //Lista de Leitura
                  ListView1.BeginUpdate;
                  ItemAdd := ListView1.Items.Add;
                  ItemAdd.Text := BarCodeTitle + ': ' + ReadResult.text;
                  ListView1.EndUpdate;


                //


                inc(iCount);
                //Toast('Leitura com sucesso.');
                FinalizaLeitura;
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
