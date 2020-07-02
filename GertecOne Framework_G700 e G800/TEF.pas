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

  GER7TEF,
  G700Interface,
  GEDIPrinterTEF,
  FMX.Surfaces,

  FMX.Platform,

  System.RegularExpressions, FMX.Layouts;


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

  EXAMPLE_VERSION = 'V0.0';

  //Ger7
  GER7_ARQ_ID = '\id.dat';
  GER7_REQ_URI = 'pos7api://pos7';
  GER7_REQ_TAG = 'jsonReq';
  GER7_RES_TAG ='jsonResp';
  GER7_FORM_FEED = #12;
  GER7_REQ_CODE = 4713;
  GER7_REIMPRESSAO = '18';
  GER7_VOUCHER = '4';
  GER7_PARCELADO_ADM = '2';
  VERSION = 'GER7TEF Api UEA';

  API_GER7 = '0';
  API_MSITEF = '1';

type
  TfrmTEF = class(TForm)
    PanelTitulo: TPanel;
    lblTitulo: TLabel;
    StyleBook1: TStyleBook;
    edtIPServidor: TEdit;
    edtValor: TEdit;
    lblValor: TLabel;
    lblIP: TLabel;
    edtParcelas: TNumberBox;
    GroupBox1: TGroupBox;
    rdgCredito: TRadioButton;
    rdgDebito: TRadioButton;
    rdgTodos: TRadioButton;
    lblParcelas: TLabel;
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
    VertScrollBox1: TVertScrollBox;
    Panel1: TPanel;
    Edit2: TEdit;
    Edit1: TEdit;
    Label1: TLabel;


    procedure cmdEnviarTransacaoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtParcelasKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure cmdCancelarTransacaoClick(Sender: TObject);
    procedure cmdFuncoesClick(Sender: TObject);


    procedure cmdReimpressaoClick(Sender: TObject);
    procedure FuncoesDiversas(Funcao:String);
    function fHabilitaImpressao:string;

    function OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent): Boolean;
    procedure HandleActivityMessage(const Sender: TObject; const M: TMessage);
    procedure ExecuteSiTEF(Tipo,NotUsed,Amount,Parcelas,TipoParcelamento,Product,HabilitaImpressao:string);
    procedure ExecuteTEF(Tipo,Id,Amount,Parcelas,TipoParcelamento,Product,HabilitaImpressao:string);
    procedure edtIPChange(Sender: TObject);


    procedure CleanTextTEF(limpaText: Boolean);

    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);

    procedure edtValorChange(Sender: TObject);
    procedure FormatarMoeda( Componente : TObject {;var Key: Char} );
    procedure rdgDebitoChange(Sender: TObject);
    procedure rdgCreditoChange(Sender: TObject);

    procedure rdgTodosChange(Sender: TObject);
    procedure edtIPServidorChangeTracking(Sender: TObject);
    procedure VertScrollBox1Click(Sender: TObject);
    procedure MSITEFChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);


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


  constFunc:integer;
  cip: integer;

  //auxiliares
  teste, auxGER7, auxMSITEF:string;

  auxTransacao:TGER7TEF;
  contR: integer;
  auxR, contREIMP:string;

implementation

{$R *.fmx}

 //***********************************************

Procedure TfrmTEF.FormatarMoeda( Componente : TObject {;var Key: Char} );
var
   valor_str  : String;
   valor  : double;
