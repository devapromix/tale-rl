unit TheTaleRL.Scenes.Abilities;

interface

uses
  System.Classes,
  TheTaleRL.Scenes;

type
  TSceneAbilities = class(TScene)
  private
    FAbilityIndex: Integer;
  public
    constructor Create;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    property AbilityIndex: Integer read FAbilityIndex write FAbilityIndex;
  end;

implementation

{ TSceneAbilities }

uses
  SysUtils,
  BearLibTerminal,
  TheTaleRL.Game;

constructor TSceneAbilities.Create;
begin
  inherited;
  FAbilityIndex := 0;
end;

procedure TSceneAbilities.Render;
var
  S: string;
begin
  Print(1, Title('Выучить новую способность'));

  S := Title(Game.Hero.Abilities.GetAbility(FAbilityIndex).Name) + ' УРОВЕНЬ ' +
    IntToStr(Game.Hero.Abilities.GetAbility(FAbilityIndex).Level + 1) + #13#10;
  S := S + Game.Hero.Abilities.GetAbility(FAbilityIndex).Description;
  Print(S);
  AddButton('Enter', 'Выучить');
  AddButton('Esc', 'Назад');
end;

procedure TSceneAbilities.Update(var Key: Word);
begin
  case Key of
    TK_ESCAPE:
      Game.Scenes.SetScene(scHero);
    TK_ENTER:
      begin
        if Game.Hero.AbPoint > 0 then
        begin
          Game.Hero.AbPoint := Game.Hero.AbPoint - 1;
          Game.Hero.Abilities.AddLevel(FAbilityIndex);
          Game.Scenes.SetScene(scHero);
        end;
      end;
  end;

end;

end.
