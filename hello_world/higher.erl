-module(higher).
-export([empty/1, foldl/3, reverse/1, 
         member/2, map/2, filter/2, partition/4, zip2/2, 
         quicksort/1, filterAcc/3]).


empty([]) -> true;
empty(_) -> false.

foldl(F, Acc, [H|T]) -> foldl(F, F(Acc, H), T);
foldl(_, Acc, []) -> Acc.

reverse(Xs) -> foldl(fun(A, X) -> [X|A] end, [], Xs).

member(_, []) -> false;
member(H, [H|_]) -> true;
member(E, [_|T]) -> member(E, T).

map(_, []) -> [];
map(F, [H|T]) -> [F(H) | map(F, T)].

filter(_, []) -> [];
filter(P, [H|T]) -> case P(H) of
  true  -> [H|filter(P, T)];
  false -> filter(P, T)
end.

filterAcc(_, [], Acc) -> reverse(Acc);
filterAcc(P, [H|T], Acc) -> case P(H) of
  true  -> filterAcc(P, T, [H|Acc]);
  false -> filterAcc(P, T, Acc)
end.

partition(_, [], Lower, Higher) -> {Lower, Higher};
partition(P, [H|T], Lower, Higher) -> case P(H) of
  true  -> partition(P, T, [H|Lower], Higher);
  false  -> partition(P, T, Lower, [H|Higher])
end.

zip2([], _) -> [];
zip2(_, []) -> [];
zip2([X|Xs], [Y|Ys]) -> [{X, Y}|zip2(Xs, Ys)].

quicksort([]) -> [];
quicksort([Pivot|T]) -> 
  {Lower, Higher} = partition(fun(X) -> X =< Pivot end, T, [], []),
  quicksort(Lower) ++ [Pivot] ++ quicksort(Higher).


