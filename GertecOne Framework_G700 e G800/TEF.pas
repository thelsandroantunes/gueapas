unit TEF;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Colors,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Types, FMX.Edit, FMX.EditBox,
  FMX.NumberBox,

  FMX.DialogService,

  System.IOUtils,
  System.Character,
  System.Generics.Collections,
  System.UIConsts, 
  System.Threading,

  Androidapi.Jni.Net,       //Required
  Androidapi.JNI.JavaTypes, //Required
  Androidapi.Helpers,       //Required
  Androidapi.JNI.GraphicsContentViewText, //Required
  Androidapi.JNI.App,       //Required
  System.Messaging,         //Required
  System.JSON,               //Required
  Androidapi.JNI.OS,        //Required

  G700Interface,
  GEDIPrinterTEF,
  GER7TEF,
  FMX.Surfaces;


const

  NORMAL = false;
  BOLD = true;

  COMANDO_VENDA = '1';
  COMANDO_CANCELAMENTO = '2';
  COMANDO_FUNCOES = '3';
  COMANDO_REIMPRESSAO = '4';

  FLAG_DESABILITA_IMPRESSAO = '0';
  FLAG_HABILITA_IMPRESSAO = '1';

  PRODUTO_TODOS = '0';
  PRODUTO_CREDITO = '1';
  PRODUTO_DEBITO = '2';


  PARCELAMENTO_NONE = '0';
  PARCELAMENTO_LOJA = '1';
  PARCELAMENTO_ADM = '3';

  REQ_CODE = 4321;
//  REQ_CODE = 4713;

  EXAMPLE_VERSION = 'V0.0';

  //Ger7
  GER7_ARQ_ID = '\id.dat';
  GER7_REQ_URI = 'pos7api://pos7';
  GER7_REQ_TAG = 'jsonReq';
  GER7_RES_TAG ='jsonResp';

  API_GER7 = '0';
  API_MSITEF = '1';

type
  TfrmTEF = class(TForm)
    PanelTitulo: TPanel;
    lblTitulo: TLabel;
    StyleBook1: TStyleBook;
    PanelValorIP: TPanel;
    edtIPServidor: TEdit;
    edtValor: TEdit;
    lblValor: TLabel;
    lblIP: TLabel;
    PanelPagamento: TPanel;
    edtParcelas: TNumberBox;
    GroupBox1: TGroupBox;
    rdgCredito: TRadioButton;
    rdgDebito: TRadioButton;
    rdgTodos: TRadioButton;
    lblParcelas: TLabel;
    PanelAPI: TPanel;
    PanelFuncao: TPanel;
    cmdEnviarTransacao: TButton;
    cmdCancelarTransacao: TButton;
    cmdFuncoes: TButton;
    cmdReimpressao: TButton;
    chkImpressao: TCheckBox;
    grpParcelamento: TGroupBox;
    rdgParceladoLoja: TRadioButton;
    rdgParceladoAdm: TRadioButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    lblAPI: TLabel;


    procedure cmdEnviarTransacaoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtParcelasKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure cmdCancelarTransacaoClick(Sender: TObject);
    procedure cmdFuncoesClick(Sender: TObject);

    procedure RandomValor;
    procedure cmdReimpressaoClick(Sender: TObject);
    procedure FuncoesDiversas(Funcao:String);
    function fHabilitaImpressao:string;

    function OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent): Boolean;
    procedure HandleActivityMessage(const Sender: TObject; const M: TMessage);
    procedure ExecuteSiTEF(Tipo,NotUsed,Amount,Parcelas,TipoParcelamento,Product,HabilitaImpressao:string);
    procedure ExecuteTEF(Tipo,Id,Amount,Parcelas,TipoParcelamento,Product,HabilitaImpressao:string);
    procedure edtParcelasChange(Sender: TObject);


    procedure CleanTextTEF(limpaText: Boolean);
    procedure rdgTefMChange(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);


  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTEF: TfrmTEF;
  ExecFlag:boolean;//Evita entrada em redundancia
  FMessageSubscriptionID:integer;

  strId:string;
  strArqId:string;

  TEFExecuteFlag :integer;
  transacao:TGER7TEF;


implementation

{$R *.fmx}

//==========================================
procedure TfrmTEF.CheckBox1Change(Sender: TObject);
begin

  if CheckBox1.IsChecked then CheckBox2.IsChecked := False;
end;

