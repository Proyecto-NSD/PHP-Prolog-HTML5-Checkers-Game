% Proyecto-NSD
% Checkers IA
%
% @package nsd\prolog\checkers
% @author Nehuen Prados <nehuensd@gmail.com>, Gil Osher
% @copyright Public Domain
% @version 1

% Evita los molestos warning por variables Singleton.

% Functor amigable para ser llamado externamente desde consola.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param FromLine Fila de origen del movimiento del jugador.
% @param FromCol Columna de origen del movimiento del jugador.
% @param ToLine Fila de destino del movimiento del jugador.
% @param ToCol Columna de destino del movimiento del jugador.
playPHP(Board, FromLine, FromCol, ToLine, ToCol) :- process(FromLine/FromCol-ToLine/ToCol, Board, 2).

% Procesa una movimiento del usuario y luego llama a la IA para que haga su jugada.
% Finalmente escribe el estado del tablero para retornar.
%
% @since 1.0
% @param FromLine Fila de origen del movimiento del jugador.
% @param FromCol Columna de origen del movimiento del jugador.
% @param ToLine Fila de destino del movimiento del jugador.
% @param ToCol Columna de destino del movimiento del jugador.
% @param Board Estado actual del tablero.
% @param Level Nivel de dificultad del juego ("Nivel de inteligencia de la IA").
process(FromLine/FromCol-ToLine/ToCol, Board, Level) :-
    move(Board, FromLine, FromCol, ToLine, ToCol, NewBoard), 	% Realiza el movimiento del usuario.
	alphabeta(x/NewBoard, -100, 100, End/EndBoard, _, Level), 	% La IA hace su jugada.
	write(EndBoard). 											% Imprime el tablero para enviarlo de respuesta.

% Getter del tablero.
% Obtiene el valor de una posicion del tablero.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param Line Linea del tablaro.
% @param Col Columna del tablero.
% @param Sign Valor de la posicion.
getPos(Board, Line, Col, Sign) :-	
    Num is ((Line - 1) * 8) + Col,	% Se reduce una dimension en la matriz.
    arg(Num, Board, Sign). 			% Retorna en Sign el argumento que este en la posicion Num de Board.

% Se fija si la posicion del tablero esta ocupada por una pieza.
%
% @since 1.0
% @param Board El tablero.
% @param Line Linea del tablero.
% @param Col Columna del tablero.
% @param Pawn Tipo de pieza que ocupa la posicion.
getPawn(Board, Line, Col, Pawn) :-
    getPos( Board, Line, Col, Pawn), 				% Obtiene el valor de la casilla del tablero.
    (Pawn = x; Pawn = xx; Pawn = o; Pawn = oo). 	% Se fija si es una pieza valida.

% Setter del tablero.
% Graba un valor en una posicion del tablero identificando si se trata de una reina de forma automatica.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param Line Linea del tablaro.
% @param Col Columna del tablero.
% @param Sign Valor a grabar.
% @param NewBoard estado final del tablero luego del cambio.
putSign(Board, 8, Col, x, NewBoard) :- putSign(Board, 8, Col, xx, NewBoard), !.	% La IA adquiere una reina.
	
putSign(Board, 1, Col, o, NewBoard) :- putSign(Board, 1, Col, oo, NewBoard), !.	% El jugador adquiere una reina.

putSign(Board, Line, Col, Sign, NewBoard) :-
    Place is ((Line - 1) * 8) + Col, 		% Se reduce una dimension en la matriz.
    Board =.. [board|List],			 		% Se convierte el functor del tablero en una lista.
    replace(List, Place, Sign, NewList),	% Se reemplaza el valor actual por el nuevo.
    NewBoard =.. [board|NewList]. 			% Se convierte la lista con el elemento modificado en un nuevo functor.

