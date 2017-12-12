Unit uBigIntsV3;
{Copyright 2001-2009, Gary Darby, Intellitech Systems Inc., www.DelphiForFun.org
 This program may be used or modified for any non-commercial purpose
 so long as this original notice remains in place.
 All other rights are reserved
}
interface
uses Forms, Dialogs, SysUtils, Windows;
type
  TDigits = array of int64;
  TInteger = class(TObject)
  protected
    Sign:    integer;
    fDigits: TDigits;
    Base:    integer;
    procedure AbsAdd(const I2: tinteger);
    function  AbsCompare(I2: TInteger): integer; overload;
    procedure AbsSubtract(const i2: Tinteger);
    function  GetBasePower: integer;
    function  GetLength: integer;
    procedure SetDigitLength(const k: integer);
    procedure assignsmall(i2: int64);
    procedure divmodsmall(d:int64; var rem: int64);
    procedure divide2;   {fast divide by 2}
  public
    property Digits: TDigits Read fDigits;
    constructor Create;
    procedure Assign(const I2: TInteger); overload;
    procedure Assign(const I2: int64); overload;
    procedure Assign(const I2: string); overload;
    procedure AbsoluteValue;
    procedure Add(const I2: TInteger); overload;
    procedure Add(const I2: int64); overload;
    procedure AssignZero;
    procedure AssignOne;
    procedure Subtract(const I2: int64); overload;
    procedure Mult(const I2: TInteger); overload;
    procedure Mult(const I2: int64); overload;
    procedure FastMult(const I2: TInteger);
    procedure Divide(const I2: TInteger); overload;
    procedure Divide(const I2: int64); overload;
    procedure Modulo(Const I2:TInteger);   overload;
    procedure Modulo(Const N:Int64); overload;
    procedure ModPow(const I2, m: Tinteger);
    procedure DivideRem(const I2: TInteger; var remain: TInteger);

    function Compare(I2: TInteger): integer; overload;
    function Compare(I2: int64): integer; overload;
    function ConvertToDecimalString(commas: boolean): string;
    function ConvertToInt64(var n: int64): boolean;
    function DigitCount: integer;
    procedure SetSign(s: integer);
    function GetSign: integer;
    function IsOdd: boolean;
    function IsPositive: boolean;
    function IsNegative: boolean;
    function IsProbablyPrime: boolean;
    function IsZero: boolean;

    procedure ChangeSign;
    procedure Pow(const exponent: int64);
    procedure Trim;
    procedure Sqroot;
    procedure Square;


    procedure NRoot(const root: integer);

    function  GetBase: integer;
    function ConvertToHexString:String;
    function AssignHex(HexStr:String):Boolean;
    procedure RandomOfSize(size:integer);
    procedure Random(maxint:TInteger);
    procedure Getnextprime;
  end;

procedure SetBaseVal(const newbase: integer);
implementation
uses Math;

var
  ThreadSafe:boolean = false;
  BaseVal:   integer = 1000; {1,000 changed to 100,000 at initialization time}
  BasePower: integer;
  ScratchPads: array of TInteger;
  LastScratchPad: integer;

{************* GetNextScratchPad *************}
function GetNextScratchPad(InitVal: TInteger): TInteger; overload;
{retrieve or create a work variable and initialize it with TInteger value}
var
  L: integer;
begin
  if LastScratchPad > High(ScratchPads) then
  begin
    L := Length(ScratchPads);
    SetLength(ScratchPads, L+1);
    ScratchPads[L] := TInteger.Create;
    Scratchpads[L].Assign(InitVal);
    Result := ScratchPads[L];
  end
  else Result := ScratchPads[LastScratchPad];
  Result.Assign(InitVal);
  Inc(LastScratchPad);
end;

{************* GetNextScratchPad *************}
function GetNextScratchPad(InitVal: Int64): TInteger; overload;
{retrieve or create a work variable and initialize it with int64 value}
var
  L: integer;
begin
  if LastScratchPad > High(ScratchPads) then
  begin
    L := Length(ScratchPads);
    SetLength(ScratchPads, L+1);
    ScratchPads[L] := TInteger.Create;
    scratchpads[L].assign(initval);
    Result := ScratchPads[L];
    Inc(LastScratchPad);
    Exit;
  end;
  Result := ScratchPads[LastScratchPad];
  Result.Assign(InitVal);
  Inc(LastScratchPad);
end;

{*********** GetNextScratchPad *********}
function GetNextScratchPad: TInteger; overload;
begin
  result:=getnextscratchpad(0);
end;

{************* Release ScratchPad *********}
procedure ReleaseScratchPad(t:TInteger);
begin
  If threadsafe then T.Free
  else
  begin
    Dec(LastScratchPad);
    Assert(T=scratchpads[lastscratchpad],'Scratchpad synch problem ');
    ScratchPads[LastScratchPad].SetDigitLength(1);
  end;
end;

{**************** GetScratchPad ***************}
function GetScratchPad(InitVal: TInteger): TInteger; overload;
begin
  if ThreadSafe then
  begin
    Result := TInteger.Create;
    result.assign(initval);
  end
  else
    Result := GetNextScratchPad(InitVal);
end;

{**************** GetScratchPad ***************}
function GetScratchPad(InitVal: Int64 = 0): TInteger; overload;
begin
  if ThreadSafe then
  begin
    Result := TInteger.Create;
    result.assign(initval);
  end
  else
  Result := GetNextScratchPad(InitVal);
end;

{*************** SetBaseVal *************}
procedure SetBaseVal(const newbase: integer);
var
  i,n: integer;
