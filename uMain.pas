unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TBuiltInResult = record
    TotalCount : Integer;
    OkCount : Integer;
    NgCount : Integer;
    TimeOutCount : Integer;
    NgList : string;
  end;

  TInspItem = (itEepromFlashCopy, itBuiltInInspection, itPowerOn, itVolt1Check, itUsbCheck,
                    itLanCheck, itCiCardCheck, itSwitchCheck, itIdsCheck, itWdcCheck);
  TInspItemHelper = record helper for TInspItem
    function ToInspName: string; inline;
    //function ToImqs: string; inline;
    //function ToSpecEdit: TSpecEdit; inline;
    //function ToGroupName: string; inline;
  end;

  TFA_NET_DATA = record
    ReturnValue : byte;
    DataCount : byte; //Max=100
    Data : array[0..100, 0..255] of byte;
    sData : array[0..100, 0..255] of Ansichar;
    StartTime : TDateTime;
    EndTime : TDateTime;
    InspTime : Int64;
  end;

  TExample =class
    class function GetClassName :string;
  end;

  TSalary = class
  public
    Amount : integer;
    constructor Create;
    constructor CreateWithAmount(AAmount : integer);
  end;

  TParent = class
    procedure VirtualProc; virtual;
    procedure DynamicProc; dynamic;
    procedure BrokenProc; virtual;
  end;

  TDescendant = class(TParent)
    procedure VirtualProc; override;
    procedure DynamicProc; override;
    procedure BrokenProc; virtual;
  end;

  TParentAbs = class
    procedure VirtualProc; virtual; abstract;
    procedure DynamicProc; virtual; abstract;
    procedure BrokenProc; virtual;
    procedure ParentFunc1;
  end;

  TDescendantAbs = class(TParentAbs)
    procedure VirtualProc; override;
    procedure DynamicProc; override;
    procedure BrokenProc; virtual;
  end;

  TPba = class
    private
      tList : TStringList;
    public
      constructor Create; virtual;
      destructor Destroy; override;//virtual;
      procedure FlashWrite; virtual; abstract;
      procedure EepromWrite; virtual; abstract;
      procedure FactoryCodeOut; virtual; abstract;
      procedure PbaFunc1;
      procedure PbaFunc2;
  end;

  TRp4 = class(TPba)
    public
      constructor Create; override;
      destructor Destroy; override;
      procedure FlashWrite; override;
      procedure EepromWrite; override;
      procedure FactoryCodeOut; override;
      procedure Rp4Func1;
  end;

  TUcb300 = class(TPba)
    public
      constructor Create; override;
      destructor Destroy; override;
      procedure FlashWrite; override;
      procedure EepromWrite; override;
      procedure FactoryCodeOut; override;
      procedure Ucb3004Func1;
  end;

  TForm3 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure TestVirtProc(Obj : TParent);
    procedure TestDynProc(Obj : TParent);
    procedure TestBrokenProc(Obj : TParent);
    function CheckInspResult(InspResult : array of Integer; var BuiltInResult : TBuiltInResult) : Boolean;
  end;

var
  Form3: TForm3;
  FA_NET : array[0..255] of TFA_NET_DATA;

implementation

{$R *.dfm}

{ TSalary }

constructor TSalary.Create;
begin
  inherited Create;
  // 기본적으로 모든 변수는 0으로 초기화 되기 때문에 이 루틴은 굳이 써 주지 않아도 된다.
  Amount := 0;
end;

constructor TSalary.CreateWithAmount(AAmount: integer);
begin
  inherited Create;
  Amount := AAmount;
end;

procedure TForm3.Button10Click(Sender: TObject);
var
  TempObj : TRp4;
  TempStr :string;
begin
  Memo1.Clear;
  TempObj := TRp4.Create;
  try
    TempObj.FlashWrite;
    TempObj.EepromWrite;
    TempObj.PbaFunc1;
    TempObj.PbaFunc2;
    TempObj.Rp4Func1;
  finally
    TempObj.Free;
  end;
end;

procedure TForm3.Button11Click(Sender: TObject);
var
  i : integer;
  LogData : string;
