unit TheTaleRL.Inventory;

interface

uses
  Classes,
  TheTaleRL.Entity;

type
  TInventory = class(TObject)
  private type
    TArtifactType = (atUseless, atMainHand, atOffHand, atPlate, atAmulet, atHelmet, atCloak, atShoulders, atGloves, atPants, atBoots, atRing);
    TArtifactRarity = (arNormal, arRare, arEpic);
    TArtifact = class(TEntity);
  private
    FGold: Cardinal;
    FInventory: TStringList;
    FCapacity: Byte;
    FPotions: Byte;
  public const
    MaxCapacity = 26;
  public
    constructor Create;
    destructor Destroy; override;
    property Gold: Cardinal read FGold write FGold;
    property Capacity: Byte read FCapacity write FCapacity;
    function Count: Byte;
    function GetArtifactIdent(I: Byte): string; overload;
    property Potions: Byte read FPotions write FPotions;
  end;

implementation

uses
  Math,
  SysUtils;

{ TInventory }

function TInventory.Count: Byte;
begin
  Result := 0;
end;

constructor TInventory.Create;
var
  I: Byte;
begin
  FGold := 0;
  FPotions := 7;
  FInventory := TStringList.Create;
  Capacity := 10;
  for I := 0 to MaxCapacity - 1 do
    FInventory.Append('');
//  FInventory[0] := '1021';
end;

destructor TInventory.Destroy;
begin
  FreeAndNil(FInventory);
  inherited;
end;

function TInventory.GetArtifactIdent(I: Byte): string;
begin
  Result := FInventory[I];
end;

end.