begin
  BaseVal := 10;
  BasePower := 1;
  n := newbase;
  {validate new base value}
  if n > 1e6 then  n := trunc(1e6)
  else if n < 10 then  n := 10;
  while n > 10 do
  begin
    Inc(BasePower);
    n := n div 10;
    BaseVal := BaseVal * 10;
  end;
  if lastscratchpad>0
  then Showmessage('Warning - Base value changed,'
         +#13+'all scratchpad variables have been released');
  for i:=0 to high(scratchpads) do scratchpads[i].free;
  setlength(scratchpads,20);
  for i:=0 to 19 do
  begin
    scratchpads[i]:=TInteger.create;
  end;
  lastscratchpad:=0;
end;

{************* Create ***********}
constructor TInteger.Create;
begin
  inherited;
  Base := BaseVal; {base in Tinteger in case we want to handle other bases later}
  AssignZero;
end;

{*************** SetDigitLength **********}
procedure TInteger.SetDigitLength(const k: integer);
begin
  SetLength(fDigits, k);
end;

{*********** GetLength **********}
function TInteger.GetLength: integer;
begin
  Result := length(fDigits);
end;

{************* Subtract (64 bit integer)}
procedure Tinteger.Subtract(const I2: int64);
begin
  Add(-i2);
end;

{********* DigitCount ************}
function TInteger.DigitCount: integer;
  { Return count of base 10 digits in the number }
var
  n:   int64;
  Top: integer;
begin
  Top    := high(Digits);
  Result := Top * GetBasePower;
  n      := Digits[Top];
  if n > 0 then
    Result := Result + 1 + system.trunc(Math.Log10(n));
end;

{************* SetSign ************}
procedure TInteger.SetSign(s: integer);
{Set the sign of the number to match the passed integer}
begin
  if s > 0 then
    Sign := +1
  else if s < 0 then
    Sign := -1
  else
    Sign := 0;
end;

{************** GetSign *********}
function TInteger.GetSign: integer;
begin
  Result := Sign;
end;

{*********** IsPositive ***********}
function TInteger.IsPositive: boolean;
begin
  Result := Sign > 0;
end;

{*********** IsNegative ***********}
function TInteger.IsNegative: boolean;
begin
  Result := Sign < 0;
end;

{************** ChangeSign **********}
procedure Tinteger.ChangeSign;
begin
  Sign := -Sign;
end;

{******** Square *********}
procedure Tinteger.Square;
const
  ConstShift = 48;
var
  Carry, n, product: int64;
  xstart, i, j, k:   integer;
  imult1:TInteger;
begin
  xstart := high(self.fDigits);
  imult1:=GetNextScratchPad(1); {assign 1 just to force sign to +}
  SetLength(imult1.fDigits, xstart + xstart + 3);
  // Step 1 - calculate diagonal
  for i := 0 to xstart do
  begin
    k     := i * 2;
    product := fDigits[i] * fDigits[i];
    Carry := product shr ConstShift;
    if Carry = 0 then
      imult1.fDigits[k] := product
    else
    begin
      Carry := product div Base;
      imult1.fDigits[k] := product - Carry * Base;
      imult1.fDigits[k + 1] := Carry;
    end;
  end;
  // Step 2 - calculate repeating part
  for i := 0 to xstart do
  begin
    Carry := 0;
    for j := i + 1 to xstart do
    begin
      k     := i + j;
      product := fDigits[j] * fDigits[i] * 2 + imult1.fDigits[k] + Carry;
      Carry := product shr ConstShift;
      if Carry = 0 then
        imult1.fDigits[k] := product
      else
      begin
        Carry := product div Base;
        imult1.fDigits[k] := product - Carry * Base;
      end;
    end;
    k := xstart + i + 1;
    imult1.fDigits[k] := Carry + imult1.fDigits[k];
  end;
  // Step 3 - place in proper base
  xstart := high(imult1.fDigits);
  Carry  := 0;
  for i := 0 to xstart - 1 do
  begin
    n     := imult1.fDigits[i] + Carry;
    Carry := n div Base;
    imult1.fDigits[i] := n - Carry * Base;
  end;
  imult1.fDigits[xstart] := Carry;
  Assign(imult1);
  releaseScratchPad(imult1);
end;

{********** Trim ***********}
procedure TInteger.Trim;
var
  i, j: integer;
begin
  i := high(fDigits);
  if i >= 0 then
  begin
    j := i;
    if (fDigits[0] <> 0) then
      while (fDigits[i] = 0) do
        Dec(i)
    else
      while (i > 0) and (fDigits[i] = 0) do
        Dec(i);
    if j <> i then
      SetLength(fDigits, i + 1);
    // make sure sign is zero if value = 0...
    if (i = 0) and (self.Digits[0] = 0) then
      Sign := 0;
  end
  else
  begin
    AssignZero;
  end;
end;

{**************** GetBasePower *******}
function TInteger.GetBasePower: integer;
var
  n: integer;
begin
  if Base = BaseVal then
    Result := BasePower
  else
  begin
    Result := 0;
    n      := Base;
    while n > 1 do
    begin
      Inc(BasePower);
      n := n div 10;
    end;
  end;
end;

 {************* Assign **********}
procedure TInteger.Assign(const I2: TInteger); {Assign - TInteger}
var
  len: integer;
begin
  if i2.Base = Base then
  begin
    len := length(i2.fDigits);
    SetLength(fDigits, len);
    move(i2.fdigits[0],fdigits[0], len*sizeof(int64));
    Sign := i2.Sign;
    Trim;
  end
  else
    self.Assign(i2.ConvertToDecimalString(False));
end;

{************ Assign (int64)***********}
procedure TInteger.Assign(const I2: int64);
{Assign - int64}
var
  i:     integer;
  n, nn: int64;
begin
  if system.abs(i2) < Base then
    assignsmall(i2)
  else
  begin
    SetLength(fDigits, 20);
    n := system.abs(i2);
    i := 0;
    repeat
      nn := n div Base;
      fDigits[i] := n - nn * Base;
      n  := nn;
      Inc(i);
    until n = 0;
    if i2 < 0 then
      Sign := -1
    else if i2 = 0 then
      Sign := 0
    else if i2 > 0 then
      Sign := +1;
    SetLength(fDigits, i);
    Trim;
  end;
end;

{************* Assign   (String type *********}
procedure TInteger.Assign(const i2: string);
{Convert a  string number}
var
  i, j:    integer;
  zeroval: boolean;
  n, nn:   int64;
  pos:     integer;
begin
  n := length(I2) div GetBasePower + 1;
  SetLength(fDigits, n);
  for i := 0 to n - 1 do
    fDigits[i] := 0;
  Sign := +1;
  j   := 0;
  zeroval := True;
  n   := 0;
  pos := 1;
  for i := length(i2) downto 1 do
  begin
    if i2[i] in ['0'..'9'] then
    begin
      n   := n + pos * (Ord(i2[i]) - Ord('0'));
      pos := pos * 10;
      if pos > Base then
      begin
        nn  := n div Base;
        fDigits[j] := n - nn * Base;
        n   := nn;
        pos := 10;
        Inc(j);
        zeroval := False;
      end
      else;
    end
    else if i2[i] = '-' then
      Sign := -1;
  end;
  fDigits[j] := n;  {final piece of the number}
  if zeroval and (n = 0) then
    Sign := 0;
  Trim;
end;

{************ Add *********}
procedure TInteger.Add(const I2: TInteger);
{add - TInteger}
var
  ii: TInteger;
begin
  ii:=GetNextScratchPad(i2);
  if Sign <> ii.Sign then AbsSubtract(ii)
    else  AbsAdd(ii);
  ReleaseScratchPad(ii);
end;

{**************** AbsAdd ***************}
procedure tinteger.AbsAdd(const i2: tinteger);
{add values ignoring signs}
var
  i: integer;
  n, Carry: int64;
  i3:TInteger;
begin
  I3:=GetNextScratchPad(self);
  SetLength(fDigits, max(length(fDigits), length(i2.fDigits)) + 1);
  {"add" could grow result by two digit}
  i     := 0;
  Carry := 0;
  while i < min(length(i2.fDigits), length(i3.fDigits)) do
  begin
    n     := i2.fDigits[i] + i3.fDigits[i] + Carry;
    Carry := n div Base;
    fDigits[i] := n - Carry * Base;
    Inc(i);
  end;
  if length(i2.fDigits) > length(i3.fDigits) then
    while i <{=}length(i2.fDigits) do
    begin
      n     := i2.fDigits[i] + Carry;
      Carry := n div Base;
      fDigits[i] := n - Carry * Base;
      Inc(i);
    end
  else if length(i3.fDigits) > length(i2.fDigits) then
  begin
    while i <{=}length(i3.fDigits) do
    begin
      n     := i3.fDigits[i] + Carry;
      Carry := n div Base;
      fDigits[i] := n - Carry * Base;
      Inc(i);
    end;
  end;
  fDigits[i] := Carry;
  Trim;
  releaseScratchpad(i3);
end;

{************* Add (int64) ********}
procedure TInteger.Add(const I2: int64);
{Add - Int64}
var
 IAdd3:TInteger;
begin
  IAdd3:=getnextScratchPad(I2);
  Add(IAdd3);
  ReleaseScratchPad(IAdd3);
end;

{*************** AbsSubtract *************}
procedure TInteger.AbsSubtract(const i2: Tinteger);
{Subtract values ignoring signs}
var
  c:  integer;
  i3: TInteger;
  i, j, k: integer;
begin {request was subtract and signs are same,
         or request was add and signs are different}
  c  := AbsCompare(i2);
  i3:=GetNextScratchPad(self);
  if c < 0 then {abs(i2) larger, swap and subtract}
  begin
    Assign(i2);
  end
  else if c >= 0 then {self is bigger} i3.Assign(i2);
  for i := 0 to high(i3.fDigits) do
  begin
    if fDigits[i] >= i3.fDigits[i]
    then fDigits[i] := fDigits[i] - i3.fDigits[i]
    else
    begin  {have to "borrow"}
      j := i + 1;
      while (j <= high(fDigits)) and (fDigits[j] = 0) do
        Inc(j);
      if j <= high(fDigits) then
      begin
        for k := j downto i + 1 do
        begin
          Dec(fDigits[k]);
          fDigits[k - 1] := fDigits[k - 1] + Base;
        end;
        fDigits[i] := fDigits[i] - i3.fDigits[i];
      end
      else
        ShowMessage('Subtract error');
    end;
  end;
  ReleaseScratchPad(i3);
  Trim;
end;

{*************** Mult  (Tinteger type) *********}
procedure TInteger.Mult(const I2: TInteger);
{Multiply - by Tinteger}
const
  ConstShift = 48;
var
  Carry, n, product: int64;
  xstart, ystart, i, j, k: integer;
  imult1:TInteger;
begin
  xstart := high(self.fDigits);
  ystart := high(i2.fDigits);
  //imult1.AssignZero;
  imult1:=GetNextScratchPad;
  imult1.Sign := i2.Sign * Sign;
  SetLength(imult1.fDigits, xstart + ystart + 3);
  // long multiply ignoring base
  for i := 0 to xstart do
  begin
    Carry := 0;
    for j := 0 to ystart do
    begin
      k     := i + j;
      product := i2.fDigits[j] * self.fDigits[i] + imult1.fDigits[k] + Carry;
      Carry := product shr ConstShift;
      if Carry = 0 then
        imult1.fDigits[k] := product
      else
      begin
        Carry := product div Base;
        imult1.fDigits[k] := product - Carry * Base;
      end;
    end;
    imult1.fDigits[ystart + i + 1] := Carry;
  end;
  // place in proper base
  xstart := length(imult1.fDigits) - 1;
  Carry  := 0;
  for i := 0 to xstart - 1 do
  begin
    n     := imult1.fDigits[i] + Carry;
    Carry := n div Base;
    imult1.fDigits[i] := n - Carry * Base;
  end;
  imult1.fDigits[xstart] := Carry;
  Assign(imult1);
  ReleaseScratchPad(Imult1);
end;

{*************** Mult  (Int64 type) *********}
procedure TInteger.Mult(const I2: int64);
{Multiply - by int64}
var
  Carry, n, d: int64;
  i:     integer;
  ITemp: TInteger;
begin
  d := system.abs(i2);
  if d > $ffffffff then {larger than 32 bits, use extended multiply}
  begin
    itemp:=getnextScratchpad(i2);
    self.Mult(itemp);
    releaseScratchPad(itemp);
    exit;
  end;
  Carry := 0;
  for i := 0 to high(fDigits) do
  begin
    n     := fDigits[i] * d + Carry;
    Carry := n div Base;
    fDigits[i] := n - Carry * Base;
  end;
  if Carry <> 0 then
  begin
    i := high(fDigits) + 1;
    SetLength(fDigits, i + 11 div GetBasePower + 1);
    while Carry > 0 do
    begin
      n     := Carry;
      Carry := n div Base;
      fDigits[i] := n - Carry * Base;
      Inc(i);
    end;
  end;
  Trim;
  setsign(i2*sign);
end;

{************ Divide *************}
procedure TInteger.Divide(const I2: TInteger);
{Divide - by TInteger}
var
  dummy: int64;
  idiv3:TInteger;
begin
  idiv3:=GetNextScratchPad;
  if high(i2.fDigits) = 0 then
    divmodsmall(i2.Sign * i2.fDigits[0], dummy)
  else
    {IDiv3 holds the remainder (which we don't need)}
    DivideRem(I2, idiv3);
  ReleaseScratchPad(idiv3);
end;

{************* Divide (Int64) **********}
procedure TInteger.Divide(const I2: int64);
{Divide - by Int64}
var
  dummy: int64;
  idiv2:TInteger;
begin
  if i2 = 0 then  exit;
  if system.abs(i2) < Base then
    divmodsmall(i2, dummy)
  else
  begin
    idiv2:=GetnextScratchpad(I2);
    Divide(idiv2);
    releaseScratchPad(idiv2);
  end;
end;

{***************** Modulo *************}
procedure Tinteger.Modulo(const i2: TInteger);
{Modulo (remainder after division) - by Tinteger}
var
  k: int64;
  imod3:TInteger;
begin
  if high(i2.fDigits) = 0 then
  begin
    divmodsmall(i2.Sign * i2.fDigits[0], k);
    assignsmall(k);
  end
  else
  begin
    imod3:=GetnextScratchPad;
    DivideRem(i2, imod3);
    Assign(imod3);
    releaseScratchPad(imod3);
  end;
end;

{***************** Modulo *************}
procedure Tinteger.Modulo(const n: Int64);
var
  i2:TInteger;
begin
  i2:=GetNextScratchpad(n);
  modulo(i2);
  releaseScratchPad(i2);
end;

{**************** Dividerem ***************}
procedure TInteger.DivideRem(const I2: TInteger; var remain: TInteger);
  procedure product(var x: TInteger; y: TInteger; k: integer);
  var
    {carry,} i:     integer;
    Carry, m, temp: int64;
  begin
    // multiple-length division revisited
    m := y.GetLength;
    x.AssignZero;
    Carry := 0;
    if length(x.fDigits) <= m then
      SetLength(x.fDigits, m + 1);
    for i := 0 to m - 1 do
    begin
      temp  := y.fDigits[i] * k + Carry;
      Carry := temp div BaseVal;
      x.fDigits[i] := temp - Carry * BaseVal;
    end;
     x.fDigits[m] := Carry;
  end;

  procedure Quotient(var x: TInteger; y: TInteger; k: integer);
  var
    i, m: integer;
    temp, Carry: int64;
  begin
    m := y.GetLength;
    x.AssignZero;
    Carry := 0;
    SetLength(x.fDigits, m);
    for i := m - 1 downto 0 do
    begin
      temp  := Carry * BaseVal + y.fDigits[i];
      x.fDigits[i] := temp div k;
      Carry := temp - x.Digits[i] * k;
    end;
  end;

  procedure Remainder(var x: TInteger; y: TInteger; k: integer);
  var
    Carry, n, temp: int64;
    i, m: integer;
  begin
    m := y.GetLength;
    x.AssignZero;
    Carry := 0;
    SetLength(x.fDigits, M);
    for i := m - 1 downto 0 do
    begin
      n     := (Carry * BaseVal + y.fDigits[i]);
      temp  := n div k;
      Carry := n - temp * k;
    end;
    x.fDigits[0] := Carry;
  end;

  function Trial(r, d: TInteger; k, m: integer): int64;
  var
    d2, r3: int64;
    km:     integer;
  begin
    {2 <= m <= k+m <= w}
    km := k + m;
    if length(r.fDigits) < km + 1 then
      SetLength(r.fDigits, km + 1);
    r3     := (r.fDigits[km] * BaseVal + r.fDigits[km - 1]) * BaseVal +
      r.fDigits[km - 2];
    d2     := d.fDigits[m - 1] * BaseVal + d.fDigits[m - 2];
    Result := min(r3 div d2, BaseVal - 1);
  end;

  function Smaller(r, dq: TInteger; k, m: integer): boolean;
  var
    i, j: integer;
  begin
    {0 <= k <= k+m <= w}
    i := m;
    j := 0;
    while i <> j do
      if r.fDigits[i + k] <> dq.fDigits[i] then
        j := i
      else
        Dec(i);
    Result := r.fDigits[i + k] < dq.fDigits[i];
  end;

  procedure Difference(var r: TInteger; dq: TInteger; k, m: integer);
  var
    borrow, diff, i: integer;
    acarry: int64;
  begin
    {0 <= k <= k+m <= w}
    if length(r.fDigits) < m + k + 1 then
      SetLength(r.fDigits, m + k + 1);
    if length(dq.fDigits) < m + 1 then
      SetLength(dq.fDigits, m + 1);
    borrow := 0;
    for i := 0 to m do
    begin
      diff   := r.fDigits[i + k] - dq.fDigits[i] - borrow + BaseVal;
      acarry := diff div BaseVal;
      r.fDigits[i + k] := diff - acarry * BaseVal;
      borrow := 1 - acarry;
    end;
    if borrow <> 0 then
      ShowMessage('Difference Overflow');
  end;

  procedure LongDivide(x, y: TInteger; var q, r: TInteger; const n, m: integer);
  var
    f, k: integer;
    qt:   int64;
    idiv4:TInteger;
    d,dq:TInteger;
  begin
    {2 <= m <= n <= w}
    f := BaseVal div (y.fDigits[m - 1] + 1);
    d:=GetNextscratchPad;
    dq:=GetNextScratchPad;
    product(r, x, f);
    product(d, y, f);
    q.AssignZero;
    SetLength(q.fDigits, n - m + 1);

    for k := n - m downto 0 do
    begin
      {2 <= m <= k+m <=n <= w}
      qt := trial(r, d, k, m);
      product(dq, d, qt);

      if length(dq.fDigits) < M + 1 then
        SetLength(dq.fDigits, M + 1);
      if smaller(r, dq, k, m) then
      begin
        qt := qt - 1;
        product(dq, d, qt);
      end;
      if k > high(q.fDigits) then
        SetLength(q.fDigits, k + 1);
      q.fDigits[k] := qt;
      difference(r, dq, k, m);
    end;
    idiv4:=GetNextScratchPad(r);
    Quotient(r, idiv4, f);
    r.Trim;
    ReleaseScratchPad(idiv4);
    ReleaseScratchPad(dq);
    ReleaseScratchPad(d);
  end;

  procedure Division(x, y: TInteger; var q, r: TInteger);
  var
    m, n, y1: integer;
  begin
    m := y.GetLength;
    if m = 1 then
    begin
      y1 := y.fDigits[m - 1];
      if y1 > 0 then
      begin
        Quotient(q, x, y1);
        Remainder(r, x, y1);
      end
      else
        ShowMessage('Division Overflow');
    end
    else
    begin
      n := x.GetLength;
      if m > n then
      begin
        q.AssignZero;
        r := x;
      end
      else {2 <= m <= n <= w}
        longdivide(x, y, q, r, n, m);
    end;
  end;

var
  signout: integer;
  signoutrem:integer;  {GDD}
  idivd2,idivd3:TInteger;
begin
  idivd2:=GetNextScratchPad(I2);
  if Sign <> idivd2.Sign then
    signout := -1
  else
    signout := +1;
  signoutrem:=sign;    {Preserve dividend sign GDD}
  if not self.IsZero then
    Sign := +1;
  if not idivd2.IsZero then
    idivd2.Sign := +1;
  if idivd2.IsZero then
  begin
    remain.AssignZero;
    releasescratchPad(idivd2);
    exit;
  end;

  if AbsCompare(idivd2) >= 0 then  {dividend>=divisor}
  begin
    idivd3:=GetNextScratchPad(self);
    division(idivd3, idivd2, self, remain);
    remain.Sign := signoutrem; {remainder sign:= Dividend sign GDD}
    Sign := signout;
    remain.Trim;
    Trim;
    releasescratchpad(idivd3);
  end
  else
  begin
    remain.Assign(self);
    AssignZero;
  end;
  releasescratchPad(idivd2);
end;

{**************** Compare ************}
function TInteger.Compare(i2: TInteger): integer;
  {Compare - to Tinteger}
begin
  if Sign < i2.Sign then
    Result := -1
  else if Sign > i2.Sign then
    Result := +1
  else if (self.Sign = 0) and (i2.Sign = 0) then
    Result := 0
  else
  begin
    {same sign} Result := AbsCompare(i2);
    if (Sign < 0) then
      Result := -Result; {inputs were negative, largest abs value is smallest}
  end;
end;

{****************** Compare (Int64) *********}
function TInteger.Compare(i2: int64): integer;
  {Compare - to int64}
  {return +1 if self>i2, 0 if self=i2 and -1 if self<i2)}
  var
    icomp3:TInteger;
begin
  icomp3:=GetnextScratchPad(i2);
  if Sign < icomp3.Sign then
    Result := -1
  else if Sign > icomp3.Sign then
    Result := +1
  else if (self.Sign = 0) and (icomp3.Sign = 0) then
    Result := 0
  else
  begin
    {same sign} Result := AbsCompare(icomp3);
    if Sign < 0 then
      Result := -Result;
  end;
  releaseScratchPad(icomp3);
end;

{************* IsZero *************}
function TInteger.IsZero: Boolean;
begin
  result := Sign=0;
end;

{************* AbsCompare *************}
function TInteger.AbsCompare(i2: Tinteger): integer;
  {compare absolute values ingoring signs - to Tinteger}
var
  i: integer;
begin
  Result := 0;
  if (self.Sign = 0) and (i2.Sign = 0) then
    Result := 0
  else if length(fDigits) > length(i2.fDigits) then
    Result := +1
  else if length(fDigits) < length(i2.fDigits) then
    Result := -1
  else {equal length}
    for i := high(fDigits) downto 0 do
    begin
      if fDigits[i] > i2.fDigits[i] then
      begin
        Result := +1;
        break;
      end
      else if fDigits[i] < i2.fDigits[i] then
      begin
        Result := -1;
        break;
      end;
    end;
end;

{************** ConvertToDecimalString ********}
function TInteger.ConvertToDecimalString(commas: boolean): string;
var
  i, j, NumCommas, CurPos, StopPos, b, DigCount, NewPos, Top: integer;
  n, nn, last: int64;
  c: byte;
begin
  trim;
  if length(fDigits) = 0 then
    AssignZero;
  if IsZero then
  begin
    Result := '0';
    exit;
  end;
  Result := '';
  b      := GetBasePower;
  Top    := high(self.Digits);
  Last   := fDigits[Top];
  DigCount := Top * b + 1 + trunc(Math.log10(Last));
  Dec(Top);
  if Sign > 0 then
  begin
    CurPos := DigCount;
    SetLength(Result, CurPos);
    StopPos := 0;
  end
  else
  begin
    CurPos := DigCount + 1;
    SetLength(Result, CurPos);
    Result[1] := '-';
    StopPos   := 1;
  end;
  for i := 0 to Top do
  begin
    n := fDigits[i];
    for j := 1 to b do
    begin
      nn := n div 10;
      c  := n - nn * 10;
      n  := nn;
      Result[CurPos] := char($30 + c);
      Dec(CurPos);
    end;
  end;
  repeat
    nn   := Last div 10;
    c    := Last - nn * 10;
    Last := nn;
    Result[CurPos] := char($30 + c);
    Dec(CurPos);
  until CurPos <= StopPos;
  if Commas = True then
  begin
    CurPos    := Length(Result);
    NumCommas := (DigCount - 1) div 3;
    if NumCommas > 0 then
    begin
      NewPos := CurPos + NumCommas;
      SetLength(Result, NewPos);
      for i := 1 to NumCommas do
      begin
        Result[NewPos]     := Result[CurPos];
        Result[NewPos - 1] := Result[CurPos - 1];
        Result[NewPos - 2] := Result[CurPos - 2];
        Result[NewPos - 3] := ThousandSeparator;
        Dec(NewPos, 4);
        Dec(CurPos, 3);
      end;
    end;
  end;
end;

{********* ConvertToInt64 **********}
function TInteger.ConvertToInt64(var n: int64): boolean;
var
  i: integer;
  savesign: integer;
begin
  Result   := False;
  savesign := Sign;
  Sign     := +1;
  if (self.Compare(high(n) {9223372036854775806}) < 1) then
  begin
    n := 0;
    for i := high(fDigits) downto 0 do
      n := Base * n + fDigits[i];
    if savesign < 0 then n := -n;
    Result := True;
  end;
  Sign := savesign;
end;

{********* Pow **************}
procedure Tinteger.Pow(const exponent: int64);
{raise self to the "exponent" power}
var
  i2: tinteger;
  n:  int64;
  s:  integer;
begin
  n := exponent;
  if (n <= 0) then
  begin
    if n = 0 then
      AssignOne
    else
      AssignZero;
    exit;
  end;
  s := Sign;
  if ((s < 0) and not (odd(n))) then
    s := 1;
  Sign := 1;
  i2:=GetNextScratchPad(1);
  if (n >= 1) then
    if n = 1 then
      i2.Assign(self)
    else
    begin
      repeat
        if (n and $1) = 1 then i2.Mult(self);
        n := N shr 1;
        application .processmessages;
        Square;
      until (n = 1);
      i2.Mult(self);
    end;
  Assign(i2);
  Sign := s;
  releaseScratchPad(i2);
end;

//partially rewritten by hk Oct 2005
procedure Tinteger.ModPow(const i2, m: Tinteger);
{self^I2 modulo m}
var
  ans, e, one: Tinteger;
  hulp: integer;
begin
  {if (length(i2.fdigits) = 0) or (length(m.fdigits) = 0) then
    exit;}
  hulp := i2.Getsign;
  if hulp <= 0 then
    if hulp = 0 then
    begin
      AssignOne;
      exit;
    end
    else
      exit;
  if m.IsZero then
    exit;
  One:=GetNextScratchPad(1);
  Ans:=GetNextScratchpad(1);
  E:=GetNextScratchPad(i2);
  hulp := e.Compare(one);
  if hulp >= 0 then
    if hulp = 0 then
    begin
      Modulo(m);
      ans.Assign(self);
    end
    else
    begin
      repeat
        if e.IsOdd then
        begin
          ans.Mult(self);
          ans.Modulo(m);
        end;
        e.divide2;
        Square;
        Modulo(m);
      until (e.Compare(one) = 0);
      ans.Mult(self);
      ans.Modulo(m);
    end;
  Assign(ans);
  Releasescratchpad(e);
  Releasescratchpad(ans);
  Releasescratchpad(one);
end;

{square root}
procedure Tinteger.Sqroot;
begin
  NRoot(2);
end;

{*********** IsOdd *********}
function Tinteger.IsOdd: boolean;
  {Return true if self is an odd integer}
begin
  Result := (fDigits[0] and $1) = 1;
end;

 {************** IsProbablyPrime ***********}
function Tinteger.IsProbablyPrime: boolean;
  //miller rabin probabilistic primetest with 10 random bases;
var
  n_1, one, i3, worki2: tinteger;
  Base, lastdigit, j, t, under10: integer;
  probableprime: boolean;
  p, work, s, diff, factorlimit: int64;

  function witness(Base: integer; e, n: tinteger): boolean;
  var
    it, h: tinteger;
    i:     integer;
  begin
    it := Getnextscratchpad(Base); //tinteger.Create;
    h  := GetNextScratchPad; //tinteger.Create;
    it.Assign(Base);
    it.ModPow(e, n);
    Result := True;
    for i := 1 to t do
    begin
      h.Assign(it);
      h.Square;
      h.Modulo(n);
      if h.Compare(one) = 0 then
        if it.Compare(one) <> 0 then
          if it.Compare(n_1) <> 0 then
            Result := False;
      it.Assign(h);
    end;
    if it.Compare(one) <> 0 then
      Result := False;
    releaseScratchpad(h);
    releasescratchpad(it);
  end;

  function is_smallprime: boolean;
  var
    j, w, diff: integer;
    prime: boolean;
    i: int64;
  begin
    prime := True;
    ConvertToInt64(i);
    w    := trunc(sqrt(0.0 + i));
    j    := 11;
    diff := 2;
    while prime and (j <= w) do
    begin
      if (i mod j) = 0 then
        prime := False;
      Inc(j, diff);
      if diff = 2 then
        diff := 4
      else
        diff := 2;
    end;
    Result := prime;
  end;

begin
  one:=GetnextScratchPad(1);
  n_1:= GetNextScratchPad;
  I3:=GetNextScratchPad;
  Worki2:=GetNextScratchPad;
  probableprime := True;
  factorlimit := self.Base;
  if factorlimit > 200 then
    factorlimit := 200;
  if factorlimit = 10 then
    factorlimit := 32;
  {lastdigit := worki2.shiftright mod 10; }
  lastdigit := fDigits[0] mod 10;
  under10 := Compare(10);
  if under10 = -1 then
    if (lastdigit <> 2) and (lastdigit <> 3) and (lastdigit <> 5) and
      (lastdigit <> 7) then
    begin
      probableprime := False;
    end;
  if under10 >= 0 then
  begin
    if (lastdigit <> 1) and (lastdigit <> 3) and (lastdigit <> 7) and
      (lastdigit <> 9) then
      probableprime := False
    else
    begin
      p := 3;
      while probableprime and (p < 8) do
      begin
        worki2.Assign(self);
        worki2.divmodsmall(p, work);
        if work = 0 then
          probableprime := False;
        p := p + 4;
      end;
    end;
  end;
  if probableprime and (under10 > 0) and (Compare(120) = 1) then
    if Compare(1000000) = -1 then
      probableprime := is_smallprime
    else
    begin
      p    := 11;
      diff := 2;
      while probableprime and (p < factorlimit) do
      begin
        worki2.Assign(self);
        worki2.divmodsmall(p, work);
        if work = 0 then
          probableprime := False;
        p := p + diff;
        if diff = 2 then
          diff := 4
        else
          diff := 2;
      end;
      if probableprime then
      begin
        one.AssignOne;
        n_1.Assign(self);
        n_1.Subtract(1);
        t := 0;
        i3.Assign(n_1);
        repeat
          if not (i3.IsOdd) then
          begin
            Inc(t);
            i3.divide2;
          end;
        until i3.IsOdd;
        worki2.Assign(self);
        j := 10;
        if Compare(1000000) > 0 then
          s := 1000000
        else
          worki2.ConvertToInt64(s);
        s := s - 1;
        while (j > 0) and probableprime do
        begin
          repeat
            Base := system.random(s);
          until Base > 1;
          probableprime := witness(Base, i3, worki2);
          Dec(j);
        end;
        //n_1.Free;
        //one.Free;
        releaseScratchPad(worki2);
        releaseScratchPad(i3);
        releasescratchpad(n_1);
        releasescratchpad(one);
      end;
    end;
  Result := probableprime;
end;

{************ NRoot **********}
procedure TInteger.NRoot(const root: integer);
var
  Parta, Partb, Partc, Guess: tinteger;
  Limit, Counter, nthroot, a: integer;
  num1, num2: int64;
  str1: string;
begin
  if (root < 2) or (self.Sign <> 1) then
  begin
    AssignZero;
    exit;
  end;
  // if number within range of int64 then compute there
  if self.ConvertToInt64(num1) = True then
  begin
    num2 := trunc(power(num1, 1 / root));
    if power(num2,root)>num1 then num2:=num2-1;
    if power(num2 + 1, root) <= num1 then
      self.Assign(num2 + 1)
    else
      self.Assign(num2);
    exit;
  end;
  Limit   := length(self.fDigits) * GetBasePower * 3 + 700;
  Counter := 0;
  nthroot := root - 1;
  PartA   := GetNextScratchpad(2);
  parta.Pow(root);
  if Compare(parta) < 0 then
  begin
    AssignOne;
    //parta.Free;
    releaseScratchPad(PartA);
    exit;
  end;
  PartB := GetNextScratchPad(0); // tinteger.Create;
  PartC := GetNextScratchPad(0); //tinteger.Create;
  Guess := GetNextScratchPad(0); //Tinteger.Create;
   //initial guess
  a     := high(self.fDigits) * GetBasePower div root - 1;
  if a = 0 then
    str1 := '2'
  else
    str1 := '1';
  str1 := str1 + stringofchar('0', a);
  guess.Assign(str1);
  parta.Assign(guess);
  parta.Pow(root);
  while self.Compare(parta) > 0 do
  begin
    guess.Mult(10);
    parta.Assign(guess);
    parta.Pow(root);
  end;
  parta.Assign(guess);
  PARTA.Divide(10);
  parta.Pow(root);
  while self.Compare(parta) <= 0 do
  begin
    guess.Divide(10);
    parta.Assign(guess);
    PARTA.Divide(10);
    parta.Pow(root);
  end;
  // start of newton
  repeat
    Inc(Counter);
    parta.Assign(guess);
    parta.Mult(nthroot);
    partb.Assign(self);
    Partc.Assign(guess);
    partc.Pow(nthroot);
    partb.Divide(partc);
    parta.Add(partb);
    parta.Divide(root);
    partc.Assign(guess);  //old guess
    partb.Assign(guess);
    partb.Subtract(1);
    guess.Assign(parta); //new guess
  until (Counter > 4) and ((Counter > Limit) or (partc.Compare(guess) = 0) or
      (partb.Compare(guess) = 0));
  if Counter > Limit then
    self.AssignZero
  else
  begin
    if partc.Compare(guess) = 0 then
      self.Assign(guess)
    else
    begin
      // assign smallest value to part c;
      if partc.Compare(guess) > 0 then
        partb.Assign(guess)
      else
        partb.Assign(partc);
      // ensure not too big
      partc.Assign(partb);
      partc.Pow(root);
      while (self.Compare(partc) < 0) and (Counter < (limit + 50)) do
      begin
        partb.Subtract(1);
        partc.Assign(partb);
        partc.Pow(root);
        Inc(Counter);
      end;
      // ensure not too small
      partc.Assign(partb);
      partc.Add(1);
      partc.Pow(root);
      while (self.Compare(partc) >= 0) and (Counter < (limit + 50)) do
      begin
        partb.Add(1);
        partc.Assign(partb);
        partc.Add(1);
        partc.Pow(root);
        Inc(Counter);
      end;
      if Counter < (limit + 50) then
        self.Assign(partb)
      else
        self.AssignZero;
    end;
  end;
  ReleaseScratchpad(Guess);
  ReleaseScratchpad(PartC);
  ReleaseScratchpad(PartB);
  ReleaseScratchpad(PartA);
end;

function TInteger.GetBase: integer;
begin
  Result := Base;
end;

procedure TInteger.AssignOne;
begin
  SetLength(fDigits, 1);
  self.Sign := 1;
  self.fDigits[0] := 1;
end;

procedure TInteger.AssignZero;
begin
  SetLength(fDigits, 1);
  self.Sign := 0;
  self.fDigits[0] := 0;
end;

(**** additions by hk Oct 2005***)
procedure TInteger.assignsmall(i2: int64);
begin
  if system.abs(i2) >= Base then
    Assign(i2)
  else
  if i2 = 0 then  AssignZero
  else
  begin
    if i2 < 0 then
    begin
      self.Sign := -1;
      i2 := -i2;
    end
    else self.Sign := +1;
    SetLength(self.fDigits, 1);
    self.fDigits[0] := i2;
  end;
end;

{************** Divide2 *************}
procedure TInteger.divide2;
{Fast divide by 2 }
var
  i: integer;
begin
  for i := high(fDigits) downto 1 do
  begin
    if (fDigits[i] and 1) = 1
    then  Inc(fDigits[i - 1], Base);
    fDigits[i] := fDigits[i] shr 1;
  end;
  fDigits[0] := fDigits[0] shr 1;
  Trim;
end;

{*********** DivModSmall **************}
procedure TInteger.divmodsmall(d: int64; var rem: int64);
{DivMod for d < base }
var
  i, dsign: integer;
  k, n, nn: int64;
  dh, remh: tinteger;
begin
  if (d = 0) or (d = 1) then
  begin
    rem := 0;
    exit;
  end;
  if d = 2 then
  begin
    rem := (fDigits[0] and 1);
    divide2;
    exit;
  end;
  if system.abs(d) >= self.Base then
  begin
    dh:=getNextScratchpad(d);
    remh:=getNextScratchPad(rem);
    DivideRem(dh, remh);
    remh.ConvertToInt64(rem);
    releasescratchpad(remh);
    releaseScratchPad(dh);
  end
  else
  begin
    if d < 0 then
    begin
      dsign := -1;
      d     := -d;
    end
    else dsign := 1;
    for i := high(fDigits) downto 1 do
    begin
      n  := fDigits[i];
      nn := n div d;
      k  := n - nn * d;
      fDigits[i] := nn;
      if k > 0 then
        fDigits[i - 1] := fDigits[i - 1] + k * Base;
    end;
    n   := fDigits[0];
    nn  := n div d;
    rem := n - nn * d;
    fDigits[0] := nn;
    if self.Sign < 0 then  rem := -rem;  {Set remainder sign to dividend sign GDD}
    self.Sign := self.Sign * dsign;
    Trim;
  end;
end;

procedure TInteger.AbsoluteValue;
begin
  if self.Sign < 0 then
    self.Sign := 1;
end;

{***************** FastMult ***************}
procedure TInteger.FastMult(const I2: TInteger);

const
  MaxArraySize = $7fffffff;
  MaxInt64ArrayElements = MaxArraySize div sizeof(int64); type
  TStaticInt64Array = array[0..MaxInt64ArrayElements - 1] of int64;
  PInt64Array = ^TStaticInt64Array;
  Int64Array = array of int64;
var
  HR: THandle;
  PA, PB, PR: PInt64Array;
  Alen, Blen, imin, imax, d: integer;

  procedure DoCarry(PR: PInt64Array; const base, d: integer);
  var
    i: integer;
    Carry: int64;
  begin
    Carry := 0;
    for i := 0 to d - 1 do
    begin
      Pr[i] := PR[i] + Carry;
      if Pr[i] < 0 then
        Carry := (Pr[i] + 1) div base - 1
      else
        Carry := PR[i] div base;
      Pr[i] := Pr[i] - Carry * base;
    end;
    if Carry <> 0 then
    begin
      pr[d - 1] := pr[d - 1] + Carry * base;
      ShowMessage('Error in FastMath DoCarry');
    end;
  end;

  procedure GradeSchoolMult(PA, PB, PR: PInt64Array; d: integer); const
  ConstShift = 48;
  var
    i, j, k,ALow,BLow: integer;
    Product, carry: int64;
  begin
    fillchar(pr[0],sizeof(int64)*2*d,0);
    Alow := d-1;
    BLow := ALow;
    while (Alow > 0) and (PA[ALow] = 0) do
      dec(ALow);
    while (BLow > 0) and (PB[Blow] = 0) do
      dec(BLow);
    k:=0;
    for i := 0 to ALow do
    begin
      Carry := 0;
      for j := 0 to BLow do
      begin
        k := i + j;
        Product := Pr[k] + PA[i] * PB[j] + Carry;
        Carry := Product shr ConstShift;
        if Carry = 0 then
          Pr[k] := product
        else begin
          Carry := product div base;
          Pr[k] := product - carry * Base;
        end;
      end;
     Pr[k + 1] :=  Pr[k + 1] + Carry;
    end;
  end;

  procedure Karatsuba(PA, PB, PR: PInt64Array; d: integer);
  var
    AL, AR, BL, BR, ASum, BSum, X1, X2, X3: PInt64Array;
    i, halfd: integer;
  begin
    if d <= 100 then
    begin
      GradeSchoolMult(Pa, Pb, Pr, d);
      exit;
    end;
    halfd := d shr 1;
    AR := @PA[0];
    AL := @PA[halfd];
    BR := @PB[0];
    BL := @PB[halfd];
    ASum := @PR[d * 5];
    BSum := @PR[d * 5 + halfd];
    X1 := @PR[0];
    X2 := @PR[d];
    X3 := @PR[d * 2];
    for i := 0 to halfd - 1 do
    begin
      asum[i] := al[i] + ar[i];
      bsum[i] := bl[i] + br[i];
    end;
    Karatsuba(AR, Br, X1, halfd);
    Karatsuba(AL, BL, X2, halfd);
    Karatsuba(ASum, BSum, X3, halfd);
    for i := 0 to d - 1 do
      X3[i] := X3[i] - X1[i] - X2[i];
    for i := 0 to d - 1 do
      PR[i + halfd] := PR[i + halfd] + X3[i];
  end;

begin
  Alen := length(self.fDigits);
  BLen := Length(I2.fDigits);
  iMin := ALen;
  iMax := BLen;
  if ALen > BLen then
  begin
    iMin := BLen;
    iMax := ALen;
  end;
  if (iMin < 80) or (imin < Imax shr 4) then
  begin
    self.Mult(i2);
    exit;
  end;
  d := 1;
  while d < iMax do
    d := d * 2;
  setlength(self.fDigits, d);
  setlength(i2.fDigits,d);
  PA := @self.fdigits[0];
  PB := @i2.fdigits[0];
  HR := GlobalAlloc(GMEM_FIXED, d * 6 * Sizeof(int64));
  PR := GlobalLock(HR);
  FillChar(Pr[0], sizeof(int64) * 6 * d, 0);
  Karatsuba(PA, PB, PR, d);
  DoCarry(Pr, self.Base, d * 2);
  d := 2 * d;
  while (d > 0) and (pr[d - 1] = 0) do
    Dec(d);
  setlength(self.fDigits, d);
  setlength(i2.fDigits, BLen);   {Changes input variable ?????????? GDD}
  move(pr[0], self.fdigits[0], d * sizeof(int64));
  self.Trim;
  self.Sign := self.Sign * i2.Sign;
  GlobalUnlock(HR);
  GlobalFree(HR);
end;

{*************** AssignHex ****************}
function TInteger.AssignHex(HexStr : String):Boolean;
var
  s:string;
  i,n:integer;
begin
  Result := True;
  Self.AssignZero;
  s:=uppercase(hexstr);
  for i:=1 to length(s) do
  begin
    mult(16);
    if s[i] in ['0'..'9'] then n:=ord(s[i])-ord('0')
    else if s[i] in ['A'..'F'] then n:=10 +ord(s[i])-ord('A')
    else
    begin
      result:=false;
      break;
    end;
    add(n);
  end;
end;

var
  hexdigits:array[0..15] of char=('0','1','2','3','4','5','6','7',
                                  '8','9','A','B','C','D','E','F');

function TInteger.ConvertToHexString:String;
var
  temp,rem,sixteen:TInteger;
  n:int64;
begin
  result:='';
  temp:=Getnextscratchpad(self);
  sixteen:=Getnextscratchpad(16);
  rem:=getnextscratchpad(0);
  repeat
    temp.dividerem(sixteen,rem);
    rem.convertToint64(n);
    result:=hexdigits[n]+result;
  until  temp.iszero;
  releasescratchpad(rem);
  releasescratchpad(sixteen);
  releasescratchpad(temp);
end;

procedure TInteger.RandomOfSize(size:integer);
var
  i:integer;
  s:string;
begin
  repeat {make sure the the leading digit is not 0}
    i:=system.random(10);
  until i<>0;
  s:=inttostr(i);
  for i:=2 to size do s:=s+inttostr(system.random(10));
  assign(s);
end;

{************** Random *************}
procedure TInteger.Random(maxint:TInteger);
{get a random number between 0 and maxint}
var
  i,d:integer;
begin
  if maxint.compare(1)<0 then assign(0)
  else
  begin
    maxint.trim;
    d:=length(maxint.fdigits);
    setdigitlength(d);
    sign:=1;
    repeat
      for i:=0 to d-1 do
      fdigits[i]:=system.random(base);
    until compare(maxint)<0;
  end;
end;

{**************** GetNextPrime **********}
procedure TInteger.Getnextprime;
var
  Test:TInteger;
begin
  Test:=TInteger.create;
  if not isodd then subtract(1);
  repeat
    add(2);
  until isprobablyprime;
  test.free;
end;

var i:integer;

initialization
  SetbaseVal(100000);
  randomize;
  Lastscratchpad:=0;
  setlength(scratchpads,20);
  for i:=0 to 19 do
  begin
    scratchpads[i]:=TInteger.create;
  end;
finalization

end.
