unit CodigoDeBarras_G800;

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

  FMX.ActnList,
  FMX.StdActns,
  FMX.MediaLibrary.Actions,
  FMX.Media,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Objects,
  FMX.Colors,

  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView, System.IOUtils,

  Androidapi.JNI.Toast,

  FMX.Layouts,
  FMX.ExtCtrls,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Platform,

  ZXing.BarcodeFormat,
  ZXing.ReadResult,
  ZXing.ScanManager,

  FMX.Barcode.DROID,
  Fmx.Bind.GenData,

  System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.ObjectScope;

  const
  SECOND = 1/86400;

type

TBarCodes = (EAN8, EAN13, QRCODE, AUTO);

  TfrmCodBarras_G800 = class(TForm)
    imgCamera: TImage;
    lblResultadoLeitura: TEdit;
    Label1: TLabel;
    btnQrCode: TButton;
    Camera: TCameraComponent;
    txtLeitura: TLabel;
    btnFlash: TButton;
    ActionList1: TActionList;
    ShowShareSheetAction1: TShowShareSheetAction;
    TetheringAppProfile1: TTetheringAppProfile;
    CbtnEan8: TColorButton;
    CbtnEan13: TColorButton;
    CbtnEan14: TColorButton;
    CbtnQrCode: TColorButton;
    lblEan8: TLabel;
    lblEan13: TLabel;
    lblEan14: TLabel;
    lblQrCode: TLabel;
    MediaPlayer1: TMediaPlayer;
    ListView1: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CameraSampleBufferReady(Sender: TObject; const ATime: TMediaTime);

    procedure ativaEan8();
    procedure ativaEan13();
    procedure ativaEan14();
    procedure ativaEanQrCode();

    procedure CbtnEan8Click(Sender: TObject);
    procedure CbtnEan13Click(Sender: TObject);
    procedure CbtnEan14Click(Sender: TObject);
    procedure CbtnQrCodeClick(Sender: TObject);

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
    procedure beepSound(ResourceID: string);
    procedure disableButtons();
    procedure enableButtons();

  end;

var
  frmCodBarras_G800: TfrmCodBarras_G800;
  barCodeTitle: string;
  ativoCamera:Boolean;

implementation

{$R *.fmx}

uses System.Threading;

var lFlash : Boolean;
    iCount:integer;
    UltimoCodigo:string;
    UltimaHora:TDateTime;