% Reemplaza un elemento de una lista por otro en una posicion determinada.
%
% @since 1.0
% @param List Lista que representa al tablero.
% @param Place Posicion de la lista a remmplazar.
% @param Val Valor nuevo.
% @param NewList estado final de la lista luego del cambio.
replace(List, Place, Val, NewList) :- replace(List, Place, Val, NewList, 1). 	% Se llama recursivamente empezando por la posicion 1.

replace([_|OldCola], Place, Val, [Val|OldCola], Place) :- !. 					% Cuando encuentra la posicion hace el reemplazo y para la ejecucion.

replace([Cabeza|OldCola], Place, Val, [Cabeza|NewCola], Counter) :- 			% No es la posicion que se buscaba.
    NewCounter is Counter + 1, 													% Incrementar la posicion.
    replace(OldCola, Place, Val, NewCola, NewCounter). 							% Llamarse recursivamente.

% Cuenta cuantas piezas hay en el tablero de un jugador determinado.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param Sign Signo de la pieza a contar.
% @param Cant La cantidad encontrada.
count(Board, Sign, Cant) :-
    Board =.. [board|List], 				% Se convierte el functor del tablero en una lista.
    count(List, Sign, Cant, 0). 			% Se comienza a recorrer con el contador en 0.
	
count([], _, Cant, Cant) :- !. 				% Cuando la lista esta vacia, no hay mas nada para contar.

count([Sign|Cola], Sign, Cant, Counter) :- 	% La casilla tiene la pieza buscada.
    NewCounter is Counter + 1, 				% Se incrementa el contador.
    count(Cola, Sign, Cant, NewCounter). 	% Se continua buscando.
	
count([_|Cola], Sign, Cant, Counter) :-   	% La casilla no tiene la pieza buscada.
    count(Cola, Sign, Cant, Counter).     	% Se continua buscando.

% ¿A quien le toca el proximo turno?
%
% @since 1.0
% @param Turn Jugador que esta jugando ahora.
% @param NexTurn El jugador del proximo turno.
next_player(x, o).	% Esta jugando la IA, le toca al jugador.
next_player(o, x).	% Esta jugando el jugador, le toca a la IA.

% ¿De que jugador es la pieza?
%
% @since 1.0
% @param Player El jugador que es dueño de la pieza.
% @param Sign Pieza del tablero.
turn_to_sign(x, x). 	% Los peones negros son de la IA.
turn_to_sign(x, xx).	% Las reinas negras son de la IA.
turn_to_sign(o, o). 	% Los peones blancos son del jugador.
turn_to_sign(o, oo).	% Las reinas blancas son del jugador.

% Condicion de victoria. Verifica si alguien ha ganado la partida.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param Winner Ganador de la partida.
% @todo Hacer que pierda si solo tiene 1 ficha.
goal(Board, Winner) :-
    next_player(Winner, Looser),
    findall(NewBoard, (turn_to_sign(Looser,Sign),validMove(Board, Sign, NewBoard)), []), !.

% Quienes son los enemigos de cada pieza del tablero.
%
% @since 1.0
% @param Piece Pieza del tablero.
% @param Enemy Tipo de pieza enemiga.
enemy(o, x).  	% Los peones del jugador son enemigos de los peones de la IA.
enemy(o, xx). 	% Los peones del jugador son enemigos de las reinas de la IA.
enemy(x, o).  	% Los peones de la IA son enemigos de los peones del jugador.
enemy(x, oo). 	% Los peones de la IA son enemigos de las reinas del jugador.
enemy(oo, x). 	% Las reinas del jugador son enemigos de los peones de la IA.
enemy(oo, xx).	% Las reinas del jugador son enemigos de las reinas de la IA.
enemy(xx, o). 	% Las reinas de la IA son enemigos de los peones del jugador.
enemy(xx, oo).	% Las reinas de la IA son enemigos de las reinas del jugador.

