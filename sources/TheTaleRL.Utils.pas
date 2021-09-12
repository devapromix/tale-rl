unit TheTaleRL.Utils;

interface

type
  Utils = class(TObject)
  public
    class function GetPath(SubDir: string): string;
    class procedure AppStr(var S: string; P: string; IsSep: Boolean);
    class function GetStrValue(D, S: string): string;
    class function GetStrKey(D, S: string): string;
    class function GetGStr(S: string; IsMale: Boolean): string;
  end;

implementation

uses SysUtils;

class procedure Utils.AppStr(var S: string; P: string; IsSep: Boolean);
begin
  if IsSep then
    S := S + ', ' + P
  else
    S := S + P;
end;

class function Utils.GetPath(SubDir: string): string;
begin
  Result := ExtractFilePath(ParamStr(0));
  Result := IncludeTrailingPathDelimiter(Result + SubDir);
end;

class function Utils.GetStrKey(D, S: string): string;
begin
  Result := Copy(S, 1, Pos(D, S) - 1);
end;

class function Utils.GetStrValue(D, S: string): string;
begin
  Result := Copy(S, Pos(D, S) + 1, Length(S));
end;

class function Utils.GetGStr(S: string; IsMale: Boolean): string;
var
  I: Integer;
  SX, RX, S1, S2: String;
  RF: Byte;
begin
  SX := '';
  RX := '';
  RF := 0;
  for I := 1 to Length(S) do
  begin
    case S[I] of
      '{':
        begin
          RF := 1;
          Continue;
        end;
      '}':
        RF := 2;
    end;
    case RF of
      0:
        RX := RX + S[I];
      1:
        SX := SX + S[I];
      2:
        begin
          S1 := GetStrKey('/', SX);
          S2 := GetStrValue('/', SX);
          SX := '';
          RF := 0;
          if IsMale then
            RX := RX + S1
          else
            RX := RX + S2;
        end;
    end;
  end;
  Result := RX;
end;

end.
