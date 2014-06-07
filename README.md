PHP-Prolog-HTML5-Checkers-Game
========

A checkers game developed in HTML5 and PHP where the AI opponent is programmed in Prolog.

## Configuracion y prueba inicial
Lo que viene a continuación es una explicación de mi escenario de trabajo, se podría hacer en otras plataformas supongo, pero asi es como lo tengo andando yo:

---

### Requerimientos
1. Swi-Prolog instalado en una pc con Windows 7.
2. Wamp server con php 5.4 o superior.
3. PHP debe tener el safe_mode apagado, esto permitira llamar a programas que no se encuentran en la misma carpeta que el php que los llama. En el php.ini hay una directiva para esto que debe estar en Off pero aun asi puede que no funcione, para asegurarte debes agregar esto al final del httpd.conf y reiniciar el servidor:

```apache
php_admin_flag safe_mode off
```

4. Debes tener agregada la carpeta de binarios de la instalacion de Prolog incorporada en el Path de Windows, por ejemplo en mi caso es: C:\Program Files\swipl\bin, si no sabes como hacer esto, aquí hay un tutorial paso a paso para Windows 7.

5. Dentro de la carpeta www del servidor, creare un directorio llamado "prolog" el cual por supuesto puede tener cualquier otro nombre, dentro de este directorio es donde trabajaremos.

---

### El Prolog

1. Dentro de la carpeta del servidor creada anteriormente, vamos a tener un archvo llamado ejemplo.pl con un functor de prueba:

```prolog
test :- write( 'Prolog \nwas called \nfrom PHP \nsuccessfully.' ).
```

---

### La prueba previa de la consola

1. Antes de meterte con el PHP por primera vez, debes realizar una prueba de la consola para asegurarte que todos los pasos previos los hisiste bien, sobre todo porque en caso de error, php no explota ni lanza errores/warning/notices ni nada, sigue como si nada pasara con lo cual puede ser muy desconcertante.

2. Abres la consola de Windows (Simbolo de sistema o cmd.exe) y alli te diriges a la carpeta de tu servidor escribiendo:

```bat
cd C:\servidor\www\prolog
```
 
reemplazando por la ubicacion de donde esta instalado tu wampserver y el nombre de la carpeta que creaste anteriormente.
3. Ahora escribes en la consola el siguiente comando:

```bat
swipl -s ejemplo.pl -g "test." -t halt.
``` 

4. Si todo esta bien, estaras viendo este mensaje:


> % C:/servidor/www/prolog/ejemplo.pl compiled 0.00 sec, 2 clauses
Prolog
was called
from PHP
successfully.

caso contrario, deberás revisar que los pasos previos esten correctos.

---

### El PHP
1. Como punto de partida destacar que a mi no me funcionaron ninguna de las funciones de ejecucion de programas y cuando digo ninguna, me refiero a ninguna de las del manual, todas fallaban, o mejor dicho, "no hacian nada" porque fallar implica un error y PHP no arrojo ni un notice, en lugar de estas funciones, tube que recurrir a el operador de comillas invertidas razon por la cual previamente tuvimos que desactivar el safe_mode con tanto énfasis.
2. En la misma carpeta prolog del servidor, donde pusimos a ejemplo.pl vamos a crear un index.php con el siguiente contenido:

```php
<?php  
  $output = `swipl -s ejemplo.pl -g "test." -t halt.`;
  var_dump($output);
```
con lo cual deberiamos tener esta salida al ingresar por el navegador:

> string 'Prolog 
was called 
from PHP 
successfully.' (length=43)

3. El envio de parametros a Prolog es muy simple, si se fijan en el comando que ejecutamos, tenemos esto "test." entre comillas, ahi dentro podemos escribir lo que queramos ya que esa una sentencia que se ejecuta en Prolog de forma directa, podemos pasar listas, variables, otros functores, lo que se quiera.
4. La recepcion de respuestas es en forma de texto, asi que debemos asegurarnos de que nuestro prolog retorne su respuesta en un formato que luego podamos desglosar con las funciones de string o expresiones regulares.
