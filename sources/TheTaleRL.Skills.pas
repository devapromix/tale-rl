unit TheTaleRL.Skills;

interface

uses
  System.Classes,
  TheTaleRL.ResObject;

const
  MaxAbiltyLevel = 5;

type
  TAbility = record
    Ident: string;
    Name: string;
    Description: string;
    MaxLevel: Byte;
    Level: Byte;
    AbilityType: string;
    ActivType: string;
  end;

type
  TAbilities = class(TResObject)
  private
    FAbility: TArray<TAbility>;
    FAbilities: TStringList;
    FNewLevelAbilityIndex: array [1 .. 4] of Byte;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load;
    function Count: Byte;
    function GetAbility(const I: Byte): TAbility;
    function CurentAbilityIndex(const Index: Integer): Integer; overload;
    function CurentAbilityIndex(const Ident: string): Integer; overload;
    procedure AddLevel(const I: Byte);
    procedure Generate;
  end;

implementation

uses
  Math,
  SysUtils,
  TheTaleRL.Hero,
  TheTaleRL.Game;

{ TAbilities }

function TAbilities.Count: Byte;
begin
  Result := Length(FAbility);
end;

constructor TAbilities.Create;
begin
  inherited Create;
  FAbilities := TStringList.Create;
  Self.Load;
end;

function TAbilities.CurentAbilityIndex(const Ident: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if (GetAbility(I).Ident = Ident.ToLower) then
      Exit(I);
end;

function TAbilities.CurentAbilityIndex(const Index: Integer): Integer;
var
  I, N: Integer;
begin
  N := 0;
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if (GetAbility(I).Level = 0) then
      Continue;
    if N = Index then
    begin
      Result := I;
      Exit;
    end;
    Inc(N);
  end;
end;

destructor TAbilities.Destroy;
begin
  FreeAndNil(FAbilities);
  inherited;
end;

procedure TAbilities.Generate;
var
  C: Byte;
begin
  for C := 1 to 4 do
    FNewLevelAbilityIndex[C] := Math.RandomRange(0, Count);
end;

function TAbilities.GetAbility(const I: Byte): TAbility;
begin
  Result := FAbility[I];
end;

procedure TAbilities.Load;
var
  I: Byte;
begin
  SetLength(FAbility, 0);
  // Считывание способнойстей из файла
  Resources.ReadSections('Abilities', FAbilities, 'Main');
  for I := 0 to FAbilities.Count - 1 do
  begin
    SetLength(FAbility, Length(FAbility) + 1);
    with FAbility[Length(FAbility) - 1] do
    begin
      Ident := FAbilities[I];
      Name := Resources.LoadFromFile('Abilities', FAbilities[I], 'Name', '');
      Description := Resources.LoadFromFile('Abilities', FAbilities[I], 'Description', '');
      MaxLevel := Resources.LoadFromFile('Abilities', FAbilities[I], 'MaxLevel', 1);
      Level := Resources.LoadFromFile('Abilities', FAbilities[I], 'CurLevel', 0);
      AbilityType := Resources.LoadFromFile('Abilities', FAbilities[I], 'AbilityType', 'NonBattle');
      ActivType := Resources.LoadFromFile('Abilities', FAbilities[I], 'ActivType', 'Passive');
    end;
  end;
end;

procedure TAbilities.AddLevel(const I: Byte);
begin
  Inc(FAbility[I].Level);
end;

end.
