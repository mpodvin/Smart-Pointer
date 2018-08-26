unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

uses MK.SmartPtr;
{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  h, h2, h3:Smart<TList>;
  i:Integer;
  sp4, sp44:Smart<TList>;
  sp, sp2, sp3:Smart<TStringList>;
  slist:BeSmart<TStringList>;

  procedure Show(const AList:Smart<TStringList>);
  begin
    AList.Add('31415');
    ShowMessage(IntToStr(AList.Count));
  end;
begin
  h := Smart.Create<TList>();
  for i := 1 to 100 do h.Add(TObject(666));
  h2 := h;
  h3 := h2;
  ShowMessage(IntToStr(h2.Count));

  h := nil;
  ShowMessage(IntToStr(h2.Count));
  h2 := nil;
  h3 := nil;

  sp4 := Smart.Create(TList.Create);
  sp44 := sp4;
  sp4 := nil;
  for i := 1 to 100 do sp44.Add(TObject(999999));

  sp := Smart.Create<TStringList>();
  with sp do for i := 1 to 100 do Add(IntToStr(i));
  ShowMessage(IntToStr(sp.Count));
  sp2 := sp;
  sp3 := sp;

  slist := TStringList.Create;
  Show(slist);

  sp := Smart.Create<TStringList>();
  for i := 1 to 10 do Smart.Create<TList>(); // memory leak?
  for i := 1 to 10 do Smart.Create(TList.Create);
end;

end.