begin
  Memo1.Clear;
  FillChar(FA_NET, sizeof(FA_NET), $ff);
  for i := 0 to 255 do
  begin
    LogData := format('ReturnVal[%d]=%d', [i, FA_NET[i].ReturnValue]);
    Memo1.Lines.add(LogData);
  end;
end;

procedure TForm3.Button12Click(Sender: TObject);
var
  InspResult : array[Low(TInspItem).. High(TInspItem)] of Integer;
  i, x, y : Integer;
  BuiltInResult : TBuiltInResult;
  LogData : string;
begin
  Memo1.Clear;
  x := ord(Low(TInspItem));
  y := ord(High(TInspItem));
  for i := 0 to y do
    InspResult[TInspItem(i)] := 0;

  InspResult[itEepromFlashCopy] := 1;
  InspResult[itBuiltInInspection] := 1;
  InspResult[itPowerOn] := 1;
  InspResult[itVolt1Check] := 2;
  InspResult[itUsbCheck] := 2;
  InspResult[itLanCheck] := 1;

  CheckInspResult(InspResult, BuiltInResult);

  if BuiltInResult.TotalCount = BuiltInResult.OkCount then
  begin
    LogData := format('Total=%d, Ok=%d', [BuiltInResult.TotalCount, BuiltInResult.OkCount]);
    Memo1.Lines.add(LogData);
  end else
  begin
    LogData := format('Totalt=%d, Ok=%d, Ng=%d, NgTimeout=%d, DefectList=%s',
                      [BuiltInResult.TotalCount, BuiltInResult.OkCount, BuiltInResult.NgCount,
                       BuiltInResult.TimeOutCount, BuiltInResult.NgList]);
    Memo1.Lines.add(LogData);
  end;

end;

procedure TForm3.Button1Click(Sender: TObject);
var
  Temp1, Temp2 : TSalary;
  TempStr : string;
begin
  Memo1.Clear;
  Temp1 := TSalary.Create;
  Temp2 := TSalary.CreateWithAmount(1000000);
  try
    memo1.Lines.add('Temp1의 급여는 ' + IntToStr(Temp1.Amount));
    memo1.Lines.add('Temp2의 급여는 ' + IntToStr(Temp2.Amount));
  finally
    Temp1.Free;
    Temp2.Free;
  end;
end;

{ TParent }

procedure TParent.BrokenProc;
begin
  Form3.Memo1.Lines.add('TParent.BrokenProc');
end;

procedure TParent.DynamicProc;
begin
  Form3.Memo1.Lines.add('TParent.DynamicProc');
end;

procedure TParent.VirtualProc;
begin
  Form3.Memo1.Lines.add('TParent.VirtualProc');
end;

{ TDescendant }

procedure TDescendant.BrokenProc;
begin
  Form3.Memo1.Lines.add('TDescendant.BrokenProc');
end;

procedure TDescendant.DynamicProc;
begin
  inherited;
  Form3.Memo1.Lines.add('TDescendant.DynamicProc');
end;

procedure TDescendant.VirtualProc;
begin
  inherited;
  Form3.Memo1.Lines.add('TDescendant.VirtualProc');
end;

procedure TForm3.Button2Click(Sender: TObject);
var
  TempObj : TDescendant;
  TempStr :string;
begin
  Memo1.Clear;
  TempObj := TDescendant.Create;
  try
    Memo1.Lines.add('# Virtual메소드');
    TestVirtProc(TempObj);
    Memo1.Lines.add('# Dynamic메소드');
    TestDynProc(TempObj);
    Memo1.Lines.add('# 메소드연결이끊어진다');
    TestBrokenProc(TempObj);
  finally
    TempObj.Free;
  end;
end;

procedure TForm3.Button3Click(Sender: TObject);
var
  TmpObj : TExample;
  TmpStr :string;
begin
  Memo1.Clear;
  // Insert user code here
  Memo1.Lines.add('직접호출->' + TExample.GetClassName);
  TmpObj := TExample.Create;
  try
    Memo1.Lines.add('객체생성후호출->' + TmpObj.GetClassName);
  finally
    TmpObj.Free;
  end;
end;

procedure TForm3.Button4Click(Sender: TObject);
var
  TempObj : TDescendantAbs;
  TempStr :string;
begin
  Memo1.Clear;
  TempObj := TDescendantAbs.Create;
  try
    TempObj.VirtualProc;
    TempObj.DynamicProc;
    TempObj.BrokenProc;
    TempObj.ParentFunc1;
  finally
    TempObj.Free;
  end;
