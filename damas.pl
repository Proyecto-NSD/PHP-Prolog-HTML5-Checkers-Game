% Proyecto-NSD
% Checkers IA
%
% @package nsd\prolog\checkers
% @author Nehuen Prados <nehuensd@gmail.com>, Gil Osher
% @copyright Public Domain
% @version 1

% Evita los molestos warning por variables Singleton.
:- style_check(-singleton).

% Functor amigable para ser llamado esternamente desde consola.
%
% @since 1
% @param Board Estado actual del tablero.
% @param FromC Columna de origen del movimiento del jugador.
% @param FromR Fila de origen del movimiento del jugador.
% @param ToC Columna de destino del movimiento del jugador.
% @param ToR Fila de destino del movimiento del jugador.
playPHP(Board, FromC, FromR, ToC, ToR) :- process(FromC/FromR-ToC/ToR, Board, 2).

% Procesa una movimiento del usuario validandolo y de ser correcto, llama a la IA para que haga su jugada.
% Finalmente escribe estado del tablero para retornar.
%
% @since 1
% @param Board Estado actual del tablero.
% @param FromC Columna de origen del movimiento del jugador.
% @param FromR Fila de origen del movimiento del jugador.
% @param ToC Columna de destino del movimiento del jugador.
% @param ToR Fila de destino del movimiento del jugador.
% @param Level Nivel de dificultad del juego ("Nivel de inteligencia de la IA").
process(FromC/FromR-ToC/ToR, Board, Level) :-
            move(Board, FromC, FromR, ToC, ToR, NewBoard), 				% Realiza el movimiento del usuario.
			alphabeta(x/NewBoard, -100, 100, End/EndBoard, _, Level), 	% La IA hace su jugada.
			write(EndBoard). 											% Imprime el tablero para enviarlo de respuesta.

% Getter del tablero.
% Obtiene el valor almacenado en una posicion del tablero.
%
% @since 1
% @param Board Estado actual del tablero.
% @param Line Linea del tablaro.
% @param Col Columna del tablero.
% @param Sign Valor de la posicion.
getPos(Board, Line, Col, Sign) :-
       Num is ((Line - 1) * 8) + Col, 		% Se reduce una dimension en la matriz.
       arg(Num, Board, Sign). 				% Retorna en Sign el argumento que este en la posicion Num de Board.

% Se fija si la posicion del tablero esta ocupada por una pieza.
%
% @since 1
% @param Board El tablero.
% @param Line Linea del tablaro.
% @param Col Columna del tablero.
% @param Pawn Tipo de pieza que ocupa la posicion.
getPawn(Board, Line, Col, Pawn) :-
         getPos( Board, Line, Col, Pawn), 				% Obtiene el valor de la casilla del tablero.
         (Pawn = x; Pawn = xx; Pawn = o; Pawn = oo). 	% Se fija si es una pieza valida.

% Setter del tablero.
% Graba un valor en una posicion del tablero identificando si se trata de una reina de forma automatica.
%
% @since 1
% @param Board Estado actual del tablero.
% @param Line Linea del tablaro.
% @param Col Columna del tablero.
% @param Sign Valor a grabar.
% @param NewBoard estado final del tablero luego del cambio.
putSign(Board, 8, Col, x, NewBoard) :- putSign(Board, 8, Col, xx, NewBoard), !. 	% La IA adquiere una reina.
putSign(Board, 1, Col, o, NewBoard) :- putSign(Board, 1, Col, oo, NewBoard), !. 	% El jugador adquiere una reina.
putSign(Board, Line, Col, Sign, NewBoard) :-
         Place is ((Line - 1) * 8) + Col, 											% Se reduce una dimension en la matriz.
         Board =.. [board|List],			 										% Se convierte el functor del tablero en una lista.
         replace(List, Place, Sign, NewList), 										% Se reemplaza el valor actual por el nuevo.
         NewBoard =.. [board|NewList]. 												% Se convierte la lista con el elemento modificado en un nuevo functor.

