unit TheTaleRL.Log;

interface

uses
  System.Classes;

type
  TLog = class(TObject)
  private
    FLog: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(const S: string);
    procedure Render(const Left, Top, Width, Height: Integer);
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal;

{ TLog }

procedure TLog.Add(const S: string);
begin
  FLog.Insert(0, S);
end;

procedure TLog.Clear;
begin
  FLog.Clear;
end;

constructor TLog.Create;
begin
  FLog := TStringList.Create;
end;

destructor TLog.Destroy;
begin
  FreeAndNil(FLog);
  inherited;
end;

procedure TLog.Render(const Left, Top, Width, Height: Integer);
var
  I: Integer;
  S: string;
begin
  S := '';
  for I := 0 to Min(Height, FLog.Count) - 1 do
    S := S + Format('%s'#32#13#10, [FLog[I]]);
  terminal_print(Left, Top, Width, Height, TK_ALIGN_DEFAULT, S.Trim);
end;

end.
