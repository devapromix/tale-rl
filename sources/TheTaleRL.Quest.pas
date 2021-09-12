unit TheTaleRL.Quest;

interface

uses
  TheTaleRL.ResObject;

type
  TQuest = class(TResObject)
  private
    FIsAct: Boolean;
    FNextTownIdent: Integer;
    FPrevTownIdent: Integer;
    FPrevMasterIdent: Integer;
    FNextMasterIdent: Integer;
    FName: string;
    FDescription: string;
    FGoldBonus: Integer;
    FExpBonus: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Gen(const CurrMaster: Integer);
    property IsAct: Boolean read FIsAct write FIsAct;
    property NextTownIdent: Integer read FNextTownIdent write FNextTownIdent;
    property PrevTownIdent: Integer read FPrevTownIdent write FPrevTownIdent;
    property NextMasterIdent: Integer read FNextMasterIdent write FNextMasterIdent;
    property PrevMasterIdent: Integer read FPrevMasterIdent write FPrevMasterIdent;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property GoldBonus: Integer read FGoldBonus write FGoldBonus;
    property ExpBonus: Integer read FExpBonus write FExpBonus;
  end;

implementation

uses
  Math,
  SysUtils,
  Vcl.Dialogs,
  TheTaleRL.Hero,
  TheTaleRL.Game;

{ TQuest }

procedure TQuest.Clear;
begin
  FIsAct := False;
  NextTownIdent := -1;
  PrevTownIdent := -1;
  NextMasterIdent := -1;
  PrevMasterIdent := -1;
  FName := '';
  FDescription := '';
  FGoldBonus := 0;
  FExpBonus := 0;
end;

constructor TQuest.Create;
begin
  inherited;
  Clear;
end;

destructor TQuest.Destroy;
begin

  inherited;
end;

procedure TQuest.Gen(const CurrMaster: Integer);
var
  I: Integer;
begin
  // Генерация нового задания
  if not FIsAct then
  begin
    Clear;
    // Опред. тек. город
    for I := 0 to Game.Towns.Count - 1 do
      if ((Game.Towns.GetTown(I).X = Game.Hero.X) and (Game.Towns.GetTown(I).Y = Game.Hero.Y)) then
      begin
        PrevTownIdent := I;
        Break;
      end;
    // Выбираем след. цель квеста
    repeat
      NextTownIdent := Math.RandomRange(0, Game.Towns.Count - 1);
    until NextTownIdent <> PrevTownIdent;
    // Мастер, который дает квест
    PrevMasterIdent := CurrMaster;
    // Мастер-цель квеста
    NextMasterIdent := (NextTownIdent * 3) + Math.RandomRange(0, 3);
    // Название квеста
    Name := Resources.LoadFromFile('Quests', 'Name', 'Quest' + Game.Towns.Masters.GetMaster(CurrMaster).QuestIdent.ToString, '');
    // Описание квеста
    Description := Resources.LoadFromFile('Quests', 'Description', 'Quest' + Game.Towns.Masters.GetMaster(CurrMaster).QuestIdent.ToString, '');
    // Золото за квест
    GoldBonus := (Game.Hero.Level * 10) + ((Math.RandomRange(0, 5) + 1) * 10);
    // Опыт за квест
    ExpBonus := (Game.Hero.Level * 5) + Math.RandomRange(1, 10);
    // Задание становится активным
    FIsAct := True;
  end;
end;

end.
