unit TheTaleRL.Game;

interface

uses
  TheTaleRL.Hero,
  TheTaleRL.Story,
  TheTaleRL.Scenes,
  TheTaleRL.Bestiary,
  TheTaleRL.Town,
  TheTaleRL.Script,
  TheTaleRL.Mob,
  TheTaleRL.Map,
  TheTaleRL.Log,
  TheTaleRL.Event,
  TheTaleRL.Quest,
  TheTaleRL.Fight;

type
  TGame = class(TObject)
  private
    FHero: THero;
    FScenes: TScenes;
    FTurn: Cardinal;
    FKill: Cardinal;
    FStory: TStory;
    FBestiary: TBestiary;
    FTowns: TTowns;
    FScript: TScript;
    FEvent: TEvent;
    FFight: TFight;
    FEnemy: TMob;
    FLog: TLog;
    FMap: TMap;
    FQuest: TQuest;
    FCups: Cardinal;
    FRevs: Cardinal;
  public
    IsCup: array [1 .. 3] of Boolean;
    constructor Create;
    destructor Destroy; override;
    property Hero: THero read FHero write FHero;
    property Scenes: TScenes read FScenes write FScenes;
    property Turn: Cardinal read FTurn write FTurn;
    property Kill: Cardinal read FKill write FKill;
    property Revs: Cardinal read FRevs write FRevs;
    property Cups: Cardinal read FCups write FCups;
    property Story: TStory read FStory;
    property Bestiary: TBestiary read FBestiary write FBestiary;
    property Script: TScript read FScript write FScript;
    property Event: TEvent read FEvent write FEvent;
    property Towns: TTowns read FTowns;
    property Fight: TFight read FFight;
    property Log: TLog read FLog write FLog;
    property Map: TMap read FMap write FMap;
    property Enemy: TMob read FEnemy write FEnemy;
    property Quest: TQuest read FQuest write FQuest;
  end;

var
  Game: TGame;
  WW, WH: Integer;

implementation

uses
  Math,
  SysUtils;

{ TGame }

constructor TGame.Create;
var
  I: Integer;
begin
  for I := 1 to 3 do
    IsCup[I] := False;
  FLog := TLog.Create;
  FScenes := TScenes.Create;
  FHero := THero.Create;
  FStory := TStory.Create;
  FTowns := TTowns.Create;
  FScript := TScript.Create;
  FEvent := TEvent.Create;
  FFight := TFight.Create;
  FMap := TMap.Create;
  FBestiary := TBestiary.Create;
  FEnemy := TMob.Create;
  FQuest := TQuest.Create;
  // Генер. города на карте
  FTowns.Gen;
  // Генератор карты
  FMap.Gen;
  // Статистика
  FTurn := 0;
  FKill := 0;
  FCups := 0;
  FRevs := 0;
end;

destructor TGame.Destroy;
begin
  FreeAndNil(FEnemy);
  FreeAndNil(FFight);
  FreeAndNil(FEvent);
  FreeAndNil(FScript);
  FreeAndNil(FTowns);
  FreeAndNil(FBestiary);
  FreeAndNil(FStory);
  FreeAndNil(FScenes);
  FreeAndNil(FHero);
  FreeAndNil(FMap);
  FreeAndNil(FLog);
  FreeAndNil(FQuest);
  inherited;
end;

initialization

Game := TGame.Create;

finalization

FreeAndNil(Game);

end.
