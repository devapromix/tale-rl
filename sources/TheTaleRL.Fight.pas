unit TheTaleRL.Fight;

interface

uses
  TheTaleRL.Mob,
  TheTaleRL.ResObject;

type
  TFight = class(TResObject)
  private
    FDefender: TMob;
    FAttacker: TMob;
    RoundResult: string;
    FRoundN: Byte;
    FIsFinish: Boolean;
    FLog: string;
    FMobIdent: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start(Attacker, Defender: TMob; MobIdent: string);
    procedure Finish;
    function GetRoundResult: string;
    property Attacker: TMob read FAttacker write FAttacker;
    property Defender: TMob read FDefender write FDefender;
    property RoundN: Byte read FRoundN write FRoundN;
    property IsFinish: Boolean read FIsFinish write FIsFinish;
    function IsQuaff: Boolean;
    procedure DoRound(Attacker, Defender: TMob; const AbIndex: Integer = 0);
    procedure Miss(Mob: TMob);
    procedure Run;
    function GetLog: string;
    procedure AddLog;
    procedure Victory;
    procedure Defeat(Mob: TMob);
    procedure Round(const AbIndex: Integer);
    procedure Quaff;
  end;

implementation

{ TFight }

uses
  Math,
  SysUtils,
  Vcl.Dialogs,
  TheTaleRL.Game,
  TheTaleRL.Utils,
  TheTaleRL.Hero;

const
  Enter = #13#10;

procedure TFight.AddLog;
var
  S: string;
begin
  S := '';
  if Game.Fight.RoundN > 0 then
  begin
    if RoundN > 1 then
      S := S + Enter;
    S := S + GetRoundResult;
    S := S + Format('[color=blue]Раунд #%d[/color]' + Enter, [RoundN]);
  end;
  FLog := FLog + S;
end;

constructor TFight.Create;
begin
  inherited Create;

end;

procedure TFight.Defeat(Mob: TMob);
var
  S: string;
begin
  // Поражение героя в бою
  if Mob = Game.Hero then
  begin
    S := Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Defeat') + #32, Mob.Gender = gdMale), [Mob.Name]);
    RoundResult := RoundResult + S;
    Game.Log.Add(S);
    Finish;
  end
  else
  // Поражение моба в бою
  begin
    S := Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Defeat') + #32, Mob.Gender = gdMale), [Mob.Name]);
    S := S + Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Exp') + #32, Game.Hero.Gender = gdMale), [Game.Hero.Name, Mob.Level]);
    RoundResult := RoundResult + S;
    Game.Log.Add(S);
    Victory;
    Finish;
  end;
end;

destructor TFight.Destroy;
begin

  inherited;
end;

procedure TFight.Finish;
begin
  IsFinish := True;
  // Убираем все эффекты
  Attacker.Burned := False;
  Defender.Burned := False;
  Attacker.Poisoned := False;
  Defender.Poisoned := False;
end;

function TFight.GetLog: string;
begin
  Result := FLog;
end;

function TFight.GetRoundResult: string;
begin
  Result := RoundResult.TrimLeft;
end;

function TFight.IsQuaff: Boolean;
begin
  Result := not Game.Hero.HP.IsMin and not Game.Hero.HP.IsMax and (Game.Hero.Inventory.Potions > 0);
end;

procedure TFight.Miss(Mob: TMob);
begin
  RoundResult := RoundResult + Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Miss') + #32, Mob.Gender = gdMale), [Mob.Name]);
end;

procedure TFight.Quaff;
var
  Heal: Integer;
begin
  Heal := Math.RandomRange(7, 12);
  Inc(FRoundN);
  RoundResult := Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Quaff') + #32, Game.Hero.Gender = gdMale), [Attacker.Name, Heal]);
  if Game.Hero.Inventory.Potions > 0 then
    Game.Hero.Inventory.Potions := Game.Hero.Inventory.Potions - 1;
  Attacker.HP.Inc(Heal);
  DoRound(Defender, Attacker);
  RoundResult := RoundResult + Enter;
  Game.Fight.AddLog;
end;

procedure TFight.DoRound(Attacker, Defender: TMob; const AbIndex: Integer = 0);
var
  Ident, S: string;
  L, Damage, Heal: Integer;
