unit TheTaleRL.Bestiary;

interface

uses
  Classes;

type
  TBestiary = class(TObject)
  private
    FIdent: TStringList;
    FKills: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(const Ident: string);
    function Count: Integer;
    function GetIdent(const I: Integer): string;
    function GetKills(const I: Integer): Integer;
  end;

implementation

uses
  SysUtils;

{ TBestiary }

procedure TBestiary.Add(const Ident: string);
var
  I, Kills: Integer;
begin
  I := FIdent.IndexOf(Ident.Trim);
  if I < 0 then
  begin
    FIdent.Append(Trim(Ident));
    FKills.Append('1');
  end
  else
  begin
    Kills := FKills[I].ToInteger + 1;
    FKills[I] := Kills.ToString;
  end;
end;

procedure TBestiary.Clear;
begin
  FIdent.Clear;
  FKills.Clear;
end;

function TBestiary.Count: Integer;
begin
  Result := FIdent.Count;
end;

constructor TBestiary.Create;
begin
  FIdent := TStringList.Create;
  FKills := TStringList.Create;
end;

destructor TBestiary.Destroy;
begin
  FreeAndNil(FKills);
  FreeAndNil(FIdent);
  inherited;
end;

function TBestiary.GetIdent(const I: Integer): string;
begin
  if I >= FIdent.Count then
    Exit('');
  Result := FIdent[I].Trim;
end;

function TBestiary.GetKills(const I: Integer): Integer;
begin
  Result := FKills[I].ToInteger;
end;

end.
