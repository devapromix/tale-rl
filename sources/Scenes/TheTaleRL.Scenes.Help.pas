unit TheTaleRL.Scenes.Help;

interface

uses
  Classes,
  TheTaleRL.Scenes;

type
  TSceneHelp = class(TScene)
  private type
    TMenu = record
      Menu: string;
      Name: string;
      Text: string;
    end;
  private
    FIndex: Integer;
    FMenu: TArray<TMenu>;
  public
    constructor Create;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    destructor Destroy; override;
    property MenuIndex: Integer read FIndex write FIndex;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TheTaleRL.Game;

{ TSceneMob }

constructor TSceneHelp.Create;
var
  SL: TStringList;
  I: Byte;
begin
  inherited Create;
  FIndex := 0;
  SL := TStringList.Create;
  try
    Resources.ReadSections('Help', SL);
    SetLength(FMenu, SL.Count);
    for I := 0 to SL.Count - 1 do
    begin
      FMenu[I].Menu := Resources.LoadFromFile('Help', SL[I].Trim, 'Menu', '');
      FMenu[I].Name := Resources.LoadFromFile('Help', SL[I].Trim, 'Name', '');
      FMenu[I].Text := Resources.LoadFromFile('Help', SL[I].Trim, 'Text', '');
    end;
  finally
    FreeAndNil(SL);
  end;
end;

procedure TSceneHelp.Render;
var
  I: Byte;
  S: string;
begin
  inherited;
  Print(1, Title('Краткий Путеводитель по Пандоре Тарна Серого, учёного Университета Естественных Наук'));
  // Меню справки
  for I := 0 to High(FMenu) do
    Print(1, I + 3, Self.Button(Chr(Ord('A') + I), FMenu[I].Menu, I = MenuIndex));
  // Страница
  S := Format('[color=title]%s[/color]', [FMenu[MenuIndex].Name]) + #13#10#13#10 + FMenu[MenuIndex].Text;
  Print((Window.Width div 4) + 1, 3, ((Window.Width div 4) * 3) - 3, Window.Height - 3, S);
  // Клавиши
  AddButton('Esc', 'Назад');
end;

procedure TSceneHelp.Update(var Key: Word);
begin
  case Key of
    TK_ESCAPE:
      Game.Scenes.SetScene(scGame);
    TK_A .. TK_Z:
      begin
        if (Key - TK_A <= High(FMenu)) then
        begin
          FIndex := Key - TK_A;
          Render;
        end;
      end;
  end;
end;

destructor TSceneHelp.Destroy;
begin
  inherited;
end;

end.
