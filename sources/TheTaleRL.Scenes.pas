unit TheTaleRL.Scenes;

interface

uses
  System.Types,
  Vcl.Graphics,
  BearLibTerminal,
  TheTaleRL.Resources;

type
  TSceneEnum = (scTitle, scRace, scHelp, scArchetype, scTown, scName, scGame, scBestiary, scItem, scInventory, scAbilities, scHero, scBackground,
    scStory, scEvent, scFight, scDialogTitle, scQuest, scVictory);

type
  IScene = interface
    procedure Render;
    procedure Update(var Key: Word);
    // procedure Timer;
  end;

type
  TScene = class(TInterfacedObject, IScene)
  private
    FWindow: TRect;
    FResources: TResources;
    FBackground: TBitmap;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; virtual; abstract;
    procedure Update(var Key: Word); virtual; abstract;
    property Window: TRect read FWindow write FWindow;
    procedure Print(const Left, Top, Width, Height: Word; const S: string; const Align: Integer = TK_ALIGN_DEFAULT); overload;
    procedure Print(const X, Y: Word; const S: string); overload;
    procedure Print(const Y: Word; const S: string); overload;
    procedure Print(const S: string); overload;
    function Title(const S: string): string;
    function Button(const B: string; S: string = ''; SelFlag: Boolean = False; ActFlag: Boolean = True): string;
    function AddLine(const S, V: string): string; overload;
    function AddLine(const B, S, V: string; F: Boolean): string; overload;
    property Resources: TResources read FResources;
    procedure AddButton(const B, S: string; SelFlag: Boolean = False; ActFlag: Boolean = True);
  end;

type
  TScenes = class(TScene)
  private
    FSceneEnum: TSceneEnum;
    FScene: array [TSceneEnum] of IScene;
    FPrevSceneEnum: TSceneEnum;
    FDraw: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    function GetScene(I: TSceneEnum): TScene;
    procedure SetScene(ASceneEnum: TSceneEnum); overload;
    procedure SetScene(ASceneEnum, CurrSceneEnum: TSceneEnum); overload;
    procedure GoBack;
  end;

implementation

uses
  Math,
  SysUtils,
  TheTaleRL.Scenes.Game,
  TheTaleRL.Scenes.Title,
  TheTaleRL.Scenes.Race,
  TheTaleRL.Scenes.Name,
  TheTaleRL.Scenes.Archetype,
  TheTaleRL.Scenes.Inventory,
  TheTaleRL.Scenes.Hero,
  TheTaleRL.Scenes.Background,
  // TheTaleRL.Scenes.Victory,
  TheTaleRL.Scenes.Abilities,
  TheTaleRL.Scenes.Story,
  TheTaleRL.Scenes.Bestiary,
  TheTaleRL.Scenes.Item,
  TheTaleRL.Scenes.Help,
  TheTaleRL.Scenes.Event,
  TheTaleRL.Utils,
  TheTaleRL.Scenes.Town,
  TheTaleRL.Scenes.Fight,
  TheTaleRL.Game,
  TheTaleRL.Scenes.Dialog.Title; // ,
// TheTaleRL.Scenes.Quest;

var
  PanelWidth: Integer = 40;
  PanelTop: Integer = 5;
  Buttons: string = '';

type
  TGUIBorder = class(TObject)
  public type
    TBordElem = (eeHL, eeVL);
  public const
    BordElemStr: array [TBordElem] of string = ('hl', 'vl');
  private
    FBordElem: array [TBordElem] of TBitmap;
  public
    procedure Render(var Surface: TBitmap);
    constructor Create;
    destructor Destroy; override;
  end;

  { TScene }

  // Печать текста на экране терминала
procedure TScene.Print(const X, Y: Word; const S: string);
begin
  terminal_print(X, Y, S);
end;

procedure TScene.Print(const Y: Word; const S: string);
begin
  terminal_print(Window.Width div 2, Y, TK_ALIGN_CENTER, S);
end;

function TScene.AddLine(const S, V: string): string;
var
  L: Integer;
