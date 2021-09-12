unit TheTaleRL.Scenes.Town;

interface

uses
  TheTaleRL.Scenes;

type
  TSceneTown = class(TScene)
  private
    FQDone: Boolean;
    FAnsFlag: Boolean;
    FAnsFlagIndex: Integer;
    FTownIndex: Integer;
    FSelIndex: Integer;
    function GetTownSpecialization: string;
    function GetAllName(const I: Integer): string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    property TownIndex: Integer read FTownIndex write FTownIndex;
    property SelIndex: Integer read FSelIndex write FSelIndex;
    property QDone: Boolean read FQDone write FQDone;
  end;

implementation

uses
  SysUtils,
  Classes,
  Vcl.Dialogs,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Master,
  TheTaleRL.Town,
  TheTaleRL.Hero;

{ TSceneTown }

constructor TSceneTown.Create;
begin
  inherited Create;
  FSelIndex := 0;
  FTownIndex := 0;
  FAnsFlag := False;
  FQDone := False;
  FAnsFlagIndex := 0;
end;

destructor TSceneTown.Destroy;
begin
  inherited;
end;

function TSceneTown.GetAllName(const I: Integer): string;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Text := Resources.LoadFromFile('Masters', 'Types', PersTypeName[Game.Towns.Masters.GetMaster(I).PersonType], '');
    Result := Format('%s  — %s, %s', [Game.Towns.Masters.GetMaster(I).Name, Game.Hero.GetRaceName(Game.Towns.Masters.GetMaster(I).Gender,
      Game.Towns.Masters.GetMaster(I).Race), SL[Ord(Game.Towns.Masters.GetMaster(I).Gender)]]);
  finally
    FreeAndNil(SL);
  end;
end;

function TSceneTown.GetTownSpecialization: string;
begin
  Result := Resources.LoadFromFile('Towns', 'Specializations', SpecName[Game.Towns.GetTown(TownIndex).Specialization], '')
end;

procedure TSceneTown.Render;
var
  I, J, K: Integer;
  S: string;
  SL: TStringList;
