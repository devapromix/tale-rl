unit TheTaleRL.Scenes.Inventory;

interface

uses
  TheTaleRL.Scenes;

type
  TSceneInventory = class(TScene)
  private
    FIsInventory: Boolean;
  public
    constructor Create;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    property IsInventory: Boolean read FIsInventory write FIsInventory;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Inventory,
  TheTaleRL.Scenes.Item,
  TheTaleRL.Equipment,
  TheTaleRL.Scenes.Hero;

{ TSceneInventory }

constructor TSceneInventory.Create;
begin
  inherited;
  FIsInventory := True;
end;

procedure TSceneInventory.Render;
var
  I: Byte;
  S, ArtifactIdent, ArtifactName, T: string;
  E: TEquipment.TEquipmentSlot;
begin
  Print(1, Title(Game.Hero.GetInfo));
  // Герой
  TSceneHero(Game.Scenes.GetScene(scHero)).RenderHero;
  // Предметы на герое
  S := Title('Экипировка') + #13#10;
  for E := Low(TEquipment.TEquipmentSlot) to High(TEquipment.TEquipmentSlot) do
  begin
    ArtifactIdent := Game.Hero.Equipment.GetArtifactIdent(E);
    if ArtifactIdent = '' then
      T := Format('[color=light gray]%s[/color] [color=gray][[%s]][/color]', ['Пусто', Game.Hero.Equipment.GetEquipmentSlotName(E)])
    else
    begin
      ArtifactName := Resources.LoadFromFile('Artifacts', ArtifactIdent, 'Name', '');
      T := Format('%s [color=gray][[%s]][/color]', [ArtifactName, Game.Hero.Equipment.GetEquipmentSlotName(E)]);
    end;
    S := S + Button(Chr(Ord(E) + Ord('A')), T, False, not(ArtifactIdent = '') and not IsInventory) + #13#10;
  end;
  Print(1, 10, (Window.Width div 2) - 2, Window.Height - 3, S);
  // Предметы в мешке
  S := Title(Format('Сумка (%d/%d)', [0, Game.Hero.Inventory.Capacity])) + #13#10;
  for I := 0 to Game.Hero.Inventory.MaxCapacity - 1 do
  begin
    ArtifactIdent := Game.Hero.Inventory.GetArtifactIdent(I);
    ArtifactName := Resources.LoadFromFile('Artifacts', ArtifactIdent, 'Name', '');
    S := S + Button(Chr(I + Ord('A')), ArtifactName, False, IsInventory) + #13#10;
  end;
  Print((Window.Width div 2) + 1, 3, (Window.Width div 2) - 2, Window.Height - 3, S);
  // Клавиши
  if IsInventory then
    AddButton('Space', 'Экипировка')
  else
    AddButton('Space', 'Сумка');
  AddButton('Tab', 'Персонаж');
  AddButton('Esc', 'Назад');
end;

procedure TSceneInventory.Update(var Key: Word);
begin
  case Key of
    TK_ESCAPE:
      Game.Scenes.SetScene(scGame);
    TK_SPACE:
      begin
        IsInventory := not IsInventory;
        Render;
      end;
    TK_TAB:
      Game.Scenes.SetScene(scHero);
    TK_A .. TK_Z:
      begin
        with TSceneItem(Game.Scenes.GetScene(scItem)) do
        begin
          case IsInventory of
            True:
              ItemIdent := Game.Hero.Inventory.GetArtifactIdent(Key - TK_A);
            False:
              ItemIdent := Game.Hero.Equipment.GetArtifactIdent(Key - TK_A);
          end;
          if ItemIdent = '' then
            Exit;
          IsAct := True;
        end;
        Game.Scenes.SetScene(scItem, scInventory);
      end;
  end;
end;

end.