begin

        if Componente is TEdit then
        begin
                // Se tecla pressionada é um numero, backspace ou delete...
                //if ( Key in ['0'..'9', #8, #9] ) then
                //begin
                         // Salva valor do edit...
                         valor_str := TEdit( Componente ).Text;

                         // Valida vazio...
                         if valor_str = EmptyStr then
                                valor_str := '0,00';

                         // Se valor numerico, insere na string...
                         {if Key in ['0'..'9'] then
                                valor_str := Concat( valor_str, Key ) ;}

                         // Retira pontos e virgulas...
                         valor_str := Trim( StringReplace( valor_str, '.', '', [rfReplaceAll, rfIgnoreCase] ) ) ;
                         valor_str := Trim( StringReplace( valor_str, ',', '', [rfReplaceAll, rfIgnoreCase] ) ) ;

                         // Inserindo 2 casas decimais...
                         valor := StrToFloat( valor_str ) ;
                         valor := ( valor / 100 ) ;

                         // Retornando valor tratado ao edit...
                         TEdit( Componente ).Text := FormatFloat( '###,##0.00', valor ) ;

                         // Reposiciona cursor...
                         TEdit( Componente ).SelStart := Length( TEdit( Componente ).Text );
                //end;

                // Se nao é key importante, reseta...
                {if Not( Key in [#8, #9] ) then
                        key := #0;}
        end;

end;
function IsWrongIP(ip: string): Boolean;
var
  z, i: byte;
  st: array[1..3] of byte;
const
  ziff = ['0'..'9'];
begin
  st[1]  := 0;
  st[2]  := 0;
  st[3]  := 0;
  z      := 0;
  Result := False;
  for i := 1 to Length(ip) do if ip[i] in ziff then
  else
  begin
    if ip[i] = '.' then
    begin
      Inc(z);
      if z < 4 then st[z] := i
      else
      begin
        IsWrongIP := True;
        Exit;
      end;
    end
    else
    begin
      IsWrongIP := True;
      Exit;
    end;
  end;
  if (z <> 3) or (st[1] < 2) or (st[3] = Length(ip)) or (st[1] + 2 > st[2]) or
    (st[2] + 2 > st[3]) or (st[1] > 4) or (st[2] > st[1] + 4) or (st[3] > st[2] + 4) then
  begin
    IsWrongIP := True;
    Exit;
  end;
  z := StrToInt(Copy(ip, 1, st[1] - 1));
  if (z > 255) or (ip[1] = '0') then
  begin
    IsWrongIP := True;
    Exit;
  end;
  z := StrToInt(Copy(ip, st[1] + 1, st[2] - st[1] - 1));
  if (z > 255) or ((z <> 0) and (ip[st[1] + 1] = '0')) then
  begin
    IsWrongIP := True;
    Exit;
  end;
  z := StrToInt(Copy(ip, st[2] + 1, st[3] - st[2] - 1));
  if (z > 255) or ((z <> 0) and (ip[st[2] + 1] = '0')) then
  begin
    IsWrongIP := True;
    Exit;
  end;
  z := StrToInt(Copy(ip, st[3] + 1, Length(ip) - st[3]));
  if (z > 255) or ((z <> 0) and (ip[st[3] + 1] = '0')) then
  begin
    IsWrongIP := True;
    Exit;
  end;
end;

//==========================================
procedure TfrmTEF.Button1Click(Sender: TObject);
begin



     TDialogService.MessageDialog('Deseja realizar a impressão pela aplicação?'+#13#10,
      System.UITypes.TMsgDlgType.mtInformation,
      [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], System.UITypes.TMsgDlgBtn.mbYes, 0,
       procedure(const AResult: TModalResult)
       begin
        if(AResult = mrYES)then
        begin

          ShowMessage('afasdfjkhlk');

        end;
       end
      );
end;

procedure TfrmTEF.CheckBox1Change(Sender: TObject);
begin

  if CheckBox1.IsChecked then
  begin
    CheckBox2.IsChecked := False;
    edtIPServidor.Enabled := False;
     auxGER7 := auxGER7;
     auxMSITEF := auxMSITEF;

      auxTransacao:=auxTransacao;
  end;
end;
procedure TfrmTEF.CheckBox2Change(Sender: TObject);
begin
  if CheckBox2.IsChecked then
  begin
    CheckBox1.IsChecked := False;
    edtIPServidor.Enabled := True;
  end;
end;
procedure TfrmTEF.CleanTextTEF(limpaText: Boolean);
begin
  if limpaText then
  begin
      edtParcelas.Text := '1';
      cip := 0;
      contR := -1;

  end;
end;
//**********************************************
function getVersion:string;
begin
  result:=VERSION;
end;
Procedure SaveId;
var Arq:textfile;
begin
  AssignFile(arq,strArqId);
  rewrite(Arq);
  writeln(Arq,strId);
  closefile(Arq);

end;
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
    end
    else
    begin
      //Se nao existir, inicializa em 1
      strId := '1';
    end;

    SaveId;
end;
function Numeric(strValor:string):string;
//Devolve somente caracteres numericos da String
//Ex: 1,23=>123
//Ex:1,2 =>120
var
i,iPos:integer;
ch:char;
strEdtValor, strResult:string;

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
procedure IniciaTransacao;
begin
  if(transacao = nil) then begin
    transacao:= TGER7TEF.Create('1.05');
  end;
end;
function objJsonGetValue( var objJson: TJSONObject;Parametro:string):string;

begin
try
    result:=objJson.GetValue<String>(Parametro);
except
    result:='';
end;

end;
//**********************************************
//==========================================================
function removevazio(texto : String) : Integer;
var
cont:Integer;
begin
  cont := 0;
  While pos(' ', Texto) <> 0 Do
    cont := cont + 1;
    delete(Texto,pos(' ', Texto),1);

  Result := cont;
end;
//==========================================================
procedure TfrmTEF.edtIPChange(Sender: TObject);
begin
  grpParcelamento.Enabled := (StrToIntDef(edtParcelas.Text,0)>1);
end;
procedure TfrmTEF.edtIPServidorChangeTracking(Sender: TObject);
begin
  cip:= 1;
end;

procedure TfrmTEF.edtParcelasKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  grpParcelamento.Enabled := (StrToIntDef(edtParcelas.Text,0)>1);
end;
procedure TfrmTEF.edtValorChange(Sender: TObject);
begin
  FormatarMoeda(edtValor);
end;
//==========================================================
procedure TfrmTEF.FormCreate(Sender: TObject);
begin


 //   System.Classes.pidAndroid64Arm := '$ffffffff';
//lblTitulo.text := 'Exemplo TEF API-Delphi '+EXAMPLE_VERSION;
  // Default is transient, change to make permanent
  //SaveState.StoragePath := TPath.GetHomePath;
   // edtMax.Text := 'No SaveState';
//Randomize;
//RandomValor;
  strArqId:=GetHomePath+GER7_ARQ_ID;

  IniciaTransacao;

  ExecFlag := false;
end;
function GetExtraData(Data:JIntent;Campo:String):String;
begin
    result := Campo+' = '+JStringToString(Data.getStringExtra(StringToJString(Campo)))
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
procedure MostraAprovada(Data:Jintent);

begin

  //reimpressão
  if contR = 2 then
  begin
     TDialogService.MessageDialog('Deseja realizar a impressão pela aplicação?'+#13#10,
      System.UITypes.TMsgDlgType.mtConfirmation,
      [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], System.UITypes.TMsgDlgBtn.mbYes, 0,
       procedure(const AResult: TModalResult)
       begin
        if(AResult = mrYES)then
        begin


          if(Trim(JStringToString(Data.getStringExtra(StringToJString('VIA_ESTABELECIMENTO'))))<>'')then begin
            PrintStringBold('**********[ESTABELECIMENTO]***********');
            printCupom2(BOLD,JStringToString(Data.getStringExtra(StringToJString('VIA_ESTABELECIMENTO'))),30);
          end;


          if(Trim(JStringToString(Data.getStringExtra(StringToJString('VIA_CLIENTE'))))<>'')then begin
            PrintString    ('*************[CLIENTE]***************');
            printCupom2(BOLD,JStringToString(Data.getStringExtra(StringToJString('VIA_CLIENTE'))),150);
          end;
        end;
       end
      );
  end;

  //enviar
  if contR = 3 then
  begin

    auxMSITEF := 'Transação aprovada!' + #13#10 +
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
      GetExtraData(Data,'NUM_PARC')+#13#10;



    TDialogService.MessageDialog(
    'Ação executada com sucesso!' + #13#10 +
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
      GetExtraData(Data,'NUM_PARC')+#13#10,
    System.UITypes.TMsgDlgType.mtInformation,
    [System.UITypes.TMsgDlgBtn.mbOk], System.UITypes.TMsgDlgBtn.mbOk, 0,
     procedure(const AResult: TModalResult)
          var CupomImpresso:string;
          begin

            if(AResult = mrOk)then
            begin
              TDialogService.MessageDialog('Deseja realizar a impressão pela aplicação?'+#13#10,
              System.UITypes.TMsgDlgType.mtConfirmation,
              [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], System.UITypes.TMsgDlgBtn.mbYes, 0,
               procedure(const AResult: TModalResult)
               begin
                if(AResult = mrYES)then
                begin

                  CupomImpresso:=JStringToString(Data.getStringExtra(StringToJString('VIA_ESTABELECIMENTO')));
                  if(Trim(CupomImpresso)<>'')then begin
                    PrintStringBold('**********[ESTABELECIMENTO]***********');
                    printCupom2(BOLD,CupomImpresso,30);
                  end;

                  CupomImpresso:=JStringToString(Data.getStringExtra(StringToJString('VIA_CLIENTE')));
                  if(Trim(CupomImpresso)<>'')then begin
                    PrintString    ('*************[CLIENTE]***************');
                    printCupom2(BOLD,CupomImpresso,150);
                  end;
                end;
               end
              );
     //       System.Close;
            end;

          end);
  end;

end;
procedure MostraNegada(Data:Jintent);

begin
  if contREIMP = 'NOT_REIMP' then
  else
  begin
    ShowMessage(
     'Ocorreu um erro durante a execução!' + #13#10 +
      GetExtraData(Data,'CODRESP'));
  end;


end;
procedure MostraAprovadaGER7;
begin

    //reimpressão
    if contR = 0 then
    begin
      TDialogService.MessageDialog('Deseja realizar a impressão pela aplicação?'+#13#10, System.UITypes.TMsgDlgType.mtConfirmation,
      [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], System.UITypes.TMsgDlgBtn.mbYes, 0,
       procedure(const AResult: TModalResult)
       begin
        if(AResult = mrYES)then
        begin

            PrintStringBold('**********[ESTABELECIMENTO]***********');
            printCupom(BOLD,transacao.textoImpressoEc);
            PrintString    ('*************[CLIENTE]***************');
            printCupom(BOLD,transacao.textoImpressoCliente);
            printOutput;
        end;
       end
      );
    end;


    //enviar
    if contR = 1 then
    begin

       //frmTEF.edtMax.Text := 'A => ' + auxGER7;

        TDialogService.MessageDialog(
    'Ação executada com sucesso' + #13#10 +
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
          'Parcelas: ' + transacao.Parcelas+#13#10 +

          'transacao.cardholder='+transacao.cardholder+#13#10 +
          'transacao.prefname='+transacao.prefname+#13#10 +
          'transacao.authorizationType='+transacao.authorizationType+#13#10 +
          'transacao.cardEntry='+transacao.cardEntry+#13#10 +
          'transacao.cvm='+transacao.cvm+#13#10 +
          'transacao.acquirer='+transacao.acquirer+#13#10 +
          'transacao.pan='+transacao.pan+#13#10,
     System.UITypes.TMsgDlgType.mtInformation,
     [System.UITypes.TMsgDlgBtn.mbOk], System.UITypes.TMsgDlgBtn.mbOk, 0,
     procedure(const AResult: TModalResult)
          var CupomImpresso:string;
          begin

            if(AResult = mrOk)then
            begin
              TDialogService.MessageDialog('Deseja realizar a impressão pela aplicação'+#13#10, System.UITypes.TMsgDlgType.mtConfirmation,
              [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], System.UITypes.TMsgDlgBtn.mbYes, 0,
               procedure(const AResult: TModalResult)
               begin
                if(AResult = mrYES)then
                begin

                    PrintStringBold('**********[ESTABELECIMENTO]***********');
                    printCupom(BOLD,transacao.textoImpressoEc);
                    PrintString    ('*************[CLIENTE]***************');
                    printCupom(BOLD,transacao.textoImpressoCliente);
                    printOutput;
                end;
               end
              );
     //       System.Close;
            end;

          end);
    end;

end;
procedure MostraNegadaGER7;
begin
    ShowMessage('Ocorreu um erro durante a execução' + #13#10 +
    'response: ' + inttostr(transacao.response) + #13#10 +
    'Error code: ' + transacao.ErrorCode + #13#10 +
    'Error: ' + transacao.ErrorMsg);

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
IpTxt,Parcelas,TipoParcelamento:String;
i,j, countP:integer;
teste : boolean;
begin
       countP := 0;
       Edit1.Text := '';
       Edit2.Text := '';
       IpTxt := '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b';

        for i:=1 to Length(edtValor.Text) do begin
          if (copy(edtValor.Text,i,1) = '.') then
          begin

            Edit2.Text := Edit2.Text
          end
          else Edit2.Text := Edit2.Text + (copy(edtValor.Text,i,1));
        end;

        for j:=1 to Length(edtIPServidor.Text) do begin
          if (copy(edtIPServidor.Text,j,1) = '.') then
          begin
            inc(countP);
            Edit1.Text := Edit1.Text
          end
          else if (copy(edtIPServidor.Text,j,1) = '-') then
          begin
             inc(countP);
          end
          else if (copy(edtIPServidor.Text,j,1) = ',') then
          begin
             inc(countP);
          end
          else Edit1.Text := Edit1.Text + (copy(edtIPServidor.Text,j,1));
        end;

        //teste := TRegEx.IsMatch(edtIPServidor.Text, IpTxt);

        

       if edtValor.Text = '0,00'  then
       begin
        ShowMessage('Insira um valor maior que R$0.0');
       end

       else if StrToInt(edtParcelas.Text) = 0 then
       begin
        ShowMessage('Número de parcelas deve ser maior que 0');
       end

       else

       begin

          try

            if rdgTodos.IsChecked then
            begin
              if CheckBox1.IsChecked then
              begin
                Produto:=GER7_VOUCHER;
              end
              else
              begin
                Produto:=PRODUTO_TODOS;
              end;

            end
            else
            if rdgCredito.IsChecked then begin
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
              end
              else
              if rdgParceladoAdm.IsChecked then
              begin
                if CheckBox1.IsChecked then
                begin
                  TipoParcelamento :=GER7_PARCELADO_ADM;
                end
                else
                begin
                  TipoParcelamento :=PARCELAMENTO_ADM;
                end;

              end;
            end;


            //xxxxxxxxxxxxxxxxxxxxxxxxx


            if CheckBox2.IsChecked then
            begin
              // Aceita enredeço de IP entre 0..255
              if ((TRegEx.IsMatch(edtIPServidor.Text, IpTxt)) and (countP=3)) then
              begin

                contR:=3; //R
                contREIMP := 'OK_REIMP';
                ExecuteSiTEF(COMANDO_VENDA,'',Numeric(Edit2.text),Parcelas,TipoParcelamento,Produto,fHabilitaImpressao);
              end
              else
                ShowMessage('Erro ao Executar a função'+ #13#10#13#10 +'Digite um IP válido');

            end
            else
            begin
              IniciaTransacao;
              //transacao.SetaDebug(true);
              IncrementaId; //
              
              contR:=1;
              ExecuteTEF(COMANDO_VENDA,strId,Numeric(Edit2.text),Parcelas,TipoParcelamento,Produto,fHabilitaImpressao);
            end;

          except
            on e: exception do begin
            ShowMessage('Erro Transacao =>'+e.Message);
          end;

          end;
       end;

    {  }

end;
procedure TfrmTEF.cmdCancelarTransacaoClick(Sender: TObject);
var
HabilitaImpressao,IpTxt:string;
j, countP:integer;

begin
  IpTxt := '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b';
  countP := 0;
  Edit1.Text := '';

  for j:=1 to Length(edtIPServidor.Text) do begin
    if (copy(edtIPServidor.Text,j,1) = '.') then
    begin
      inc(countP);
      Edit1.Text := Edit1.Text
    end
    else if (copy(edtIPServidor.Text,j,1) = '-') then
    begin
       inc(countP);
    end
    else if (copy(edtIPServidor.Text,j,1) = ',') then
    begin
       inc(countP);
    end
    else Edit1.Text := Edit1.Text + (copy(edtIPServidor.Text,j,1));
  end;


  if CheckBox1.IsChecked then
  begin
     try
       contR := 1;
       if chkImpressao.IsChecked then
        begin
          auxR:='1';
        end
        else
        begin
          auxR:='0';
        end;

        IncrementaId; //Colocar aqui o seu tratamento do Id!!
        ExecuteTEF(COMANDO_CANCELAMENTO,strId,'','','','',auxR);
      except
        on e: exception do begin
        ShowMessage('ErroTr=>'+e.Message);
      end;

      end;
  end
  else
  begin
    try
      contR := 3; //kkkkkkkkkkkkkkk
      contREIMP := 'OK_REIMP';
      // Aceita enredeço de IP entre 0..255
      if ((TRegEx.IsMatch(edtIPServidor.Text, IpTxt)) and (countP=3)) then
      begin
        FuncoesDiversas(COMANDO_CANCELAMENTO);
      end
      else
        ShowMessage('Erro ao Executar a função'+ #13#10#13#10 +'Digite um IP válido');

      except
        on e: exception do begin
        ShowMessage('Erro Cancelamento =>'+e.Message);
      end;

    end;
  end;

end;
procedure TfrmTEF.FuncoesDiversas(Funcao:String);
begin

  if chkImpressao.IsChecked then
    begin
      auxR:='1';
    end
    else
    begin
      auxR:='0';
    end;


  if CheckBox1.IsChecked then
  begin

    try

    IncrementaId; //Colocar aqui o seu tratamento do Id!!
    ExecuteTEF(Funcao,strId,'','','','',auxR);

    except
      on e: exception do begin
      ShowMessage('ErroTr=>'+e.Message);
      end;
    end;
  end
  else begin
    try

      ExecuteSiTEF(Funcao,'','','','','',auxR);

    except
      on e: exception do begin
      ShowMessage('Erro Funcoes =>'+e.Message);
      end;
    end;
  end;

end;
procedure TfrmTEF.cmdFuncoesClick(Sender: TObject);
var
IpTxt: string;
countP: integer;
j:integer;

begin
  IpTxt := '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b';
  countP := 0;
  Edit1.Text := '';
  constFunc := 1;

   for j:=1 to Length(edtIPServidor.Text) do begin
    if (copy(edtIPServidor.Text,j,1) = '.') then
    begin
      inc(countP);
      Edit1.Text := Edit1.Text
    end
    else if (copy(edtIPServidor.Text,j,1) = '-') then
    begin
       inc(countP);
    end
    else if (copy(edtIPServidor.Text,j,1) = ',') then
    begin
       inc(countP);
    end
    else Edit1.Text := Edit1.Text + (copy(edtIPServidor.Text,j,1));
  end;


  if CheckBox1.IsChecked then
  begin
    FuncoesDiversas(COMANDO_FUNCOES);
  end
  else
  begin

    contREIMP := 'NOT_REIMP';
    if ((TRegEx.IsMatch(edtIPServidor.Text, IpTxt)) and (countP=3)) then
    begin
      FuncoesDiversas(COMANDO_FUNCOES);
    end
    else
      ShowMessage('Erro ao Executar a função'+ #13#10#13#10 +'Digite um IP válido');

  end;

end;
procedure TfrmTEF.cmdReimpressaoClick(Sender: TObject);
var
IpTxt: string;
countP,j:integer;
begin

  IpTxt := '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b';
  countP := 0;
  Edit1.Text := '';

  for j:=1 to Length(edtIPServidor.Text) do begin
    if (copy(edtIPServidor.Text,j,1) = '.') then
    begin
      inc(countP);
      Edit1.Text := Edit1.Text
    end
    else if (copy(edtIPServidor.Text,j,1) = '-') then
    begin
       inc(countP);
    end
    else if (copy(edtIPServidor.Text,j,1) = ',') then
    begin
       inc(countP);
    end
    else Edit1.Text := Edit1.Text + (copy(edtIPServidor.Text,j,1));
  end;

  if CheckBox1.IsChecked then
  begin
    contR := 0;

    if chkImpressao.IsChecked then
    begin
      auxR:='1';
    end
    else
    begin
      auxR:='0';
    end;

    FuncoesDiversas(GER7_REIMPRESSAO);
  end
  else
  begin
    contR := 2;
    contREIMP:= 'NOT_REIMP';

    if ((TRegEx.IsMatch(edtIPServidor.Text, IpTxt)) and (countP=3)) then
    begin
      FuncoesDiversas(COMANDO_REIMPRESSAO);
    end
    else
      ShowMessage('Erro ao Executar a função'+ #13#10#13#10 +'Digite um IP válido');

  end;

end;
//************************************************

procedure TfrmTEF.rdgCreditoChange(Sender: TObject);
begin
edtParcelas.Enabled := True;
end;
procedure TfrmTEF.rdgDebitoChange(Sender: TObject);
begin
  edtParcelas.Text := '1';
  edtParcelas.Enabled := False;
end;
procedure TfrmTEF.rdgTodosChange(Sender: TObject);
begin
     edtParcelas.Text := '1';
     edtParcelas.Enabled := False;
end;
procedure TfrmTEF.VertScrollBox1Click(Sender: TObject);
begin

end;

//**********************************************
function TfrmTEF.OnActivityResult(RequestCode, ResultCode: Integer; Data:
                  JIntent): Boolean;
var
  json: JString;
  objJson: TJSONObject;
  CupomImpresso:string;
  iPos:integer;
  strDebug:string;
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

            //RandomValor;
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
      //RandomValor;

      Result := True;
    end;



    if (RequestCode = GER7_REQ_CODE) and (ResultCode = TJActivity.JavaClass.RESULT_OK)
    and Assigned(Data) then
    begin

      if(TEFExecuteFlag <>0) then exit;//Evita reentrancias
        TEFExecuteFlag :=1;

        try
          transacao.Zera;
          json := Data.getStringExtra(StringToJString(GER7_RES_TAG));
          //Debug!! ShowMessage(inttostr(TEFExecuteFlag)+'=>'+JStringToString(json));
          objJson := TJSONObject.ParseJSONValue(JStringToString(json)) as TJSONObject;

          transacao.response := objJson.GetValue<Integer>('response');

          transacao.Versao:=objJsonGetValue(objJson,'version');
          transacao.Status:= objJsonGetValue(objJson,'status');
          transacao.License:= objJsonGetValue(objJson,'license');
          transacao.Terminal:= objJsonGetValue(objJson,'terminal');
          transacao.Merchant:= objJsonGetValue(objJson,'merchant');
          transacao.IDTransacao:= objJsonGetValue(objJson,'id');
          transacao.ProdutoSelecionado:= objJsonGetValue(objJson,'product');
          transacao.Parcelas:= objJsonGetValue(objJson,'installments');
          transacao.TipoParcela:= objJsonGetValue(objJson,'instmode');
          transacao.STAN:= objJsonGetValue(objJson,'stan') ;

          transacao.cardholder:= objJsonGetValue(objJson,'cardholder');
          transacao.prefname:= objJsonGetValue(objJson,'prefname');
          transacao.authorizationType:= objJsonGetValue(objJson,'authorizationType');
          transacao.cardEntry:= objJsonGetValue(objJson,'cardEntry');
          transacao.cvm:= objJsonGetValue(objJson,'cvm');
          transacao.acquirer:= objJsonGetValue(objJson,'acquirer');
          transacao.pan:= objJsonGetValue(objJson,'pan');
          //RC05
          transacao.Tipo:= objJsonGetValue(objJson,'type');
          transacao.Amount:= objJsonGetValue(objJson,'amount');

          if(transacao.response = 0)then
          begin
            transacao.Authorization := objJsonGetValue(objJson,'authorization') ;
            transacao.IDTransacao:= objJsonGetValue(objJson,'id');
            //transacao.ProdutoSelecionado:=objJsonGetValue(objJson,'type');
            transacao.LabelTransacao:=objJsonGetValue(objJson,'label');

            transacao.RRN:=objJsonGetValue(objJson,'rrn');
            transacao.AID:=objJsonGetValue(objJson,'aid');
            transacao.Horario:=objJsonGetValue(objJson,'time');

            transacao.Valor:=objJsonGetValue(objJson,'amount');
            CupomImpresso:=objJsonGetValue(objJson,'print');

            iPos:=Pos(GER7_FORM_FEED,CupomImpresso);

            if(iPos>0)then begin
              transacao.textoImpressoEc:=copy(CupomImpresso,1,iPos-1);
              transacao.textoImpressoCliente:=copy(CupomImpresso,iPos+2,length(CupomImpresso));
            end else begin
              transacao.textoImpressoEc:=CupomImpresso;
              transacao.textoImpressoCliente:='';
            end;


        end
        else
        begin
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
            MostraAprovadaGER7;
          end);

      end else begin
          TThread.Synchronize(nil,
          procedure
          begin
           MostraNegadaGER7;
          end );
      end;
      //TEFExecuteFlag:=0;
      //RandomValor;

    end;

end;
procedure TfrmTEF.MSITEFChange(Sender: TObject);
begin

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
  edtIPServidor.Text :=  StringReplace(edtIPServidor.Text,' ', EmptyStr, [rfReplaceAll]);
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
//==========================================================
procedure TfrmTEF.ExecuteTEF(Tipo,Id,Amount,Parcelas,TipoParcelamento,Product,HabilitaImpressao:string);
var
Intent:JIntent;
JSON:JString;
DeviceType:String;


begin

  if(transacao = nil) then
    begin
      transacao:= TGER7TEF.Create;
    end;


  DeviceType := JStringToString(TJBuild.JavaClass.MODEL);

  if(Trim(DeviceType) <> 'GPOS700')and (Trim(DeviceType)<>'Smart G800')then
  begin
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
  TAndroidHelper.Activity.startActivityForResult(Intent, GER7_REQ_CODE);


end;



end.
