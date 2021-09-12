unit TheTaleRL.Scenes.Bestiary;

interface

uses
  TheTaleRL.Scenes;

type
  TSceneBestiary = class(TScene)
  private
    FIndex: Integer;
    FArtifactIdent: string;
    FLootIdent: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    property MobIndex: Integer read FIndex write FIndex;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Bestiary,
  TheTaleRL.Scenes.Item;

{ TSceneMob }

constructor TSceneBestiary.Create;
begin
  inherited Create;
  FIndex := 0;
end;

destructor TSceneBestiary.Destroy;
begin
  inherited;
end;

procedure TSceneBestiary.Render;
var
  I: Integer;
  S, Ident, Name, Description, Source, ArtifactName, LootName: string;
begin
  inherited;
  Print(1, Title('Бестиарий Пандоры'));
  // Счит. данных
  Ident := Game.Bestiary.GetIdent(FIndex);
  if not Ident.IsEmpty then
  begin
    Name := Resources.LoadFromFile('Monsters', Ident, 'Name', '');
    Description := Resources.LoadFromFile('Monsters', Ident, 'Description', '');
    Source := Resources.LoadFromFile('Monsters', Ident, 'Source', '');
    FArtifactIdent := Resources.LoadFromFile('Monsters', Ident, 'Artifact', '');
    ArtifactName := Resources.LoadFromFile('Artifacts', FArtifactIdent, 'Name', '');
    FLootIdent := Resources.LoadFromFile('Monsters', Ident, 'Loot', '');
    LootName := Resources.LoadFromFile('Artifacts', FLootIdent, 'Name', '');
    // Список существ
    for I := 0 to Game.Bestiary.Count - 1 do
      Print(1, I + 3, Self.Button(Chr(Ord('A') + I), Resources.LoadFromFile('Monsters', Game.Bestiary.GetIdent(I), 'Name', ''), I = MobIndex));
    // Описание и др. информация
    S := Title('Описание монстра') + #13#10;
    S := S + Description + #13#10;
    S := S + #13#10 + '[color=title]' + Source + '[/color]' + #13#10#13#10;
    if Game.Bestiary.GetKills(FIndex) >= 3 then
      S := S + Button('1', '', False, LootName <> '') + AddLine('Хлам', LootName) + #13#10;
    if Game.Bestiary.GetKills(FIndex) >= 7 then
      S := S + Button('2', '', False, ArtifactName <> '') + AddLine('Артефакт', ArtifactName) + #13#10;
    S := S + '    ' + AddLine('Убито', Game.Bestiary.GetKills(FIndex).ToString) + #13#10;
  end;
  Print((Window.Width div 4) + 1, 3, ((Window.Width div 4) * 3) - 3, Window.Height - 3, S);
  AddButton('Esc', 'Назад');
end;

procedure TSceneBestiary.Update(var Key: Word);
begin
  case Key of
    TK_ESCAPE:
      Game.Scenes.SetScene(scGame);
    TK_1:
      if Game.Bestiary.GetKills(FIndex) >= 3 then
      begin
        if FLootIdent.Trim = '' then
          Exit;
        // Информация о предмете
        with TSceneItem(Game.Scenes.GetScene(scItem)) do
        begin
          ItemIdent := FLootIdent;
          IsAct := False;
        end;
        Game.Scenes.SetScene(scItem, scBestiary);
      end;
    TK_2:
      if Game.Bestiary.GetKills(FIndex) >= 7 then
      begin
        if FArtifactIdent.Trim = '' then
          Exit;
        // Информация об артефакте
        with TSceneItem(Game.Scenes.GetScene(scItem)) do
        begin
          ItemIdent := FArtifactIdent;
          IsAct := False;
        end;
        Game.Scenes.SetScene(scItem, scBestiary);
      end;
    TK_A .. TK_Z:
      begin
        if (Key - TK_A <= Game.Bestiary.Count - 1) then
        begin
          FIndex := Key - TK_A;
          Render;
        end;
      end;
  end;
end;

end.
