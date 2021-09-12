unit TheTaleRL.Town;

interface

uses
  TheTaleRL.Entity,
  TheTaleRL.Master,
  TheTaleRL.ResObject;

const
  SpecName: array [0 .. 8] of string = ('Craft_Center', 'Polic', 'Transport_Node', 'Fort', 'Trade_Center', 'Outlaws', 'Holy_City', 'Political_Center',
    'Resort');

const
  PersTypeName: array [0 .. 21] of string = ('Blacksmith', 'Fisherman', 'Tailor', 'Carpenter', 'Hunter', 'Warden', 'Merchant', 'Innkeeper', 'Rogue',
    'Farmer', 'Miner', 'Priest', 'Physician', 'Alchemist', 'Executioner', 'Magician', 'Usurer', 'Clerk', 'Magomechanic', 'Bard', 'Tamer', 'Herdsman');

type
  TTowns = class(TResObject)
  public type
    TTown = class(TEntity)
    private
      FSpecialization: Byte;
      FDescription: string;
      FGoblin: Byte;
      FOrc: Byte;
      FHuman: Byte;
      FDwarf: Byte;
      FElf: Byte;
      FRace: TRaceEnum;
      FPop: Integer;
      FCult: Integer;
      FSafety: Integer;
    public
      property Specialization: Byte read FSpecialization write FSpecialization;
      property Description: string read FDescription;
      property Human: Byte read FHuman;
      property Orc: Byte read FOrc;
      property Dwarf: Byte read FDwarf;
      property Goblin: Byte read FGoblin;
      property Elf: Byte read FElf;
      property Pop: Integer read FPop;
      property Cult: Integer read FCult;
      property Safety: Integer read FSafety;
      procedure Clear;
    end;
  private
    FMasters: TMasters;
    FTowns: TArray<TTown>;
    FMaxCount: Integer;
    function IsName(const N: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Count: Integer;
    procedure Gen;
    function GetTown(const Index: Integer): TTown;
    property Masters: TMasters read FMasters;
    function GenTownDescription(const I: Integer): string;
  end;

implementation

uses
  Math,
  Classes,
  SysUtils,
  TheTaleRL.Hero,
  TheTaleRL.Game,
  TheTaleRL.Scenes,
  TheTaleRL.Scenes.Game;

{ TTown }

function TTowns.Count: Integer;
begin
  Result := FMaxCount;
end;

constructor TTowns.Create;
begin
  inherited Create;
  FMasters := TMasters.Create;
end;

destructor TTowns.Destroy;
var
  I: Byte;
begin
  FreeAndNil(FMasters);
  for I := 0 to FMaxCount - 1 do
    FreeAndNil(FTowns[I]);
  inherited;
end;

procedure TTowns.Gen;
var
  I, J, M, H, Sum, MasterCount: Integer;
  N: string;
begin
  // Кол-во городов на карте
  FMaxCount := 8;
  SetLength(FTowns, FMaxCount);
  for I := 0 to FMaxCount - 1 do
    FTowns[I] := TTown.Create;
  for I := 0 to FMaxCount - 1 do
  begin
    with FTowns[I] do
    begin
      Clear;
      // Название города должно быть уникальным
      repeat
        N := Resources.RandomValue('Towns', 'Names');
      until not IsName(N);
      Name := N.Trim;
      // Позиция тоже должна быть уникальной
      //repeat
      //  N := Resources.RandomValue('Towns', 'Names');
      //until not IsName(N);
      //Name := N.Trim;
      // Специализация города
      Specialization := RandomRange(0, Resources.KeysCount('Towns', 'Specializations'));
      // Демография
      repeat
        FGoblin := RandomRange(5, 55);
        FOrc := RandomRange(5, 55);
        FHuman := RandomRange(5, 55);
        FDwarf := RandomRange(5, 55);
        FElf := RandomRange(5, 55);
        Sum := FGoblin + FOrc + FHuman + FDwarf + FElf;
      until (Sum = 100);
      M := Math.MaxIntValue([FGoblin, FOrc, FHuman, FDwarf, FElf]);
      H := Math.MinIntValue([FGoblin, FOrc, FHuman, FDwarf, FElf]);
      if FGoblin = M then
        FRace := reGoblin;
      if FOrc = M then
        FRace := reOrc;
      if FHuman = M then
        FRace := reHuman;
      if FDwarf = M then
        FRace := reDwarf;
      if FElf = M then
        FRace := reElf;
      // Размер города
      Level := M div H;
      // Население
      FPop := RandomRange(Level * 1000, Level * 2000);
      // Культура
      FCult := EnsureRange(((M div H) + (Level div 2) * 10) + RandomRange(0, 10), 10, 120);
      // Безопасность
      FSafety := EnsureRange((Level * (FCult div 5) * 2) + RandomRange(0, 10), 5, 100);
      // Описание города
      FDescription := GenTownDescription(I);
      // Позиция города
      SetLocation(Math.RandomRange(1, WW - 2), Math.RandomRange(1, WH - 2));
    end;
    // Кол-во мастеров в городе
    MasterCount := 3;
    for J := 0 to MasterCount - 1 do
      Masters.AddMaster(I);
  end;
end;

function TTowns.GenTownDescription(const I: Integer): string;
var
  S: array [1 .. 3] of string;
  J: Byte;

  function GetAll(const N: Byte): string;
  begin
    Result := Format(Resources.RandomValue('Towns', 'All' + N.ToString), [FTowns[I].Name]);
  end;

  function GetSpec(const N: Byte): string;
  begin
    Result := Format(Resources.RandomValue('Towns', SpecName[FTowns[I].Specialization] + N.ToString), [FTowns[I].Name]);
  end;

  function GetRace(const N: Byte): string;
  begin
    Result := Format(Resources.RandomValue('Towns', RaceName[TRace(FTowns[I].FRace)] + N.ToString), [FTowns[I].Name]);
  end;

begin
  repeat
    for J := 1 to 3 do
    begin
      case Math.RandomRange(0, 7) of
        0:
          S[J] := GetAll(J);
        1:
          S[J] := GetSpec(J);
      else
        S[J] := GetRace(J);
      end;
    end;
  until ((S[1] <> '') and (S[2] <> '') and (S[3] <> ''));

  Result := Format('%s %s %s', [S[1], S[2], S[3]]);
end;

function TTowns.GetTown(const Index: Integer): TTown;
begin
  Result := FTowns[Index];
end;

function TTowns.IsName(const N: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
    if (N = FTowns[I].Name) then
      Exit(True);
end;

{ TTowns.TTown }

procedure TTowns.TTown.Clear;
begin
  Name := '';
  Level := 0;
  SetLocation(0, 0);
end;

end.
