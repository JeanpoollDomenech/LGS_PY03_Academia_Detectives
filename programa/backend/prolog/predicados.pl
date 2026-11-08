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
    
% ============================================================
% REGLAS DEL CASO
% ============================================================
 
% ------------------------------------------------------------
% tiene_acceso(?Persona, ?Lugar)
% Entrada:   Persona y Lugar (atomos; pueden ser variables).
% Salida:    Verdadero si la persona puede ingresar al lugar. Con
%            variables, devuelve todas las soluciones por backtracking.
% Restricc.: Un mismo par puede salir repetido si se cumple por
%            varias vias (por ejemplo, acceso directo y por objeto).
% Objetivo:  Determinar si una persona tiene autorizacion para entrar
%            a un lugar, por dos vias:
%            1) acceso directo, segun acceso/2;
%            2) acceso por objeto: el lugar se abre con un objeto
%               (accesoPorObjeto/2), el objeto esta en cierto lugar
%               (ubicado/2) y la persona estuvo registrada en ese
%               lugar, por lo que pudo obtenerlo.
% ------------------------------------------------------------
tiene_acceso(Persona, Lugar) :-
    acceso(Persona, Lugar).
 
tiene_acceso(Persona, Lugar) :-
    accesoPorObjeto(Lugar, Objeto),
    ubicado(Objeto, LugarObjeto),
    estuvo(Persona, LugarObjeto, _).
 
 
% ------------------------------------------------------------
% tiene_contradiccion(?Persona)
% Entrada:   Persona (atomo).
% Salida:    Verdadero si algun testimonio de la persona es
%            incompatible con sus registros de movimientos.
% Restricc.: Se considera que hay contradiccion cuando el testimonio
%            ubica a la persona en un lugar y un registro estuvo/3 la
%            ubica en OTRO lugar con una diferencia de 10 minutos o
%            menos entre ambas horas.
% Objetivo:  Detectar cuando lo que dice una persona no coincide con
%            lo que dicen los registros, sin guardar un hecho que diga
%            "miente" (se infiere con las reglas).
% ------------------------------------------------------------
tiene_contradiccion(Persona) :-
    testimonio(Persona, LugarTestimonio, HoraTestimonio),
    estuvo(Persona, LugarRegistro, HoraRegistro),
    LugarTestimonio \= LugarRegistro,
    minutos(HoraTestimonio, MinutosTestimonio),
    minutos(HoraRegistro, MinutosRegistro),
    abs(MinutosTestimonio - MinutosRegistro) =< 10.
 
 
% ------------------------------------------------------------
% tiene_coartada(?Persona)
% Entrada:   Persona (atomo).
% Salida:    Verdadero si la persona tiene una posible coartada.
% Restricc.: Usa la ventana de tiempo de ventana_evento/3. Debe
%            existir un hecho evento/3.
% Objetivo:  Inferir una coartada (no se guarda como hecho): la
%            persona declaro estar en un lugar DISTINTO al del evento
%            durante la ventana del evento, y sus registros no
%            contradicen ese testimonio (\+ tiene_contradiccion).
% ------------------------------------------------------------
tiene_coartada(Persona) :-
    ventana_evento(Inicio, Fin, LugarEvento),
    testimonio(Persona, LugarTestimonio, HoraTestimonio),
    HoraTestimonio >= Inicio,
    HoraTestimonio =< Fin,
    LugarTestimonio \= LugarEvento,
    \+ tiene_contradiccion(Persona).
 
 
% ------------------------------------------------------------
% posible_sospechoso(?Persona)
% Entrada:   Persona (atomo) o variable para listar a todos.
% Salida:    Verdadero si la persona cumple las tres condiciones.
%            Con variable, devuelve cada sospechoso una sola vez.
% Restricc.: Debe existir un hecho evento/3.
% Objetivo:  Decidir si una persona es posible sospechosa del evento
%            central. Condiciones (todas juntas):
%            1) Presencia: estuvo en el lugar del evento durante la
%               ventana de tiempo.
%            2) Oportunidad: tenia acceso a ese lugar O tiene alguna
%               evidencia relacionada con ella (corresponde/2).
%            3) Sin coartada: no se puede inferir una coartada.
%            Se usa once/1 para que una persona no salga repetida si
%            cumple una condicion de varias formas.
% ------------------------------------------------------------
posible_sospechoso(Persona) :-
    persona(Persona),
    ventana_evento(Inicio, Fin, LugarEvento),
    once(( estuvo(Persona, LugarEvento, Hora),
           Hora >= Inicio,
           Hora =< Fin )),
    once(( tiene_acceso(Persona, LugarEvento)
         ; corresponde(_, Persona) )),
    \+ tiene_coartada(Persona).
 
