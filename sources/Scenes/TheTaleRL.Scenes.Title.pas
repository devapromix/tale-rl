unit TheTaleRL.Scenes.Title;

interface

uses
  System.Classes,
  TheTaleRL.Scenes;

type
  TSceneTitle = class(TScene)
  private

  public
    constructor Create;
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

{ TSceneTitle }

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Scenes.Race;

constructor TSceneTitle.Create;
begin
  inherited;

end;

procedure TSceneTitle.Render;
var
  S: string;
begin
  S := '[color=light red]THE TALE Roguelike[/color]' + #13#10#13#10;
  S := S + '' + #13#10#13#10;
  S := S + 'Игра на КРИЛ по мотивам вселенной игры «Сказка» — [color=blue]https://the-tale.org[/color]' + #13#10#13#10;
  S := S + 'За помощь и советы по лору автор выражает благодарность следующим игрокам в «Сказку»: [color=light yellow]Шерхан, IoannSahin...[/color]' + #13#10#13#10;
  S := S + 'Идет генерация мира... Нажмите [color=button][[ENTER]][/color] и дождитесь полной генерации мира...' + #13#10#13#10;
  S := S + '' + #13#10#13#10;
  S := S + 'Apromix (C) 2018' + #13#10#13#10;
  Print(S);
end;

procedure TSceneTitle.Update(var Key: Word);
begin
  case Key of
    TK_ENTER:
      begin
        with TSceneRace(Game.Scenes.GetScene(scRace)) do
          RaceIndex := Math.RandomRange(0, RacesCount);
        Game.Scenes.SetScene(scRace);
        //Game.Scenes.SetScene(scGame);
      end;
  end;
end;

end.
