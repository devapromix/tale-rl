unit TheTaleRL.Map;

interface

type
  TMap = class(TObject)
  private
    FWidth: Integer;
    FHeight: Integer;
    FTop: Integer;
    FLeft: Integer;
    FMap: TArray<TArray<Integer>>;
  public
    constructor Create(const AWidth, AHeight: Integer); overload;
    constructor Create; overload;
    destructor Destroy; override;
    procedure RenderTile(const X, Y, TX, TY: Integer);
    function GetTile(const X, Y: Integer): Integer;
    function GetTileChar(const X, Y: Integer): string;
    function InMap(const X, Y: Integer): Boolean;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
    procedure Clear;
    procedure Gen;
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);
  end;

implementation

uses
  BearLibTerminal,
  Math,
  Classes,
  SysUtils,
  TheTaleRL.Game;

{ TMap }

procedure TMap.Clear;
var
  X, Y: Integer;
begin
  for Y := 0 to FHeight - 1 do
    for X := 0 to FWidth - 1 do
      FMap[X, Y] := 0;
end;

constructor TMap.Create;
begin
  FWidth := 100;
  FHeight := 100;
  FLeft := 0;
  FTop := 0;
  SetLength(FMap, FWidth, FHeight);
end;

constructor TMap.Create(const AWidth, AHeight: Integer);
begin
  FWidth := AWidth;
  FHeight := AHeight;
  FLeft := 0;
  FTop := 0;
  SetLength(FMap, FWidth, FHeight);
end;

destructor TMap.Destroy;
begin

  inherited;
end;

procedure TMap.Gen;
var
  I, D, X, Y, HX, HY: Integer;
begin
  Clear;
  //
  D := FWidth * FHeight div 10;
  for I := 0 to D - 1 do
  begin
    X := Math.RandomRange(0, FWidth);
    Y := Math.RandomRange(0, FHeight);
    FMap[X, Y] := Math.RandomRange(1, 4);
  end;
  //
  {
    HX := Math.RandomRange(0, FWidth);
    HY := Math.RandomRange(0, FHeight);
    Game.Hero.SetLocation(HX, HY);
    FMap[HX, HY] := 0;
  }
  //
end;

function TMap.GetTile(const X, Y: Integer): Integer;
begin
  if InMap(X, Y) then
    Result := FMap[X][Y]
  else
    Result := 0;
end;

function TMap.GetTileChar(const X, Y: Integer): string;
begin
  case GetTile(X, Y) of
    0: // Dirt
      //Result := '[color=darker yellow].[/color]';
      Result := '.';
    1: // Tree
      //Result := '[color=dark green]T[/color]';
      Result := 'T';
    2: // Hill
      //Result := '[color=dark gray]^[/color]';
      Result := '^';
    3: // Swamp
      //Result := '[color=dark gray]^[/color]';
      Result := '=';
  end;
end;

function TMap.InMap(const X, Y: Integer): Boolean;
begin
  Result := (X >= 0) and (X < FWidth) and (Y >= 0) and (Y < FHeight);
end;

procedure TMap.LoadFromFile(const FileName: string);
var
  X, Y: Integer;
  L: TStringList;
begin
  L := TStringList.Create;
  L.LoadFromFile(FileName);
  for Y := 0 to Height - 1 do
    for X := 0 to Width - 1 do
      FMap[Y][X] := Ord(L[Y][X + 1]);
  FreeAndNil(L);
end;

procedure TMap.RenderTile(const X, Y, TX, TY: Integer);
begin
  terminal_print(X, Y, GetTileChar(TX, TY));
end;

procedure TMap.SaveToFile(const FileName: string);
var
  X, Y: Integer;
  L: TStringList;
  S: string;
begin
  L := TStringList.Create;
  for Y := 0 to Height - 1 do
  begin
    S := '';
    for X := 0 to Width - 1 do
      S := S + Chr(FMap[Y][X]);
    L.Append(S);
  end;
  L.SaveToFile(FileName);
  FreeAndNil(L);
end;

end.
