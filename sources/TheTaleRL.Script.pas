unit TheTaleRL.Script;

interface

uses
  Classes,
  TheTaleRL.Script.Vars;

type
  TScript = class(TObject)
  private const
    // Символ комментария
    ComSymbol = '/';
  private
    FStringList: TStringList;
    FVars: TVars;
    FFileName: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    property Vars: TVars read FVars write FVars;
    procedure LoadFromFile(const FileName: string);
    function GetSection(const Section: string): string;
    procedure Exec(const Section: string);
  end;

implementation

uses
  SysUtils,
  Vcl.Dialogs,
  TheTaleRL.Utils,
  TheTaleRL.Script.Pascal;

{ TScript }

procedure TScript.Clear;
begin
  FVars.Clear;
  FStringList.Clear;
end;

constructor TScript.Create;
begin
  FStringList := TStringList.Create;
  FVars := TVars.Create;
  Clear;
end;

destructor TScript.Destroy;
begin
  FreeAndNil(FVars);
  FreeAndNil(FStringList);
  inherited;
end;

procedure TScript.Exec(const Section: string);
var
  S: string;
  Pas: TPascalScript;
begin
  // Выполнение скрипта секции
  Pas := TPascalScript.Create(FFileName, Section, GetSection('var'), GetSection('const'), GetSection('common'));
  try
    S := Self.GetSection(Section);
    if S.Trim = '' then
      Exit;
    Pas.RunScript(S);
  finally
    FreeAndNil(Pas);
  end;
end;

function TScript.GetSection(const Section: string): string;
var
  I: Integer;
  Flag: Boolean;
begin
  // Добавление строк начнется после того, как будет найдена секция
  Result := '';
  Flag := False;
  for I := 0 to FStringList.Count - 1 do
  begin
    if (FStringList[I] = Format('[%s]', [Section])) then
    begin
      // Секция найдена, можно добавлять строки исходного кода
      Flag := True;
      Continue;
    end;
    if Flag then
    begin
      // Добавляем строки до конца файла или до след. секции
      if FStringList[I].StartsWith('[') then
        Break;
      Result := Result + FStringList[I] + #13#10;
    end;
  end;
  // ShowMessage(Result);
end;

procedure TScript.LoadFromFile(const FileName: string);
var
  I: Integer;
  S: string;
begin
  FFileName := Utils.GetPath('resources\scripts') + FileName.Trim.ToLower;
  FStringList.LoadFromFile(FFileName, TEncoding.UTF8);
  for I := FStringList.Count - 1 downto 0 do
  begin
    // Убираем лишние пробелы в конце строки
    S := FStringList[I].TrimRight;
    // Если строка содержит комментарий - удаляем ее полностью
    if ((S.Trim.IsEmpty) or (S.Trim.StartsWith(ComSymbol + ComSymbol))) then
    begin
      FStringList.Delete(I);
      Continue;
    end;
    // Если в конце строки комментарий - удаляем его
    if (S.IndexOf(ComSymbol) > 0) then
      S := S.Remove(S.IndexOf(ComSymbol));
    FStringList[I] := S.TrimRight;
  end;
  // ShowMessage(FStringList.Text);
end;

end.
