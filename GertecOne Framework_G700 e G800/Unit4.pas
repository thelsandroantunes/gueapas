unit Unit4;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.Helpers,System.IOUtils,
  Androidapi.JNI.JavaTypes,
  JavaInterfacesNew, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ScrollBox,
  FMX.Memo;

type
  TForm4 = class(TForm)
    memo1: TMemo;
    ImageControl1: TImageControl;
    btnEnviarDadosVenda: TButton;
    btnConsultarStatusOperacional: TButton;
    btnConsultarSAT: TButton;
    Button1: TButton;

    procedure FormActivate(Sender: TObject);
    procedure btnConsultarSATClick(Sender: TObject);
    procedure btnConsultarStatusOperacionalClick(Sender: TObject);
    procedure btnEnviarDadosVendaClick(Sender: TObject);
    procedure SplitDataPipe(Tipo:integer;Dados:string);
    procedure Button1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }

    procedure teste(pin: Boolean);
  end;

const
  TIPO_CONSULTA = 0;
  TIPO_OPERACIONAL = 1;
  TIPO_VENDA = 2;

var
  Form4: TForm4;
  satLib : JSatGerLib;
  onDataReceived : JSatGerLib_OnDataReceived;
  RetornoSAT:string;

implementation

{$R *.fmx}

procedure TForm4.teste(pin: Boolean);
begin
     //satLib := sat;
end;

procedure TForm4.btnConsultarSATClick(Sender: TObject);
begin

try
  RetornoSAT:= JStringToString( satLib.ConsultarSAT(Round(random(99999))));
  SplitDataPipe(TIPO_CONSULTA,RetornoSAT);
except on e: exception do
  begin
    //ShowMessage('Erro Consulta SAT: '#13 + e.Message);
    memo1.Lines.Add('Erro Consulta SAT: '#13 + e.Message);
  end;
end;
end;

procedure TForm4.btnConsultarStatusOperacionalClick(Sender: TObject);
begin
   try
  RetornoSAT:= JStringToString(satLib.ConsultarStatusOperacional(random(99999),StringToJString('12345678')));
  SplitDataPipe(TIPO_OPERACIONAL,RetornoSAT);

  except on e: exception do
  begin
    //ShowMessage('Erro Consultar Status Operacional: '#13 + e.Message);
    memo1.Lines.Add('Erro Consultar Status Operacional: '#13 + e.Message);
  end;

end;
end;

procedure TForm4.btnEnviarDadosVendaClick(Sender: TObject);
var
  Arq:TextFile;
  Linha,
  VendaXML,
  NomeArqVendas:string;

begin

try
NomeArqVendas:=  TPath.GetDocumentsPath + PathDelim + 'venda.xml';
   if FileExists(NomeArqVendas)then begin
    AssignFile(Arq,NomeArqVendas);
    VendaXML:='';
    reset(Arq);
    while not eof(Arq) do begin
      Readln(Arq,Linha);
      VendaXML:=VendaXML + Linha;
    end;
    CloseFile(Arq);

    RetornoSAT:= JStringToString( satLib.EnviarDadosVenda(Round(random(99999)),StringToJString('12345678'),StringToJString(VendaXML)));
    SplitDataPipe(TIPO_VENDA,RetornoSAT);

  end else begin
      ShowMessage('Nao existe Arquivo de Vendas:'+NomeArqVendas);
  end;
except on e: exception do
  begin
    //ShowMessage('Erro Enviar Dados Venda: '#13 + e.Message);
    memo1.Lines.Add('Erro Enviar Dados Venda: '#13 + e.Message);
  end;

end;
end;


procedure TForm4.Button1Click(Sender: TObject);
begin
 //satLib.AtivarSAT(999999,1,StringToJString('03654119000176'),StringToJString('35'), 0);
end;

procedure TForm4.SplitDataPipe(Tipo:integer;Dados:string);
//
var
  OutPutList: TStringList;
  i:integer;
  strLabel:string;
begin
  if(Dados<>'') then begin

      memo1.Lines.Clear;
      memo1.Lines.Add('[RetSAT]');
      memo1.Lines.Add(Dados);

      OutPutList := TStringList.Create;
      OutPutList.StrictDelimiter:=True;
      OutPutList.Delimiter := '|';
      OutPutList.DelimitedText := Dados;

      for i := 0 to OutPutList.Count-1 do begin

        case Tipo of

          TIPO_OPERACIONAL:begin
          case i of
            0:strLabel:='numeroSessao';
            1:strLabel:='Retorno';
            2:strLabel:='mensagem';
            3:strLabel:='codSefaz';
            4:strLabel:='mensagemSEFAZ';
            5:strLabel:='NSERIE';
            6:strLabel:='TIPO_LAN';
            7:strLabel:='LAN_IP ';
            8:strLabel:='LAN_MAC';
            9:strLabel:='LAN_MASK';
            10:strLabel:='LAN_GW';
            11:strLabel:='LAN_DNS_1';
            12:strLabel:='LAN_DNS_2';
            13:strLabel:='STATUS_LAN';
            14:strLabel:='NIVEL_BATERIA';
            15:strLabel:='MT_TOTAL';
            16:strLabel:='MT_USADA';
            17:strLabel:='DH_ATUAL';
            18:strLabel:='VER_SB';
            19:strLabel:='VER_LAYOUT';
            20:strLabel:='ULTIMO_CF-E-SAT';
            21:strLabel:='LISTA_ INICIAL';
            22:strLabel:='LISTA_ FINAL';
            23:strLabel:='DH_CFe';
            24:strLabel:='DH_ULTIMA';
            25:strLabel:='CERT_EMISSAO';
            26:strLabel:='CERT_VENCIMENTO';
            27:strLabel:='ESTADO_OPERACAO';
            else
            strLabel:=IntToStr(i);
          end;
          end;

          TIPO_CONSULTA:begin
          case i of
            0:strLabel:='numeroSessao';
            1:strLabel:='Retorno';
            2:strLabel:='mensagem';
            3:strLabel:='codSefaz';
            4:strLabel:='mensagemSEFAZ';
            else
              strLabel:=IntToStr(i);
          end;

          end;

          TIPO_VENDA:begin
            case i of
              0:strLabel:='numeroSessao';
              1:strLabel:='Retorno';
              2:strLabel:='CCCC';
              3:strLabel:='mensagem';
              4:strLabel:='codSefaz';
              5:strLabel:='mensagemSEFAZ';
              6:strLabel:='CF-e-SAT(base64)';
              7:strLabel:='timeStamp';
              8:strLabel:='chaveConsulta';
              9:strLabel:='valorTotalCFe';
              10:strLabel:='CPFCNPJValue';
              11:strLabel:='assinQRCODE';
            else
              strLabel:=IntToStr(i);
            end;
        end;

        end;

        memo1.Lines.Add('['+strLabel+'] '+OutPutList[i])
      end;//for i
  end;

end;

procedure TForm4.FormActivate(Sender: TObject);
begin

  //satLib := TJSatGerLib.JavaClass.init(SharedActivityContext.getApplicationContext, onDataReceived);
  satLib := TJSatGerLib.JavaClass.init(TAndroidHelper.Context, onDataReceived);
end;

end.
