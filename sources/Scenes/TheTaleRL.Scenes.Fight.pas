unit TheTaleRL.Scenes.Fight;

interface

uses
  Classes,
  TheTaleRL.Scenes;

type
  TSceneFight = class(TScene)
  private
    SL: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  Math,
  SysUtils,
  Vcl.Dialogs,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Town,
  TheTaleRL.Hero;

{ TSceneFight }

constructor TSceneFight.Create;
begin
  inherited;
  SL := TStringList.Create;
end;

destructor TSceneFight.Destroy;
begin
  FreeAndNil(SL);
  inherited;
end;

procedure TSceneFight.Render;
var
  S, E: string;
  I, J, R: Integer;
begin
  inherited;
  Print(1, Title('Бой!'));

  // Герой
  Print(1, 3, Title('Герой'));
  Print(1, 4, AddLine('Здоровье', Game.Hero.HP.ToString));

  // Способности Героя
  Print(1, 6, Title('Боевые навыки'));
  Print(1, 7, Button(Chr(Ord('A')), 'Удар', False, not Game.Fight.IsFinish));

  J := 0;
  for I := 0 to Game.Hero.Abilities.Count - 1 do
  begin
    R := Game.Hero.Abilities.CurentAbilityIndex(I);
    if (R >= 0) then
      if (Game.Hero.Abilities.GetAbility(R).AbilityType.Trim.ToUpper = 'BATTLE') then
        if (Game.Hero.Abilities.GetAbility(R).ActivType.Trim.ToUpper = 'ACTIVE') then
          if (Game.Hero.Abilities.GetAbility(I).Level > 0) then
          begin
            Print(1, 7 + J, Button(Chr(Ord('A') + J), Game.Hero.Abilities.GetAbility(I).Name, False, not Game.Fight.IsFinish));
            Inc(J);
          end;
  end;

  // Выпить зелье
  Print(1, 8 + J, Title('Пояс'));
  Print(1, 9 + J, Button(Chr(Ord('Q')), Format('Выпить зелье лечения (%d)', [Game.Hero.Inventory.Potions]), False, Game.Fight.IsQuaff));

  // Отступление
  Print(1, 11 + J, Title('Отступление'));
  Print(1, 12 + J, Button(Chr(Ord('Z')), 'Отступить', False, not Game.Fight.IsFinish));

  // Лог
  E := '';
  if Game.Fight.Defender.Poisoned then
    E := E + ' [color=green]ОТРАВЛЕН[/color]';
  if Game.Fight.Defender.Burned then
    E := E + ' [color=red]ГОРИТ[/color]';
  if E <> '' then
    E := Format(' [[%s]]', [E.Trim]);
  S := Format('%s (Здоровье %s)' + E, [Game.Fight.Defender.Name, Game.Fight.Defender.HP.ToString]) + #13#10#13#10;
  SL.Text := Game.Fight.GetLog;
  J := Max(SL.Count - (Window.Height - 9), 0);
  for I := SL.Count - 1 downto J do
    S := S + SL[I] + #13#10;
  Print((Window.Width div 3) + 1, 3, ((Window.Width div 3) * 2) - 3, Window.Height - 3, S);

  // Run
  if Game.Fight.IsFinish then
    Print(1, Window.Height - 2, Button('Esc', 'Выход', False));
end;

procedure TSceneFight.Update(var Key: Word);
var
  I, J, R: Integer;
begin
  case Key of
    TK_ESCAPE:
      if Game.Fight.IsFinish then
      begin
        // Если умер - воскрешаем
        if Game.Hero.HP.IsMin then
        begin
          Game.Log.Add('[color=light blue]Герой воскрешен Хранителем!!![/color]');
          Game.Hero.HP.ToMax;
          Game.Revs := Game.Revs + 1;
          // Первая Чаша Силы
          for I := 1 to 3 do
            if (Game.Hero.Level >= I * 2) and not Game.IsCup[I] then
            begin
              Game.Scenes.SetScene(scStory);
              Game.Log.Add('[color=yellow]Вы нашли Чашу Силы![/color]');
              Game.Cups := Game.Cups + 1;
              Game.IsCup[I] := True;
              Exit;
            end;
        end;
        Game.Scenes.SetScene(scGame);
      end;
    // Aтака
    TK_A .. TK_P:
      if not Game.Fight.IsFinish then
      begin
        J := 0;
        for I := 0 to Game.Hero.Abilities.Count - 1 do
        begin
          R := Game.Hero.Abilities.CurentAbilityIndex(I);
          if (R >= 0) then
            if (Game.Hero.Abilities.GetAbility(R).AbilityType.Trim.ToUpper = 'BATTLE') then
              if (Game.Hero.Abilities.GetAbility(R).ActivType.Trim.ToUpper = 'ACTIVE') then
                if (Game.Hero.Abilities.GetAbility(R).Level > 0) then
                begin
                  if J = Key - TK_A then
                  begin
                    Game.Fight.Round(R);
                    Render;
                    Exit;
                  end;
                  Inc(J);
                end;
        end;
      end;
    // Выпить зелье
    TK_Q:
      if Game.Fight.IsQuaff then
      begin
        Game.Fight.Quaff;
        Render;
      end;
    // Побег
    TK_Z:
      if not Game.Fight.IsFinish then
      begin
        Game.Fight.IsFinish := True;
        Game.Fight.Run;
        Render;
      end;
  end;
end;

end.