% Reemplaza un elemento de una lista por otro en una posicion determinada.
%
% @since 1
% @param List Lista que representa al tablero.
% @param Place Posicion de la lista a remmplazar.
% @param Val Valor nuevo.
% @param NewList estado final de la lista luego del cambio.
replace(List, Place, Val, NewList) :- replace(List, Place, Val, NewList, 1). 	% Se llama recursivamente empezando por la posicion 1.
replace([_|OldCola], Place, Val, [Val|OldCola], Place) :- !. 					% Cuando encuentra la posicion hace el reemplazo y para la ejecucion.
replace([Cabeza|OldCola], Place, Val, [Cabeza|NewCola], Counter) :- 			% No es la posicion que se buscaba.
        NewCounter is Counter + 1, 												% Incrementar la posicion.
        replace(OldCola, Place, Val, NewCola, NewCounter). 						% Llamarse recursivamente.

% Cuenta cuantas piezas hay en el tablero de un jugador determinado.
%
% @since 1
% @param Board Estado actual del tablero.
% @param Sign Signo de la pieza a contar.
% @param Res La cantidad encontrada.
count(Board, Sign, Res) :-
    Board =.. [board|List], 				% Se convierte el functor del tablero en una lista.
    count(List, Sign, Res, 0). 				% Se comienza a recorrer con el contador en 0.
count([], _, Res, Res) :- !. 				% Cuando la lista esta vacia, no hay mas nada para contar.
count([Sign|Cola], Sign, Res, Counter) :- 	% La casilla tiene la pieza buscada.
    NewCounter is Counter + 1, 				% Se incrementa el contador.
    count(Cola, Sign, Res, NewCounter). 	% Se continua buscando.
count([_|Cola], Sign, Res, Counter) :-   	% La casilla no tiene la pieza buscada.
    count(Cola, Sign, Res, Counter).     	% Se continua buscando.

% ¿A quien le toca el proximo turno?
%
% @since 1
% @param Turn Jugador que esta jugando ahora.
% @param NexTurn El jugador del proximo turno.
next_player(x, o). 		% Esta jugando la IA, le toca al jugador.
next_player(o, x). 		% Esta jugando el jugador, le toca a la IA.

% ¿De que jugador es la pieza?
%
% @since 1
% @param Player El jugador que es dueño de la pieza.
% @param Sign Pieza del tablero.
turn_to_sign(x, x).  	% Los peones negros son de la IA.
turn_to_sign(x, xx). 	% Las reinas negras son de la IA.
turn_to_sign(o, o).  	% Los peones blancos son del jugador.
turn_to_sign(o, oo). 	% Las reinas blancas son del jugador.

% Condicion de victoria. Verifica si alguien ha ganado la partida.
%
% @since 1
% @param Board Estado actual del tablero.
% @param Winner Ganador de la partida.
% @todo Hacer que pierda si solo tiene 1 ficha.
goal(Board, Winner) :-
    next_player(Winner, Looser),
    findall(NewBoard, (turn_to_sign(Looser,Sign),validMove(Board, Sign, NewBoard)), []), !.

% Quienes son los enemigos de cada pieza del tablero.
%
% @since 1
% @param Piece Pieza del tablero.
% @param Enemy Tipo de pieza enemiga.
enemy(o, x).   		% Los peones del jugador son enemigos de los peones de la IA.
enemy(o, xx).  		% Los peones del jugador son enemigos de las reinas de la IA.
enemy(x, o).   		% Los peones de la IA son enemigos de los peones del jugador.
enemy(x, oo).  		% Los peones de la IA son enemigos de las reinas del jugador.
enemy(oo, x).  		% Las reinas del jugador son enemigos de los peones de la IA.
enemy(oo, xx). 		% Las reinas del jugador son enemigos de las reinas de la IA.
enemy(xx, o).  		% Las reinas de la IA son enemigos de los peones del jugador.
enemy(xx, oo). 		% Las reinas de la IA son enemigos de las reinas del jugador.

%
% Move relations
%

