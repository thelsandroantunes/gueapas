unit CodigoDeBarras;

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
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  Fmx.Bind.GenData, System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.ObjectScope;

  const
  SECOND = 1/86400;

type
TBarCodes = (EAN8, EAN13, QRCODE, AUTO);

  TfrmCodBarra = class(TForm)
    btnEan8: TButton;
    Label1: TLabel;
    btnEan13: TButton;
    btnEan14: TButton;
    btnQrCode: TButton;
    ListView1: TListView;
    imgCamera: TImage;
    lblResultadoLeitura: TEdit;
    Camera: TCameraComponent;
    txtLeitura: TLabel;
    ActionList1: TActionList;
    ShowShareSheetAction1: TShowShareSheetAction;
    TetheringAppProfile1: TTetheringAppProfile;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CameraSampleBufferReady(Sender: TObject; const ATime: TMediaTime);
    procedure btnEan8Click(Sender: TObject);
    procedure btnEan13Click(Sender: TObject);
    procedure btnQrCodeClick(Sender: TObject);
    procedure btnEan14Click(Sender: TObject);
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

    procedure iniciaBarCode(limpa: Boolean);
    function getAtivoCamera(): Boolean;

  end;

var
  frmCodBarra: TfrmCodBarra;
  barCodeTitle: string;
  ativoCamera:Boolean;

implementation

{$R *.fmx}

uses System.Threading;

var lFlash : Boolean;
    iCount:integer;
    UltimoCodigo:string;
    UltimaHora:TDateTime;

   
function TfrmCodBarra.AppEvent(AAppEvent: TApplicationEvent;
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

//***********************************************************
 function TfrmCodBarra.getAtivoCamera(): Boolean;
 begin
   Result := ativoCamera;
 end;

//***********************************************************
procedure TfrmCodBarra.iniciaBarCode(limpa: Boolean);
begin
  if limpa then
  begin
    ListView1.Items.Clear;
  end else begin
    ListView1.Items.Clear;
    FinalizaLeitura;
  end;
end;

procedure TfrmCodBarra.AtivaLeitura(tipo : TBarcodeFormat);
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

  ativoCamera:=True;
  txtLeitura.Visible:=True;
  lblResultadoLeitura.Visible:=True;

end;

procedure TfrmCodBarra.btnEan13Click(Sender: TObject);
begin
  AtivaLeitura(TBarcodeFormat.EAN_13);
  barCodeTitle:='EAN_13';
  txtLeitura.Text := 'Leitura de EAN13';

  btnEan8.Visible:=False;
  btnEan13.Visible:=False;
  btnEan14.Visible:=False;
  btnQrCode.Visible:=False;
  
  
  ListView1.Visible:=False;
  imgCamera.Visible:=True;
end;

procedure TfrmCodBarra.btnEan14Click(Sender: TObject);
begin
  AtivaLeitura(TBarcodeFormat.ALL_1D);
  barCodeTitle:='EAN_14';
  txtLeitura.Text := 'Leitura de EAN14';

  btnEan8.Visible:=False;
  btnEan13.Visible:=False;
  btnEan14.Visible:=False;
  btnQrCode.Visible:=False;
  
  
  ListView1.Visible:=False;
  imgCamera.Visible:=True;
end;

procedure TfrmCodBarra.btnEan8Click(Sender: TObject);
begin
  AtivaLeitura(TBarcodeFormat.EAN_8);
  barCodeTitle:='EAN_8';
  txtLeitura.Text := 'Leitura de EAN8';

  btnEan8.Visible:=False;
  btnEan13.Visible:=False;
  btnEan14.Visible:=False;
  btnQrCode.Visible:=False;
  
  
  ListView1.Visible:=False;
  imgCamera.Visible:=True;
  
end;

procedure TfrmCodBarra.btnQrCodeClick(Sender: TObject);
begin
  AtivaLeitura(TBarcodeFormat.QR_CODE);
  barCodeTitle:='QR_CODE';
  txtLeitura.Text := 'Leitura de QrCode';

  btnEan8.Visible:=False;
  btnEan13.Visible:=False;
  btnEan14.Visible:=False;
  btnQrCode.Visible:=False;
  
  
  ListView1.Visible:=False;
  imgCamera.Visible:=True;
end;

procedure TfrmCodBarra.FinalizaLeitura;
begin
  
  Camera.Active := False;
  fScanManager.Free;
  fFMXBarcode.Free;
  fScanInProgress := False;
  

  btnEan8.Visible:=True;
  btnEan13.Visible:=True;
  btnEan14.Visible:=True;
  btnQrCode.Visible:=True;
  txtLeitura.Visible:=True;
  ListView1.Visible:=True;
  imgCamera.Visible:=False;
  lblResultadoLeitura.Visible:=False;
  txtLeitura.Visible:=False;

  ativoCamera:=False;

  //Toast('Leitura feita com sucesso.');
end;

procedure TfrmCodBarra.CameraSampleBufferReady(Sender: TObject;
  const ATime: TMediaTime);
begin
  TThread.Synchronize(TThread.CurrentThread, GetImage);
end;

procedure TfrmCodBarra.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not fInProgress;
end;

procedure TfrmCodBarra.FormCreate(Sender: TObject);
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

procedure TfrmCodBarra.FormDestroy(Sender: TObject);
begin
  fScanManager.Free;
  fFMXBarcode.Free;
end;

procedure TfrmCodBarra.GetImage;
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
            Codigo := ReadResult.text;
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
                FinalizaLeitura;
                //Toast('Leitura com sucesso.');
                //FinalizaLeitura;
              end;              
            end else if((ReadResult = nil) and (abs(time-UltimaHora)>30*SECOND))then begin
              UltimaHora:=Time;

              ListView1.BeginUpdate; 
              ItemAdd := ListView1.Items.Add;
              ItemAdd.Text := BarCodeTitle + ': Não foi possível ler o Código.';
              ListView1.EndUpdate;              

              FinalizaLeitura;
              
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
