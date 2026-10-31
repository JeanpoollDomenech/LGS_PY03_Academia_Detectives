% ============================================================
% hechos.pl  -  Academia Detectives
% Proyecto Programado 3 - Lenguajes de Programacion (IC-4700)
%
% Caso: desaparicion en la bodega de un museo.
%
% Reglas de sintaxis que se usan en todo el archivo:
%   - Cada hecho termina con un punto (.)
%   - Los nombres en minuscula (ana, bodega) son atomos: valores fijos.
%   - Las horas son enteros en formato HHMM (1955 = 7:55 PM).
%   - Los textos entre comillas dobles son cadenas (strings).
%   - Todo lo que va despues de % es un comentario.
% ============================================================

:- encoding(utf8).


% ------------------------------------------------------------
% PERSONAS
% persona(Nombre)
% Todas las personas relacionadas con el caso.
% ------------------------------------------------------------
persona(ana).
persona(bruno).
persona(carla).
persona(diego).
persona(elena).


% ------------------------------------------------------------
% LUGARES
% lugar(Nombre, Descripcion)
% Lugares relevantes para la investigacion, con su descripcion.
% ------------------------------------------------------------
lugar(entrada, "Entrada principal del museo.").
lugar(biblioteca, "Biblioteca del museo.").
lugar(laboratorio, "Laboratorio de restauracion.").
lugar(bodega, "Bodega de almacenamiento.").
lugar(oficina, "Oficina administrativa.").


% ------------------------------------------------------------
% OBJETOS
% objeto(Objeto)
% Objetos relevantes para el caso.
% ------------------------------------------------------------
objeto(llave_maestra).
objeto(tarjeta_laboratorio).
objeto(documento).
objeto(caja_herramientas).


% ------------------------------------------------------------
% UBICACION DE OBJETOS
% ubicado(Objeto, Lugar)
% Indica en que lugar se encontraba cada objeto.
% ------------------------------------------------------------
ubicado(llave_maestra, oficina).
ubicado(tarjeta_laboratorio, biblioteca).
ubicado(documento, oficina).
ubicado(caja_herramientas, bodega).


% ------------------------------------------------------------
% ACCESO DIRECTO A LUGARES
% acceso(Persona, Lugar)
% La persona esta autorizada para ingresar a ese lugar.
% ------------------------------------------------------------
acceso(ana, biblioteca).
acceso(ana, oficina).
acceso(bruno, entrada).
acceso(bruno, bodega).
acceso(carla, laboratorio).
acceso(carla, biblioteca).
acceso(diego, entrada).
acceso(diego, biblioteca).
acceso(elena, oficina).


% ------------------------------------------------------------
% ACCESO CONDICIONADO POR UN OBJETO
% accesoPorObjeto(Lugar, Objeto)
% Para ingresar a ese lugar se necesita ese objeto.
% ------------------------------------------------------------
accesoPorObjeto(bodega, llave_maestra).
accesoPorObjeto(laboratorio, tarjeta_laboratorio).


% ------------------------------------------------------------
% REGISTRO DE MOVIMIENTOS
% estuvo(Persona, Lugar, Hora)
% La persona fue registrada en ese lugar a esa hora (HHMM).
% ------------------------------------------------------------
estuvo(ana, entrada, 1900).
estuvo(ana, biblioteca, 1930).
estuvo(bruno, entrada, 1910).
estuvo(bruno, bodega, 1950).
estuvo(carla, biblioteca, 1920).
estuvo(carla, laboratorio, 1955).
estuvo(diego, entrada, 1900).
estuvo(diego, biblioteca, 1940).
estuvo(elena, oficina, 1900).


% ------------------------------------------------------------
% EVENTO CENTRAL
% evento(Nombre, Lugar, Hora)
% Cada caso tiene UN SOLO evento: es lo que se investiga.
% ------------------------------------------------------------
evento(desaparicion, bodega, 2000).


% ------------------------------------------------------------
% EVIDENCIAS
% evidencia(Evidencia, Lugar, Hora)
% Evidencia encontrada, donde y a que hora.
% ------------------------------------------------------------
evidencia(huella, bodega, 1955).
evidencia(llave, bodega, 1950).
evidencia(documento, oficina, 1930).


% ------------------------------------------------------------
% RELACION ENTRE EVIDENCIA Y PERSONA
% corresponde(Evidencia, Persona)
% La evidencia fue relacionada con esa persona.
% ------------------------------------------------------------
corresponde(huella, bruno).
corresponde(llave, bruno).
corresponde(documento, ana).


% ------------------------------------------------------------
% TESTIMONIOS
% testimonio(Persona, Lugar, Hora)
% La persona declara que estaba en ese lugar a esa hora.
% ------------------------------------------------------------
testimonio(bruno, entrada, 1955).
testimonio(carla, biblioteca, 1955).
testimonio(ana, biblioteca, 1930).
