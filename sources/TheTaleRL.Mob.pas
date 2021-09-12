unit TheTaleRL.Mob;

interface

uses
  TheTaleRL.Entity,
  TheTaleRL.HP;

type
  TGender = (gdMale, gdFemale);

type
  TMob = class(TEntity)
  private
    FGender: TGender;
    FMagic: Word;
    FMight: Word;
    FExperience: Cardinal;
    FHP: THP;
    FBurned: Boolean;
    FPoisoned: Boolean;
    FAbPoint: Byte;
    function GetMagic: Word;
    function GetMight: Word;
  public
    constructor Create;
    destructor Destroy; override;
    property HP: THP read FHP write FHP;
    property AbPoint: Byte read FAbPoint write FAbPoint;
    property Might: Word read GetMight;
    property Magic: Word read GetMagic;
    property Experience: Cardinal read FExperience;
    procedure SetMightAndMagic(const Might, Magic: Word);
    function GetDeltaToNext: Cardinal;
    procedure GainExp(const Exp: Word);
    property Gender: TGender read FGender write FGender;
    function GetDamage: Integer;
    property Burned: Boolean read FBurned write FBurned;
    property Poisoned: Boolean read FPoisoned write FPoisoned;
  end;

implementation

uses
  Math,
  SysUtils;

{ TMob }

procedure TMob.GainExp(const Exp: Word);
begin
  FExperience := FExperience + Exp;
  if (FExperience >= GetDeltaToNext) then
  begin
    Level := Level + 1;
    AbPoint := AbPoint + 1;
    case Math.RandomRange(0, 2) of
      0:
        Inc(FMight);
      1:
        Inc(FMagic);
    end;
  end;
end;

constructor TMob.Create;
begin
  inherited Create;
  FMagic := 1;
  FMight := 1;
  FExperience := 0;
  FAbPoint := 1;
  FHP := THP.Create;
  FGender := gdMale;
  FBurned := False;
  FPoisoned := False;
end;

destructor TMob.Destroy;
begin
  FreeAndNil(FHP);
  inherited;
end;

function TMob.GetDamage: Integer;
begin
  Result := Level * 3;
end;

function TMob.GetDeltaToNext: Cardinal;
var
  I: Byte;
begin
  Result := 0;
  for I := 1 to Self.Level do
    Result := Result + (I * 25);
end;

function TMob.GetMagic: Word;
begin
  Result := FMagic;
end;

function TMob.GetMight: Word;
begin
  Result := FMight;
end;

procedure TMob.SetMightAndMagic(const Might, Magic: Word);
begin
  FMagic := Might;
  FMight := Magic;
end;

end.
