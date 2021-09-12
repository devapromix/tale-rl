unit TheTaleRL.Scenes.Story;

interface

uses
  TheTaleRL.Scenes;

type
  TSceneStory = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  SysUtils,
  Vcl.Dialogs,
  BearLibTerminal,
  TheTaleRL.Game,
  TheTaleRL.Story;

{ TSceneStory }

procedure TSceneStory.Render;
var
  S: string;
begin
  S := Title(Game.Story.GetDialog.Title) + #13#10#13#10;
  S := S + Game.Story.GetDialog.Text + #13#10#13#10;
  case Game.Story.GetDialog.DialogType of
    dtYes:
      S := S + Button('ENTER', Game.Story.GetDialog.NextText);
    dtYesOrNo:
      S := S + Button('A', Game.Story.GetDialog.NextText) + ' ' + Button('B', Game.Story.GetDialog.AltNextText);
  end;
  Print(S);
end;

procedure TSceneStory.Update(var Key: Word);
begin
  case Game.Story.GetDialog.DialogType of
    dtYes:
      case Key of
        TK_ENTER:
          begin
            // Завершаем игру, если выполнен главный квест
            // и найдены все Чаши Силы
            //
            with Game.Story do
            begin
              DialogIndex := GetDialogIndex(GetDialog.NextIndexes);
              if DialogIndex >= 50 then
              begin
                Game.Scenes.SetScene(scVictory);
                Exit;
              end;
            end;
            Game.Scenes.SetScene(scGame);
          end;
      end;
    dtYesOrNo:
      case Key of
        // Next
        TK_A:
          begin
            with Game.Story do
              DialogIndex := GetDialogIndex(GetDialog.NextIndexes);
            Game.Scenes.SetScene(scGame);
          end;
        // AltNext
        TK_B:
          begin
            with Game.Story do
              DialogIndex := GetDialogIndex(GetDialog.AltNextIndexes);
            Game.Scenes.SetScene(scGame);
          end;
      end;
  end;
end;

end.