procedure TfrmTEF.CheckBox2Change(Sender: TObject);
begin
  if CheckBox2.IsChecked then CheckBox1.IsChecked := False;
end;

procedure TfrmTEF.CleanTextTEF(limpaText: Boolean);
begin
  if limpaText then
  begin


  end;
end;

//**********************************************
procedure IniciaTransacao;
begin
if(transacao = nil) then begin
  transacao:= TGER7TEF.Create('1.05');
end;
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

//==========================================================
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

//==========================================================
procedure TfrmTEF.edtParcelasChange(Sender: TObject);
begin
grpParcelamento.Enabled := (StrToIntDef(edtParcelas.Text,0)>1);
end;

//==========================================================
procedure TfrmTEF.edtParcelasKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
grpParcelamento.Enabled := (StrToIntDef(edtParcelas.Text,0)>1);
end;

//==========================================================
procedure TfrmTEF.FormCreate(Sender: TObject);
begin

//lblTitulo.text := 'Exemplo TEF API-Delphi '+EXAMPLE_VERSION;

Randomize;
RandomValor;

ExecFlag := false;
end;

//==========================================================
function GetExtraData(Data:JIntent;Campo:String):String;
begin
    result := Campo+' = '+JStringToString(Data.getStringExtra(StringToJString(Campo)))
end;

//==========================================================
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

//==========================================================
function RetornaTipoParcelamento(Valor:string):string;
var iValor:integer;
begin
iValor:=StrToIntDef(Valor,4);

case iValor of
  0: result :=  'A vista';
  1:result := 'Pré-Datado';
  2:result := 'Parcelado Loja';
  3:result := 'Parcelado Adm';
  else result := 'Valor invalido';
end;//case

end;

//==========================================================
procedure MostraAprovada(Data:Jintent);

begin

TDialogService.MessageDialog(
//ShowMessage(
    'Transação aprovada!' + #13#10 +
    GetExtraData(Data,'CODRESP')+#13#10+
    GetExtraData(Data,'COMP_DADOS_CONF')+#13#10+
    GetExtraData(Data,'CODTRANS')+#13#10+
    GetExtraData(Data,'TIPO_PARC')+' ('+
    RetornaTipoParcelamento(JStringToString(Data.getStringExtra(StringToJString('TIPO_PARC'))))+')'+#13#10+
    GetExtraData(Data,'VLTROCO')+#13#10+
    GetExtraData(Data,'REDE_AUT')+#13#10+
    GetExtraData(Data,'BANDEIRA')+#13#10+
    GetExtraData(Data,'NSU_SITEF')+#13#10+
    GetExtraData(Data,'NSU_HOST')+#13#10+
    GetExtraData(Data,'COD_AUTORIZACAO')+#13#10+
    GetExtraData(Data,'NUM_PARC')+#13#10+
        'Você deseja imprimir os cupons?',

        System.UITypes.TMsgDlgType.mtInformation,
        [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo],
        System.UITypes.TMsgDlgBtn.mbYes, 0,

      // Use an anonymous method to make sure the acknowledgment appears as expected.
        procedure(const AResult: TModalResult)
        var CupomImpresso:string;
        begin
          if(AResult = mrYES)then begin

            CupomImpresso:=JStringToString(Data.getStringExtra(StringToJString('VIA_ESTABELECIMENTO')));
            if(Trim(CupomImpresso)<>'')then begin
              PrintStringBold('**********[ESTABELECIMENTO]***********');
              printCupom2(BOLD,CupomImpresso,30);
            end;

            CupomImpresso:=JStringToString(Data.getStringExtra(StringToJString('VIA_CLIENTE')));
            if(Trim(CupomImpresso)<>'')then begin
              PrintString    ('**************[CLIENTE]***************');
              printCupom2(BOLD,CupomImpresso,150);
            end;
          end;

        end);

end;

//==========================================================
procedure MostraNegada(Data:Jintent);

begin

ShowMessage(
    'm-SiTef Nao Executado!' + #13#10 +
    GetExtraData(Data,'CODRESP'));
end;

//==========================================================
function TfrmTEF.fHabilitaImpressao:string;
begin
  if(chkImpressao.IsChecked)then
    result:=FLAG_HABILITA_IMPRESSAO
  else
    result:=FLAG_DESABILITA_IMPRESSAO;
end;

//==========================================================
procedure TfrmTEF.cmdEnviarTransacaoClick(Sender: TObject);
var

Produto,
Parcelas,TipoParcelamento:String;

