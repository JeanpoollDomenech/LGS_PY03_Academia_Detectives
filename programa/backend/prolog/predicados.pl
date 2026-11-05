% ============================================================
% predicados.pl  -  Academia Detectives
% Proyecto Programado 3 - Lenguajes de Programacion (IC-4700)
%
% Reglas (predicados) del juego. Los datos del caso estan en
% hechos.pl
% ============================================================

:- encoding(utf8).
 
 
% ------------------------------------------------------------
% CABECERA
% ------------------------------------------------------------
 
% Declara que estos predicados pueden existir o no en un caso.
% Si un hechos.pl no trae, por ejemplo, ubicado/2, Prolog responde
% "false" en lugar de dar un error de "predicado no existe".
:- dynamic persona/1, lugar/2, objeto/1, ubicado/2,
           acceso/2, accesoPorObjeto/2, estuvo/3,
           evento/3, evidencia/3, corresponde/2, testimonio/3.
 
% Carga los hechos del caso (hechos.pl, en esta misma carpeta).
:- consult(hechos).
 
 
% ============================================================
% PREDICADOS AUXILIARES
% ============================================================
 
% ------------------------------------------------------------
% minutos(+Hora, -Minutos)
% Entrada:   Hora en formato HHMM (entero), por ejemplo 1955.
% Salida:    Minutos transcurridos desde las 00:00, por ejemplo 1195.
% Restricc.: Hora debe ser un entero valido (HH de 00 a 23 y MM de 00 a 59).
% Objetivo:  Convertir horas HHMM a minutos para poder restarlas
%            correctamente (1955 - 1950 son 5 minutos, y 2005 - 1955
%            son 10, aunque la resta directa de HHMM daria 50).
% ------------------------------------------------------------
minutos(Hora, Minutos) :-
    Minutos is (Hora // 100) * 60 + (Hora mod 100).
 
 
% ------------------------------------------------------------
% ventana_evento(-Inicio, -Fin, -Lugar)
% Entrada:   ninguna (usa el unico evento/3 del caso).
% Salida:    Inicio y Fin de la ventana de tiempo relevante (HHMM)
%            y el Lugar donde ocurrio el evento.
% Restricc.: Debe existir exactamente un hecho evento/3.
%            La ventana es de una hora antes y una hora despues del
%            evento. Supone eventos dentro de un mismo dia (no cruza
%            la medianoche).
% Objetivo:  Definir el intervalo de tiempo que usan las demas reglas
%            (coartada y sospechoso) en un solo lugar, para
%            que cambiar el tamano de la ventana sea modificar 2 lineas.
% ------------------------------------------------------------
ventana_evento(Inicio, Fin, Lugar) :-
    evento(_, Lugar, Hora),
    Inicio is Hora - 100,
    Fin is Hora + 100.
    
