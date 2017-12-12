unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, psAPI, ComCtrls, ExtCtrls, DES, UBigIntsV3;

type
  TForm1 = class(TForm)
    Label9: TLabel;
    Ehasil: TEdit;
    Label10: TLabel;
    Button3: TButton;
    GroupBox2: TGroupBox;
    Plainteks: TMemo;
    GroupBox4: TGroupBox;
    Plainteks2: TMemo;
    Panel1: TPanel;
    GroupBox3: TGroupBox;
    Chiperteks: TMemo;
    ControlSheet: TPageControl;
    IntroSheet: TTabSheet;
    GroupBox6: TGroupBox;
    Button2: TButton;
    Button1: TButton;
    GroupBox5: TGroupBox;
    kunciDES: TEdit;
    TabSheet2: TTabSheet;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Long1Edt: TEdit;
    Long2Edt: TEdit;
    Long3Edt: TEdit;
    NextPrima: TButton;
    KunciPublik: TButton;
    Memo1: TMemo;
    Control: TGroupBox;
    Enkripsi: TButton;
    Dekripsi: TButton;
    Label8: TLabel;
    timerDec: TEdit;
    Label7: TLabel;
    Label6: TLabel;
    timerEnc: TEdit;
    Label5: TLabel;
    Help: TTabSheet;
    About: TMemo;
    TabSheet1: TTabSheet;
    MemoHelp: TMemo;
    Label11: TLabel;
    procedure NextPrimaClick(Sender: TObject);
    procedure KunciPublikClick(Sender: TObject);
    procedure EnkripsiClick(Sender: TObject);
    procedure DekripsiClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


{************** FungsiTimer**************}
Function TimerMilliseconds (const D1, D2 : TDateTime) : Int64;
const
  OneDay         = 1.0;
  OneHour        = OneDay / 24.0;
  OneMinute      = OneHour / 60.0;
  OneSecond      = OneMinute / 60.0;
  OneMillisecond = OneSecond / 1000.0;
Begin
  Result := Trunc ((D2 - D1) / OneMillisecond);
End;

{************** Elgamal-NextPrima(p) **************}
procedure TForm1.NextPrimaClick(Sender: TObject);
var
  i1:Tinteger;
begin
  screen.cursor:=crhourglass;
  i1:=TInteger.create;
  i1.assign(long3edt.text);
  i1.Getnextprime;
  long3edt.text:=i1.converttoDecimalString(false);
  i1.free;
  screen.cursor:=crdefault;
end;

{************ Elgamal-KunciPublik *************}
procedure TForm1.KunciPublikClick(Sender: TObject);
var bil,g,x,p :Tinteger;
r:boolean;
begin
application.processmessages;
bil:=tinteger.create;
bil.assign(long3edt.text);
r:=bil.IsProbablyPrime;
if not r then
ShowMessage('Untuk membuat Kunci Publik, P harus Prima. Gunakan tombol "Next Prime (p)" untuk mencari bilangan prima yang lain.')
else
g:=TInteger.create;
x:=TInteger.create;
p:=TInteger.create;
g.assign(long1edt.text);
x.assign(long2edt.text);
p.assign(long3edt.text);
g.modpow(x,p);            //g^x mod p
memo1.text:=g.ConvertToDecimalString(False);   //true jika ingin menggunakan separator ribuan
g.free;
x.free;
p.free;
end;

{************** Elgamal-Enkripsi **************}
procedure TForm1.EnkripsiClick(Sender: TObject);
var
g,y,p,k:Tinteger;
ldMulai,ldSelesai : TDateTime;
liSelisih : Int64;
gkp,k_str,y_str,temp,temp2,temp3,str:string;
outblock,k_int,m,j:integer;
begin
ldMulai := now;
Chiperteks.clear;
g:=TInteger.create;
y:=TInteger.create;
p:=TInteger.create;
k:=TInteger.create;
y.assign(memo1.text);
p.assign(long3edt.text);

outblock:=p.digitcount;  // ukuran output blok
str:=Plainteks.text;             //m string

