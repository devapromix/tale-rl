unit TheTaleRL.Scenes.Name;

interface

uses
  TheTaleRL.Scenes;

type
  TSceneName = class(TScene)
  private
    FNameIndex: Integer;
    FNamesCount: Integer;
    FAllNames: string;
  public
    function GetRandomName: string;
    property AllNames: string read FAllNames write FAllNames;
    constructor Create;
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

{ TSceneName }

uses
  Math,
  SysUtils,
  System.Classes,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Hero,
  TheTaleRL.Scenes.Archetype,
  TheTaleRL.Mob;

constructor TSceneName.Create;
begin
  inherited;
  FNameIndex := 0;
  FNamesCount := 0;
  FAllNames := '';
end;

function TSceneName.GetRandomName: string;
var
  SL: TStringList;
begin
  if AllNames = '' then
    Exit('');
  SL := TStringList.Create;
  try
    SL.Text := AllNames;
    Result := SL[Math.RandomRange(0, SL.Count)];
  finally
    FreeAndNil(SL);
  end;
end;

procedure TSceneName.Render;
var
  S: string;
begin
  if Game.Hero.Gender = gdMale then
    S := Title('Какое имя будет у героя?')
  else
    S := Title('Какое имя будет у героини?');
  S := S + #13#10#13#10 + Game.Hero.Name.ToUpper + #13#10#13#10;
  S := S + ' ' + Button('Space', 'Случайное имя');
  S := S + ' ' + Button('Enter', 'Выбрать');
  Print(S.Trim);
end;

procedure TSceneName.Update(var Key: Word);
var
  NewName: string;
begin
  case Key of
    TK_ESCAPE:
      Game.Scenes.SetScene(scRace);
    TK_SPACE:
      begin
        repeat
          NewName := GetRandomName;
          if NewName = '' then
            Break;
        until Game.Hero.Name <> NewName;
        Game.Hero.Name := NewName;
        Render;
      end;
    TK_ENTER:
      begin
        with TSceneArchetype(Game.Scenes.GetScene(scArchetype)) do
          ArchetypeIndex := Math.RandomRange(0, Ord(High(THero.TArchetype)));
        Game.Scenes.SetScene(scArchetype);
      end;
  end;
end;

end.
