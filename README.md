# Smart-Pointer
Smart Pointer with reference counting and small memory consumption penalty (8 or 12 bytes in 32bits).

Be Smart !

You can write this :

```pascal
var
  h:Smart<TList>;
  sp, sp4:Smart<TStringList>;
  slist:BeSmart<TStringList>;
begin
  h := Smart.Create<TList>();
  h.Add(...);
  ...
  sp4 := Smart.Create(TStringList.Create);
  sp4.LoadFromFile(...);
  ...
  sp := Smart.Create<TStringList>(TStringList.Create);
  ...
  slist := TStringList.Create;
  ...
  //use it!
end;
```
