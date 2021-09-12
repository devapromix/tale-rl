unit TheTaleRL.Scenes.Archetype;

interface

uses
  System.Classes,
  TheTaleRL.Scenes;

type
  TSceneArchetype = class(TScene)
  private
    FArchetypeIndex: Integer;
    FArchetypes: TStringList;
    FArchetypeMale: string;
    FArchetypeFemale: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    property ArchetypeIndex: Integer read FArchetypeIndex write FArchetypeIndex;
  end;

implementation

{ TSceneArchetype }

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Hero,
  TheTaleRL.Mob;

constructor TSceneArchetype.Create;
begin
  inherited;
  FArchetypeIndex := 0;
  FArchetypes := TStringList.Create;
end;

destructor TSceneArchetype.Destroy;
begin
  FreeAndNil(FArchetypes);
  inherited;
end;

procedure TSceneArchetype.Render;
var
  S: string;
  Description: string;
begin
  // Считывание данных из файла
  Resources.ReadSections('Archetypes', FArchetypes);
  FArchetypeMale := Resources.LoadFromFile('Archetypes', FArchetypes[FArchetypeIndex], 'TitleMale', '');
  FArchetypeFemale := Resources.LoadFromFile('Archetypes', FArchetypes[FArchetypeIndex], 'TitleFemale', '');
  Description := Resources.LoadFromFile('Archetypes', FArchetypes[FArchetypeIndex], 'Description', '');
  //
  if Game.Hero.Gender = gdMale then
    S := Title('Герой предпочитает магию или грубую силу?') + #13#10#13#10 + Title(FArchetypeMale) + #13#10
  else
    S := Title('Героиня предпочитает магию или грубую силу?') + #13#10#13#10 + Title(FArchetypeFemale) + #13#10;
  S := S + Description + #13#10#13#10;
  S := S + ' ' + Button('Влево', 'Предыдущий архетип');
  S := S + ' ' + Button('Enter', 'Выбрать');
  S := S + ' ' + Button('Вправо', 'Следующий архетип');
  Print(S.Trim);
end;

procedure TSceneArchetype.Update(var Key: Word);
begin
  case Key of
    TK_ESCAPE:
      Game.Scenes.SetScene(scName);
    TK_ENTER:
      begin
        case Game.Hero.Gender of
          gdMale:
            Game.Hero.ArchetypeName := FArchetypeMale;
          gdFemale:
            Game.Hero.ArchetypeName := FArchetypeFemale;
        end;
        Game.Hero.Archetype := THero.TArchetype(FArchetypeIndex);
        Game.Hero.Generate;
        Game.Scenes.SetScene(scBackground);
      end;
    TK_LEFT:
      begin
        Dec(FArchetypeIndex);
        if (FArchetypeIndex < 0) then
          FArchetypeIndex := FArchetypes.Count - 1;
        Render;
      end;
    TK_RIGHT:
      begin
        Inc(FArchetypeIndex);
        if (FArchetypeIndex >= FArchetypes.Count) then
          FArchetypeIndex := 0;
        Render;
      end;
  end;
end;

end.
