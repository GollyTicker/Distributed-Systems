-module(reader).
-export([execute/4]).
-import(werkzeug,[timeMilliSecond/0]).
-import(utils,[log/3]).


execute(ServerService, Nrs, ClientNumber, Datei) ->
  % Maybe do stuff here...
  loop(ServerService, Nrs, ClientNumber, Datei).

loop(ServerService, Nrs, ClientNumber, Datei) ->
  
  ServerService ! {self(), getmessages},

  receive
    {reply,[Nr,Msg,_,_,_,_],Terminated} ->
      % log: dropped message NR at 16.06 09:55:43,525| content
      LogMsg = ["Received message ",Nr," at ",timeMilliSecond()," with ",Msg],
      ByEditor = messageByEditor(Nr, Nrs),
      log(Datei,editor, LogMsg ++ ByEditor),

      case Terminated of
        false -> loop(ServerService, Nrs, ClientNumber, Datei);
        true -> ok
      end;

    Any -> % Terminate
      log(Datei,editor,["Unknown message: ", Any])

  end.


messageByEditor(Nr,Nrs) ->
  [case lists:member(Nr, Nrs) of
    true -> 
      "was sent by my editor";
    false -> ""
  end].



