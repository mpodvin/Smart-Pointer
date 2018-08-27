(*
  Smart Pointer (with small memory consumption penalty)
  Be Smart!
  Copyright (c) 2018 Michel Podvin

  MIT License
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Based On :
  - Sergey Antonov(aka oxffff)'s code
  - Eric Grange's idea/code
*)
unit MK.SmartPtr;
{$M-,O+}
interface

// Uses Monitor hidden field to store refcount, so not compatible with monitor use
// (but Monitor is buggy, so no great loss) > Eric Grange
{$DEFINE USE_MONITOR}

type
  Smart<T> = reference to function:T;

  Smart = record
    class function Create<T:class>(AObject:T):Smart<T>;overload;static;
    class function Create<T:class,constructor>():Smart<T>;overload;static;inline;
  end;

  BeSmart<T:class> = record
  private
    FSmart:Smart<T>;
  public
    class operator Implicit(AObject:T):BeSmart<T>;inline;
    class operator Implicit(const ASmart:BeSmart<T>):Smart<T>;inline;
  end;

  function _CreateSmartObject(AObject:TObject):Pointer;//don't use it!

implementation

type
  TSmartRec = packed record // 8 or 12 bytes size
    VMT:Pointer;
    Instance:TObject;
{$IFNDEF USE_MONITOR}
    RefCount:Integer;
{$ENDIF}
  end;
  PSmartRec = ^TSmartRec;


function _AddRef(Self:PSmartRec):Integer;stdcall;
var
  Ptr:PInteger;
begin
{$IFDEF USE_MONITOR}
  Ptr := PInteger(NativeInt(Self^.Instance) + Self^.Instance.InstanceSize - hfFieldSize + hfMonitorOffset);
{$ELSE}
  Ptr := @(Self^.RefCount);
{$ENDIF}
  Result := AtomicIncrement(Ptr^);
end;

function _Release(Self:PSmartRec):Integer;stdcall;
var
  Ptr:PInteger;
begin
{$IFDEF USE_MONITOR}
  Ptr := PInteger(NativeInt(Self^.Instance) + Self^.Instance.InstanceSize - hfFieldSize + hfMonitorOffset);
{$ELSE}
  Ptr := @(AObj^.RefCount);
{$ENDIF}
  if Ptr^ = 0 then
  begin
    Self^.Instance.Free;
    FreeMem(Self);
    Result := 0;
  end
  else Result := AtomicDecrement(Ptr^);
end;

function _QueryInterface(Self:PSmartRec; const IID:TGUID; out Obj):HResult;stdcall;//for fun
begin
  Result := E_NOINTERFACE;
end;

function _Invoke(Self:PSmartRec):TObject;
begin
  Result := Self^.Instance;
end;

const
  PSEUDO_VMT:array[0..3] of Pointer = (@_QueryInterface, @_AddRef, @_Release, @_Invoke);

function _CreateSmartObject(AObject:TObject):Pointer;
var
  Ptr:PSmartRec absolute Result;
begin
  GetMem(Result, Sizeof(TSmartRec));
  with Ptr^ do
  begin
    VMT      := @PSEUDO_VMT;
    Instance := AObject;
{$IFNDEF USE_MONITOR}
    RefCount := 0; // because, by default, hfMonitor field value = 0
{$ENDIF}
  end;
end;

{ Smart }

class function Smart.Create<T>(AObject:T):Smart<T>;
begin
  if Assigned(Result) then IInterface(Result)._Release;
  Pointer(Result) := _CreateSmartObject(AObject);
end;

class function Smart.Create<T>:Smart<T>;
begin
  Result := Create(T.Create);
end;

{ BeSmart<T> }

class operator BeSmart<T>.Implicit(AObject:T):BeSmart<T>;
begin
  Result.FSmart := Smart.Create<T>(AObject);
end;

class operator BeSmart<T>.Implicit(const ASmart:BeSmart<T>):Smart<T>;
begin
  Result := ASmart.FSmart;
end;

end.
