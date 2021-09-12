program TheTaleRL;

{$IFDEF FPC}
{$IFDEF Windows}
{$APPTYPE GUI}
{$ENDIF}
{$ENDIF}

uses
  SysUtils,
  BearLibTerminal in 'sources\Third-Party\BearLibTerminal\BearLibTerminal.pas',
  TheTaleRL.Scenes in 'sources\TheTaleRL.Scenes.pas',
  TheTaleRL.Scenes.Race in 'sources\Scenes\TheTaleRL.Scenes.Race.pas',
  TheTaleRL.Scenes.Game in 'sources\Scenes\TheTaleRL.Scenes.Game.pas',
  TheTaleRL.Log in 'sources\TheTaleRL.Log.pas',
  TheTaleRL.Utils in 'sources\TheTaleRL.Utils.pas',
  TheTaleRL.Resources in 'sources\TheTaleRL.Resources.pas',
  TheTaleRL.Hero in 'sources\TheTaleRL.Hero.pas',
  TheTaleRL.Scenes.Title in 'sources\Scenes\TheTaleRL.Scenes.Title.pas',
  TheTaleRL.Game in 'sources\TheTaleRL.Game.pas',
  TheTaleRL.Scenes.Name in 'sources\Scenes\TheTaleRL.Scenes.Name.pas',
  TheTaleRL.Scenes.Archetype in 'sources\Scenes\TheTaleRL.Scenes.Archetype.pas',
  TheTaleRL.Mob in 'sources\TheTaleRL.Mob.pas',
  TheTaleRL.HP in 'sources\TheTaleRL.HP.pas',
  TheTaleRL.Inventory in 'sources\TheTaleRL.Inventory.pas',
  TheTaleRL.Scenes.Hero in 'sources\Scenes\TheTaleRL.Scenes.Hero.pas',
  TheTaleRL.Scenes.Inventory in 'sources\Scenes\TheTaleRL.Scenes.Inventory.pas',
  TheTaleRL.Scenes.Background in 'sources\Scenes\TheTaleRL.Scenes.Background.pas',
  TheTaleRL.Scenes.Story in 'sources\Scenes\TheTaleRL.Scenes.Story.pas',
  TheTaleRL.Story in 'sources\TheTaleRL.Story.pas',
  TheTaleRL.Entity in 'sources\TheTaleRL.Entity.pas',
  TheTaleRL.MapObject in 'sources\TheTaleRL.MapObject.pas',
  TheTaleRL.Skills in 'sources\TheTaleRL.Skills.pas',
  TheTaleRL.Scenes.Abilities in 'sources\Scenes\TheTaleRL.Scenes.Abilities.pas',
  TheTaleRL.Scenes.Bestiary in 'sources\Scenes\TheTaleRL.Scenes.Bestiary.pas',
  TheTaleRL.Scenes.Help in 'sources\Scenes\TheTaleRL.Scenes.Help.pas',
  TheTaleRL.Scenes.Item in 'sources\Scenes\TheTaleRL.Scenes.Item.pas',
  TheTaleRL.Bestiary in 'sources\TheTaleRL.Bestiary.pas',
  TheTaleRL.Equipment in 'sources\TheTaleRL.Equipment.pas',
  TheTaleRL.Scenes.Town in 'sources\Scenes\TheTaleRL.Scenes.Town.pas',
  TheTaleRL.Town in 'sources\TheTaleRL.Town.pas',
  TheTaleRL.Script in 'sources\TheTaleRL.Script.pas',
  TheTaleRL.Script.Vars in 'sources\TheTaleRL.Script.Vars.pas',
  TheTaleRL.Script.Pascal in 'sources\TheTaleRL.Script.Pascal.pas',
  TheTaleRL.Master in 'sources\TheTaleRL.Master.pas',
  TheTaleRL.Event in 'sources\TheTaleRL.Event.pas',
  TheTaleRL.Scenes.Event in 'sources\Scenes\TheTaleRL.Scenes.Event.pas',
  TheTaleRL.Fight in 'sources\TheTaleRL.Fight.pas',
  TheTaleRL.Scenes.Fight in 'sources\Scenes\TheTaleRL.Scenes.Fight.pas',
  TheTaleRL.ResObject in 'sources\TheTaleRL.ResObject.pas',
  TheTaleRL.Map in 'sources\TheTaleRL.Map.pas',
  TheTaleRL.Scenes.Dialog.Title in 'sources\Scenes\TheTaleRL.Scenes.Dialog.Title.pas',
  TheTaleRL.Quest in 'sources\TheTaleRL.Quest.pas';//,
//  TheTaleRL.Scenes.Quest in 'sources\Scenes\TheTaleRL.Scenes.Quest.pas',
//  TheTaleRL.Scenes.Victory in 'sources\Scenes\TheTaleRL.Scenes.Victory.pas';

var
  Key: Word;
  IsRender: Boolean = True;
begin
  Randomize;
  ReportMemoryLeaksOnShutdown := True;
  repeat
    if IsRender then
    begin
      IsRender := False;
      Game.Scenes.Render;
    end;
    if terminal_has_input() then
    begin
      Key := terminal_read();
      IsRender := True;
      Game.Scenes.Update(Key);
      Continue;
    end;
    terminal_delay(10);
  until Key = TK_CLOSE;
end.