begin
  L := (Window.Width div 4) - S.Length - V.Length - 1;
  Result := S + StringOfChar(#32, L) + V;
end;

procedure TScene.AddButton(const B, S: string; SelFlag: Boolean = False; ActFlag: Boolean = True);
begin
  Buttons := Buttons + ' ' + Button(B, S, SelFlag, ActFlag);
end;

function TScene.AddLine(const B, S, V: string; F: Boolean): string;
var
  L: Integer;
  C: string;
begin
  L := (Window.Width div 4) - B.Length - S.Length - V.Length - 4;
  if F then
    C := '[color=title]'
  else
    C := '[color=button]';
  Result := C + '[[' + B + ']][/color] ' + S + StringOfChar(#32, L) + V;
end;

function TScene.Button(const B: string; S: string = ''; SelFlag: Boolean = False; ActFlag: Boolean = True): string;
begin
  if SelFlag then
    if ActFlag then
      Result := Format('[color=title][[%s]][/color] %s', [B.ToUpper, S])
    else
      Result := Format('[color=gray][[%s]][/color] %s', [B.ToUpper, S])
  else if ActFlag then
    Result := Format('[color=button][[%s]][/color] %s', [B.ToUpper, S])
  else
    Result := Format('[color=gray][[%s]][/color] %s', [B.ToUpper, S]);
end;

constructor TScene.Create;
begin
  FResources := TResources.Create;
  FBackground := TBitmap.Create;
  FBackground.LoadFromFile(Utils.GetPath('resources\images') + 'paper.bmp');
end;

destructor TScene.Destroy;
begin
  FreeAndNil(FBackground);
  FreeAndNil(FResources);
  inherited;
end;

procedure TScene.Print(const Left, Top, Width, Height: Word; const S: string; const Align: Integer = TK_ALIGN_DEFAULT);
begin
  terminal_print(Left, Top, Width, Height, Align, S.Trim);
end;

procedure TScene.Print(const S: string);
begin
  terminal_print(1, 1, Window.Width - 2, Window.Height - 2, TK_ALIGN_CENTER + TK_ALIGN_MIDDLE, S.Trim);
end;

function TScene.Title(const S: string): string;
begin
  Result := '[color=title]' + S.ToUpper + '[/color]';
end;

{ TScenes }

constructor TScenes.Create;
var
  SceneEnum: TSceneEnum;
  Width, Height: Word;
  GUIBorder: TGUIBorder;
  TempBitmap: TBitmap;
begin
  inherited;
  FDraw := False;
  // Запуск терминала
  terminal_open();
  // Считывание конфигурации
  Width := Math.EnsureRange(StrToIntDef(terminal_get('ini.screen.width'), 80), 60, 200);
  Height := Math.EnsureRange(StrToIntDef(terminal_get('ini.screen.height'), 35), 25, 200);
  PanelWidth := Math.EnsureRange(StrToIntDef(terminal_get('ini.panel.width'), 40), 30, 100);
  // Фон
  TempBitmap := TBitmap.Create;
  try
    TempBitmap.Assign(FBackground);
    FBackground.SetSize(Width + PanelWidth, Height);
    FBackground.Canvas.StretchDraw(Rect(0, 0, Window.Width + PanelWidth, Window.Height), TempBitmap);
    GUIBorder := TGUIBorder.Create;
    try
      GUIBorder.Render(FBackground);
    finally
      FreeAndNil(GUIBorder);
    end;
  finally
    FreeAndNil(TempBitmap);
  end;
  // Окно терминала
  terminal_set(Format('window.title=%s', ['The Tale Roguelike']));
  terminal_set(Format('window.size=%dx%d', [Width + PanelWidth, Height]));
  Window.Create(0, 0, Width + PanelWidth, Height);
  // Конструкторы сцен
  for SceneEnum := Low(TSceneEnum) to High(TSceneEnum) do
  begin
    case SceneEnum of
      scTitle:
        FScene[SceneEnum] := TSceneTitle.Create;
      scRace:
        FScene[SceneEnum] := TSceneRace.Create;
      scName:
        FScene[SceneEnum] := TSceneName.Create;
      scArchetype:
        FScene[SceneEnum] := TSceneArchetype.Create;
      scGame:
        FScene[SceneEnum] := TSceneGame.Create;
      scBestiary:
        FScene[SceneEnum] := TSceneBestiary.Create;
      scHero:
        FScene[SceneEnum] := TSceneHero.Create;
      scItem:
        FScene[SceneEnum] := TSceneItem.Create;
      scTown:
        FScene[SceneEnum] := TSceneTown.Create;
      scFight:
        FScene[SceneEnum] := TSceneFight.Create;
      scHelp:
        FScene[SceneEnum] := TSceneHelp.Create;
      scInventory:
        FScene[SceneEnum] := TSceneInventory.Create;
      scBackground:
        FScene[SceneEnum] := TSceneBackground.Create;
      scStory:
        FScene[SceneEnum] := TSceneStory.Create;
      scEvent:
        FScene[SceneEnum] := TSceneEvent.Create;
      scQuest:
        ;
      // FScene[SceneEnum] := TSceneQuest.Create;
      scAbilities:
        FScene[SceneEnum] := TSceneAbilities.Create;
      scDialogTitle:
        FScene[SceneEnum] := TSceneDialogTitle.Create;
      scVictory:
        ;
      // FScene[SceneEnum] := TSceneVictory.Create;
    end;
    // GetScene(SceneEnum).Window.Create(0, 0, Width + PanelWidth, Height);
    // Доп. конфигурирование игровой сцены
    { if SceneEnum = scGame then
      begin
      TSceneGame(FScene[SceneEnum]).Panel.Create(1, PanelTop, PanelWidth, Window.Height - 1);
      TSceneGame(FScene[SceneEnum]).Screen.Create(PanelWidth + 1, 1, Window.Width - 1, Window.Height - 1);
      WW := TSceneGame(FScene[SceneEnum]).Screen.Width;
      WH := TSceneGame(FScene[SceneEnum]).Screen.Height;
      end; }
  end;
  // Экран приветствия
  SetScene(scTitle);
end;

destructor TScenes.Destroy;
begin
  terminal_close();
  inherited;
end;

function TScenes.GetScene(I: TSceneEnum): TScene;
begin
  Result := TScene(FScene[I]);
end;

procedure TScenes.GoBack;
begin
  FSceneEnum := FPrevSceneEnum;
end;

procedure TScenes.Render;
var
  X, Y: Byte;

  function GetColor(Color: Integer): Cardinal;
  begin
    Result := color_from_argb($FF, Byte(Color), Byte(Color shr 8), Byte(Color shr 16));
  end;

begin
  terminal_color('silver');
  terminal_bkcolor('none');
  // terminal_clear();
  if not FDraw then
  begin
    terminal_layer(0);
    for Y := 0 to Window.Height - 1 do
      for X := 0 to (Window.Width + PanelWidth) - 1 do
      begin
        terminal_bkcolor(GetColor(FBackground.Canvas.Pixels[X, Y]));
        terminal_print(X, Y, ' ');
      end;
    FDraw := True;
  end;
  terminal_layer(1);
  terminal_clear_area(0, 0, Window.Width + PanelWidth, Window.Height);
  Buttons := '';
  if (FScene[FSceneEnum] <> nil) then
  begin
    FScene[FSceneEnum].Render;
    if Buttons <> '' then
      Print(Window.Height - 2, Buttons);
  end;
  terminal_refresh();
end;

procedure TScenes.SetScene(ASceneEnum, CurrSceneEnum: TSceneEnum);
begin
  FDraw := False;
  FPrevSceneEnum := CurrSceneEnum;
  SetScene(ASceneEnum);
end;

procedure TScenes.SetScene(ASceneEnum: TSceneEnum);
begin
  FDraw := False;
  FSceneEnum := ASceneEnum;
  Render;
end;

procedure TScenes.Update(var Key: Word);
begin
  if (FScene[FSceneEnum] <> nil) then
  begin
    FScene[FSceneEnum].Update(Key);
  end;
end;

{ TGUIBorder }

constructor TGUIBorder.Create;
var
  I: TBordElem;
begin
  for I := Low(TBordElem) to High(TBordElem) do
  begin
    FBordElem[I] := TBitmap.Create;
    FBordElem[I].Transparent := True;
    FBordElem[I].TransparentColor := clBlack;
    FBordElem[I].LoadFromFile(Utils.GetPath('resources\images') + BordElemStr[I] + '.bmp');
  end;

end;

destructor TGUIBorder.Destroy;
var
  I: TBordElem;
begin
  for I := Low(TBordElem) to High(TBordElem) do
    FreeAndNil(FBordElem[I]);
  inherited;
end;

procedure TGUIBorder.Render(var Surface: TBitmap);
begin
  Surface.Canvas.Draw(0, 0, FBordElem[eeHL]);
  Surface.Canvas.Draw(0, 0, FBordElem[eeVL]);
  Surface.Canvas.Draw(0, Surface.Height - 1, FBordElem[eeHL]);
  Surface.Canvas.Draw(Surface.Width - 1, 0, FBordElem[eeVL]);
end;

end.