% move a pawn from one location to another location
move( Board, FromC, FromR, ToC, ToR, NewBoard) :-
      getPawn(Board, FromC, FromR, P),
      turn_to_sign(T, P),!,
      validMove(Board, T, NewBoard), 	% Check if there is an eat constraint on the board
      (movePawnEatRec(Board, P, FromC, FromR, ToC, ToR, NewBoard) ;
      movePawn(Board, P, FromC, FromR, ToC, ToR, NewBoard)).

% Perform a standard move of a pawn
movePawn( Board, Pawn, FromC, FromR, ToC, ToR, NewBoard) :-
          validateMove(Board, Pawn, FromC, FromR, ToC, ToR),
          putSign(Board, FromC, FromR, e, TB),
          putSign(TB, ToC, ToR, Pawn, NewBoard).

% Perform an eating move of a pawn recursively
movePawnEatRec( Board, Pawn, FromC, FromR, ToC, ToR, NewBoard) :-
          movePawnEat( Board, Pawn, FromC, FromR, ToC, ToR, NewBoard).

movePawnEatRec( Board, Pawn, FromC, FromR, ToC, ToR, NewBoard) :-
          ((Pawn = x ; Pawn = xx ; Pawn = oo),
          FromC1 is FromC + 2 ;
          (Pawn = o ; Pawn = xx ; Pawn = oo),
          FromC1 is FromC - 2),
          FromR1 is FromR + 2,
          FromR2 is FromR - 2,
          (movePawnEat( Board, Pawn, FromC, FromR, FromC1, FromR1, TempBoard),
          movePawnEatRec( TempBoard, Pawn, FromC1, FromR1, ToC, ToR, NewBoard) ;
          movePawnEat( Board, Pawn, FromC, FromR, FromC1, FromR2, TempBoard),
          movePawnEatRec( TempBoard, Pawn, FromC1, FromR2, ToC, ToR, NewBoard)).

% Perform a standard eating move of a pawn
movePawnEat( Board, Pawn, FromC, FromR, ToC, ToR, NewBoard) :-
          validateEat(Board, Pawn, FromC, FromR, ToC, ToR),
          getPos(Board, ToC, ToR, e),
          EC1 is (FromR + ToR) / 2,
          EL1 is (FromC + ToC) / 2,
          abs(EC1, ComidoR), abs(EL1, ComidoC),
          putSign(Board, FromC, FromR, e, TB1),
          putSign(TB1, ComidoC, ComidoR, e, TB2),
          putSign(TB2, ToC, ToR, Pawn, NewBoard).

% Valida un intento de comer segun el tipo de pieza.
%
% @since 1
% @param Board Estado actual del tablero.
% @param Piece Pieza del tablero.
% @param FromC Columna de origen del movimiento.
% @param FromR Fila de origen del movimiento.
% @param ToC Columna de destino del movimiento.
% @param ToR Fila de destino del movimiento.
% @TODO Los nombres de filas y columnas estan al revez en todos lados, no aca solo.
validateEat(Board, King, FromC, FromR, ToC, ToR) :-				% Cuando la que come es una reina.
        (King = xx ; King = oo),								% Si es una reina de la IA o del Jugador.
        ToC >= 1, ToR >= 1,										% Si se esta moviendo a una
        FromC =< 8, FromC =< 8,									% casilla que esta dentro del tablero.
        (ToC is FromC - 2 ;										% Si la columna esta salteando solo un casillero hacia la izquierda
         ToC is FromC + 2),										% o hacia la derecha.
        (ToR is FromR + 2 ;										% Si la fila esta salteando solo un casillero hacia abajo
         ToR is FromR - 2),                        				% o hacia arriba.
		validateEatPos(Board, King, FromC, FromR, ToC, ToR).	% Validar la casilla comida.