begin


    try

      if rdgTodos.IsChecked then begin
        Produto:=PRODUTO_TODOS;
      end else if rdgCredito.IsChecked then begin
        Produto:=PRODUTO_CREDITO;
      end else if rdgDebito.IsChecked then begin
        Produto:=PRODUTO_DEBITO;
      end;


      Parcelas:= IntToStr(StrToIntDef(edtParcelas.Text,0));


      if((Parcelas='0')or(Parcelas='1'))then begin
        TipoParcelamento :=PARCELAMENTO_NONE;
      end else begin
        if rdgParceladoLoja.IsChecked then begin
          TipoParcelamento :=PARCELAMENTO_LOJA;
        end else if rdgParceladoAdm.IsChecked then begin
          TipoParcelamento :=PARCELAMENTO_ADM;
        end;
      end;

      //xxxxxxxxxxxxxxxxxxxxxxxxx


      if CheckBox2.IsChecked then
      begin
        ExecuteSiTEF(COMANDO_VENDA,'',Numeric(edtValor.text),Parcelas,TipoParcelamento,Produto,fHabilitaImpressao);
      end else
      begin
        IniciaTransacao;
        //transacao.SetaDebug(true);

        IncrementaId; //
        ExecuteTEF(COMANDO_VENDA,strId,Numeric(edtValor.text),Parcelas,TipoParcelamento,Produto,fHabilitaImpressao);
      end;

    except
      on e: exception do begin
      ShowMessage('Erro Transacao =>'+e.Message);
    end;

    end;

end;

//**********************************************
procedure TfrmTEF.cmdCancelarTransacaoClick(Sender: TObject);

begin
try
  FuncoesDiversas(COMANDO_CANCELAMENTO);
  except
    on e: exception do begin
    ShowMessage('Erro Cancelamento =>'+e.Message);
  end;

  end;

end;

//**********************************************
procedure TfrmTEF.FuncoesDiversas(Funcao:String);
begin
  try
    ExecuteSiTEF(Funcao,'','','','','',fHabilitaImpressao);
  except
    on e: exception do begin
    ShowMessage('Erro Funcoes =>'+e.Message);
    end;
  end;

end;

//**********************************************
procedure TfrmTEF.cmdFuncoesClick(Sender: TObject);
begin
FuncoesDiversas(COMANDO_FUNCOES);
end;

//**********************************************
procedure TfrmTEF.cmdReimpressaoClick(Sender: TObject);
begin
FuncoesDiversas(COMANDO_REIMPRESSAO);
end;

//************************************************
procedure TfrmTEF.RandomValor;
var strAux:string;
    i:integer;
begin
for i := 1 to 3 do begin
    strAux:=strAux+chr(48+random(10));
    if(i=1)then strAux:=strAux+',';
end;
edtValor.text := strAux;

end;


procedure TfrmTEF.rdgTefMChange(Sender: TObject);
begin

end;

//**********************************************
function TfrmTEF.OnActivityResult(RequestCode, ResultCode: Integer; Data:
                  JIntent): Boolean;
begin

  Result := False;
  TMessageManager.DefaultManager.Unsubscribe(TMessageResultNotification, FMessageSubscriptionID);
  FMessageSubscriptionID := 0;


  if RequestCode = REQ_CODE then begin

    if ResultCode = TJActivity.JavaClass.RESULT_OK then begin

      if Assigned(Data) then begin


        if(ExecFlag) then begin
          ExecFlag :=false;
                TThread.Synchronize(nil,
                  procedure
                  begin
                    MostraAprovada(Data);
                  end);

          RandomValor;
        end;
      end;
    end else if ResultCode = TJActivity.JavaClass.RESULT_CANCELED then begin
      if(ExecFlag) then begin
        //ShowMessage('m-SiTef Nao Executado!');
        MostraNegada(Data);
        ExecFlag :=false;
      end;
    end else begin
      if(ExecFlag) then begin
        ShowMessage('m-SiTef Outro Codigo');
        ExecFlag :=false;
      end;

      ShowMessage('m-SiTef Outro Codigo')
    end;
    RandomValor;

    Result := True;
  end;

end;

//**********************************************
procedure TfrmTEF.HandleActivityMessage(const Sender: TObject; const M: TMessage);
begin
 if M is TMessageResultNotification then
     OnActivityResult( TMessageResultNotification( M ).RequestCode, TMessageResultNotification( M ).ResultCode,
                       TMessageResultNotification( M ).Value );
end;

