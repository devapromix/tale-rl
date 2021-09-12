unit TheTaleRL.Resources;

interface

uses
  System.Classes,
  IniFiles;

type
  TResources = class(TObject)
  private
  public
    constructor Create;
    destructor Destroy; override;
    procedure ReadSections(const FileName: string; Sections: TStrings; Section: string = '');
    function LoadFromFile(const FileName, SectionName, KeyName, DefaultValue: string): string; overload;
    function LoadFromFile(const FileName, SectionName, KeyName: string; DefaultValue: Integer): Integer; overload;
    procedure LoadFromFile(const FileName: string; var StringList: TStringList); overload;
    function KeysCount(const FileName, SectionName: string): Integer;
    function RandomValue(const FileName, SectionName: string): string;
    function RandomSectionIdent(const FileName: string): string;
  end;

implementation

{ TResources }

uses
  Math,
  SysUtils,
  TheTaleRL.Utils;

constructor TResources.Create;
begin
end;

destructor TResources.Destroy;
begin

  inherited;
end;

function TResources.KeysCount(const FileName, SectionName: string): Integer;
var
  IniFile: TMemIniFile;
  Keys: TStringList;
begin
  IniFile := TMemIniFile.Create(Utils.GetPath('resources') + FileName + '.ini', TEncoding.UTF8);
  try
    Keys := TStringList.Create;
    try
      IniFile.ReadSection(SectionName, Keys);
      Result := Keys.Count;
    finally
      FreeAndNil(Keys);
    end;
  finally
    FreeAndNil(IniFile);
  end;
end;

function TResources.LoadFromFile(const FileName, SectionName, KeyName: string; DefaultValue: Integer): Integer;
var
  IniFile: TMemIniFile;
begin
  IniFile := TMemIniFile.Create(Utils.GetPath('resources') + FileName + '.ini', TEncoding.UTF8);
  try
    Result := IniFile.ReadInteger(SectionName, KeyName, DefaultValue);
  finally
    FreeAndNil(IniFile);
  end;
end;

procedure TResources.LoadFromFile(const FileName: string; var StringList: TStringList);
begin
  StringList.LoadFromFile(Utils.GetPath('resources') + FileName + '.txt', TEncoding.UTF8);
end;

function TResources.LoadFromFile(const FileName, SectionName, KeyName, DefaultValue: string): string;
var
  IniFile: TMemIniFile;
begin
  Result := DefaultValue;
  IniFile := TMemIniFile.Create(Utils.GetPath('resources') + FileName + '.ini', TEncoding.UTF8);
  try
    Result := IniFile.ReadString(SectionName.ToLower, KeyName, DefaultValue).Trim.Replace('|', #13#10).Replace('<', '[color=title]-- ')
      .Replace('>', ' --[/color]');
  finally
    FreeAndNil(IniFile);
  end;
end;

function TResources.RandomSectionIdent(const FileName: string): string;
var
  FSections: TStringList;
begin
  FSections := TStringList.Create;
  try
    ReadSections(FileName, FSections);
    Result := FSections[Math.RandomRange(0, FSections.Count)].Trim;
  finally
    FreeAndNil(FSections);
  end;
end;

function TResources.RandomValue(const FileName, SectionName: string): string;
var
  IniFile: TMemIniFile;
  Keys: TStringList;
begin
  Result := '';
  IniFile := TMemIniFile.Create(Utils.GetPath('resources') + FileName.ToLower + '.ini', TEncoding.UTF8);
  try
    Keys := TStringList.Create;
    try
      IniFile.ReadSection(SectionName.ToLower, Keys);
      if Keys.Count = 0 then
        Exit;
      Result := LoadFromFile(FileName.ToLower, SectionName.ToLower, Keys[RandomRange(0, Keys.Count)], '');
    finally
      FreeAndNil(Keys);
    end;
  finally
    FreeAndNil(IniFile);
  end;
end;

procedure TResources.ReadSections(const FileName: string; Sections: TStrings; Section: string = '');
var
  IniFile: TMemIniFile;
  I: Integer;
begin
  IniFile := TMemIniFile.Create(Utils.GetPath('resources') + FileName + '.ini', TEncoding.UTF8);
  try
    IniFile.ReadSections(Sections);
    if Section <> '' then
      for I := Sections.Count - 1 downto 0 do
        if Sections[I].ToLower = Section.ToLower then
          Sections.Delete(I);
  finally
    FreeAndNil(IniFile);
  end;
end;

end.