end;

procedure TForm3.Button5Click(Sender: TObject);
var
  TempObj : TParent;
  TempStr :string;
begin
  Memo1.Clear;
  TempObj := TDescendant.Create;
  try
    Memo1.Lines.add('# Virtual메소드');
    TempObj.VirtualProc;
    Memo1.Lines.add('# Dynamic메소드');
    TempObj.DynamicProc;
    Memo1.Lines.add('# 메소드연결이끊어진다');
    TempObj.BrokenProc;
  finally
    TempObj.Free;
  end;
end;

procedure TForm3.Button6Click(Sender: TObject);
var
  TempObj : TDescendant;
  TempStr :string;
begin
  Memo1.Clear;
  TempObj := TDescendant.Create;
  try
    Memo1.Lines.add('# Virtual메소드');
    TempObj.VirtualProc;
    Memo1.Lines.add('# Dynamic메소드');
    TempObj.DynamicProc;
    Memo1.Lines.add('# 메소드연결이끊어지지않음');
    TempObj.BrokenProc;
  finally
    TempObj.Free;
  end;
end;

procedure TForm3.Button7Click(Sender: TObject);
var
  TempObj : TParentAbs;
  TempStr :string;
begin
  Memo1.Clear;
  TempObj := TDescendantAbs.Create;
  try
    TempObj.VirtualProc;
    TempObj.DynamicProc;
    TempObj.BrokenProc;
    TempObj.ParentFunc1;
  finally
    TempObj.Free;
  end;
end;

procedure TForm3.Button8Click(Sender: TObject);
var
  TempObj : TPba;
  TempStr :string;
begin
  Memo1.Clear;
  TempObj := TRp4.Create;
  try
    TempObj.FlashWrite;
    TempObj.EepromWrite;
    TempObj.PbaFunc1;
    TempObj.PbaFunc2;
    TempObj.FactoryCodeOut;
  finally
    TempObj.Free;
  end;
end;

procedure TForm3.Button9Click(Sender: TObject);
var
  TempObj : TPba;
  TempStr :string;
begin
  Memo1.Clear;
  TempObj := TUcb300.Create;
  try
    TempObj.FlashWrite;
    TempObj.EepromWrite;
    TempObj.PbaFunc1;
    TempObj.PbaFunc2;
    TempObj.FactoryCodeOut;
  finally
    TempObj.Free;
  end;
end;



function TForm3.CheckInspResult(InspResult : array of Integer; var BuiltInResult: TBuiltInResult): Boolean;
var
  i, x, y : Integer;
begin
  BuiltInResult.TotalCount := 0;
  BuiltInResult.OkCount := 0;
  BuiltInResult.NgCount := 0;
  BuiltInResult.TimeOutCount := 0;
  BuiltInResult.NgList := '';

  x := Length(InspResult);
  for i := 0 to x-1 do
  begin
    Inc(BuiltInResult.TotalCount);
    if InspResult[i] = 1 then
      Inc(BuiltInResult.OkCount);

    if InspResult[i] = 2 then
    begin
      Inc(BuiltInResult.NgCount);
      if BuiltInResult.NgList = '' then
        BuiltInResult.NgList := TInspItem(i).ToInspName
      else
        BuiltInResult.NgList := BuiltInResult.NgList + ', ' + TInspItem(i).ToInspName;
    end;

    if InspResult[i] = 0 then
    begin
      Inc(BuiltInResult.TimeOutCount);
      if BuiltInResult.NgList = '' then
        BuiltInResult.NgList := TInspItem(i).ToInspName + '(TimeOut)'
      else
        BuiltInResult.NgList := BuiltInResult.NgList + ', ' + TInspItem(i).ToInspName + '(TimeOut)';
    end;
  end;
end;

procedure TForm3.TestBrokenProc(Obj: TParent);
begin
  Obj.BrokenProc;
end;

procedure TForm3.TestDynProc(Obj: TParent);
begin
  Obj.DynamicProc;
end;

procedure TForm3.TestVirtProc(Obj: TParent);
begin
  Obj.VirtualProc;
end;

{ TExample }