% Mover una pieza a otro lado del tablero.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param FromLine Fila de origen del movimiento.
% @param FromCol Columna de origen del movimiento.
% @param ToLine Fila de destino del movimiento.
% @param ToCol Columna de destino del movimiento.
% @param NewBoard Estado del tablero luego del movimiento.
move(Board, FromLine, FromCol, ToLine, ToCol, NewBoard) :-
	getPawn(Board, FromLine, FromCol, Pawn), 									% Obtener la pieza que esta en la posicion de origen del tablero.
	turn_to_sign(Turn, Pawn), !,												% Obtener en Turn el jugador al que perteneza la pieza a mover.
	validMove(Board, Turn, NewBoard), 											% Valida si se puede llegar a esa posicion comiendo o de forma directa.
	(movePawnEatRec(Board, Pawn, FromLine, FromCol, ToLine, ToCol, NewBoard); 	% Si puede llegar a la posicion comiendo piezas va comiendo
	 movePawn(Board, Pawn, FromLine, FromCol, ToLine, ToCol, NewBoard)).		% si no va de forma directa.

% Movimiento directo de una pieza a otra posicion.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param Pawn Tipo de pieza que ocupa la posicion.
% @param FromLine Fila de origen del movimiento.
% @param FromCol Columna de origen del movimiento.
% @param ToLine Fila de destino del movimiento.
% @param ToCol Columna de destino del movimiento.
% @param NewBoard Estado del tablero luego del movimiento.
movePawn(Board, Pawn, FromLine, FromCol, ToLine, ToCol, NewBoard) :-
    validateMove(Board, Pawn, FromLine, FromCol, ToLine, ToCol),	% Se fija si el movimiento es correcto y puede realizarse.
    putSign(Board, FromLine, FromCol, e, TB),						% Vacia la posicion de origen del tablero.
    putSign(TB, ToLine, ToCol, Pawn, NewBoard).						% Graba la pieza en la posicion de destino.

% Mueve a un peon comiendo casilleros recursivamente.
% Este functor permite que una pieza pueda comer a varias sucesivamente.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param Pawn Tipo de pieza que ocupa la posicion.
% @param FromLine Fila de origen del movimiento.
% @param FromCol Columna de origen del movimiento.
% @param ToLine Fila de destino del movimiento.
% @param ToCol Columna de destino del movimiento.
% @param NewBoard Estado del tablero luego del movimiento.
movePawnEatRec(Board, Pawn, FromLine, FromCol, ToLine, ToCol, NewBoard) :-	% Caso base, solo va a comer una vez. @TODO: Ver si se puede sacar porque abajo ya esta.
    movePawnEat(Board, Pawn, FromLine, FromCol, ToLine, ToCol, NewBoard).	% Intenta comer solo una vez.

movePawnEatRec(Board, Pawn, FromLine, FromCol, ToLine, ToCol, NewBoard) :-
    (
	 (Pawn = x; Pawn = xx; Pawn = oo),	% Si la pieza puede moverse hacia abajo
     FromC1 is FromLine + 2 ;			% entonces puede avanzar 2 hacia abajo.
     (Pawn = o; Pawn = xx; Pawn = oo),	% Si la pieza puede moverse hacia arriba
     FromC1 is FromLine - 2				% entonces puede avanzar 2 hacia arriba. 
	),
    FromR1 is FromCol + 2,				% Puede ir dos a la derecha
    FromR2 is FromCol - 2,				% y dos a la izquierda.
    (
	 movePawnEat(Board, Pawn, FromLine, FromCol, FromC1, FromR1, TempBoard),		% Intenta comer hacia la derecha
     movePawnEatRec(TempBoard, Pawn, FromC1, FromR1, ToLine, ToCol, NewBoard) ;		% y si pudo intenta comer de nuevo.
     movePawnEat(Board, Pawn, FromLine, FromCol, FromC1, FromR2, TempBoard),		% Intenta comer hacia la izquierda
     movePawnEatRec(TempBoard, Pawn, FromC1, FromR2, ToLine, ToCol, NewBoard)    	% y si pudo intenta comer de nuevo.
	).

