unit Teste;

interface


uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.DialogService,


  System.IOUtils,
  System.Character,
  System.Generics.Collections,
  System.UIConsts, FMX.Edit,
  FMX.EditBox, FMX.NumberBox,
  System.Threading,


  Androidapi.Jni.Net,       //Required
  Androidapi.JNI.JavaTypes, //Required
  Androidapi.Helpers,       //Required
  Androidapi.JNI.GraphicsContentViewText, //Required
  Androidapi.JNI.App,       //Required
  System.Messaging,         //Required
  System.JSON,               //Required
  Androidapi.JNI.OS,        //Required

  GER7TEF,
  G700Interface,
  GEDIPrinterTEF,
  FMX.Surfaces;
const

  NORMAL = false;
  BOLD = true;

  GER7_VENDA = '1';
  GER7_CANCELAMENTO = '2';
  GER7_FUNCOES = '3';
  GER7_REIMPRESSAO = '18';

  GER7_DESABILITA_IMPRESSAO = '0';
  GER7_HABILITA_IMPRESSAO = '1';

  GER7_CREDITO = '1';
  GER7_DEBITO = '2';
  GER7_VOUCHER = '4';

  GER7_SEMPARCELAMENTO = '0';
  GER7_PARCELADO_LOJA = '1';
  GER7_PARCELADO_ADM = '2';

  ARQ_ID = '\id.dat';

  REQ_CODE = 4713;

  REQ_URI = 'pos7api://pos7';
  REQ_TAG = 'jsonReq';
  RES_TAG ='jsonResp';


  FORM_FEED = #12;
  VERSION = 'GER7TEF Api UEA';

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
    cmdCancelarTransacao: TButton;
    cmdFuncoes: TButton;
    edtParcelas: TNumberBox;
    Label2: TLabel;
    chkImpressao: TCheckBox;
    edtValor: TEdit;
    lblTitulo: TLabel;
    cmdReimpressao: TButton;


    procedure cmdEnviarTransacaoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtParcelasKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure cmdCancelarTransacaoClick(Sender: TObject);
    procedure cmdFuncoesClick(Sender: TObject);
    procedure RandomValor;
    procedure cmdReimpressaoClick(Sender: TObject);
    procedure FuncoesDiversas(Funcao:String);

    //Funcoes Intent
    procedure ExecuteTEF(Tipo,Id,Amount,Parcelas,TipoParcelamento,Product,HabilitaImpressao:string);
    function OnActivityResult(RequestCode, ResultCode: Integer; Data:JIntent): Boolean;
    procedure HandleActivityMessage(const Sender: TObject; const M: TMessage);
  private
    { Private declarations }
    //bTask:ITask;

  public
    { Public declarations }
  end;



var
  Form1: TForm1;
  strId:string;
  strArqId:string;

  TEFExecuteFlag :integer;
  transacao:TGER7TEF;
  FMessageSubscriptionID: Integer;

implementation

{$R *.fmx}

//**********************************************
function getVersion:string;
begin
  result:=VERSION;
end;

//**********************************************
Procedure SaveId;
var Arq:textfile;
begin
  AssignFile(arq,strArqId);
  rewrite(Arq);
  writeln(Arq,strId);
  closefile(Arq);

end;

//**********************************************
Procedure IncrementaId;
var Arq:textfile;
intId:integer;
begin
    if(FileExists(strArqId))then begin
      //Le o Id do Arquivo
      AssignFile(arq,strArqId);
      reset(Arq);
      readln(Arq,strId);
      closefile(Arq);

      //Incrementa o id
      strId := IntToStr(StrToIntDef(strId,1)+1);
    end else begin
      //Se nao existir, inicializa em 1
      strId := '1';
    end;
    SaveId;
end;

//**********************************************

function Numeric(strValor:string):string;
//Devolve somente caracteres numericos da String
//Ex: 1,23=>123
//Ex:1,2 =>120
var
i,iPos:integer;
ch:char;
strResult:string;
begin
  iPos:=Pos(',',strValor);
  iPos:=length(strValor)-iPos;
  case iPos of
    0:strValor:=strValor+'00';
    1:strValor:=strValor+'0';
  end;

  strResult:='';
  for i := 0 to Length(strValor)-1 do begin
    ch:= strValor[i];
    if(ch>='0')and(ch<='9')then
      strResult:=strResult+ch;
  end;
  Result:=strResult;
end;

//**********************************************
procedure IniciaTransacao;
begin
if(transacao = nil) then begin
  transacao:= TGER7TEF.Create('1.05');
end;
end;
//**********************************************
procedure TForm1.edtParcelasKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
grpParcelamento.Enabled := (StrToIntDef(edtParcelas.Text,0)>1);
end;
//**********************************************
procedure TForm1.FormCreate(Sender: TObject);
begin


