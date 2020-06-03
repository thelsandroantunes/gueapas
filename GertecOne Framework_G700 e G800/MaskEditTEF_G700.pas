unit MaskEditTEF_G700;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Mask;

type
  TTipo = (tMoeda,tIP);
  TMaskEdit = class(TMaskEdit)
  private
    FTipo: TTipo;
    procedure SetTipo(const Value:TTipo);
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
  property Tipo:TTipo read FTipo write SetTipo;
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('AddTEF', [TMaskEdit]);
end;

{TMaskEdit}

procedure TMaskEdit.SetTipo(const Value: TTipo);
begin
  FTipo := Value;

  case Value of
    tMoeda: EditMask;
    tIP: ;
  end;

end;


end.