% Mueve a una pieza comiendo a un unico casillero si es posible.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param Pawn Tipo de pieza que ocupa la posicion.
% @param FromLine Fila de origen del movimiento.
% @param FromCol Columna de origen del movimiento.
% @param ToLine Fila de destino del movimiento.
% @param ToCol Columna de destino del movimiento.
% @param NewBoard Estado del tablero luego del movimiento.
movePawnEat(Board, Pawn, FromLine, FromCol, ToLine, ToCol, NewBoard) :-
    validateEat(Board, Pawn, FromLine, FromCol, ToLine, ToCol),		% Valida si es posible comer la posicion.
    EC1 is (FromCol + ToCol) / 2,									% Columna del casillero comido.
    EL1 is (FromLine + ToLine) / 2,                            	 	% Fila del casillero comido.
    abs(EC1, ComidoR), abs(EL1, ComidoC),							% @TODO ver que hace
    putSign(Board, FromLine, FromCol, e, TB1),						% Vacia la posicion de origen del tablero.
    putSign(TB1, ComidoC, ComidoR, e, TB2),							% Vacia la posicion de la pieza comida.
    putSign(TB2, ToLine, ToCol, Pawn, NewBoard).					% Mueve la pieza a la posicion de destino.

% Valida un intento de comer segun el tipo de pieza.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param Piece Pieza del tablero.
% @param FromLine Fila de origen del movimiento.
% @param FromCol Columna de origen del movimiento.
% @param ToLine Fila de destino del movimiento.
% @param ToCol Columna de destino del movimiento.
validateEat(Board, King, FromLine, FromCol, ToLine, ToCol) :-		% Cuando la que come es una reina.
    (King = xx; King = oo),											% Si es una reina de la IA o del Jugador.
    ToLine >= 1, ToCol >= 1,										% Si se esta moviendo a una
    FromLine =< 8, FromLine =< 8,									% casilla que esta dentro del tablero.
    (
     ToLine is FromLine + 2	;										% Si la fila esta salteando solo un casillero hacia abajo
	 ToLine is FromLine - 2 										% o hacia arriba.
	),										
    (
	 ToCol is FromCol + 2 ;											% Si la columna esta salteando solo un casillero hacia la derecha
     ToCol is FromCol - 2											% o hacia la izquierda.
	),                        				
	validateEatPos(Board, King, FromLine, FromCol, ToLine, ToCol).	% Validar la casilla comida.

validateEat(Board, x, FromLine, FromCol, ToLine, ToCol) :-			% Cuando el que come es un peon de la IA.
    ToLine >= 1, ToCol >= 1,                            			% Si se esta moviendo a una
    FromLine =< 8, FromLine =< 8,                        			% casilla que esta dentro del tablero.
    ToLine is FromLine + 2,                              			% Si la fila esta salteando solo un casillero hacia abajo.
    (
	 ToCol is FromCol + 2 ;                            				% Si la columna esta salteando solo un casillero hacia la izquierda
     ToCol is FromCol - 2											% o hacia la derecha.
	),                            				
	validateEatPos(Board, x, FromLine, FromCol, ToLine, ToCol).		% Validar la casilla comida.

validateEat( Board, o, FromLine, FromCol, ToLine, ToCol) :-         % Cuando el que come es un peon del jugador.
    ToLine >= 1, ToCol >= 1,                            			% Si se esta moviendo a una
    FromLine =< 8, FromLine =< 8,                        			% casilla que esta dentro del tablero.
    ToLine is FromLine - 2,                              			% Si la fila esta salteando solo un casillero hacia arriba.
    (
	 ToCol is FromCol + 2;                            				% Si la columna esta salteando solo un casillero hacia la derecha
     ToCol is FromCol - 2											% o hacia la izquierda.
	),                            				
	validateEatPos(Board, o, FromLine, FromCol, ToLine, ToCol).		% Validar la casilla comida.

