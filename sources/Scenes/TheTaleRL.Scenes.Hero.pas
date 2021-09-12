unit TheTaleRL.Scenes.Hero;

interface

uses
  TheTaleRL.Scenes,
  TheTaleRL.ResObject;

type
  TSceneHero = class(TScene)
  private
    FAbilityIndex: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    function AbCount: Integer;
    function BattleAbCount: Integer;
    procedure RenderHero;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Hero,
  TheTaleRL.Scenes.Abilities;

{ TScenePlayer }

function TSceneHero.AbCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Game.Hero.Abilities.Count - 1 do
    if Game.Hero.Abilities.GetAbility(I).Level > 0 then
      Inc(Result);
end;

function TSceneHero.BattleAbCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Game.Hero.Abilities.Count - 1 do
    if Game.Hero.Abilities.GetAbility(I).Level > 0 then
      Inc(Result);
end;

constructor TSceneHero.Create;
begin
  inherited Create;
  FAbilityIndex := 0;
end;

destructor TSceneHero.Destroy;
begin
  inherited;
end;

procedure TSceneHero.Render;
var
  S: string;
  I, J, R: Integer;
begin
  Print(1, Title(Game.Hero.GetInfo));
  // Герой
  RenderHero;
  // Статистика
  Print(1, 10, Title('Статистика'));
  Print(1, 11, AddLine('Сделано ходов', Game.Turn.ToString));
  Print(1, 12, AddLine('Убито врагов', Game.Kill.ToString));
  Print(1, 13, AddLine('Воскрешений Хранителем', Game.Revs.ToString));
  Print(1, 15, AddLine('Собрано Чаш Силы', Game.Cups.ToString));
  // Print(1, 12, AddLine('', Game.Kill.ToString));
  J := 0;
  // Выуч. способности
  S := Title('Способности') + #13#10;
  for I := 0 to Game.Hero.Abilities.Count - 1 do
    if (Game.Hero.Abilities.GetAbility(I).Level > 0) then
    begin
      S := S + AddLine(Chr(Ord('A') + J), Game.Hero.Abilities.GetAbility(I).Name, Game.Hero.Abilities.GetAbility(I).Level.ToString,
        J = FAbilityIndex) + #13#10;
      Inc(J);
    end;
  R := Game.Hero.Abilities.CurentAbilityIndex(FAbilityIndex);
  // Описание способности
  S := S + #13#10 + Title('Описание') + #13#10;
  S := S + Game.Hero.Abilities.GetAbility(R).Description + #13#10;
  if (Game.Hero.Abilities.GetAbility(R).ActivType.Trim.ToUpper = 'ACTIVE') then
  begin
    S := S + #13#10 + Title('Активная способность') + #13#10 + Resources.LoadFromFile('Abilities', 'Main', 'ActiveTypeDescription', '') + #13#10;
  end;
  if (Game.Hero.Abilities.GetAbility(R).ActivType.Trim.ToUpper = 'PASSIVE') then
  begin
    S := S + #13#10 + Title('Пассивная способность') + #13#10 + Resources.LoadFromFile('Abilities', 'Main', 'PassiveTypeDescription', '') + #13#10;
  end;
  if (Game.Hero.Abilities.GetAbility(R).AbilityType.Trim.ToUpper = 'BATTLE') then
  begin
    S := S + #13#10 + Title('Боевая способность') + #13#10 + Resources.LoadFromFile('Abilities', 'Main', 'BattleTypeDescription', '') + #13#10;
  end;
  if (Game.Hero.Abilities.GetAbility(R).AbilityType.Trim.ToUpper = 'NONBATTLE') then
  begin
    S := S + #13#10 + Title('Мирная способность') + #13#10 + Resources.LoadFromFile('Abilities', 'Main', 'NonBattleTypeDescription', '') + #13#10;
  end;
  Print((Window.Width div 4) + 1, 3, (Window.Width div 4), Window.Height - 3, S);
  // О жизни персонажа
  S := Title('О жизни ' + Game.Hero.Name + '...') + #13#10 + Game.Hero.Background + #13#10#13#10;
  // О смерти персонажа
  S := S + Title('О смерти ' + Game.Hero.Name + '...') + #13#10 + Game.Hero.Death + #13#10#13#10;
  // S := S + Title('Причина смерти...') + #13#10 + Game.Hero.Death + #13#10#13#10;
  Print((Window.Width div 2) + 1, 3, (Window.Width div 2) - 2, Window.Height - 3, S);
  // Клавиши
  if Game.Hero.AbPoint > 0 then
    AddButton('Space', 'Выучить способность');
  AddButton('Tab', 'Сумка');
  AddButton('Esc', 'Назад');
end;

procedure TSceneHero.RenderHero;
begin
  Print(1, 3, Title('Герой'));
  Print(1, 4, AddLine('Здоровье', Game.Hero.HP.ToString));
  Print(1, 5, AddLine('Опыт', Format('%d/%d', [Game.Hero.Experience, Game.Hero.GetDeltaToNext])));
  Print(1, 6, AddLine('Физическая сила', Game.Hero.Might.ToString));
  Print(1, 7, AddLine('Магическая сила', Game.Hero.Magic.ToString));
  Print(1, 8, AddLine('Золото', Game.Hero.Inventory.Gold.ToString));
end;

procedure TSceneHero.Update(var Key: Word);
begin
  case Key of
    TK_ESCAPE:
      Game.Scenes.SetScene(scGame);
    TK_TAB:
      Game.Scenes.SetScene(scInventory);
    TK_SPACE:
      if Game.Hero.AbPoint > 0 then
      begin
        TSceneAbilities(Game.Scenes.GetScene(scAbilities)).AbilityIndex := Math.RandomRange(1, Game.Hero.Abilities.Count);
        Game.Scenes.SetScene(scAbilities);
      end;
    TK_A .. TK_Z:
      begin
        if (Key - TK_A <= AbCount - 1) then
        begin
          FAbilityIndex := Key - TK_A;
          Render;
        end;
      end;
  end;
end;

end.
