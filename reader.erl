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
    {reply,MsgL,Terminated} ->
      
      TSclientIn = now(),
      [Nr,Msg|_] = MsgL ++ [TSclientIn],
      
      case Terminated of
        false ->
					LogMsg = ["Received #",Nr," at ",timeMilliSecond(),"| ",Msg],
					ByEditor = messageByEditor(Nr, Nrs),
					log(Datei,reader, LogMsg ++ ByEditor),
					loop(ServerService, Nrs, ClientNumber, Datei);
        true ->
					log(Datei,reader,["Terminated for #",Nr]),
					ok
      end;

    Any -> % Terminate
      log(Datei,reader,["Unknown message: ", Any])

  end.


messageByEditor(Nr,Nrs) ->
  [case lists:member(Nr, Nrs) of
    true -> 
      "was sent by my editor";
    false -> ""
  end].