lblTitulo.text := 'Delphi '+getVersion;
Randomize;
RandomValor;
strArqId:=GetHomePath+ARQ_ID;

IniciaTransacao;

end;
//**********************************************
procedure MostraAprovada;
begin

TDialogService.MessageDialog(
        'Transação aprovada!' + #13#10 +
        'Authorization: '+ transacao.Authorization + #13#10 +
        'ID: ' + transacao.IDTransacao + #13#10 +
        'Produto: ' + transacao.ProdutoSelecionado + #13#10 +
        'Label: ' + transacao.LabelTransacao + #13#10 +
        'STAN: ' + transacao.STAN + #13#10 +
        'AID: ' + transacao.AID + #13#10 +
        'RRN: ' + transacao.RRN + #13#10 +
        'Horario: ' + transacao.Horario+ #13#10 +
        'Version: ' + transacao.Versao+#13#10 +
        'Valor: ' + transacao.Valor+#13#10 +

        'transacao.cardholder='+transacao.cardholder+#13#10 +
        'transacao.prefname='+transacao.prefname+#13#10 +
        'transacao.authorizationType='+transacao.authorizationType+#13#10 +
        'transacao.cardEntry='+transacao.cardEntry+#13#10 +
        'transacao.cvm='+transacao.cvm+#13#10 +
        'transacao.acquirer='+transacao.acquirer+#13#10 +
        'transacao.pan='+transacao.pan+#13#10 +

        'Você deseja imprimir os cupons?',

        System.UITypes.TMsgDlgType.mtInformation,
        [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo],
        System.UITypes.TMsgDlgBtn.mbYes, 0,

      // Use an anonymous method to make sure the acknowledgment appears as expected.
        procedure(const AResult: TModalResult)
        begin
          if(AResult = mrYES)then begin
            PrintStringBold('************[ESTABELECIMENTO]************');
            printCupom(BOLD,transacao.textoImpressoEc);
            PrintString    ('****************[CLIENTE]****************');
            printCupom(BOLD,transacao.textoImpressoCliente);
            printOutput;
          end;

        end);

end;
//************************************************
procedure MostraNegada;
begin

          ShowMessage('Transação negada' + #13#10 +
          'response: ' + inttostr(transacao.response) + #13#10 +
          'Error code: ' + transacao.ErrorCode + #13#10 +
          'Error: ' + transacao.ErrorMsg);
end;
//**********************************************
function objJsonGetValue( var objJson: TJSONObject;Parametro:string):string;

begin
try
    result:=objJson.GetValue<String>(Parametro);
except
    result:='';
end;

end;
//**********************************************
function TForm1.OnActivityResult(RequestCode, ResultCode: Integer; Data:
JIntent): Boolean;
var
  json: JString;
  objJson: TJSONObject;
  CupomImpresso:string;
  iPos:integer;
  strDebug:string;

begin
  Result := False;


  TMessageManager.DefaultManager.Unsubscribe(TMessageResultNotification,
  FMessageSubscriptionID);

  FMessageSubscriptionID := 0;


  if (RequestCode = REQ_CODE) and (ResultCode = TJActivity.JavaClass.RESULT_OK)
