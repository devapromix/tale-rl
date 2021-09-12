unit TheTaleRL.Script.Pascal;

interface

uses
  Classes,
  uPSUtils,
  uPSRuntime,
  uPSCompiler,
  uPSComponent,
  uPSComponent_StdCtrls,
  uPSComponent_Controls,
  TheTaleRL.Script;

type
  TPascalScript = class(TObject)
  public
    function Rand(A, B: Integer): Integer;
    procedure MsgBox(const S: string);
  private
    FStringList: TStringList;
    FFileName: string;
    FVarSection: string;
    FConstSection: string;
    FSection: string;
    FPascalScript: TPSScript;
    FCommonSection: string;
    procedure CompAfterExecute(Sender: TPSScript);
    procedure CompCompile(Sender: TPSScript);
    procedure CompExecute(Sender: TPSScript);
    function CompNeedFile(Sender: TObject; const OrginFileName: AnsiString; var FileName, Output: AnsiString): Boolean;
    function GetNum(I: Integer): string;
  public
    constructor Create(const FileName, Section, VarSection, ConstSection, CommonSection: string);
    destructor Destroy; override;
    procedure RunScript(Script: string);
  end;

implementation

uses
  SysUtils,
  Vcl.Dialogs,
  TheTaleRL.Game,
  TheTaleRL.Utils;

{ TPascal }

procedure TPascalScript.CompAfterExecute(Sender: TPSScript);
begin
  // Здоровье героя
  Game.Hero.HP.Cur := VGetInt(FPascalScript.GetVariable('HP'));
  Game.Hero.HP.Max := VGetInt(FPascalScript.GetVariable('MaxHP'));
  // Золото героя
  Game.Hero.Inventory.Gold := VGetInt(FPascalScript.GetVariable('Gold'));
end;

procedure TPascalScript.CompCompile(Sender: TPSScript);
begin
  // Процедуры и функции
  Sender.AddMethod(Self, @TPascalScript.MsgBox, 'procedure MsgBox(S: string);');
  Sender.AddMethod(Self, @TPascalScript.Rand, 'function Rand(A, B: Integer): Integer;');
  // Здоровье героя
  FPascalScript.AddRegisteredVariable('HP', 'Word');
  FPascalScript.AddRegisteredVariable('MaxHP', 'Word');
  // Все золото героя
  FPascalScript.AddRegisteredVariable('Gold', 'Cardinal');
  // Уровень героя
  FPascalScript.AddRegisteredVariable('Level', 'Byte');
  // Опыт героя
  FPascalScript.AddRegisteredVariable('Experience', 'Cardinal');
  FPascalScript.AddRegisteredVariable('DeltaToNextExperience', 'Cardinal');
  // Имя героя
  FPascalScript.AddRegisteredVariable('Name', 'String');
end;

procedure TPascalScript.CompExecute(Sender: TPSScript);
begin
  // Здоровье героя
  VSetInt(FPascalScript.GetVariable('HP'), Game.Hero.HP.Cur);
  VSetInt(FPascalScript.GetVariable('MaxHP'), Game.Hero.HP.Max);
  // Золото
  VSetInt(FPascalScript.GetVariable('Gold'), Game.Hero.Inventory.Gold);
  // Уровень
  VSetInt(FPascalScript.GetVariable('Level'), Game.Hero.Level);
  // Опыт
  VSetInt(FPascalScript.GetVariable('Experience'), Game.Hero.Experience);
  VSetInt(FPascalScript.GetVariable('DeltaToNextExperience'), Game.Hero.GetDeltaToNext);
  // Имя героя
  VSetString(FPascalScript.GetVariable('Name'), Game.Hero.Name);
end;

function TPascalScript.CompNeedFile(Sender: TObject; const OrginFileName: AnsiString; var FileName, Output: AnsiString): Boolean;
var
  StringList: TStringList;
begin
  StringList := TStringList.Create;
  try
    try
      StringList.LoadFromFile(Utils.GetPath('resources\scripts') + string(FileName), TEncoding.UTF8);
      Output := AnsiString(StringList.Text.Trim);
      Result := True;
    except
      Result := False;
      Exit;
    end;
  finally
    FreeAndNil(StringList);
  end;
end;

constructor TPascalScript.Create(const FileName, Section, VarSection, ConstSection, CommonSection: string);
begin
  FStringList := TStringList.Create;
  FFileName := FileName;
  FSection := Section;
  FVarSection := VarSection;
  FConstSection := ConstSection;
  FCommonSection := CommonSection;
  FPascalScript := TPSScript.Create(nil);
  FPascalScript.OnAfterExecute := CompAfterExecute;
  FPascalScript.OnCompile := CompCompile;
  FPascalScript.OnExecute := CompExecute;
  FPascalScript.OnNeedFile := CompNeedFile;
  FPascalScript.UsePreProcessor := True;
end;

destructor TPascalScript.Destroy;
begin
  FreeAndNil(FPascalScript);
  FreeAndNil(FStringList);
  inherited;
end;

function TPascalScript.GetNum(I: Integer): string;
begin
  case I of
    0 .. 9:
      Result := '  ' + I.ToString;
    10 .. 99:
      Result := ' ' + I.ToString;
  else
    Result := I.ToString;
  end;
end;

procedure TPascalScript.MsgBox(const S: string);
begin
  ShowMessage(S);
end;

function TPascalScript.Rand(A, B: Integer): Integer;
begin
  Result := Round(Random(B - A + 1) + A);
end;

procedure TPascalScript.RunScript(Script: string);
const
  F = '  %s';
var
  IsCompiled: Boolean;
  I: Integer;
  S: string;
  SL: TStringList;
begin
  try
    FStringList.Clear;
    SL := TStringList.Create;
    try
      SL.Text := Script;
      for I := 0 to SL.Count - 1 do
        FStringList.Append(Format(F, [SL[I]]));
      FStringList.Insert(0, 'begin');
      // Секция common
      SL.Text := FCommonSection;
      for I := SL.Count - 1 downto 0 do
        FStringList.Insert(0, SL[I]);
      // Секция var
      SL.Text := FVarSection;
      for I := 0 to SL.Count - 1 do
        FStringList.Insert(0, Format(F, [SL[I]]));
      FStringList.Insert(0, 'var');
      // Секция const
      SL.Text := FConstSection;
      for I := 0 to SL.Count - 1 do
        FStringList.Insert(0, Format(F, [SL[I]]));
      FStringList.Insert(0, 'const');
    finally
      FreeAndNil(SL);
    end;
    FStringList.Append('end.');
    FPascalScript.Script.Text := FStringList.Text;
    IsCompiled := FPascalScript.Compile;
    //
    if not IsCompiled then
    begin
      // Если ошибка
      S := Format('Ошибки в скрипте: %s'#10#13'Идентификатор текущей секции: [%s]'#10#13#10#13, [FFileName, FSection]);
      for I := 0 to FPascalScript.CompilerMessageCount - 1 do
        S := S + string(FPascalScript.CompilerMessages[I].MessageToString) + ';'#10#13;
      S := S + #10#13;
      for I := 0 to FStringList.Count - 1 do
        S := S + Format('%s %s', [GetNum(I + 1), FStringList[I]]) + #10#13;
      MsgBox(S);
      Exit;
    end;
    //
    if IsCompiled then
      if not FPascalScript.Execute then
        MsgBox('Ошибки во время выполнения скрипта:'#10#13 + string(FPascalScript.ExecErrorToString));
  except

  end;
end;

end.