validateEatPos(Board, Piece, FromLine, FromCol, ToLine, ToCol) :-	% Valida si la casilla comida es enemiga de la que come y se le puede pasar por arriba.
    getPos(Board, ToLine, ToCol, e),								% Se fija si la posicion del tablero de destino esta vacio.
    ComidoC is (ToLine + FromLine) / 2,                 			% Columna del casillero comido.
    ComidoR is (ToCol + FromCol) / 2,                 				% Fila del casillero comido.
    enemy(Piece, Enemy),                          					% Traer los enemigos de la pieza que esta comiendo.
    getPawn(Board, ComidoC, ComidoR, Enemy).      					% Ver si la pieza que esta en la posicion comida esta entre los enemigos de la que come.

% Valida que un movimiento especifico sea valido.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param Piece Pieza del tablero.
% @param FromCol Columna de origen del movimiento.
% @param FromLine Fila de origen del movimiento.
% @param ToLine Fila de destino del movimiento.
% @param ToCol Columna de destino del movimiento.
validateMove(Board, King, FromLine, FromCol, ToLine, ToCol) :-		% Cuando la que se mueva es una reina.
    (King = xx ; King = oo),                                		% Si es una reina de la IA o del Jugador.
    ToLine >= 1, ToCol >= 1,                                     	% Si se esta moviendo a una
    FromLine =< 8, FromLine =< 8,                                 	% casilla que esta dentro del tablero.
    (                                                       
	 ToLine is FromLine + 1 ;                                     	% Si la fila esta un casillero mas abajo
     ToLine is FromLine - 1                                      	% o hacia arriba.
	),                                                      
    (                                                       
	 ToCol is FromCol + 1 ;                                     	% Si la columna esta un casillero hacia la derecha
     ToCol is FromCol - 1                                       	% o hacia la izquierda.
	),
    getPos(Board, ToLine, ToCol, e).								% Si la posicion de destino esta vacia.

validateMove(Board, x, FromLine, FromCol, ToLine, ToCol) :-			% Cuando se mueve un peon de la IA.
    ToLine >= 1, ToCol >= 1,										% Si se esta moviendo a una
    FromLine =< 8, FromLine =< 8,                                	% casilla que esta dentro del tablero.
    ToLine is FromLine + 1,											% Solo puede moverse hacia abajo.
    (
	 ToCol is FromCol + 1 ;											% Si la columna esta un casillero hacia la derecha
     ToCol is FromCol - 1  											% o hacia la izquierda.
	),
    getPos(Board, ToLine, ToCol, e).								% Si la posicion de destino esta vacia.

validateMove(Board, o, FromLine, FromCol, ToLine, ToCol) :-			% Cuando se mueve un peon de la IA.
    ToLine >= 1, ToCol >= 1,                                    	% Si se esta moviendo a una
    FromLine =< 8, FromLine =< 8,                                 	% casilla que esta dentro del tablero.
    ToLine is FromLine - 1,                                       	% Solo puede moverse hacia arriba.
    (                                                       
	 ToCol is FromCol + 1 ;                                     	% Si la columna esta un casillero hacia la derecha
     ToCol is FromCol - 1                                       	% o hacia la izquierda.
	),                                                      
    getPos(Board, ToLine, ToCol, e).                             	% Si la posicion de destino esta vacia.

% Busca un tipo de pieza en el tablero y retorna la linea y la columna en que se encuentra.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param Sign Signo de la pieza.
% @param Line Linea en que se encuentra.
% @param Col Columna en que se encuentra.
findPawn(Board, Sign, Line, Col) :-
    arg(Num, Board, Sign),				% Obtiene las posiciones de las piezas con ese signo en el tablero.
    Temp is Num / 8,					% Buscar la fila en que se encuentra
    ceiling(Temp, Line),				% que es el cociente redondeado hacia arriba. 
    Col is Num - ((Line - 1) * 8).		% La columna es la posicion actual menos las posiciones de las fichas de las filas anteriores.