Temp:='';
Temp2:='';
Temp3:='';
Chiperteks.Text:='waiting...';
    FOR j := 1 TO Length(Str) DO
    BEGIN
    g.assign(long1edt.text);
    y.assign(memo1.text);
    k.random(p);                    //k random
    g.modpow(k,p);                  //g^k mod p
    k_str:=k.convertTodecimalstring(false);   //k string
    k_int:=strtoint(k_str);                     // k integer

    m:=Ord(Str[j]);
    y.pow(k_int);                               //y^k
    y.mult(m);                                  //y^k . m
    y.modulo(p);                                //y^k . m mod p
    gkp:= g.convertTodecimalstring(false);
    y_str:=y.convertTodecimalstring(false);

    while length(gkp)<outblock do
    gkp:='0'+gkp;         // penambahan '0' jika digit blok hasil enkripsi kurang dari digit p
    Temp:=Temp+gkp;

    while length(y_str)<outblock do
    y_str:='0'+y_str;   // penambahan '0' jika digit blok hasil enkripsi kurang dari digit p
    Temp2:=Temp2+y_str;

    Temp3:=Temp3+Temp+Temp2;
    temp:='';
    temp2:='';
    END;

Chiperteks.Text:=temp3;        //ab
Ehasil.Text := inttostr(length(str));
ldSelesai := now;
liSelisih := TimerMilliseconds( ldMulai, ldSelesai);
timerEnc.text:=inttostr(liselisih);
end;

{************** Elgamal-Dekripsi **************}
procedure TForm1.DekripsiClick(Sender: TObject);
var
p,x,a,b:Tinteger;
ldMulai, ldSelesai : TDateTime;
liSelisih : Int64;
Inblock,p2,x2,p1x:integer;
ch:Int64;
p_str,x_str,plain,chiper,dstring:string;
begin
ldMulai := now;
p:=TInteger.Create;
x:=TInteger.Create;
a:=TInteger.Create;
b:=TInteger.Create;
p.assign(Long3edt.text);
x.assign(Long2edt.text);
p_str:=p.convertTodecimalstring(false);
x_str:=x.convertTodecimalstring(false);
p2:=strtoint(p_str);
x2:=strtoint(x_str);
Inblock:=p.digitcount;  // ukuran Input blok
chiper:=Chiperteks.Text;

plain:='';
plainteks2.text:='waiting...';
while length(chiper)>0 do
        begin
        a.assign(copy(chiper,1,Inblock));
        delete(chiper,1,Inblock);
        b.assign(copy(chiper,1,Inblock));
        delete(chiper,1,Inblock);
        p1x:=p2-1-x2;     //(p-1-x)
        a.pow(p1x);       //a^(p-1-x)
        a.modulo(p2);      //a^(p-1-x) mod p
        a.mult(b);          // a^(p-1-x).b
        a.modulo(p2);      //a^(p-1-x).b mod p
        a.converttoInt64(ch);

        dstring:=char(ch);
        plain:=plain+dstring;
        dstring:='';
        end;
plainteks2.Text:=plain;
ldSelesai := now;
liSelisih := TimerMilliseconds( ldMulai, ldSelesai);
timerDec.text:=inttostr(liselisih);
end;

{************** DES-Enkripsi**************}
procedure TForm1.Button1Click(Sender: TObject);
var
ldMulai, ldSelesai : TDateTime;
liSelisih : Int64;
teks:string;
begin
  ldMulai := now;
  Chiperteks.Text:= DES.EncryStrHex(Plainteks.Text,kunciDES.Text );
  teks := Plainteks.Text ;
  Ehasil.Text := inttostr(length(teks));
  ldSelesai := now;
  liSelisih := TimerMilliseconds( ldMulai, ldSelesai);
  timerEnc.text:=inttostr(liselisih);
end;

{************** DES-Dekripsi**************}
procedure TForm1.Button2Click(Sender: TObject);
var
ldMulai, ldSelesai : TDateTime;
liSelisih : Int64;
begin
   ldMulai := now;
   Plainteks2.Text := DES.DecryStrHex(Chiperteks.Text,kunciDES.Text);
   ldSelesai := now;
   liSelisih := TimerMilliseconds( ldMulai, ldSelesai);
   timerDec.text:=inttostr(liselisih);
end;

{************** Clearence**************}
procedure TForm1.Button3Click(Sender: TObject);
begin
  Plainteks.clear;
  Chiperteks.clear;
  Plainteks2.clear;
  Ehasil.Clear;
  timerEnc.Clear;
  timerDec.Clear;
end;

end.
