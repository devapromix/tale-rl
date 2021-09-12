unit TheTaleRL.Hero;

interface

uses
  System.Types,
  System.Classes,
  TheTaleRL.Mob,
  TheTaleRL.Skills,
  TheTaleRL.Equipment,
  TheTaleRL.Inventory;

type
  TDirectionEnum = (drEast, drWest, drSouth, drNorth, drSouthEast, drSouthWest, drNorthEast, drNorthWest, drOrigin);

const
  Direction: array [TDirectionEnum] of TPoint = ((X: 1; Y: 0), (X: - 1; Y: 0), (X: 0; Y: 1), (X: 0; Y: - 1), (X: 1; Y: 1), (X: - 1; Y: 1), (X: 1;
    Y: - 1), (X: - 1; Y: - 1), (X: 0; Y: 0));

type
  TRace = (rcHuman, rcGoblin, rcOrc, rcDwarf, rcElf);

const
  RaceName: array [TRace] of string = ('Human', 'Goblin', 'Orc', 'Dwarf', 'Elf');

type
  THero = class(TMob)
  public type
    TArchetype = (arWarrior, arAdventurer, arMage);
  private
    FArchetype: TArchetype;
    FRaceTitle: string;
    FArchetypeName: string;
    FInventory: TInventory;
    FBackground: string;
    FDeath: string;
    FRaces: TStringList;
    FRaceIndex: Integer;
    FAbilities: TAbilities;
    FEquipment: TEquipment;
    procedure GenerateBackground();
    procedure GenerateDeath();
    procedure GenerateStory();
  public
    constructor Create;
    destructor Destroy; override;
    property RaceTitle: string read FRaceTitle write FRaceTitle;
    property Background: string read FBackground;
    property ArchetypeName: string read FArchetypeName write FArchetypeName;
    property Archetype: TArchetype read FArchetype write FArchetype;
    property Equipment: TEquipment read FEquipment write FEquipment;
    property Inventory: TInventory read FInventory write FInventory;
    property Abilities: TAbilities read FAbilities;
    property RaceIndex: Integer read FRaceIndex write FRaceIndex;
    property Death: string read FDeath;
    procedure Move(Dir: TDirectionEnum);
    function GetRaceName(const Gender: TGender; const Race: TRace): string;
    procedure Generate;
    function GetInfo: string;
    procedure Calc;
  end;

implementation

uses
  Math,
  SysUtils,
  TheTaleRL.Game,
  TheTaleRL.Scenes,
  TheTaleRL.Scenes.Game,
  TheTaleRL.Scenes.Fight;

{ THero }

procedure THero.Move(Dir: TDirectionEnum);
begin
  // Ход
  Self.SetLocation(Math.EnsureRange(Direction[Dir].X + X, 0, TSceneGame(Game.Scenes.GetScene(scGame)).Screen.Width - 1),
    Math.EnsureRange(Direction[Dir].Y + Y, 0, TSceneGame(Game.Scenes.GetScene(scGame)).Screen.Height - 1));
  Game.Turn := Game.Turn + 1;
  // Бой или событие
  case Math.RandomRange(0, 50) of
    0:
      ;//Game.Event.DoRandomEvent;
    // Бой
    1 .. 5:
      Game.Event.DoRandomFight;
  end;
  Calc;
end;

procedure THero.Calc;
begin
  // Макс. здоровье
  HP.Max := (Might + Magic) * 12;
end;

constructor THero.Create;
begin
  inherited Create;
  FRaceTitle := '';
  FArchetypeName := '';
  FArchetype := arAdventurer;
  FBackground := '';
  FDeath := '';
  FRaceIndex := 0;
  FRaces := TStringList.Create;
  FInventory := TInventory.Create;
  FEquipment := TEquipment.Create;
  FAbilities := TAbilities.Create;
  // Герой на карте появляется в случайном месте
  Self.SetLocation(Math.RandomRange(1, WW - 2), Math.RandomRange(1, WH - 2));
  // Калькулятор
  Calc;
  HP.ToMax;
end;

destructor THero.Destroy;
begin
  FreeAndNil(FAbilities);
  FreeAndNil(FEquipment);
  FreeAndNil(FInventory);
  FreeAndNil(FRaces);
  inherited;
end;

procedure THero.Generate;
begin
  // О жизни персонажа
  GenerateBackground();
  // Как умер и стал героем
  GenerateDeath();
  // Главная сюжетная линия
  GenerateStory;
