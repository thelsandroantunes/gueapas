unit Unit1;

//{$DEFINE __WINDOWS__}
interface

//storeFile file("Development_MarcosPSaporetti_CustomerAPP.jks")
//            storePassword 'Development@MarcosPSaporetti2018d'
//            keyAlias 'developmentmarcospsaporetti_customerapp'
//            keyPassword 'Development@MarcosPSaporetti2018'

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls,Rtti,
  //JavaInterfaces,


  IdURI,
  Androidapi.Jni.Net,
  Androidapi.JNI.JavaTypes,
  Androidapi.Helpers,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.App,
  System.Messaging,

  System.IOUtils,
  System.Character,
  System.Generics.Collections,
  System.UIConsts, FMX.Edit,
  FMX.EditBox, FMX.NumberBox,
  Androidapi.JNIBridge,
  Androidapi.JNI.Widget,
  Androidapi.JNI.Util,
  Androidapi.JNI.Os



  //Vcl.Forms.

  {$IFNDEF __WINDOWS__}
  ,JavaInterfaces,
  //JavaInterPos7Api,
  FMX.Helpers.Android,
  FMX.Surfaces

  {$ENDIF}

  ;
const
   MSGBOX_FLAG = true;
  STR_VERSION='03d';
  REQCODE = 0;
type
  TForm1 = class(TForm)
    Label1: TLabel;
    GroupBox1: TGroupBox;
    rdgProdutos: TRadioButton;
    rdgDebito: TRadioButton;
    grpParcelamento: TGroupBox;
    rdgParceladoLoja: TRadioButton;
    rdgParceladoAdm: TRadioButton;
    cmdEnviarTransacao: TButton;
    rdgVoucher: TRadioButton;
    Edit1: TEdit;
    cmdCancelarTransacao: TButton;
    cmdFechamento: TButton;
    cmdFuncoes: TButton;
    edtParcelas: TNumberBox;
    Label2: TLabel;
    chkImpressao: TCheckBox;
    edtValor: TEdit;
    procedure cmdEnviarTransacaoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtParcelasKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure cmdCancelarTransacaoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//  TFruit = class
//    procedure Eat; virtual;
//  end;

//  TApple = class(TFruit)
//    procedure Eat; override;
//  end;

  I1 = interface
    procedure DoSomething;
  end;

  T1 = class(  TInterfacedObject, I1)
    procedure DoSomething;virtual;abstract;
  end;

  T2 = class(T1)
    procedure DoSomething; override;
  end;




var
  Form1: TForm1;
  {$IFNDEF __WINDOWS__}
  transacao:JSDKStone;
//comment7api  transacaopos7:JPOS7API;
  {$ENDIF}
implementation

//procedure T1.DoSomething;
//begin
//  ShowMessage('parent(T1.DoSomething)');
//end;

procedure T2.DoSomething;
begin
  ShowMessage('Child(T1.DoSomething)');
end;

//  procedure TFruit.Eat;
//  begin
//  ShowMessage('TFruit.Eat;');
//  end;

//  procedure TApple.Eat;
//  begin
//  ShowMessage('TApple.Eat;');
//  end;

{$R *.fmx}

//**********************************************
function Numeric(strValor:string):string;
//Devolve somente caracteres numericos da String
//Ex: 1,23=>123
var
i:integer;
ch:char;
strResult:string;
begin
  strResult:='';
  {$IFDEF __WINDOWS__}
  for i := 1 to Length(strValor) do begin
  {$ELSE}
  for i := 0 to Length(strValor)-1 do begin
  {$ENDIF}
    ch:= strValor[i];
    if(ch>='0')and(ch<='9')then
      strResult:=strResult+ch;
  end;
  Result:=strResult;
end;


//**********************************************
procedure DebugaMsgBox(Msg:string);
begin
   if(MSGBOX_FLAG)then begin
       ShowMessage(Msg);
   end;
end;

