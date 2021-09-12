unit TheTaleRL.Equipment;

interface

uses
  Classes;

type
  TEquipment = class(TObject)
  public type
    TEquipmentSlot = (esHandPrimary, esHandSecondary, esHelmet, esAmulet, esShoulders, esPlate, esGloves, esCloak, esPants, esBoots, esRing);
  private
    FEquipment: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Count: Byte;
    function GetEquipmentSlotName(I: Byte): string; overload;
    function GetEquipmentSlotName(I: TEquipmentSlot): string; overload;
    function GetArtifactIdent(I: Byte): string; overload;
    function GetArtifactIdent(I: TEquipmentSlot): string; overload;
  end;

implementation

uses
  SysUtils;

{ TEquipment }

procedure TEquipment.Clear;
var
  I: Byte;
begin
  for I := 0 to FEquipment.Count - 1 do
    FEquipment[I] := '';
end;

function TEquipment.Count: Byte;
begin
  Result := FEquipment.Count;
end;

constructor TEquipment.Create;
var
  I: TEquipmentSlot;
begin
  FEquipment := TStringList.Create;
  FEquipment.Clear;
  for I := Low(TEquipmentSlot) to High(TEquipmentSlot) do
    FEquipment.Append('');
  Clear;
end;

destructor TEquipment.Destroy;
begin
  FreeandNil(FEquipment);
  inherited;
end;

const
  EquipmentSlotStr: array [TEquipment.TEquipmentSlot] of string = ('основная рука', 'вспомогательная рука', 'шлем', 'амулет', 'наплечники', 'доспех',
    'перчатки', 'плащ', 'штаны', 'сапоги', 'кольцо');

function TEquipment.GetArtifactIdent(I: TEquipmentSlot): string;
begin
  Result := FEquipment[Ord(I)];
end;

function TEquipment.GetArtifactIdent(I: Byte): string;
begin
  if I > FEquipment.Count - 1 then
    Exit('');
  Result := FEquipment[I];
end;

function TEquipment.GetEquipmentSlotName(I: TEquipmentSlot): string;
begin
  Result := EquipmentSlotStr[I];
end;

function TEquipment.GetEquipmentSlotName(I: Byte): string;
begin
  Result := EquipmentSlotStr[TEquipmentSlot(I)];
end;

end.