validateEat( Board, x, FromC, FromR, ToC, ToR) :-				% Cuando el que come es un peon de la IA.
        ToC >= 1, ToR >= 1,                            			% Si se esta moviendo a una
        FromC =< 8, FromC =< 8,                        			% casilla que esta dentro del tablero.
        ToC is FromC + 2,                              			% Si la fila esta salteando solo un casillero hacia abajo.
        (ToR is FromR + 2 ;                            			% Si la columna esta salteando solo un casillero hacia la izquierda
         ToR is FromR - 2),                            			% o hacia la derecha.
		validateEatPos(Board, x, FromC, FromR, ToC, ToR).		% Validar la casilla comida.

validateEat( Board, o, FromC, FromR, ToC, ToR) :-           	% Cuando el que come es un peon del jugador.
        ToC >= 1, ToR >= 1,                            			% Si se esta moviendo a una
        FromC =< 8, FromC =< 8,                        			% casilla que esta dentro del tablero.
        ToC is FromC - 2,                              			% Si la fila esta salteando solo un casillero hacia arriba.
        (ToR is FromR + 2;                            			% Si la columna esta salteando solo un casillero hacia la izquierda
         ToR is FromR - 2),                            			% o hacia la derecha.
		validateEatPos(Board, o, FromC, FromR, ToC, ToR).		% Validar la casilla comida.

validateEatPos(Board, Piece, FromC, FromR, ToC, ToR) :-			% Valida si la casilla comida es enemiga de la que come.
        ComidoC is (ToC + FromC) / 2,                 			% Columna del casillero comido.
        ComidoR is (ToR + FromR) / 2,                 			% Fila del casillero comido.
        enemy(Piece, Enemy),                          			% Traer los enemigos de la pieza que esta comiendo.
        getPawn(Board, ComidoC, ComidoR, Enemy).      			% Ver si la pieza que esta en la posicion comida esta entre los enemigos de la que come.

% Check if a specific move is valid
validateMove( Board, King, FromC, FromR, ToC, ToR) :-
              (King = xx ; King = oo),
              ToC >= 1, ToR >= 1,
              FromC =< 8, FromC =< 8,
              (ToC is FromC + 1 ;
               ToC is FromC - 1),
              (ToR is FromR + 1 ;
               ToR is FromR - 1),
               getPos(Board, ToC, ToR, e).

validateMove( Board, x, FromC, FromR, ToC, ToR) :-
              ToC >= 1, ToR >= 1,
              FromC =< 8, FromC =< 8,
              ToC is FromC + 1,
              (ToR is FromR + 1 ;
               ToR is FromR - 1),
               getPos(Board, ToC, ToR, e).

validateMove( Board, o, FromC, FromR, ToC, ToR) :-
              ToC >= 1, ToR >= 1,
              FromC =< 8, FromC =< 8,
              ToC is FromC - 1,
              (ToR is FromR + 1 ;
               ToR is FromR - 1),
               getPos(Board, ToC, ToR, e).

% Gets a board and a place in the array
% and returns the line and column of it
findPawn( Board, S, Line, Col) :-
          arg(Num, Board, S),
          Temp is Num / 8,
          ceiling(Temp, Line),
          Col is Num - ((Line - 1) * 8).

% Get all the valid eat moves that availible on the board
validEatMove( Board, Sign, NewBoard) :-
           findPawn(Board, Sign, L, C),findPawn(Board, e, Tl, Tc),
           movePawnEatRec(Board, Sign, L, C, Tl, Tc, NewBoard).

% Get all the valid standard moves that availible on the board
validStdMove( Board, Sign, NewBoard) :-
              findPawn(Board, Sign, L, C),findPawn(Board, e, Tl, Tc),
              movePawn(Board, Sign, L, C, Tl, Tc, NewBoard).

% A move on the board is valid if it's an eat move
validMove( Board, Turn, NewBoard) :-
           turn_to_sign(Turn, Sign),
           validEatMove(Board, Sign, NewBoard).

% Or a standard move when no eat moves are availible
validMove( Board, Turn, NewBoard) :-
           not((turn_to_sign(Turn, Sign),
           validEatMove(Board, Sign, NewBoard))),
           turn_to_sign(Turn, Sign1),
           validStdMove(Board, Sign1, NewBoard).



