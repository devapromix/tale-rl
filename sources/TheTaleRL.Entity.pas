unit TheTaleRL.Entity;

interface

uses
  TheTaleRL.MapObject;

type
  TRaceEnum = (reHuman, reGoblin, reOrc, reDwarf, reElf);

type
  TEntity = class(TMapObject)
  private
    FLevel: Byte;
    FName: string;
  public
    constructor Create;
    property Level: Byte read FLevel write FLevel;
    property Name: string read FName write FName;
  end;

implementation

{ TEntity }

constructor TEntity.Create;
begin
  inherited Create;
  FLevel := 1;
  FName := '';
end;

end.
