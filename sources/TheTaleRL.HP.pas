unit TheTaleRL.HP;

interface

type
  THP = class(TObject)
  private
    FCur: Word;
    FMax: Word;
    function GetCur: Word;
    function GetMax: Word;
    procedure SetCur(const Value: Word);
    procedure SetMax(const Value: Word);
  public
    constructor Create;
    function IsMin: Boolean;
    function IsMax: Boolean;
    procedure Dec(Value: Word = 1);
    procedure Inc(Value: Word = 1);
    property Cur: Word read GetCur write SetCur;
    property Max: Word read GetMax write SetMax;
    procedure ToMin;
    procedure ToMax;
    function ToString: string; override;
  end;

implementation

uses
  SysUtils;

{ THP }

constructor THP.Create;
begin
  FMax := 10;
  Self.ToMax;
end;

procedure THP.Dec(Value: Word);
begin
  if FCur >= Value then
    System.Dec(FCur, Value) else FCur := 0;
end;

function THP.GetCur: Word;
begin
  Result := FCur;
end;

function THP.GetMax: Word;
begin
  Result := FMax;
end;

procedure THP.Inc(Value: Word);
begin
  System.Inc(FCur, Value);
  if FCur > FMax then
    Self.ToMax;
end;

function THP.IsMax: Boolean;
begin
  Result := FCur = FMax;
end;

function THP.IsMin: Boolean;
begin
  Result := FCur = 0;
end;

procedure THP.SetCur(const Value: Word);
begin
  FCur := Value;
  if FCur > FMax then
    Self.ToMax;
end;

procedure THP.SetMax(const Value: Word);
begin
  FMax := Value;
  if FCur > FMax then
    Self.ToMax;
end;

procedure THP.ToMax;
begin
  FCur := FMax;
end;

procedure THP.ToMin;
begin
  FCur := 0;
end;

function THP.ToString: string;
begin
  Result := IntToStr(Cur) + '/' + IntToStr(Max);
end;

end.