and Assigned(Data) then
  begin

    if(TEFExecuteFlag <>0) then exit;//Evita reentrancias
    TEFExecuteFlag :=1;

    try
      transacao.Zera;
      json := Data.getStringExtra(StringToJString(RES_TAG));
      //Debug!! ShowMessage(inttostr(TEFExecuteFlag)+'=>'+JStringToString(json));
      objJson := TJSONObject.ParseJSONValue(JStringToString(json)) as TJSONObject;

      transacao.response := objJson.GetValue<Integer>('response');

      transacao.Versao:=objJsonGetValue(objJson,'version');
      transacao.Status:=objJsonGetValue(objJson,'status');
      transacao.License:=objJsonGetValue(objJson,'license');
      transacao.Terminal:=objJsonGetValue(objJson,'terminal');
      transacao.Merchant:=objJsonGetValue(objJson,'merchant');
      transacao.IDTransacao:=objJsonGetValue(objJson,'id');
      transacao.ProdutoSelecionado:=objJsonGetValue(objJson,'product');
      transacao.Parcelas:=objJsonGetValue(objJson,'installments');
      transacao.TipoParcela:=objJsonGetValue(objJson,'instmode');
      transacao.STAN:=objJsonGetValue(objJson,'stan') ;

      transacao.cardholder:=objJsonGetValue(objJson,'cardholder');
      transacao.prefname:=objJsonGetValue(objJson,'prefname');
      transacao.authorizationType:=objJsonGetValue(objJson,'authorizationType');
      transacao.cardEntry:=objJsonGetValue(objJson,'cardEntry');
      transacao.cvm:=objJsonGetValue(objJson,'cvm');
      transacao.acquirer:=objJsonGetValue(objJson,'acquirer');
      transacao.pan:=objJsonGetValue(objJson,'pan');
      //RC05
      transacao.Tipo:=objJsonGetValue(objJson,'type');
      transacao.Amount:=objJsonGetValue(objJson,'amount');

      if(transacao.response = 0)then begin
        transacao.Authorization :=objJsonGetValue(objJson,'authorization') ;
        transacao.IDTransacao:=objJsonGetValue(objJson,'id');
        //transacao.ProdutoSelecionado:=objJsonGetValue(objJson,'type');
        transacao.LabelTransacao:=objJsonGetValue(objJson,'label');

        transacao.RRN:=objJsonGetValue(objJson,'rrn');
        transacao.AID:=objJsonGetValue(objJson,'aid');
        transacao.Horario:=objJsonGetValue(objJson,'time');

        transacao.Valor:=objJsonGetValue(objJson,'amount');
        CupomImpresso:=objJsonGetValue(objJson,'print');

        iPos:=Pos(FORM_FEED,CupomImpresso);

        if(iPos>0)then begin
          transacao.textoImpressoEc:=copy(CupomImpresso,1,iPos-1);
          transacao.textoImpressoCliente:=copy(CupomImpresso,iPos+2,length(CupomImpresso));
        end else begin
          transacao.textoImpressoEc:=CupomImpresso;
          transacao.textoImpressoCliente:='';
        end;


    end else begin
      transacao.ErrorCode:=objJsonGetValue(objJson,'errcode');
      transacao.ErrorMsg:=objJsonGetValue(objJson,'errmsg');
    end;

    Except on E: Exception do
      begin
        //ShowMessage('Falha na transação');
        transacao.response :=2;
        transacao.ErrorCode:='9999';
        transacao.ErrorMsg:='Falha na transação(Exception) '+E.Message;
        TEFExecuteFlag:= 2;

      end;

    end;//try

    if (TEFExecuteFlag=1)and(transacao.response = 0) then begin
        TThread.Synchronize(nil,
        procedure
        begin
          MostraAprovada;
        end);

    end else begin
        TThread.Synchronize(nil,
        procedure
        begin
         MostraNegada;
        end );
    end;
    //TEFExecuteFlag:=0;
    RandomValor;

  end;


end;
//**********************************************
function BuildJson(Tipo,Id,Amount,Parcelas,TipoParcelamento,Product,HabilitaImpressao:string): JString;
var
  Json: TJSONObject;
  Res: JString;

begin
   try
    Json := TJSONObject.Create;
    Json.AddPair('type', Tipo);
    Json.AddPair('id', Id);
    Json.AddPair('amount', Amount);
    Json.AddPair('installments', Parcelas);
    Json.AddPair('instmode', TipoParcelamento);
    Json.AddPair('product', Product);
    Json.AddPair('receipt', HabilitaImpressao);

    if(transacao.apiversion<>'')then
      Json.AddPair('apiversion', transacao.apiversion);
   finally
    Res := StringToJString(Json.ToString);
    Json.Free;
   end;

   Result := Res;
end;
//**********************************************
procedure TForm1.HandleActivityMessage(const Sender: TObject; const M: TMessage);
begin
 if M is TMessageResultNotification then
     OnActivityResult( TMessageResultNotification( M ).RequestCode, TMessageResultNotification( M ).ResultCode,
                       TMessageResultNotification( M ).Value );
end;

//************************************************
procedure TForm1.ExecuteTEF(Tipo,Id,Amount,Parcelas,TipoParcelamento,Product,HabilitaImpressao:string);
var
Intent:JIntent;
JSON:JString;
DeviceType:String;


begin

if(transacao = nil) then begin
  transacao:= TGER7TEF.Create;
end;




  DeviceType := JStringToString(TJBuild.JavaClass.MODEL);

  if(Trim(DeviceType) <> 'GPOS700')and (Trim(DeviceType)<>'Smart G800')then begin
    transacao.Zera;
    transacao.response :=2;
    transacao.ErrorCode:='9997';
    transacao.ErrorMsg:='Modelo nao suportado';
    TEFExecuteFlag:= 1;
    exit;
  end;


Intent := TJIntent.JavaClass.init(
TJIntent.JavaClass.ACTION_VIEW,TJnet_Uri.JavaClass.parse(StringToJString(REQ_URI)));

