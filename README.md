# Smart-Pointer
Smart Pointer with reference counting...

You can write this :

```pascal
var
  h:Smart<TList>;
  sp, sp4:Smart<TStringList>;
begin
  h := Smart.Create<TList>();
  ...
  sp4 := Smart.Create(TList.Create);
  ...
  sp := Smart.Create<TStringList>();
  ...
  //use it!
end;
```
