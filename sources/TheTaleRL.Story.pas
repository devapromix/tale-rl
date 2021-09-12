unit TheTaleRL.Story;

interface

uses
  TheTaleRL.ResObject;

type
  TDialogType = (dtYes, dtYesOrNo);

type
  TDialogAct = (daNone, daFindGold, daGainExp);

type
  TDialogRec = record
    Title: string;
    Text: string;
    DialogType: TDialogType;
    DialogAct: TDialogAct;
    Value: Integer;
    NextText: string;
    NextIndexes: string;
    AltNextText: string;
    AltNextIndexes: string;
    DialogActStr: string;
  end;

type
  TStory = class(TResObject)
  private
    FDialogIndex: Byte;
  public
    constructor Create;
    destructor Destroy; override;
    function GetDialog: TDialogRec;
    function GetDialogRec(const FileName: string): TDialogRec;
    function GetDialogType(Value: string): TDialogType;
    property DialogIndex: Byte read FDialogIndex write FDialogIndex;
    function GetDialogIndex(const S: string): Integer;
    function GetDialogAct: TDialogAct;
  end;

implementation

uses
  Math,
  SysUtils;

{ TStory }

constructor TStory.Create;
begin
  inherited Create;
  FDialogIndex := 0;
end;

destructor TStory.Destroy;
begin
  inherited;
end;

function TStory.GetDialogType(Value: string): TDialogType;
begin
  Value := Value.Trim.ToUpper;
  Result := dtYes;
  if Value = 'YESORNO' then
    Result := dtYesOrNo;
end;

function TStory.GetDialog: TDialogRec;
begin
  Result := GetDialogRec('Story');
end;

function TStory.GetDialogAct: TDialogAct;
var
  S: string;
  A: TArray<string>;
  Min, Max: Integer;
begin
  //
  Min := 0;
  Max := 0;
  Result := daNone;
  if (S.Trim <> '') then
  begin
    A := S.Split([',']);
    if (A[0].ToLower = 'findgold') then
      Result := daFindGold
    else if (A[0].ToLower = 'gainexp') then
      Result := daGainExp
    else
      Result := daNone;
    if (High(A) > 0) then
    begin
      Min := A[1].ToInteger;
      //Result.Value := EnsureRange(Min, 0, Min);
    end;
    if (High(A) > 1) then
    begin
      Max := A[2].ToInteger;
      //Result.Value := EnsureRange(RandomRange(Min, Max + 1), 0, Max);
    end;
  end;
end;

function TStory.GetDialogIndex(const S: string): Integer;
var
  A: TArray<string>;
begin
  A := S.Split([',']);
  Result := A[RandomRange(0, Length(A))].ToInteger;
end;

function TStory.GetDialogRec(const FileName: string): TDialogRec;
begin
  Result.Title := Resources.LoadFromFile(FileName, FDialogIndex.ToString, 'Title', '').ToUpper;
  Result.Text := Resources.LoadFromFile(FileName, FDialogIndex.ToString, 'Text', '');
  Result.DialogType := GetDialogType(Resources.LoadFromFile(FileName, FDialogIndex.ToString, 'DialogType', 'Yes'));
  Result.NextText := Resources.LoadFromFile(FileName, FDialogIndex.ToString, 'Next', 'Продолжить');
  Result.NextIndexes := Resources.LoadFromFile(FileName, FDialogIndex.ToString, 'NextIndex', '0');
  Result.AltNextText := Resources.LoadFromFile(FileName, FDialogIndex.ToString, 'AltNext', '');
  Result.AltNextIndexes := Resources.LoadFromFile(FileName, FDialogIndex.ToString, 'AltNextIndex', '0');
  Result.DialogActStr := Resources.LoadFromFile(FileName, FDialogIndex.ToString, 'DialogAct', '');
end;

end.
