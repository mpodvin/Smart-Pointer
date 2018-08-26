# Smart-Pointer
Smart Pointer with Reference counting (small memory consumption penalty) 

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
