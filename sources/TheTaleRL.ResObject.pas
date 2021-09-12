unit TheTaleRL.ResObject;

interface

uses
  TheTaleRL.Resources;

type
  TResObject = class(TObject)
  private
    FResources: TResources;
  public
    constructor Create;
    destructor Destroy; override;
    property Resources: TResources read FResources;
  end;

implementation

uses
  System.SysUtils;

{ TResObject }

constructor TResObject.Create;
begin
  FResources := TResources.Create;
end;

destructor TResObject.Destroy;
begin
  FreeAndNil(FResources);
  inherited;
end;

end.
