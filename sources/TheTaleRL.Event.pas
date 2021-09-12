unit TheTaleRL.Event;

interface

uses
  Classes,
  TheTaleRL.Story;

type
  TEvent = class(TStory)
  private
    FSections: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    function GetDialog: TDialogRec;
    procedure DoRandomEvent;
    procedure DoRandomFight;
    procedure Act;
    procedure Run;
  end;

implementation

uses
  Math,
  SysUtils,
  Vcl.Dialogs,
  TheTaleRL.Game,
  TheTaleRL.Scenes, TheTaleRL.Scenes.Fight;

{ TMyClass }

procedure TEvent.Act;
begin
  case GetDialog.DialogAct of
    daFindGold:
      if GetDialog.Value > 0 then
        Game.Hero.Inventory.Gold := Game.Hero.Inventory.Gold + GetDialog.Value;
    daGainExp:
      if GetDialog.Value > 0 then
      begin
        ShowMessage(IntToStr(GetDialog.Value));
        Game.Hero.GainExp(GetDialog.Value);
      end;
  end;

end;

constructor TEvent.Create;
begin
  inherited;
  FSections := TStringList.Create;
  Resources.ReadSections('Events', FSections);
end;

destructor TEvent.Destroy;
begin
  FreeAndNil(FSections);
  inherited;
end;

procedure TEvent.DoRandomEvent;
var
  I: Integer;
begin
  // Случайное событие
  repeat
    I := Math.RandomRange(0, FSections.Count) * 10;
    Game.Event.DialogIndex := I;
  until GetDialog.Text <> '';
  Game.Event.Run;
  Game.Scenes.SetScene(scEvent);
end;

procedure TEvent.DoRandomFight;
var
  MobIdent: string;
begin
  with TSceneFight(Game.Scenes.GetScene(scFight)) do
    if not Game.Hero.HP.IsMin then
    begin
      // Генер. случай. вид монстра
      MobIdent := Resources.RandomSectionIdent('Monsters');
      // Название монстра
      Game.Enemy.Name := Resources.LoadFromFile('Monsters', MobIdent, 'Name', '');
      // Его здоровье
      Game.Enemy.HP.Max := Math.RandomRange(((Game.Hero.HP.Max div 10) - 1) * 10, ((Game.Hero.HP.Max div 10) + 1) * 10);
      Game.Enemy.HP.ToMax;
      // Уровень
      Game.Enemy.Level := Game.Hero.Level;
      // Бой
      Game.Fight.Start(Game.Hero, Game.Enemy, MobIdent);
      Game.Scenes.SetScene(scFight);
    end;
end;

function TEvent.GetDialog: TDialogRec;
begin
  Result := GetDialogRec('Events');
end;

procedure TEvent.Run;
begin
  ShowMessage('Text');
end;

end.
