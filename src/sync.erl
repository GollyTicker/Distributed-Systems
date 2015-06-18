-module(sync).

-export([fstByMillis/1,millisToNextFrame/1]).

fstByMillis(M) ->
  RestInFrame = restInFrame(M),
  {M div 1000, RestInFrame div 40 + 1, RestInFrame rem 40}.

restInFrame(M) -> M rem 1000.

millisToNextFrame(M) -> restInFrame(M).



