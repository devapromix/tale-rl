unit TheTaleRL.Scenes.Background;

interface

uses
  System.Classes,
  TheTaleRL.Scenes;

type
  TSceneBackground = class(TScene)
  private

  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

{ TSceneBackground }

uses
  SysUtils,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Hero;

constructor TSceneBackground.Create;
begin
  inherited;

end;

destructor TSceneBackground.Destroy;
begin

  inherited;
end;

procedure TSceneBackground.Render;
var
  S: string;
begin
  S := Title('Как сложилась судьба Героя?') + #13#10#13#10;
  S := S + Game.Hero.Background + #13#10#13#10;
  S := S + ' ' + Button('Space', 'Случайно');
  S := S + ' ' + Button('Enter', 'Принять');
  Print(S.Trim);
end;

procedure TSceneBackground.Update(var Key: Word);
begin
  case Key of
    TK_ESCAPE:
      Game.Scenes.SetScene(scArchetype);
    TK_SPACE:
      begin
        Game.Hero.Generate;
        Render;
      end;
    TK_ENTER:
      begin
        Game.Scenes.SetScene(scStory);
      end;
  end;

end;

end.
