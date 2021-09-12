unit TheTaleRL.Scenes.Item;

interface

uses
  TheTaleRL.Scenes;

type
  TSceneItem = class(TScene)
  private
    FItemIdent: string;
    FIsAct: Boolean;
    FMobIdent: string;
    FMobName: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    property ItemIdent: string read FItemIdent write FItemIdent;
    property IsAct: Boolean read FIsAct write FIsAct;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Bestiary,
  TheTaleRL.Scenes.Bestiary;

{ TSceneItem }

constructor TSceneItem.Create;
begin
  inherited Create;
  IsAct := False;
end;

destructor TSceneItem.Destroy;
begin
  inherited;
end;

procedure TSceneItem.Render;
var
  S, Name, Description, Source: string;
  Power: Integer;
const
  PowerStr: array [0 .. 5] of string = ('-', 'физическая', 'ближе к силе', 'равновесие', 'ближе к магии', 'магическая');
begin
  Name := Resources.LoadFromFile('Artifacts', ItemIdent, 'Name', '');
  Description := Resources.LoadFromFile('Artifacts', ItemIdent, 'Description', '');
  Source := Resources.LoadFromFile('Artifacts', ItemIdent, 'Source', '');
  Power := EnsureRange(Resources.LoadFromFile('Artifacts', ItemIdent, 'Power', 0), 0, 5);
  FMobIdent := Resources.LoadFromFile('Artifacts', ItemIdent, 'Mob', '');
  FMobName := Resources.LoadFromFile('Monsters', FMobIdent, 'Name', '-');
  Print(1, Title(Name));
  S := Description + #13#10;
  S := S + #13#10 + '[color=title]' + Source + '[/color]' + #13#10#13#10;
  S := S + Button('1', '', False, FMobName <> '-') + AddLine('Моб', FMobName) + #13#10;
  S := S + '    ' + AddLine('Сила', PowerStr[Power]) + #13#10;
  Print(1, 3, Window.Width - 2, Window.Height - 3, S);
  if IsAct then
  begin

  end;
  AddButton('Esc', 'Назад');
end;

procedure TSceneItem.Update(var Key: Word);
var
  I: Integer;
begin
  case Key of
    TK_ESCAPE:
      Game.Scenes.GoBack;
    TK_1:
      if FMobName <> '-' then
      begin
        // Информация о монстре
        for I := 0 to Game.Bestiary.Count - 1 do
          if FMobIdent.Trim = Game.Bestiary.GetIdent(I) then
          begin
            with TSceneBestiary(Game.Scenes.GetScene(scBestiary)) do
            begin
              MobIndex := I;
              Game.Scenes.SetScene(scBestiary);
            end;
            Exit;
          end;
      end;
  end;
  if IsAct then
    case Key of
      TK_ENTER:
        ;
    end;
end;

end.
