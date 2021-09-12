unit TheTaleRL.Script.Vars;

interface

uses
  Classes;

type
  TVars = class(TObject)
  private
    FName: TStringList;
    FValue: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Count: Integer;
    function IsVar(const Name: string): Boolean;
    procedure SetVar(const Name: string; Value: Variant);
    function GetVar(const Name: string; const DefaultValue: string = ''): string; overload;
    function GetVar(const Name: string; const DefaultValue: Integer = 0): Integer; overload;
    procedure SaveToFile(const FileName: string);
  end;

implementation

uses
  SysUtils;

{ TVars }

procedure TVars.Clear;
begin
  FName.Clear;
  FValue.Clear;
end;

function TVars.Count: Integer;
begin
  Result := FName.Count;
end;

constructor TVars.Create;
begin
  FName := TStringList.Create;
  FValue := TStringList.Create;
  Clear;
end;

destructor TVars.Destroy;
begin
  FName.Free;
  FValue.Free;
  inherited;
end;

function TVars.GetVar(const Name: string; const DefaultValue: string = ''): string;
var
  Index: Integer;
begin
  Index := FName.IndexOf(Name);
  if Index < 0 then
    Result := ''
  else
    Result := FValue[Index];
  if (Result = '') and (DefaultValue <> '') then
    Result := DefaultValue;
end;

function TVars.GetVar(const Name: string; const DefaultValue: Integer = 0): Integer;
var
  Value: string;
begin
  Value := Trim(GetVar(Name, ''));
  Result := StrToIntDef(Value, DefaultValue);
end;

function TVars.IsVar(const Name: string): Boolean;
begin
  Result := FName.IndexOf(Name.Trim) >= 0;
end;

procedure TVars.SaveToFile(const FileName: string);
var
  I: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  SL.WriteBOM := False;
  try
    for I := 0 to FName.Count - 1 do
      SL.Append(FName[I] + ', ' + FValue[I]);
    SL.SaveToFile(FileName, TEncoding.UTF8);
  finally
    FreeAndNil(SL);
  end;
end;

procedure TVars.SetVar(const Name: string; Value: Variant);
var
  Index: Integer;
begin
  Index := FName.IndexOf(Name);
  if Index < 0 then
  begin
    FName.Append(Name);
    FValue.Append(Value);
  end
  else
    FValue[Index] := Value;
end;

end.
