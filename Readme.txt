
In ggt.cfg und koordinator.cfg den Nameservice Node aktualisieren.

Windows:
> wbuild.bat

> werl -setcookie vs -name nameservice -run nameservice start

> werl -setcookie vs -name koordinator
  > koordinator:start().
  ...
  > chef ! step.
  > chef ! CMD.

> werl -setcookie vs -name starter
  > starter:start(0).


Linux:
> ./build.sh

> erl -name nameservice -setcookie vsp -run nameservice start

> erl -name koordinator -setcookie vsp
  > koordinator:start().
  ...
  > chef ! step.
  > chef ! CMD.

> erl -name starter -setcookie vsp
  > starter:start(9).

