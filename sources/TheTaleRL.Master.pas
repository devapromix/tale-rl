unit TheTaleRL.Master;

interface

uses
  Classes,
  TheTaleRL.Mob,
  TheTaleRL.Hero,
  TheTaleRL.ResObject;

type
  TMasters = class(TResObject)
  private type
    TMaster = class(TMob)
      TownIdent: Integer;
      QuestIdent: Integer;
      PersonType: Integer;
      Gender: TGender;
      Race: TRace;
      procedure Clear;
    end;
  private
    FMasters: TArray<TMaster>;
    function IsName(const N: string): Boolean;
    function GetGender(const N: string): TGender;
    function GetRace(const N: string): TRace;
  public
    constructor Create;
    destructor Destroy; override;
    function Count: Integer;
    function GetMaster(const Index: Integer): TMaster;
    procedure AddMaster(const TownId: Integer);
    function GenName: string;
  end;

implementation

uses
  Math,
  SysUtils;

{ TMasters }

procedure TMasters.AddMaster(const TownId: Integer);
var
  I: Integer;
begin
  // Новый мастер получает случайные параметры
  I := Length(FMasters) + 1;
  SetLength(FMasters, I);
  FMasters[I - 1] := TMaster.Create;
  with FMasters[I - 1] do
  begin
    Name := GenName;
    Level := Math.RandomRange(25, 45);
    TownIdent := TownId;
    QuestIdent := Math.RandomRange(0, Resources.KeysCount('Quests', 'Name'));
    PersonType := RandomRange(0, Resources.KeysCount('Masters', 'Types'));
    Gender := GetGender(Name);
    Race := GetRace(Name);
  end;
end;

function TMasters.Count: Integer;
begin
  Result := Length(FMasters)
end;

constructor TMasters.Create;
begin
  inherited;
  SetLength(FMasters, 0);
end;

destructor TMasters.Destroy;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    FreeAndNil(FMasters[I]);
  inherited;
end;

function TMasters.GenName: string;
var
  N: string;
begin
  repeat
    N := Resources.RandomValue('Masters', 'Names').Trim;
  until not IsName(N);
  Result := N;
end;

function TMasters.GetGender(const N: string): TGender;
begin
  if N.Contains('M]') then
    Result := gdMale
  else
    Result := gdFemale;
end;

function TMasters.GetMaster(const Index: Integer): TMaster;
begin
  Result := FMasters[Index];
end;

function TMasters.GetRace(const N: string): TRace;
begin
  Result := rcHuman;
  if N.Contains('[G') then
    Result := rcGoblin;
  if N.Contains('[O') then
    Result := rcOrc;
  if N.Contains('[D') then
    Result := rcDwarf;
  if N.Contains('[E') then
    Result := rcElf;
end;

function TMasters.IsName(const N: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  if N.IsEmpty then
    Exit;
  for I := 0 to Count - 1 do
    if (N = FMasters[I].Name) then
      Exit(True);
end;

{ TMasters.TMaster }

procedure TMasters.TMaster.Clear;
begin
  Name := '';
  Level := 0;
  TownIdent := -1;
  QuestIdent := -1;
  PersonType := -1;
  Gender := gdMale;
  Race := rcHuman;
end;

end.