class function TExample.GetClassName: string;
begin
  Result :='클래스메소드예제클래스';
end;

{ TParentAbs }

procedure TParentAbs.BrokenProc;
begin
  Form3.Memo1.Lines.add('TParentAbs.BrokenProc');
end;

procedure TParentAbs.ParentFunc1;
begin
  Form3.Memo1.Lines.add('TParentAbs.ParentFunc1');
end;

{ TDescendantAbs }

procedure TDescendantAbs.BrokenProc;
begin
  //inherited;
  Form3.Memo1.Lines.add('TDescendantAbs.BrokenProc');
end;

procedure TDescendantAbs.DynamicProc;
begin
  Form3.Memo1.Lines.add('TDescendantAbs.DynamicProc');
end;

procedure TDescendantAbs.VirtualProc;
begin
  Form3.Memo1.Lines.add('TDescendantAbs.VirtualProc');
end;

{ TPba }

constructor TPba.Create;
begin
  tList := TStringList.Create;
  Form3.Memo1.Lines.add('TPba.Create');
end;

destructor TPba.Destroy;
begin
  tList.Free;
  Form3.Memo1.Lines.add('TPba.Destroy');
end;

procedure TPba.PbaFunc1;
begin
  Form3.Memo1.Lines.add('TPba.PbaFunc1');
end;

procedure TPba.PbaFunc2;
begin
  Form3.Memo1.Lines.add('TPba.PbaFunc2');
end;

{ TRp4 }

procedure TRp4.FactoryCodeOut;
begin
  Form3.Memo1.Lines.add('TRp4.FactoryCodeOut');
end;

procedure TRp4.FlashWrite;
begin
  Form3.Memo1.Lines.add('TRp4.Flash1Write, TRp4.Flash1Write 동시 Write');
end;

procedure TRp4.EepromWrite;
begin
  Form3.Memo1.Lines.add('TRp4.EepromWrite');
end;

constructor TRp4.Create;
begin
  inherited;
  Form3.Memo1.Lines.add('TRp4.Create');
end;

destructor TRp4.Destroy;
begin
  Form3.Memo1.Lines.add('TRp4.Destroy');
  inherited;
end;

procedure TRp4.Rp4Func1;
begin
  Form3.Memo1.Lines.add('TRp4.Rp4Func1');
end;

{ TUcb300 }

procedure TUcb300.FactoryCodeOut;
begin
  Form3.Memo1.Lines.add('TUcb300.FactoryCodeOut');
end;

procedure TUcb300.FlashWrite;
begin
  Form3.Memo1.Lines.add('TUcb300.Flash1Write');
  Form3.Memo1.Lines.add('TUcb300.Flash2Write');
end;

procedure TUcb300.EepromWrite;
begin
  Form3.Memo1.Lines.add('TUcb300.EepromWrite');
end;

constructor TUcb300.Create;
begin
  inherited;
  Form3.Memo1.Lines.add('TUcb300.Create');
end;

destructor TUcb300.Destroy;
begin
  Form3.Memo1.Lines.add('TUcb300.Destroy');
  inherited;
end;

procedure TUcb300.Ucb3004Func1;
begin
  Form3.Memo1.Lines.add('TUcb300.Ucb3004Func1');
end;

{ TInspItemHelper }

function TInspItemHelper.ToInspName: string;
begin
  Result := 'NoInsp';
  case Self of
    TInspItem.itEepromFlashCopy:  Result := '_Ax_ EepromCopy';
    TInspItem.itBuiltInInspection:  Result := '_Sx_ Built-In Inspection';
    TInspItem.itPowerOn:  Result := '_Ax_ Power On';
    TInspItem.itVolt1Check:  Result := '_Px_ Volt1 Check';
    TInspItem.itUsbCheck:  Result := '_Sx_ USB Inspection';
    TInspItem.itLanCheck:  Result := '_Sx_ LAN Inspection';
    TInspItem.itCiCardCheck:  Result := '_Sx_ CI CARD Inspection';
    TInspItem.itSwitchCheck:  Result := '_Dx_ Switch Check';
    TInspItem.itIdsCheck:  Result := '_Dx_ IDS Inspection (SU2e)';
    TInspItem.itWdcCheck:  Result := '_Dx_ WDC Inspection';
  end;
end;

end.