% Busca todos los movimientos validos posibles para comer en el tablero.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param Sign Signo de la pieza.
% @param NewBoard Estado del tablero luego de comer.
validEatMove(Board, Sign, NewBoard) :-
    findPawn(Board, Sign, Line, Col),										% Busca las piezas que tengan el signo especificado.
	findPawn(Board, e, EmptyLine, EmptyCol),								% Busca las casillas vacias.
    movePawnEatRec(Board, Sign, Line, Col, EmptyLine, EmptyCol, NewBoard).	% Busca las piezas que puedan llegar a una casilla vacia comiendo.

% Busca todos los movimientos validos posibles para moverse en el tablero.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param Sign Signo de la pieza.
% @param NewBoard Estado del tablero luego de moverse.
validStdMove(Board, Sign, NewBoard) :-
    findPawn(Board, Sign, Line, Col),									% Busca las piezas que tengan el signo especificado.
	findPawn(Board, e, EmptyLine, EmptyCol),                            % Busca las casillas vacias.
    movePawn(Board, Sign, Line, Col, EmptyLine, EmptyCol, NewBoard).    % Busca las piezas que puedan llegar a una casilla vacia directamente.

% Obtiene los movimientos validos para un jugador segun el estado del tablero.
%
% @since 1.0
% @param Board Estado actual del tablero.
% @param Turn Jugador actual.
% @param NewBoard Estado del tablero luego de comer.
validMove(Board, Turn, NewBoard) :- 			% Si hay movimientos para comer disponibles, estos son los unicos validos.
    turn_to_sign(Turn, Sign),					% Obtener las piezas del jugador.
    validEatMove(Board, Sign, NewBoard).		% Obtener los movimientos de comer posibles.

validMove( Board, Turn, NewBoard) :-			% Si no hay movimientos para comer disponibles, puede realizar un movimiento comun.
    not(										
	 (
	  turn_to_sign(Turn, Sign),					% Obtener las piezas del jugador.
      validEatMove(Board, Sign, NewBoard)		% Ninguna debe poder comer.
	 )
	),
    turn_to_sign(Turn, Sign1),					% Obtener las piezas del jugador.
    validStdMove(Board, Sign1, NewBoard).		% Obtener los movimientos comunes posibles.

%
% Alpha-Beta implementation
%

% @TODO: Ver que onda con esto.
min_to_move(o/_).
max_to_move(x/_).

% Algoritmo alphabeta para la busqueda de movimientos.
%
% @since 1.0
% @param Pos 
% @param Alpha
% @param Beta 
% @param GoodPos 
% @param Val
% @param Depth
alphabeta(Pos, Alpha, Beta, GoodPos, Val, Depth) :-
    Depth > 0, 													% Poda por profundidad.
	moves(Pos, PosList), !,										
    boundedbest( PosList, Alpha, Beta, GoodPos, Val, Depth);
    staticval( Pos, Val).        % Static value of Pos

boundedbest( [Pos|PosList], Alpha, Beta, GoodPos, GoodVal, Depth) :-
             Depth1 is Depth - 1,
             alphabeta( Pos, Alpha, Beta, _, Val, Depth1),
             goodenough( PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth).

goodenough([], _, _, Pos, Val, Pos, Val, _) :- !.     	% No hay mas candidatos.

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

% Funcion generadora del arbol de movimientos.
% Devuelve en PosList la todos los movimientos validos posibles del tablero para
% el jugador 
%
% @since 1.0
% @param Turn 	
% @param Board
% @param PosList
moves(Turn/Board, PosList) :-
    next_player(Turn, NextTurn),
    findall(NextTurn/NewBoard, validMove(Board, Turn, NewBoard), PosList).

% Combierte un peon en una reina.
%
% @since 1.0
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