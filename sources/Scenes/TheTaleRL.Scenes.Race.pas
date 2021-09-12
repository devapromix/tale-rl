unit TheTaleRL.Scenes.Race;

interface

uses
  System.Classes,
  TheTaleRL.Scenes;

type
  TSceneRace = class(TScene)
  private
    FRace: string;
    FDescription: string;
    FRaceIndex: Integer;
    FRaces: TStringList;
    FNamesMale: string;
    FNamesFemale: string;
    FRaceMale: string;
    FRaceFemale: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    function RacesCount: Integer;
    property RaceIndex: Integer read FRaceIndex write FRaceIndex;
  end;

implementation

{ TSceneRace }

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Hero,
  TheTaleRL.Scenes.Name,
  TheTaleRL.Mob;

constructor TSceneRace.Create;
begin
  inherited;
  FRaceIndex := 0;
  FRaces := TStringList.Create;
end;

destructor TSceneRace.Destroy;
begin
  FreeAndNil(FRaces);
  inherited;
end;

function TSceneRace.RacesCount: Integer;
begin
  if FRaces.Count = 0 then
    Resources.ReadSections('Races', FRaces);
  Result := FRaces.Count;
end;

procedure TSceneRace.Render;
var
  Result: string;
begin
  Resources.ReadSections('Races', FRaces);
  FRace := Resources.LoadFromFile('Races', FRaces[FRaceIndex], 'Title', '');
  FRaceMale := Resources.LoadFromFile('Races', FRaces[FRaceIndex], 'TitleMale', '');
  FRaceFemale := Resources.LoadFromFile('Races', FRaces[FRaceIndex], 'TitleFemale', '');
  FNamesMale := Resources.LoadFromFile('Races', FRaces[FRaceIndex], 'NamesMale', '');
  FNamesFemale := Resources.LoadFromFile('Races', FRaces[FRaceIndex], 'NamesFemale', '');
  FDescription := Resources.LoadFromFile('Races', FRaces[FRaceIndex], 'Description', '');
  //
  Result := Title('Какой расы герой?') + #13#10#13#10;
  Result := Result + Title(FRace) + #13#10#13#10 + FDescription + #13#10#13#10;
  Result := Result + ' ' + Button('Влево', 'Предыдущая раса');
  Result := Result + ' ' + Button('A', FRaceMale);
  Result := Result + ' ' + Button('B', FRaceFemale);
  Result := Result + ' ' + Button('Enter', 'Случайный пол');
  Result := Result + ' ' + Button('Вправо', 'Следующая раса');
  Print(Result);
end;

procedure TSceneRace.Update(var Key: Word);
begin
  case Key of
    TK_ESCAPE:
      Game.Scenes.SetScene(scTitle);
    TK_LEFT:
      begin
        Dec(FRaceIndex);
        if (FRaceIndex < 0) then
          FRaceIndex := RacesCount - 1;
        Render;
      end;
    TK_A:
      begin
        Game.Hero.RaceIndex := FRaceIndex;
        Game.Hero.Gender := TGender.gdMale;
        Game.Hero.RaceTitle := FRaceMale;
        with TSceneName(Game.Scenes.GetScene(scName)) do
        begin
          AllNames := FNamesMale;
          Game.Hero.Name := GetRandomName;
        end;
        Game.Scenes.SetScene(scName);
      end;
    TK_B:
      begin
        Game.Hero.RaceIndex := FRaceIndex;
        Game.Hero.Gender := TGender.gdFemale;
        Game.Hero.RaceTitle := FRaceFemale;
        with TSceneName(Game.Scenes.GetScene(scName)) do
        begin
          AllNames := FNamesFemale;
          Game.Hero.Name := GetRandomName;
        end;
        Game.Scenes.SetScene(scName);
      end;
    TK_ENTER:
      begin
        Game.Hero.RaceIndex := FRaceIndex;
        if Math.RandomRange(0, 2) = 0 then
        begin
          Game.Hero.Gender := TGender.gdMale;
          Game.Hero.RaceTitle := FRaceMale;
          with TSceneName(Game.Scenes.GetScene(scName)) do
          begin
            AllNames := FNamesMale;
            Game.Hero.Name := GetRandomName;
          end;
        end
        else
        begin
          Game.Hero.Gender := TGender.gdFemale;
          Game.Hero.RaceTitle := FRaceFemale;
          with TSceneName(Game.Scenes.GetScene(scName)) do
          begin
            AllNames := FNamesFemale;
            Game.Hero.Name := GetRandomName;
          end;
        end;
        Game.Scenes.SetScene(scName);
      end;
    TK_RIGHT:
      begin
        Inc(FRaceIndex);
        if (FRaceIndex >= RacesCount) then
          FRaceIndex := 0;
        Render;
      end;
  end;
end;

end.
