
In ggt.cfg und koordinator.cfg den Nameservice Node aktualisieren.

wbuild.bat

werl -setcookie a -name nameservice -run nameservice start

werl -setcookie a -name koordinator
  > K = koordinator:start().
  ...
  > K ! step.
  > K ! CMD.

werl -setcookie a -name starter
  > starter:start(0).