JSON:= BuildJson(Tipo,Id,Amount,Parcelas,TipoParcelamento,Product,HabilitaImpressao);
Intent.putExtra(StringToJString(REQ_TAG), JSON);

TMessageManager.DefaultManager.SubscribeToMessage(TMessageResultNotification, HandleActivityMessage);

TEFExecuteFlag :=0;
TAndroidHelper.Activity.startActivityForResult(Intent, REQ_CODE);

end;
//**********************************************
procedure TForm1.cmdEnviarTransacaoClick(Sender: TObject);
var

Produto,
HabilitaImpressao,
Parcelas,TipoParcelamento:String;

begin

try

  if(chkImpressao.IsChecked)then
    HabilitaImpressao:=GER7_HABILITA_IMPRESSAO
  else
    HabilitaImpressao:=GER7_DESABILITA_IMPRESSAO;

  if rdgProdutos.IsChecked then begin
    Produto:=GER7_CREDITO
  end else if rdgDebito.IsChecked then begin
    Produto:=GER7_DEBITO
  end else if rdgVoucher.IsChecked then begin
    Produto:=GER7_VOUCHER
  end;


  Parcelas:= IntToStr(StrToIntDef(edtParcelas.Text,0));


  if((Parcelas='0')or(Parcelas='1'))then begin
    TipoParcelamento :=GER7_SEMPARCELAMENTO;
  end else begin
    if rdgParceladoLoja.IsChecked then begin
      TipoParcelamento :=GER7_PARCELADO_LOJA;
    end else if rdgParceladoAdm.IsChecked then begin
      TipoParcelamento :=GER7_PARCELADO_ADM;
    end;
  end;


  IniciaTransacao;
//  transacao.SetaDebug(true);

  IncrementaId; //Colocar aqui o seu tratamento do Id!!
  ExecuteTEF(GER7_VENDA,strId,Numeric(edtValor.text),Parcelas,TipoParcelamento,Produto,HabilitaImpressao);

except
  on e: exception do begin
  ShowMessage('Erro=>'+e.Message);
end;

end;

end;
//**********************************************

procedure TForm1.cmdCancelarTransacaoClick(Sender: TObject);
var
    HabilitaImpressao:string;

begin
try
  if(chkImpressao.IsChecked)then
    HabilitaImpressao:=GER7_HABILITA_IMPRESSAO
  else
    HabilitaImpressao:=GER7_DESABILITA_IMPRESSAO;

    IncrementaId; //Colocar aqui o seu tratamento do Id!!
    ExecuteTEF(GER7_CANCELAMENTO,strId,'','','','',HabilitaImpressao);
  except
    on e: exception do begin
    ShowMessage('ErroTr=>'+e.Message);
  end;

  end;

end;
//**********************************************
procedure TForm1.FuncoesDiversas(Funcao:String);
begin
  try

    IncrementaId; //Colocar aqui o seu tratamento do Id!!
    ExecuteTEF(Funcao,strId,'','','','','1');

  except
    on e: exception do begin
    ShowMessage('ErroTr=>'+e.Message);
    end;
  end;

end;
//**********************************************
procedure TForm1.cmdFuncoesClick(Sender: TObject);
begin
FuncoesDiversas(GER7_FUNCOES);
end;
//**********************************************
procedure TForm1.cmdReimpressaoClick(Sender: TObject);
var
strAux:string;
begin
FuncoesDiversas(GER7_REIMPRESSAO);
{strAux:=strAux+
'transacao.getApiVersion='+transacao.getApiVersion+#13#10+
'transacao.getPos7Version='+transacao.getPos7Version+#13#10+
'transacao.getTerminalId='+transacao.getTerminalId+#13#10+
'transacao.getMerchantId='+transacao.getMerchantId+#13#10+
'transacao.getResType='+transacao.getResType+#13#10+
'transacao.getResProduct='+transacao.getResProduct+#13#10+
'transacao.getResponse='+transacao.getResponse+#13#10+
'transacao.getResAuthorization='+transacao.getResAuthorization+#13#10+
'transacao.getResAmount='+transacao.getResAmount+#13#10+
'transacao.getResStan='+transacao.getResStan+#13#10+
'transacao.getResRrn='+transacao.getResRrn+#13#10+
'transacao.getResTime='+transacao.getResTime+#13#10+
'transacao.getResErrorCode='+transacao.getResErrorCode+#13#10;

ShowMessage(strAux);
}

end;

//************************************************
procedure TForm1.RandomValor;
var strAux:string;
    i:integer;
begin
for i := 1 to 3 do begin
    strAux:=strAux+chr(48+random(10));
    if(i=1)then strAux:=strAux+',';
end;
edtValor.text := strAux;

end;
//************************************************

end.