//**********************************************
//==========================================================
procedure TfrmTEF.ExecuteSiTEF(Tipo,NotUsed,Amount,Parcelas,TipoParcelamento,Product,HabilitaImpressao:string);
var
  Intent : JIntent;
begin

  ExecFlag :=true;
  Intent := TJIntent.JavaClass.init(StringToJString('br.com.softwareexpress.sitef.msitef.ACTIVITY_CLISITEF'));

  Intent.putExtra(StringToJString('empresaSitef'), StringToJString('00000000'));
  Intent.putExtra(StringToJString('enderecoSitef'), StringToJString(edtIPServidor.Text));
  Intent.putExtra(StringToJString('operador'), StringToJString('0001'));
  Intent.putExtra(StringToJString('data'), StringToJString(FormatDateTime('yyyyMMdd',Date)));
  Intent.putExtra(StringToJString('hora'), StringToJString(FormatDateTime('hhmmss',Time)));
  Intent.putExtra(StringToJString('numeroCupom'), StringToJString('1234'));


  Intent.putExtra(StringToJString('valor'), StringToJString(Amount));
  Intent.putExtra(StringToJString('CNPJ_CPF'), StringToJString('03654119000176'));
  Intent.putExtra(StringToJString('comExterna'), StringToJString('0'));

  case Tipo[0] of
    COMANDO_VENDA:begin
      if Product= PRODUTO_CREDITO then begin
        Intent.putExtra(StringToJString('modalidade'), StringToJString('3'));
        case TipoParcelamento[0] of
          PARCELAMENTO_NONE:begin
            Intent.putExtra(StringToJString('transacoesHabilitadas'), StringToJString('26'));
          end;
          PARCELAMENTO_LOJA:begin
            Intent.putExtra(StringToJString('transacoesHabilitadas'), StringToJString('27'));
          end;
          PARCELAMENTO_ADM:begin
            Intent.putExtra(StringToJString('transacoesHabilitadas'), StringToJString('28'));
          end;
        end;//case
        Intent.putExtra(StringToJString('numParcelas'), StringToJString(Parcelas));

      end else if Product= PRODUTO_DEBITO then begin
        Intent.putExtra(StringToJString('modalidade'), StringToJString('2'));
        Intent.putExtra(StringToJString('transacoesHabilitadas'), StringToJString('16'));
      end else if Product= PRODUTO_TODOS then begin
        Intent.putExtra(StringToJString('modalidade'), StringToJString('0'));
        Intent.putExtra(StringToJString('restricoes'), StringToJString('transacoesHabilitadas=16'));
      end;
    end;

    COMANDO_CANCELAMENTO:begin
      Intent.putExtra(StringToJString('modalidade'), StringToJString('200'));
    end;

    COMANDO_FUNCOES:begin
      Intent.putExtra(StringToJString('modalidade'), StringToJString('110'));
      Intent.putExtra(StringToJString('restricoes'), StringToJString('transacoesHabilitadas=16;26;27'));
    end;

    COMANDO_REIMPRESSAO:begin
      Intent.putExtra(StringToJString('modalidade'), StringToJString('114'));
    end;

  end;


  Intent.putExtra(StringToJString('isDoubleValidation'), StringToJString('0'));
  Intent.putExtra(StringToJString('caminhoCertificadoCA'), StringToJString('ca_cert_perm'));
  Intent.putExtra(StringToJString('comprovante'), StringToJString(HabilitaImpressao));


  TMessageManager.DefaultManager.SubscribeToMessage(TMessageResultNotification, HandleActivityMessage);
  TAndroidHelper.Activity.startActivityForResult(Intent, REQ_CODE);

end;

//**********************************************
//==========================================================
procedure TfrmTEF.ExecuteTEF(Tipo,Id,Amount,Parcelas,TipoParcelamento,Product,HabilitaImpressao:string);
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
TJIntent.JavaClass.ACTION_VIEW,TJnet_Uri.JavaClass.parse(StringToJString(GER7_REQ_URI)));

JSON:= BuildJson(Tipo,Id,Amount,Parcelas,TipoParcelamento,Product,HabilitaImpressao);
Intent.putExtra(StringToJString(GER7_REQ_TAG), JSON);

TMessageManager.DefaultManager.SubscribeToMessage(TMessageResultNotification, HandleActivityMessage);

TEFExecuteFlag :=0;
TAndroidHelper.Activity.startActivityForResult(Intent, REQ_CODE);

end;



end.