begin
  // Полураунд
  if Attacker.HP.IsMin or Defender.HP.IsMin then
    Exit;
  // Эффект "Burned" от способности "ПИРОМАНИЯ"
  if Attacker.Burned then
  begin
    Damage := RandomRange(Defender.GetDamage div 3, (Defender.GetDamage div 2) + 1);
    RoundResult := RoundResult + Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Burned') + #32, Attacker.Gender = gdMale),
      [Attacker.Name, Attacker.Name, Damage]);
    Attacker.HP.Dec(Damage);
    if Attacker.HP.IsMin then
    begin
      Defeat(Attacker);
      Exit;
    end;
    if (Math.RandomRange(0, 2) = 0) then
    begin
      RoundResult := RoundResult + Format(Utils.GetGStr(Resources.RandomValue('Fight', 'After_Burned') + #32, Attacker.Gender = gdMale),
        [Attacker.Name]);
      Attacker.Burned := False;
    end;
  end;
  // Эффект "Poisoned" от способности "ЯД"
  if Attacker.Poisoned then
  begin
    Damage := Math.RandomRange(1, RoundN);
    RoundResult := RoundResult + Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Poisoned') + #32, Attacker.Gender = gdMale),
      [Attacker.Name, Attacker.Name, Damage]);
    Attacker.HP.Dec(Damage);
    if Attacker.HP.IsMin then
    begin
      Defeat(Attacker);
      Exit;
    end;
  end;
  // Промах
  if Math.RandomRange(0, 5) = 0 then
  begin
    Miss(Attacker);
    Exit;
  end;
  // Бой
  if Attacker = Game.Hero then
  begin
    Ident := Game.Hero.Abilities.GetAbility(AbIndex).Ident.ToLower;
    L := Game.Hero.Abilities.GetAbility(AbIndex).Level;
    if L <= 0 then
      Exit;
    // Способность "УДАР" у героя
    if Ident = 'hit' then
    begin
      Damage := Math.RandomRange(Attacker.GetDamage div 3, Attacker.GetDamage + 1);
      // Способность "КРИТИЧЕСКИЙ УДАР" удваивает урон способности "УДАР" у героя
      L := Game.Hero.Abilities.GetAbility(Game.Hero.Abilities.CurentAbilityIndex('Critical_Hit')).Level;
      if ((Game.Hero.Abilities.CurentAbilityIndex('Critical_Hit') >= 0) and (Math.RandomRange(0, 100) + 1 <= L * 10)) then
      begin
        RoundResult := RoundResult + Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Critical_Hit') + #32, Game.Hero.Gender = gdMale),
          [Attacker.Name]);
        Damage := Damage * 2;
      end;
      RoundResult := RoundResult + Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Hit') + #32, Game.Hero.Gender = gdMale),
        [Attacker.Name, Defender.Name, Damage]);
      Defender.HP.Dec(Damage);
    end;
    // Способность "ПИРОМАНИЯ" у героя
    if Ident = 'fireball' then
    begin
      Damage := Attacker.GetDamage + (Attacker.GetDamage div 2);
      RoundResult := RoundResult + Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Fireball') + #32, Game.Hero.Gender = gdMale),
        [Attacker.Name, Defender.Name, Damage]);
      Defender.HP.Dec(Damage);
      if (not Defender.Burned and (Math.RandomRange(0, 100) + 1 <= L * 10)) then
      begin
        RoundResult := RoundResult + Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Before_Burned') + #32, Defender.Gender = gdMale),
          [Defender.Name]);
        Defender.Burned := True;
      end;
    end;
    // Способность "ЯД" у героя
    if Ident = 'poison' then
    begin
      Damage := Attacker.GetDamage;
      RoundResult := RoundResult + Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Poison') + #32, Game.Hero.Gender = gdMale),
        [Attacker.Name, Defender.Name, Damage]);
      Defender.HP.Dec(Damage);
      if (not Defender.Poisoned and (Math.RandomRange(0, 100) + 1 <= L * 19)) then
      begin
        RoundResult := RoundResult + Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Before_Poisoned') + #32, Defender.Gender = gdMale),
          [Defender.Name]);
        Defender.Poisoned := True;
      end;
    end;
    // Способность "ВАМПИРИЗМ" у героя
    if Ident = 'vamp' then
    begin
      Heal := Math.RandomRange(L, (L * 2) + 1);
      Damage := Math.RandomRange(Attacker.GetDamage div 2, Attacker.GetDamage + 1);
      RoundResult := RoundResult + Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Vamp') + #32, Game.Hero.Gender = gdMale),
        [Attacker.Name, Defender.Name, Damage, Heal]);
      Attacker.HP.Inc(Heal);
      Defender.HP.Dec(Damage);
    end;
  end
  else
  begin
    // Способность "УДАР" у врагов
    Damage := Math.RandomRange(Attacker.GetDamage div 3, Attacker.GetDamage + 1);
    RoundResult := RoundResult + Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Hit') + #32, Attacker.Gender = gdMale),
      [Attacker.Name, Defender.Name, Damage]);
    Defender.HP.Dec(Damage);
  end;
  if Defender.HP.IsMin then
    Defeat(Defender);
end;

procedure TFight.Round(const AbIndex: Integer);
begin
  Inc(FRoundN);
  RoundResult := '';
  DoRound(Attacker, Defender, AbIndex);
  DoRound(Defender, Attacker);
  RoundResult := RoundResult + Enter;
  Game.Fight.AddLog;
end;

procedure TFight.Run;
var
  S: string;
begin
  // Герой бежит
  Inc(FRoundN);
  S := Format(Utils.GetGStr(Resources.RandomValue('Fight', 'Run') + #32, Game.Hero.Gender = gdMale), [Attacker.Name]);
  Game.Log.Add(S);
  RoundResult := S;
  RoundResult := RoundResult + Enter;
  Game.Fight.AddLog;
end;

procedure TFight.Start(Attacker, Defender: TMob; MobIdent: string);
begin
  // Начало поединка
  RoundResult := '';
  RoundN := 0;
  FLog := '';
  IsFinish := False;
  Self.Attacker := Attacker;
  Self.Attacker.Burned := False;
  Self.Attacker.Poisoned := False;
  Self.Defender := Defender;
  Self.Defender.Burned := False;
  Self.Defender.Poisoned := False;
  FMobIdent := MobIdent;
end;

procedure TFight.Victory;
begin
  // Доб. информацию в бестиарий
  Game.Bestiary.Add(FMobIdent);
  // Доб. опыт
  if Defender.HP.IsMin then
    if Attacker = Game.Hero then
      Game.Hero.GainExp(Defender.Level * (Math.RandomRange(0, 3) + 1))
    else
      Game.Hero.GainExp(Attacker.Level);
  // Статистика
  Game.Kill := Game.Kill + 1;
end;

end.
