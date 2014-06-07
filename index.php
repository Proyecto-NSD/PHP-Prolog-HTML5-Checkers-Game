<?php
    session_start();    
    
    if(isset($_GET["ia_turn"]) && $_GET["ia_turn"] == 1)
    {
        //// Esto se debe aser desde prolog, es solo un parche.
        $bak = $_SESSION["tablero"];  
        
        // Procesar jugada del usuario y de la IA.
        $cmd = "playPHP(board(".implode(",", array_map(function($val){ return implode(",", $val); }, $_SESSION["tablero"]))."), ".($_POST["source"][0]+1).",".($_POST["source"][1]+1).",".($_POST["target"][0]+1).",".($_POST["target"][1]+1).").";
        $output = `swipl -s damas.pl -g "$cmd" -t halt.`;
        if($output)
        {
            $board = explode(",", substr($output, 6, -1));
            
            // Esto se debe aser desde prolog, es solo un parche.
            $changes = [];
            foreach($bak as $pRow => $row)
            {
                foreach($row as $pCol => $col)
                {
                    $_SESSION["tablero"][$pRow][$pCol] = array_shift($board);
                    if($col != $_SESSION["tablero"][$pRow][$pCol])
                    {
                        $changes[] = $pRow.$pCol."-".$_SESSION["tablero"][$pRow][$pCol];
                    }            
                }
            }
            echo(implode("|", array_filter($changes)));        
        }
        else
        {            
            echo($cmd);
        }
        exit();
    }
?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8" />
		<meta name="viewport" content="width=device-width" />
		<title>Another experiment with Prolog, HTML5 and PHP</title>
		<link rel="stylesheet" media="screen" href="style.css" />
		<script src="damas.js"></script>
	</head>
	<body>
        <aside>
            <header>
                <h1><span contenteditable>Jugador 1</span> vs IA Prolog</h1>
                <h2>another experiment</h2>
            </header>
            <hr>
            <div>
                <button id="confirm">Realizar Movimiento</button>
            </div>
            <hr>
            <p>
                Este es un pequeño experimento donde te enfrentaras en un juego de damas a una IA programada en Prolog.
            </p>
            <p>
                La IA juega en simultaneo contra todos los usuarios conectados a la web revisando en cada turno el estado actual del tablero y decidiendo en base a eso, su proxima jugada.
            </p>
            <p>
                CSS3, HTML5 y Javascript manejan la interface visual comunicándose asíncronamente con que PHP, quien controla la información de la sesión y trackea en una base de datos MySQL los movimientos de la partida para luego llamar a Prolog pidiendole que desida la proxima jugada de la IA en el tablero.
            </p>
            <p>
                <b>Buena Suerte!</b>
            </p>
            <hr>
            <a href="nuevo-juego" id="decline">Me rindo! Reiniciar juego</a>
        </aside>
		<section id="main">
			<table id="chess_board">
            <?php
                if(isset($_GET["new_game"]) && $_GET["new_game"] == 1)
                {
                    /*/
                     * El tablero se representa mediante una matriz con la siguiente simbologia:
                     * x  => Ficha negra de la IA.
                     * xx => Dama negra de la IA.
                     * o  => Ficha blanca del jugador.
                     * oo => Dama blanca del jugador.
                     * e  => Espacio del tablero libre.
                     * n  => Posicion blanca del tablero.
                    /*/
                    $_SESSION["tablero"] = [
                        ["n", "x", "n", "x", "n", "x", "n", "x"],
                        ["x", "n", "x", "n", "x", "n", "x", "n"],
                        ["n", "x", "n", "x", "n", "x", "n", "x"],
                        ["e", "n", "e", "n", "e", "n", "e", "n"],
                        ["n", "e", "n", "e", "n", "e", "n", "e"],
                        ["o", "n", "o", "n", "o", "n", "o", "n"],
                        ["n", "o", "n", "o", "n", "o", "n", "o"],
                        ["o", "n", "o", "n", "o", "n", "o", "n"]
                    ];
                }
                    
                foreach($_SESSION["tablero"] as $nRow => $row)
                {
                    echo("<tr>");
                    foreach($row as $nCol => $col)
                    {
                        echo("<td id=\"c_$nRow$nCol\">");
                        switch($col)
                        {
                            case "x"  :
                                echo ("<label data-tipo=\"peon\" for=\"o_$nRow$nCol\">&#9823</label>");
                            break;
                            case "xx" :
                                echo ("<label data-tipo=\"dama\" for=\"o_$nRow$nCol\">&#9818</label>");
                            break;
                            case "o"  :
                                echo (" <input data-tipo=\"peon\" type=\"radio\" name=\"white\" value=\"$nRow$nCol\" id=\"o_$nRow$nCol\">
                                        <label for=\"o_$nRow$nCol\">&#9817</label>");
                            break;
                            case "oo" :
                                echo (" <input data-tipo=\"dama\" type=\"radio\" name=\"white\" value=\"$nRow$nCol\" id=\"o_$nRow$nCol\">
                                        <label for=\"o_$nRow$nCol\">&#9812;</label>");
                            break;
                            case "e"  :
                                echo (" <input type=\"radio\" name=\"empty\" value=\"$nRow$nCol\" id=\"o_$nRow$nCol\">
                                        <label for=\"o_$nRow$nCol\"></label>");
                            break;
                        }
                    }
                    echo("</tr>");
                }
            ?>
			</table>
		</section>
	</body>
</html>