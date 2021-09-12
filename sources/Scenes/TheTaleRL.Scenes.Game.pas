unit TheTaleRL.Scenes.Game;

interface

uses
  System.Types,
  TheTaleRL.Scenes;

type
  TSceneGame = class(TScene)
  private
    FIsShowTownName: Boolean;
    FDraw: Boolean;
    FPanel: TRect;
    FScreen: TRect;
    procedure ClearPanel;
    procedure ClearScreen;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    property Panel: TRect read FPanel write FPanel;
    property Screen: TRect read FScreen write FScreen;
  end;

implementation

{ TSceneGame }

uses
  SysUtils,
  Vcl.Dialogs,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Scenes.Town,
  TheTaleRL.Scenes.Fight,
  TheTaleRL.Hero,
  TheTaleRL.Town;

procedure TSceneGame.ClearPanel;
begin
  terminal_clear_area(Panel.Left, Panel.Top, Panel.Width, Panel.Height);
end;

procedure TSceneGame.ClearScreen;
begin
  terminal_clear_area(Screen.Left, Screen.Top, Screen.Width, Screen.Height);
end;

constructor TSceneGame.Create;
begin
  inherited Create;
  FDraw := False;
  FIsShowTownName := False;
end;

destructor TSceneGame.Destroy;
begin

  inherited;
end;

procedure TSceneGame.Render;
var
  I, X, Y: Integer;
begin
  terminal_bkcolor('darkest gray');
  // Панель
  ClearPanel;
  // Имя героя, его раса и архетип
  Print(Panel.Left, 1, Format('%s, %s, %s', [Game.Hero.Name, Game.Hero.RaceTitle, Game.Hero.ArchetypeName]));
  Print(Panel.Left, 2, Format('Здоровье %s', [Game.Hero.HP.ToString]));
  Print(Panel.Left, 3, Format('Уровень %d, Опыт %d/%d', [Game.Hero.Level, Game.Hero.Experience, Game.Hero.GetDeltaToNext]));
  //
  terminal_color('gray');
  Game.Log.Render(Panel.Left, Panel.Top, Panel.Width, Panel.Height);
  // Карта
  ClearScreen;
  // Местность
  terminal_layer(0);
  if not FDraw then
  begin
    for Y := 0 to Screen.Height - 1 do
      for X := 0 to Screen.Width - 1 do
        Game.Map.RenderTile(X + Panel.Width + 2, Y + 1, X, Y);
    for I := 0 to Game.Towns.Count - 1 do
    begin
      terminal_print(Game.Towns.GetTown(I).X + Panel.Width + 2, Game.Towns.GetTown(I).Y + 1, '[color=yellow]&[/color]');
      if FIsShowTownName then
        terminal_print(Game.Towns.GetTown(I).X + Panel.Width + 4, Game.Towns.GetTown(I).Y + 1, '[color=dark yellow]' + Game.Towns.GetTown(I).Name +
          '[/color]');
    end;
    FDraw := True;
  end;
  // Герой
  terminal_layer(1);
  ClearScreen;
  terminal_print(Game.Hero.X + Panel.Width + 2, Game.Hero.Y + 1, '[color=green]@[/color]');
  terminal_layer(0);
  //
  terminal_bkcolor('none');
end;

procedure TSceneGame.Update(var Key: Word);
var
  I: Integer;
begin
  FDraw := False;
  FIsShowTownName := False;
  case Key of
    TK_ENTER:
      begin
        for I := 0 to Game.Towns.Count - 1 do
          if ((Game.Towns.GetTown(I).X = Game.Hero.X) and (Game.Towns.GetTown(I).Y = Game.Hero.Y)) then
          begin
            with TSceneTown(Game.Scenes.GetScene(scTown)) do
            begin
              TownIndex := I;
              if Game.Quest.NextTownIdent = I then
                QDone := True;
            end;
            Game.Scenes.SetScene(scTown);
            Break;
          end;
      end;
    TK_SPACE:
      begin
        FIsShowTownName := True;
        Render;
      end;
    TK_R: // Ритуал
      if Game.Cups >= 3 then
      begin
        Game.Scenes.SetScene(scStory);
        Exit;
      end;
    TK_LEFT, TK_KP_4, TK_A:
      Game.Hero.Move(drWest);
    TK_RIGHT, TK_KP_6, TK_D:
      Game.Hero.Move(drEast);
    TK_UP, TK_KP_8, TK_W:
      Game.Hero.Move(drNorth);
    TK_DOWN, TK_KP_2, TK_X:
      Game.Hero.Move(drSouth);
    TK_KP_7, TK_Q:
      Game.Hero.Move(drNorthWest);
    TK_KP_9, TK_E:
      Game.Hero.Move(drNorthEast);
    TK_KP_1, TK_Z:
      Game.Hero.Move(drSouthWest);
    TK_KP_3, TK_C:
      Game.Hero.Move(drSouthEast);
    // TK_ESCAPE:
    // Game.Scenes.SetScene(scTitle);
    TK_SLASH, TK_F1:
      Game.Scenes.SetScene(scHelp);
    TK_L:
      Game.Scenes.SetScene(scQuest);
    TK_H:
      Game.Scenes.SetScene(scHero);
    TK_I:
      Game.Scenes.SetScene(scInventory);
    TK_B:
      Game.Scenes.SetScene(scBestiary);
    // Test
    TK_P:
      begin
         Game.Script.LoadFromFile('test.pas');
         Game.Script.Exec('0');
         Game.Script.Exec('1');
      end;
  end;
end;

end.