procedure TForm1.cmdEnviarTransacaoClick(Sender: TObject);
var
{$IFNDEF __WINDOWS__}
//P1:JEntradaTransacao;
//P2x:JSDKStone_SDKStoneCallback;
entrada:JEntradaTransacao;
saidaDados:JSaidaDados;

//comment7api entradaPOS7:JParamIn;
//comment7api callbackPOS7:JPOS7API_Pos7apiCallbackClass;
//comment7api saidaPOS7:JParamOut;

{$ENDIF}
strValor:string;
//iAux:PInteger;

begin

//comment7api callbackPOS7.onResult(saidaPOS7);
//:=TJPOS7API_Pos7apiCallback.JavaClass.onResult;
{$IFDEF __WINDOWS__}

strValor:=Numeric(edtValor.Text);

if rdgProdutos.IsChecked then begin
  DebugaMsgBox('Credito=>'+strValor);
end else if rdgDebito.IsChecked then begin
  DebugaMsgBox('Debito=>'+strValor);
end else if rdgVoucher.IsChecked then begin
  DebugaMsgBox('Voucher=>'+strValor);
end;

{$ELSE}
entrada:=TJEntradaTransacao.Create;
saidaDados:=TJSaidaDados.Create;
//TJSDKStone_SDKStoneCallback.JavaClass.


//TJSDKStone_SDKStoneCallback.JavaClass.obtemResposta();
//P2:=TJSDKStone_SDKStoneCallback.Create;
//@P2.obtemResposta(saidaDados):=GetProcAddress(obtemRespostateste(saidaDados));
//TJSDKStone_SDKStoneCallback.JavaClass.obtemResposta:=@obtemRespostateste;

DebugaMsgBox('saidaDados:=TJSaidaDados.Create(10A)');

//@TJSDKStone_SDKStoneCallback.JavaClass.obtemResposta = obtemRespostateste;
//P2.obtemResposta :=@obtemRespostateste;
//TJSDKStone_SDKStoneCallback.Create;

//P2:=TJSDKStone_SDKStoneCallback.JavaClass.obtemResposta;

//TJSDKStone_SDKStoneCallback.JavaClass.obtemResposta:= @obtemRespostateste;




strValor:=Numeric(edtValor.Text);
entrada.informaValor(StringToJString(strValor));


if rdgProdutos.IsChecked then begin
  DebugaMsgBox('Credito=>'+strValor);
  entrada.informaProdutos(TJISDKStoneConstants.JavaClass.SDKSTONE_PROD_CREDITO);
end else if rdgDebito.IsChecked then begin
  DebugaMsgBox('Debito=>'+strValor);
  entrada.informaProdutos(TJISDKStoneConstants.JavaClass.SDKSTONE_PROD_DEBITO);
end else if rdgVoucher.IsChecked then begin
  entrada.informaProdutos(TJISDKStoneConstants.JavaClass.SDKSTONE_PROD_VOUCHER);
  DebugaMsgBox('Voucher=>'+strValor);
end;

if rdgParceladoLoja.IsChecked then begin
  entrada.informaTipoParcela( TJISDKStoneConstants.JavaClass.SDKSTONE_PARCELADO_LOJA);
  ShowMessage('Parcelado Loja')
end else if rdgParceladoAdm.IsChecked then begin
  entrada.informaTipoParcela( TJISDKStoneConstants.JavaClass.SDKSTONE_PARCELADO_ADM);
  ShowMessage('Parcelado Adm');
end;

{$ENDIF}

entrada.informaTipoTransacao(TJISDKStoneConstants.JavaClass.SDKSTONE_TRS_VENDA);
entrada.informaValor(StringToJString('123'));
entrada.informaParcelas( 1);
entrada.informaProdutos(TJISDKStoneConstants.JavaClass.SDKSTONE_PROD_CREDITO);
entrada.informaTipoParcela( TJISDKStoneConstants.JavaClass.SDKSTONE_PARCELADO_LOJA);
entrada.informaId(StringToJString('01234678901'));
entrada.habilitaComprovanteImpresso(true);