%
% Alpha-Beta implementation
%

% @TODO: Ver que onda con esto.
min_to_move(o/_).
max_to_move(x/_).

% alphabeta algorithm
alphabeta( Pos, Alpha, Beta, GoodPos, Val, Depth) :-
           Depth > 0, moves( Pos, PosList), !,
           boundedbest( PosList, Alpha, Beta, GoodPos, Val, Depth);
           staticval( Pos, Val).        % Static value of Pos

boundedbest( [Pos|PosList], Alpha, Beta, GoodPos, GoodVal, Depth) :-
             Depth1 is Depth - 1,
             alphabeta( Pos, Alpha, Beta, _, Val, Depth1),
             goodenough( PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth).

goodenough( [], _, _, Pos, Val, Pos, Val, _) :- !.     % No other candidate

goodenough( _, Alpha, Beta, Pos, Val, Pos, Val, _) :-
            min_to_move( Pos), Val > Beta, !;       % Maximizer attained upper bound
            max_to_move( Pos), Val < Alpha, !.      % Minimizer attained lower bound

goodenough( PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth) :-
            newbounds( Alpha, Beta, Pos, Val, NewAlpha, NewBeta),        % Refine bounds
            boundedbest( PosList, NewAlpha, NewBeta, Pos1, Val1, Depth),
            betterof( Pos, Val, Pos1, Val1, GoodPos, GoodVal).

newbounds( Alpha, Beta, Pos, Val, Val, Beta) :-
           min_to_move( Pos), Val > Alpha, !.        % Maximizer increased lower bound

newbounds( Alpha, Beta, Pos, Val, Alpha, Val) :-
           max_to_move( Pos), Val < Beta, !.         % Minimizer decreased upper bound

newbounds( Alpha, Beta, _, _, Alpha, Beta).          % Otherwise bounds unchanged

betterof( Pos, Val, _, Val1, Pos, Val) :-         % Pos better then Pos1
          min_to_move( Pos), Val > Val1, !;
          max_to_move( Pos), Val < Val1, !.

betterof( _, _, Pos1, Val1, Pos1, Val1).             % Otherwise Pos1 better

%
% Alpha-Beta satellite relations
%

% Get a list of the valid moves that can be on the board
moves( Turn/Board, [X|Xs]) :-
       next_player(Turn, NextTurn),
       findall(NextTurn/NewBoard, validMove(Board, Turn, NewBoard), [X|Xs]).

% Combierte un peon en una reina.
%
% @since 1
% @param Pawn Signo del peon.
% @param King Signo de la reina.
king_sign(x, xx). 	% El peon de la IA se convierte en reina.
king_sign(o, oo). 	% El peon del jugador se convierte en reina.

% The hueristic function
% The amount of the computers pawns minus the amount of the human pawns
% a king is worth two standard pawns
staticval( _/Board, Res) :-
           max_to_move(Comp/_),
           min_to_move(Human/_),
           %next_player(Comp, Human),
           count( Board, Comp, Res1),
           count( Board, Human, Res2),
           king_sign(Comp, CompK),
           king_sign(Human, HumanK),
           count(Board, CompK, Res1k),
           count(Board, HumanK, Res2k),
           king_bonus(Board, CompK, Bonus),
           Res is (Res1 + (Res1k * 1.4)) - (Res2 + (Res2k * 1.4)) + Bonus.

king_bonus( Board, Sign, Bonus) :-
            findall(L/C, findPawn(Board, Sign, L, C), List),!,
            king_bonusL( List, Bonus, 0).

king_bonusL( [], Bonus, Bonus).
king_bonusL( [L/C|Xs], Bonus, Agg) :-
             ((L > 2, L < 7, B1 is 0.4,!) ;
             B1 is 0),
             ((C > 2, C < 7, B2 is 0.2,!) ;
             B2 is 0),
             Agg1 is Agg + B1 + B2,
             king_bonusL(Xs, Bonus, Agg1).

% End of file