end;

procedure THero.GenerateBackground();
var
  I: (cpChild, cpClass, cpParent, cpCredit, cpBackground, cpEyeType, cpEyeColour, cpHairStyle, cpHairColour, cpComplexion);
  SL: array [Low(I) .. High(I)] of TStringList;
  FEyesColor: string;
begin
  Resources.ReadSections('Races', FRaces);
  FBackground := '';
  for I := Low(I) to High(I) do
    SL[I] := TStringList.Create;
  try
    // Цвет глаз
    SL[cpEyeColour].Text := Resources.LoadFromFile('Races', FRaces[FRaceIndex], 'EyesColor', '').ToLower;
    // Тип глаз зависит от пола
    case Gender of
      gdMale:
        SL[cpEyeType].Text := Resources.LoadFromFile('Races', FRaces[FRaceIndex], 'EyesTypeMale', '').ToLower;
      gdFemale:
        SL[cpEyeType].Text := Resources.LoadFromFile('Races', FRaces[FRaceIndex], 'EyesTypeFemale', '').ToLower;
    end;
    // Цвет волос
    SL[cpHairColour].Text := Resources.LoadFromFile('Races', FRaces[FRaceIndex], 'HairColor', '').ToLower;
    // Внешний вид волос зависит от пола
    case Gender of
      gdMale:
        SL[cpHairStyle].Text := Resources.LoadFromFile('Races', FRaces[FRaceIndex], 'HairStyleMale', '').ToLower;
      gdFemale:
        SL[cpHairStyle].Text := Resources.LoadFromFile('Races', FRaces[FRaceIndex], 'HairStyleFemale', '').ToLower;
    end;
    // Комплекция
    SL[cpComplexion].Text := Resources.LoadFromFile('Races', FRaces[FRaceIndex], 'Complexion', '').ToLower;
    //

    SL[cpChild].DelimitedText := ('"единственным ребенком","одним из двух детей",' +
      '"одним из многих детей","единственным выжившим ребенком","одним из нескольких детей",' + '"",""');
    SL[cpClass].DelimitedText := ('"бедной", "среднего достатка","богатой"');
    SL[cpParent].DelimitedText := ('"торговца","мельника"');
    SL[cpBackground].DelimitedText := ('"миролюбивый","проблемный"');

    FBackground := Format(('Герой был %s в %s семье %s. В детстве он был %s. У него %s %s глаза, %s %s волосы и %s фигура.'),
      [SL[cpChild][Random(SL[cpChild].Count - 1)],
      SL[cpClass][Random(SL[cpClass].Count - 1)],
      SL[cpParent][Random(SL[cpParent].Count - 1)],
      SL[cpBackground][Random(SL[cpBackground].Count - 1)],
      SL[cpEyeType][Random(SL[cpEyeType].Count - 1)],
      SL[cpEyeColour][Random(SL[cpEyeColour].Count - 1)],
      SL[cpHairStyle][Random(SL[cpHairStyle].Count - 1)],
      SL[cpHairColour][Random(SL[cpHairColour].Count - 1)],
      SL[cpComplexion][Random(SL[cpComplexion].Count - 1)]]);
  finally
    for I := Low(I) to High(I) do
      FreeAndNil(SL[I]);
  end;
end;

procedure THero.GenerateDeath;
begin
  FDeath := '';
  FDeath := FDeath + 'Герой умер молодым. ';
  FDeath := FDeath + 'Пандора — опасное место. Хищник не будет смотреть на возраст своей жертвы, да и бандитам жалость чужда. ';
  FDeath := FDeath +
    'После воскрешения герой перестаёт стареть. Умерев молодым, герой навсегда сохранит юношеский задор и максимализм. Но и окружающие могут не всегда воспринимать его серьёзно.';
end;

procedure THero.GenerateStory;
begin

end;

function THero.GetInfo: string;
begin
  Result := Format('%s, %s, %s %d-го уровня', [Name, RaceTitle, ArchetypeName, Level]);
end;

function THero.GetRaceName(const Gender: TGender; const Race: TRace): string;
begin
  if Gender = gdMale then
    Result := Resources.LoadFromFile('Races', RaceName[Race], 'TitleMale', '').ToLower
  else
    Result := Resources.LoadFromFile('Races', RaceName[Race], 'TitleFemale', '').ToLower;
end;

end.