//From Android
//entrada.informaTipoTransacao(ISDKStoneConstants.SDKSTONE_TRS_VENDA);
//entrada.informaValor(mCampoValor.getText().toString());
//entrada.informaParcelas( Integer.parseInt (mCampoParcelas.getText().toString()));
//entrada.informaProdutos(tipoTransacao);
//entrada.informaTipoParcela( tipoParcela);
//entrada.informaId("01234678901");
//entrada.habilitaComprovanteImpresso(mCheckImpressao.isChecked());



{$IFNDEF __WINDOWS__}
//Edit1.Text :=JStringToString(entrada.obtemValor());
//transacao.transacaoFinanceira(entrada,P2);

//ShowMessage('ClassNamxx=>'+TJSDKStone_SDKStoneCallback.ClassName);
//P2:=TJSDKStone_SDKStoneCallback.;
//P2:=TJSDKStone_SDKStoneCallback.Create;


//TJSDKStone_SDKStoneCallback.JavaClass.obtemResposta := @obtemRespostateste;
//iAux:=@obtemRespostateste;
//iAux:=@
//TJSDKStone_SDKStoneCallback.JavaClassobtemResposta:=@obtemRespostateste;
//iAux:=@P2.obtemResposta;
//TJSDKStone_SDKStoneCallback.JavaClass.obtemResposta(saidaDados);

//iAux:=@obtemRespostateste;

//ShowMessage('iAux:='+inttostr(iAux^));


//ShowMessage(inttostr(TJSDKStone_SDKStoneCallback.JavaClass.obtemResposta(saidaDados)));

try
//P2x:=TJSDKStone_SDKStoneCallback.Create;
//transacao2.transacaoFinanceira(entrada,P2x);

//comment7api entradaPOS7:=TJParamIn.Create;
//comment7api saidaPOS7:=TJParamOut.Create;
//callbackPOS7 :=TJPOS7API_Pos7apiCallback.Create;
//transacaopos7.processTransaction(entradaPOS7,callbackPOS7);

//TJPOS7API.JavaClass.processTransaction(entradaPOS7,callbackPOS7);


//entradaPOS7
except
on e: exception do begin
ShowMessage('ErroTr=>'+e.Message);
end;
end;


//P2:=TJSDKStone_SDKStoneCallback.Create;

//stone =
//TJSDKStone.JavaClass.transacaoFinanceira(P1,P2);
//teste.JavaClass.obtemValor StringToJString('123'));
//stone.transacaoFinanceira(P1,P2);
{$ENDIF}

end;


procedure TForm1.edtParcelasKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
grpParcelamento.Enabled := (StrToIntDef(edtParcelas.Text,0)>1);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
{$IFNDEF __WINDOWS__}

//comment7api transacaopos7:=TJPOS7API.JavaClass.init(TAndroidHelper.Context);


//gbSaidaDados:= TJSaidaDados.Create;

//entradaPOS7:=TJParamIn.Create;
//callbackPOS7:JPOS7API_Pos7apiCallback;

cmdCancelarTransacao.Text:='Cancelar Trans'+STR_VERSION;
transacao :=TJSDKStone.JavaClass.init(TAndroidHelper.Context);


{$ENDIF}
end;
//************************
//**********************************************
procedure TForm1.cmdCancelarTransacaoClick(Sender: TObject);


var
//entrada:JEntradaTransacao;
Intent:JIntent;


//comment7apicallbackPOS7:JPOS7API_Pos7apiCallback;
//comment7apisaidaPOS7:JParamOut;


saida:JSaidaDados;
stoneCallback: JSDKStone_SDKStoneCallback;
s: JSDKStone;
JSON:String;

Produto,
HabilitaImpressao:String;

begin



try