begin
  inherited;
  Print(1, Title(Format('%s %s', [GetTownSpecialization, Game.Towns.GetTown(TownIndex).Name])));

  // Описание города
  Print(1, 2, Title('Город'));
  Print(1, 3, Button(Chr(Ord('A')), Format('%s (%d)', [Game.Towns.GetTown(TownIndex).Name, Game.Towns.GetTown(TownIndex).Level]), FSelIndex = 0));

  // Список мастеров города
  Print(1, 5, Title('Мастера'));
  J := 0;
  for I := 0 to Game.Towns.Masters.Count - 1 do
    if Game.Towns.Masters.GetMaster(I).TownIdent = FTownIndex then
    begin
      Print(1, J + 6, Button(Chr(I + Ord('B')), GetAllName(I), FSelIndex = J + 1));
      Inc(J);
    end;

  // Сообщение об успешно выполненном задании
  K := (FTownIndex * 3) + (FSelIndex - 1);
  if FQDone and (K = Game.Quest.NextMasterIdent) then
  begin
    S := Title(Game.Towns.Masters.GetMaster(K).Name) + #13#10;
    S := S + '-' + Resources.RandomValue('Masters', 'Quest_Comp') + #13#10#13#10;
    S := S + Self.AddLine('Опыт', IntToStr(Game.Quest.ExpBonus)) + #13#10;
    S := S + Self.AddLine('Золото', IntToStr(Game.Quest.GoldBonus)) + #13#10#13#10;
    S := S + Button('Enter', 'Забрать вознаграждение!');
    Print((Window.Width div 3) + 1, 3, ((Window.Width div 3) * 2) - 3, Window.Height - 3, S);
    Exit;
  end;

  //
  if FSelIndex = 0 then
  begin
    // Описание города
    S := Title('Описание') + #13#10;
    S := S + Game.Towns.GetTown(TownIndex).Description + #13#10#13#10;
    // Параметры
    S := S + Title('Параметры') + #13#10;
    S := S + AddLine('Размер города', Game.Towns.GetTown(TownIndex).Level.ToString) + #13#10;
    S := S + AddLine('Население', Game.Towns.GetTown(TownIndex).Pop.ToString) + #13#10;
    S := S + AddLine('Культура', Game.Towns.GetTown(TownIndex).Cult.ToString + '%') + #13#10;
    S := S + AddLine('Безопасность', Game.Towns.GetTown(TownIndex).Safety.ToString + '%') + #13#10;
    // Демография
    S := S + #13#10 + Title('Демография') + #13#10;
    S := S + AddLine(Resources.LoadFromFile('Races', 'Goblin', 'Title', ''), Game.Towns.GetTown(TownIndex).Goblin.ToString + '%') + #13#10;
    S := S + AddLine(Resources.LoadFromFile('Races', 'Elf', 'Title', ''), Game.Towns.GetTown(TownIndex).Elf.ToString + '%') + #13#10;
    S := S + AddLine(Resources.LoadFromFile('Races', 'Human', 'Title', ''), Game.Towns.GetTown(TownIndex).Human.ToString + '%') + #13#10;
    S := S + AddLine(Resources.LoadFromFile('Races', 'Orc', 'Title', ''), Game.Towns.GetTown(TownIndex).Orc.ToString + '%') + #13#10;
    S := S + AddLine(Resources.LoadFromFile('Races', 'Dwarf', 'Title', ''), Game.Towns.GetTown(TownIndex).Dwarf.ToString + '%') + #13#10;
  end
  else
  begin
    // Диалог с мастером
    K := (FTownIndex * 3) + (FSelIndex - 1);
    S := Title(Game.Towns.Masters.GetMaster(K).Name) + #13#10;
    if FAnsFlag then
      case FAnsFlagIndex of
        0: // Мастер рассказывает сам о себе
          begin
            SL := TStringList.Create;
            try
              SL.Text := Resources.LoadFromFile('Masters', 'Types', PersTypeName[Game.Towns.Masters.GetMaster(K).PersonType], '');
              S := S + '-' + Format(Resources.RandomValue('Masters', 'About_Master'),
                [Game.Towns.Masters.GetMaster(K).Name, Game.Hero.GetRaceName(Game.Towns.Masters.GetMaster(K).Gender,
                Game.Towns.Masters.GetMaster(K).Race), SL[Ord(Game.Towns.Masters.GetMaster(K).Gender)]]);
            finally
              FreeAndNil(SL);
            end;
          end;
        1: // Мастер дает Герою задание
          begin
            if Game.Quest.IsAct then
              if Game.Quest.PrevMasterIdent = K then
                S := S + '-' + Resources.RandomValue('Masters', 'Quest_Do_It')
              else
                S := S + '-' + Resources.RandomValue('Masters', 'Quest_Not_Comp')
            else
            begin
              S := S + '-' + Resources.LoadFromFile('Quests', 'Dialog', 'Quest' + Game.Towns.Masters.GetMaster(K).QuestIdent.ToString, '') +
                #13#10#13#10;
              S := S + Button('Enter', 'Взять задание!');
            end;
          end;
        2: // Торговля с Мастером
          begin
            S := S + '-Упс... На эту функцию у автора не хватило времени :(';
          end;
      end
    else
    begin
      S := S + '-' + Resources.RandomValue('Masters', 'Welcome') + #13#10#13#10;
      // Меню диалога
      S := S + Button('1', '-' + Resources.RandomValue('Masters', 'About')) + #13#10;
      S := S + Button('2', '-' + Resources.RandomValue('Masters', 'Quest') + ' [[задание]]') + #13#10;
      S := S + Button('3', '-' + Resources.RandomValue('Masters', 'Trade') + ' [[торговля]]') + #13#10;
    end;
  end;
  //
  Print((Window.Width div 3) + 1, 3, ((Window.Width div 3) * 2) - 3, Window.Height - 3, S);
  AddButton('Esc', 'Назад');
end;

procedure TSceneTown.Update(var Key: Word);
var
  I: Integer;
begin
  case Key of
    TK_ESCAPE:
      begin
        // Задание выполнено
        if Game.Quest.IsAct and FQDone then
          Exit;
        // Выход из ветки диалога
        if FAnsFlag then
        begin
          FAnsFlag := False;
          Render;
          Exit;
        end;
        // Выход из города
        Game.Scenes.SetScene(scGame);
      end;
    TK_ENTER:
      begin
        // Взять задание
        if FAnsFlag and (FAnsFlagIndex = 1) and not Game.Quest.IsAct then
        begin
          Game.Quest.Gen((FTownIndex * 3) + (FSelIndex - 1));
          Game.Log.Add('Получено новое задание.');
        end;
        // Задание выполнено
        if Game.Quest.IsAct and FQDone then
        begin
          Game.Log.Add('Задание выполнено.');
          Game.Hero.Inventory.Gold := Game.Hero.Inventory.Gold + Game.Quest.GoldBonus;
          Game.Hero.GainExp(Game.Quest.ExpBonus);
          Game.Quest.Clear;
          FQDone := False;
        end;
      end;
    TK_A:
      if not FAnsFlag then
      begin
        FSelIndex := 0;
        Render;
      end;
    TK_B .. TK_Y:
      if not FAnsFlag then
      begin
        I := ((Key - TK_B) - (FTownIndex * 3)) + 1;
        if (I in [1 .. 3]) then
        begin
          FSelIndex := I;
          Render;
        end;
      end;
    TK_1 .. TK_3:
      if not FAnsFlag then
      begin
        FAnsFlag := True;
        FAnsFlagIndex := (Key - TK_1);
        Render;
      end;
  end;

end;

end.