//***********************************************************
function TfrmCodBarras_G800.AppEvent(AAppEvent: TApplicationEvent;
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
function TfrmCodBarras_G800.getAtivoCamera(): Boolean;
 begin
   Result := ativoCamera;
 end;
//***********************************************************
procedure TfrmCodBarras_G800.iniciaBarCode(limpa: Boolean);
begin
  if limpa then
  begin
    ListView1.Items.Clear;
  end else begin
    ListView1.Items.Clear;
    FinalizaLeitura;
  end;
end;
 //***********************************************************
procedure TfrmCodBarras_G800.disableButtons;
begin
  CbtnEan8.Visible:=False;
  lblEan8.Visible := False;

  CbtnEan13.Visible := False;
  lblEan13.Visible := False;

  CbtnEan14.Visible := False;
  lblEan14.Visible := False;

  CbtnQrCode.Visible := False;
  lblQrCode.Visible := False;

  ListView1.Visible:=False;
  imgCamera.Visible:=True;
end;
procedure TfrmCodBarras_G800.enableButtons();
begin

  CbtnEan8.Visible:=True;
  lblEan8.Visible := True;

  CbtnEan13.Visible := True;
  lblEan13.Visible := True;

  CbtnEan14.Visible := True;
  lblEan14.Visible := True;

  CbtnQrCode.Visible := True;
  lblQrCode.Visible := True;

  ListView1.Visible:=True;
  imgCamera.Visible:=False;

end;
//***********************************************************
procedure TfrmCodBarras_G800.CbtnEan13Click(Sender: TObject);
begin
    ativaEan13();
end;
procedure TfrmCodBarras_G800.CbtnEan14Click(Sender: TObject);
begin
    ativaEan14();
end;
procedure TfrmCodBarras_G800.CbtnEan8Click(Sender: TObject);
begin
    ativaEan8();
end;
procedure TfrmCodBarras_G800.CbtnQrCodeClick(Sender: TObject);
begin
     ativaEanQrCode();
end;
//**********************************************************
//Fun��es de Ativa��o para leituras
procedure TfrmCodBarras_G800.ativaEan8();
begin
  AtivaLeitura(TBarcodeFormat.EAN_8);
  barCodeTitle:='EAN_8';
  txtLeitura.Text := 'Leitura de EAN8';

  disableButtons;

end;
procedure TfrmCodBarras_G800.ativaEan13();
begin
  AtivaLeitura(TBarcodeFormat.EAN_13);
  barCodeTitle:='EAN_13';
  txtLeitura.Text := 'Leitura de EAN13';

  disableButtons;

end;
procedure TfrmCodBarras_G800.ativaEan14();
begin
  AtivaLeitura(TBarcodeFormat.ALL_1D);
  barCodeTitle:='EAN_14';
  txtLeitura.Text := 'Leitura de EAN14';

  disableButtons;

end;
procedure TfrmCodBarras_G800.ativaEanQrCode();
begin
  AtivaLeitura(TBarcodeFormat.QR_CODE);
  barCodeTitle:='QR_CODE';
  txtLeitura.Text := 'Leitura de QrCode';

  disableButtons;

end;
//***********************************************************
procedure TfrmCodBarras_G800.AtivaLeitura(tipo : TBarcodeFormat);
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

  ativoCamera:=True;
  txtLeitura.Visible:=True;
  lblResultadoLeitura.Visible:=True;

end;
procedure TfrmCodBarras_G800.FinalizaLeitura;
begin

  Camera.Active := False;
  fScanManager.Free;
  fFMXBarcode.Free;
  fScanInProgress := False;

  enableButtons;

  txtLeitura.Visible:=True;
  lblResultadoLeitura.Visible:=False;
  txtLeitura.Visible:=False;

  ativoCamera:=False;

  //Toast('Leitura feita com sucesso.');
end;
//***********************************************************
procedure TfrmCodBarras_G800.beepSound(ResourceID: string);
var
  ResStream: TResourceStream;
  TmpFile: string;
begin
      ResStream := TResourceStream.Create(HInstance, ResourceID, RT_RCDATA);
      try

        TmpFile := TPath.Combine(TPath.GetDocumentsPath, 'Bleep.mp3');

        //TPath.Combine(TPath.GetDocumentsPath, 'filename')  { Internal }
        //TPath.Combine(TPath.GetSharedDocumentsPath, 'filename')  { External }

        ResStream.Position := 0;
        ResStream.SaveToFile(TmpFile);

        MediaPlayer1.FileName := TmpFile;
        MediaPlayer1.Play;

      finally
        ResStream.Free;
      end;


      MediaPlayer1.Play;

end;
//***********************************************************
procedure TfrmCodBarras_G800.CameraSampleBufferReady(Sender: TObject;
  const ATime: TMediaTime);
begin
  TThread.Synchronize(TThread.CurrentThread, GetImage);
end;
procedure TfrmCodBarras_G800.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not fInProgress;
end;
procedure TfrmCodBarras_G800.FormCreate(Sender: TObject);
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
procedure TfrmCodBarras_G800.FormDestroy(Sender: TObject);
begin
  fScanManager.Free;
  fFMXBarcode.Free;
end;
procedure TfrmCodBarras_G800.GetImage;
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

//            MMSystem.PlaySound(pchar('sdafasdf'), 0, SND_ASYNC or SND_FILENAME);

            if (ReadResult <> nil) then
            begin
            Codigo := ReadResult.text;
            beepSound('Resource_1');
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
            end else if((ReadResult <> nil) and (abs(time-UltimaHora)>30*SECOND))then begin
              UltimoCodigo := Codigo;
              UltimaHora:=Time;

              ListView1.BeginUpdate;
              ItemAdd := ListView1.Items.Add;
              ItemAdd.Text := BarCodeTitle + ': N�o foi poss�vel ler o C�digo.';
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
