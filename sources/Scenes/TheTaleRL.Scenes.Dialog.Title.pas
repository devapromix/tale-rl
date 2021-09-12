unit TheTaleRL.Scenes.Dialog.Title;

interface

uses
  System.Classes,
  TheTaleRL.Scenes;

type
  TSceneDialogTitle = class(TScene)
  private
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

{ TSceneDialogTitle }

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Hero,
  TheTaleRL.Mob;

constructor TSceneDialogTitle.Create;
begin
  inherited;

end;

destructor TSceneDialogTitle.Destroy;
begin

  inherited;
end;

procedure TSceneDialogTitle.Render;
begin
  // Считывание данных из файла

end;

procedure TSceneDialogTitle.Update(var Key: Word);
begin
  case Key of
    TK_ESCAPE:
      Game.Scenes.SetScene(scTown);
  end;
end;

end.