{ShowMessage('VambaMay'+STR_VERSION);

saida:= TJSaidaDados.Create;



//stoneCallback:=TJSDKStone_SDKStoneCallback.Create;
stoneCallback.obtemResposta(saida);

//TJSDKStone_SDKStoneCallback.JavaClass.obtemResposta(saida);





//saidaPOS7:=TJParamOut.Create;
//callbackPOS7:=TJPOS7API_Pos7apiCallbackAux.Create;
//callbackPOS7.onResult(saidaPOS7);

//Invoke Error:method not found
//stoneCallback.JavaClass.obtemResposta(saida);

//Invoke Error:method not found
//TJSDKStone_SDKStoneCallback.JavaClass.obtemResposta(saida );
//stoneCallback.obtemResposta(saida);

//stoneCallback.obtemResposta(saida);
//TJSDKStone_SDKStoneCallback.obtemResposta(saida);
//stoneCallback.obtemResposta(saida);
//stoneCallback.Teste;

//entrada:=TJEntradaTransacao.Create;
//transacao.transacaoFinanceira(entrada,stoneCallback);

//stoneCallback.


TJSDKStone_SDKStoneCallback.

//Access violation at adress A54..
//stoneCallback.obtemResposta(saida);


}
Intent := TJIntent.JavaClass.init(
TJIntent.JavaClass.ACTION_VIEW,TJnet_Uri.JavaClass.parse(StringToJString('pos7api://pos7')));

if(chkImpressao.IsChecked)then
  HabilitaImpressao:='1'
else
  HabilitaImpressao:='0';

if rdgProdutos.IsChecked then begin
  Produto:='1'
end else if rdgDebito.IsChecked then begin
  Produto:='2'
end else if rdgVoucher.IsChecked then begin
  Produto:='4'
end;


JSON:='{'+
'"type":"1",'+
'"id":"123456",'+
'"amount":"'+edtValor.text+'"'+
'"installments":"0"'+
'"instmode":"0"'+
'"product":"'+Produto+'"'+
'"receipt":"'+HabilitaImpressao+'"'+
'}';


Intent.putExtra(StringToJString('jsonReq'), StringToJString(JSON));

//***********
TMessageManager.DefaultManager.SubscribeToMessage(
      TMessageResultNotification,
      procedure(const Sender   : TObject;
                const aMessage : TMessage)
      var
        M    : TMessageResultNotification;
        JStr : JString;
        FullPhotoUri : Androidapi.JNI.Net.Jnet_Uri;
        StrMsg:String;
        Intent:JIntent;
        Bundle:JBundle;
        //https://forums.embarcadero.com/message.jspa?messageID=877569

      begin
        M := TMessageResultNotification(aMessage);
        {Is this request the right one?}
        if M.RequestCode = REQCODE then begin
          {Did the request return OK?}
          if (M.ResultCode = TJActivity.JavaClass.RESULT_OK) then begin

            //Intent := M.Value.



            //FullPhotoUri := M.Value.getData();

            JStr         := M.Value.getStringExtra(StringToJString('jsonResp'));


            //StrMsg := JStringToString( FullPhotoUri.getPath);
            showMessage('StrMsgJstr('+JStr.Length.ToString+')=>'+JStringToString(JStr));

            //StrMsg := JStringToString( FullPhotoUri.getEncodedPath);
            //showMessage('StrMsg2('+StrMsg.Length.ToString+')=>'+strMsg);

            //Str := JStringToString( FullPhotoUri.getPath );
            //Str := JStringToString( FullPhotoUri.getEncodedPath );

            //JStr := M.Value.toURI;
            //Str := JStringToString( JStr );

            //Str := JStringToString( FullPhotoUri.toString );


          end;
        end;
      end
  );

//*******************

TAndroidHelper.Activity.startActivityForResult(Intent, REQCODE);

except
on e: exception do begin
ShowMessage('Erro=>'+e.Message);
end;

end;
//   showmessage(inttostr(gbSaidaDados.obtemCodigoErro));


end;



end.
