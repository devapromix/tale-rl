unit TheTaleRL.Scenes.Event;

interface

uses
  TheTaleRL.Scenes;

type
  TSceneEvent = class(TScene)
  private
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Event,
  TheTaleRL.Story;

{ TSceneEvent }

procedure TSceneEvent.Render;
var
  S: string;
begin
  Print(1, Title(Game.Event.GetDialog.Title));
  //
  S := Game.Event.GetDialog.Text + #13#10#13#10;
  case Game.Event.GetDialog.DialogAct of
    daFindGold:
      S := S + Format('Золото: +%d', [Game.Event.GetDialog.Value]);
    daGainExp:
      S := S + Format('Опыт: +%d', [Game.Event.GetDialog.Value]);
  end;
  Print(S);
  //
  case Game.Event.GetDialog.DialogType of
    dtYes:
      AddButton('ENTER', Game.Event.GetDialog.NextText);
    dtYesOrNo:
      begin
        AddButton('A', Game.Event.GetDialog.NextText);
        AddButton('B', Game.Event.GetDialog.AltNextText);
      end;
  end;
end;

procedure TSceneEvent.Update(var Key: Word);
begin
  case Game.Event.GetDialog.DialogType of
    dtYes:
      case Key of
        // Дефолтный выбор
        TK_ENTER:
          begin
            with Game.Event do
            begin
              DialogIndex := GetDialogIndex(GetDialog.NextIndexes);
              if ((DialogIndex div 10) = (DialogIndex / 10)) then
                Game.Scenes.SetScene(scGame)
              else
              begin
                Act;
                Render;
              end;
            end;
          end;
      end;
    dtYesOrNo:
      case Key of
        // Первый вариант
        TK_A:
          begin
            with Game.Event do
            begin
              DialogIndex := GetDialogIndex(GetDialog.NextIndexes);
              if ((DialogIndex div 10) = (DialogIndex / 10)) then
                Game.Scenes.SetScene(scGame)
              else
              begin
                Act;
                Render;
              end;
            end;
          end;
        // Второй вариант
        TK_B:
          begin
            with Game.Event do
            begin
              DialogIndex := GetDialogIndex(GetDialog.AltNextIndexes);
              if ((DialogIndex div 10) = (DialogIndex / 10)) then
                Game.Scenes.SetScene(scGame)
              else
              begin
                Act;
                Render;
              end;
            end;
          end;
      end;
  end;

end;

end.
