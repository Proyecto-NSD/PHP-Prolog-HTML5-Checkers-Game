// Auxiliar.
function $(sel) { var list = document.querySelectorAll(sel); return (list.length == 1 ? list[0] : list); }

// Al cargarse el documento...
document.addEventListener('DOMContentLoaded', function() 
{
	// Cuando juega el usuario...
	$("#confirm").addEventListener('click', function() {
		var valid = false;
		var target = 0;
		var vacios = $("input[type=radio][name=empty]");
		for(var act=0; act<vacios.length; act++)
		{
			if(vacios[act].checked)
			{
				valid = true;
				target = vacios[act].value;
				break;
			}
		}

		if(valid)
		{
			valid = false;
			var source = 0;
			var fichas = $("input[type=radio][name=white]");
			if(fichas.length)
			{
				for(var act=0; act<fichas.length; act++)
				{
					if(fichas[act].checked)
					{
						valid = true;
						source = fichas[act].value;
						break;
					}
				}			
			} 
			else
			{
				valid = fichas.checked;
			}

			if(valid)
			{
				var fData = new FormData();
				fData.append("source", source);
				fData.append("target", target);

				var pAjax = new RAjax('ia_turn', fData);
				pAjax.done = function()
				{
					if(pAjax.respuesta == "invalid")
					{
						var vacios = $("input[type=radio][name=empty]");
						for(var act=0; act<vacios.length; act++)
						{
							if(vacios[act].checked)
							{
								vacios[act].className = "invalid";
								break;
							}
						}
					}
					else
					{
						var changes = pAjax.respuesta.split("|");
						for(var act=0; act<changes.length; act++)
						{
							var newInfo = changes[act].split("-");
							var td = $("#c_"+newInfo[0]);
							switch(newInfo[1])
							{
								case "x"  :
									td.innerHTML = ("<label data-tipo=\"peon\" for=\"o_"+newInfo[0]+"\">&#9823</label>");
								break;
								case "xx" :
									td.innerHTML = ("<label data-tipo=\"dama\" for=\"o_"+newInfo[0]+"\">&#9818</label>");
								break;
								case "o"  :
									td.innerHTML = ("<input data-tipo=\"peon\" type=\"radio\" name=\"white\" value=\""+newInfo[0]+"\" id=\"o_"+newInfo[0]+"\">"+
													"<label for=\"o_"+newInfo[0]+"\">&#9817</label>");
								break;
								case "oo" :
									td.innerHTML = ("<input data-tipo=\"dama\" type=\"radio\" name=\"white\" value=\""+newInfo[0]+"\" id=\"o_"+newInfo[0]+"\">"+
													"<label for=\"o_"+newInfo[0]+"\">&#9812;</label>");
								break;
								case "e"  :
									td.innerHTML = ("<input type=\"radio\" name=\"empty\" value=\""+newInfo[0]+"\" id=\"o_"+newInfo[0]+"\">"+
													"<label for=\"o_"+newInfo[0]+"\"></label>");
								break;
							}
						}					
						
						var targets = $("input[type=radio][name=empty], input[type=radio][name=white]");
						for(var act=0; act<targets.length; act++)
						{
							targets[act].checked = false;
							targets[act].className = "";
						}
					}
				}
				pAjax.run();
			}
			else
			{
				alert("Debes seleccionar una ficha.");
			}
		}
		else
		{
			alert("El objetivo no es valido.");
		}
	}, false);

}, false);

//#####################################################################################################################
//######################################### HERRAMIENTAS ##############################################################
//#####################################################################################################################

//Prototipo de asincronia.
var RAjax = function ( archivoPHP , parametros , metodo , asincronico) {

	//Valores por defecto.
	parametros || ( parametros = 'Origen=RAjax' );
	metodo || ( metodo = 'POST' );
	asincronico || ( asincronico = true );

	//Propiedades publicas.
	this.archivoPHP = new String(archivoPHP);
    this.parametros = parametros;
    this.metodo = new String(metodo);
    this.respuesta = '';
    this.estado = 'Construida';

	//Propiedades privadas.
	var ThisRAjax = this;

	//metodos publicos genericos.
	this.Preparando = function() { }
	this.Esperando = function() { }
	this.Cargando = function() { }
	this.done = function() { }

	//metodos publicos de archivos.
	this.InicioTransmicion = function() { }
	this.Progreso = function(estado) { }
	this.FinTransmicion = function() { }

	this.Error = function(DetalleError) {
		alert(DetalleError);
	}

	this.run = function() {

		//Creo la peticion.
		var Peticion = new XMLHttpRequest();

		//Abro el nexo.
		Peticion.open ( ThisRAjax.metodo , archivoPHP , asincronico);

		//Monitoreo la subida de archivos.
		Peticion.upload.addEventListener('loadstart' , this.InicioTransmicion , false);
		Peticion.upload.addEventListener('progress' , this.Progreso , false);
		Peticion.upload.addEventListener('load' , this.FinTransmicion , false);

		//Monitoreo el estado.
		Peticion.onreadystatechange = function () {
			//Cuando se completa correctamente.
			switch (Peticion.readyState) {
				case 0:
					//No inicializado (el método open no a sido llamado).
					ThisRAjax.estado = 'No iniciada';
					ThisRAjax.Preparando();
				break;
				case 1:
					//Cargando (se llamó al método open).
					ThisRAjax.estado = 'Nexo abierto';
					ThisRAjax.Preparando();
				break;
				case 2:
					//Cargado (se llamó al método send y ya tenemos la cabecera de la petición HTTP y el status).
					ThisRAjax.estado = 'Esperando respuesta';
					ThisRAjax.Esperando();
				break;
				case 3:
					//Interactivo (la propiedad responseText tiene datos parciales).
					ThisRAjax.estado = 'Cargando datos';
					ThisRAjax.Cargando();
				break;
				case 4:
					//Completado (la propiedad responseText tiene todos los datos pedidos al servidor).
					ThisRAjax.estado = 'Completada';

					//Si se realizo correctamente.
					if (Peticion.status == 200)
					{
						console.log(Peticion.responseText);
						ThisRAjax.respuesta = Peticion.responseText;
						ThisRAjax.done();
					} else {
						switch (Peticion.status) {
							case 404 :
								ThisRAjax.Error('No se encontro la pagina solicitada.');
							break;
							case 500 :
								ThisRAjax.Error('Error interno del servidor.');
							break;
							default:
								ThisRAjax.Error('La peticion se completo con un status: ' + Peticion.status);
							break;
						}
					}
				break;
			}
		};

		//La envio con los parametros.
		Peticion.send(parametros);
	}
}