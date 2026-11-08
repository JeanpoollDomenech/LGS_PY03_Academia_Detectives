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
% contradiccion_detalle(?Persona, ?LugarTestimonio, ?HoraTestimonio,
%                       ?LugarRegistro, ?HoraRegistro)
% Entrada:   Persona (atomo).
% Salida:    Los datos de una contradiccion: lo que la persona declaro
%            (lugar y hora) y el registro que lo contradice (lugar y hora).
% Restricc.: Hay contradiccion cuando el testimonio ubica a la persona
%            en un lugar y un registro estuvo/3 la ubica en OTRO lugar
%            con una diferencia de 10 minutos o menos entre ambas horas.
% Objetivo:  Ser la unica fuente de la regla de contradiccion. La usan
%            tiene_contradiccion/1, explicaciones/2 y resolver_caso/0.
% ------------------------------------------------------------
contradiccion_detalle(Persona, LugarTestimonio, HoraTestimonio,
                      LugarRegistro, HoraRegistro) :-
    testimonio(Persona, LugarTestimonio, HoraTestimonio),
    estuvo(Persona, LugarRegistro, HoraRegistro),
    LugarTestimonio \= LugarRegistro,
    minutos(HoraTestimonio, MinutosTestimonio),
    minutos(HoraRegistro, MinutosRegistro),
    abs(MinutosTestimonio - MinutosRegistro) =< 10.


% ------------------------------------------------------------
% tiene_contradiccion(?Persona)
% Entrada:   Persona (atomo).
% Salida:    Verdadero si algun testimonio de la persona es
%            incompatible con sus registros de movimientos.
% Restricc.: Ver contradiccion_detalle/5 (tolerancia de 10 minutos).
% Objetivo:  Detectar cuando lo que dice una persona no coincide con
%            lo que dicen los registros, sin guardar un hecho que diga
%            "miente" (se infiere con las reglas).
% ------------------------------------------------------------
tiene_contradiccion(Persona) :-
    contradiccion_detalle(Persona, _, _, _, _).


% ------------------------------------------------------------
% coartada_detalle(?Persona, ?LugarTestimonio, ?HoraTestimonio)
% Entrada:   Persona (atomo).
% Salida:    El lugar y la hora del testimonio que sirve de coartada.
% Restricc.: Usa la ventana de ventana_evento/3. Debe existir un
%            hecho evento/3.
% Objetivo:  Ser la unica fuente de la regla de coartada: la persona
%            declaro estar en un lugar DISTINTO al del evento durante
%            la ventana del evento, y sus registros no contradicen
%            ese testimonio (\+ tiene_contradiccion).
% ------------------------------------------------------------
coartada_detalle(Persona, LugarTestimonio, HoraTestimonio) :-
    ventana_evento(Inicio, Fin, LugarEvento),
    testimonio(Persona, LugarTestimonio, HoraTestimonio),
    HoraTestimonio >= Inicio,
    HoraTestimonio =< Fin,
    LugarTestimonio \= LugarEvento,
    \+ tiene_contradiccion(Persona).


% ------------------------------------------------------------
% tiene_coartada(?Persona)
% Entrada:   Persona (atomo).
% Salida:    Verdadero si la persona tiene una posible coartada.
% Restricc.: Ver coartada_detalle/3.
% Objetivo:  Inferir una coartada (no se guarda como hecho).
% ------------------------------------------------------------
tiene_coartada(Persona) :-
    coartada_detalle(Persona, _, _).


% ------------------------------------------------------------
% presente_en_evento(?Persona)
% Entrada:   Persona (atomo).
% Salida:    Verdadero si hay un registro estuvo/3 de la persona en el
%            lugar del evento con hora dentro de la ventana.
% Restricc.: Debe existir un hecho evento/3.
% Objetivo:  Condicion de PRESENCIA para ser sospechoso.
% ------------------------------------------------------------
presente_en_evento(Persona) :-
    ventana_evento(Inicio, Fin, LugarEvento),
    once(( estuvo(Persona, LugarEvento, Hora),
           Hora >= Inicio,
           Hora =< Fin )).


% ------------------------------------------------------------
% tiene_oportunidad(?Persona)
% Entrada:   Persona (atomo).
% Salida:    Verdadero si la persona tenia acceso al lugar del evento
%            o tiene alguna evidencia relacionada con ella.
% Restricc.: Debe existir un hecho evento/3.
% Objetivo:  Condicion de OPORTUNIDAD para ser sospechoso.
% ------------------------------------------------------------
tiene_oportunidad(Persona) :-
    ventana_evento(_, _, LugarEvento),
    once(( tiene_acceso(Persona, LugarEvento)
         ; corresponde(_, Persona) )).


% ------------------------------------------------------------
% posible_sospechoso(?Persona)
% Entrada:   Persona (atomo) o variable para listar a todos.
% Salida:    Verdadero si la persona cumple las tres condiciones.
%            Con variable, devuelve cada sospechoso una sola vez.
% Restricc.: Debe existir un hecho evento/3.
% Objetivo:  Decidir si una persona es posible sospechosa del evento
%            central. Condiciones (todas juntas):
%            1) Presencia: presente_en_evento/1.
%            2) Oportunidad: tiene_oportunidad/1 (acceso o evidencia).
%            3) Sin coartada: no se puede inferir una coartada.
% ------------------------------------------------------------
posible_sospechoso(Persona) :-
    persona(Persona),
    presente_en_evento(Persona),
    tiene_oportunidad(Persona),
    \+ tiene_coartada(Persona).


% ------------------------------------------------------------
% posibles_responsables(-Lista)
% Entrada:   ninguna.
% Salida:    Lista con las personas que son posibles sospechosos.
%            Lista vacia [] si no hay ninguna.
% Restricc.: Nunca falla.
% Objetivo:  Recorrer todas las personas del caso (persona/1) y
%            quedarse con las que cumplen posible_sospechoso/1.
% ------------------------------------------------------------
posibles_responsables(Lista) :-
    findall(Persona, (persona(Persona), posible_sospechoso(Persona)), Lista).


% ------------------------------------------------------------
% explicacion(+Persona, -Texto)       (auxiliar de explicaciones/2)
% Entrada:   Persona (atomo).
% Salida:    Un texto por cada explicacion que aplique; con
%            backtracking se obtienen todas.
% Restricc.: Cada texto se arma con datos reales de los hechos
%            (nada de conclusiones guardadas de antemano).
% Objetivo:  Reunir las razones logicas por las que una persona es
%            sospechosa o relevante para la investigacion.
% ------------------------------------------------------------
explicacion(Persona, Texto) :-
    posible_sospechoso(Persona),
    format(atom(Texto),
           'CONCLUSION: ~w es posible sospechoso: estuvo en el lugar del evento durante la ventana, tuvo acceso o evidencia relacionada y no tiene coartada.',
           [Persona]).

explicacion(Persona, Texto) :-
    ventana_evento(Inicio, Fin, LugarEvento),
    estuvo(Persona, LugarEvento, Hora),
    Hora >= Inicio,
    Hora =< Fin,
    format(atom(Texto),
           '~w estuvo en ~w (lugar del evento) a las ~w, dentro de la ventana de ~w a ~w.',
           [Persona, LugarEvento, Hora, Inicio, Fin]).

explicacion(Persona, Texto) :-
    ventana_evento(_, _, LugarEvento),
    once(tiene_acceso(Persona, LugarEvento)),
    format(atom(Texto),
           '~w tiene acceso a ~w, el lugar del evento.',
           [Persona, LugarEvento]).

explicacion(Persona, Texto) :-
    corresponde(Evidencia, Persona),
    format(atom(Texto),
           'La evidencia ~w esta relacionada con ~w.',
           [Evidencia, Persona]).

explicacion(Persona, Texto) :-
    contradiccion_detalle(Persona, LugarT, HoraT, LugarR, HoraR),
    format(atom(Texto),
           '~w declaro estar en ~w a las ~w, pero un registro la ubica en ~w a las ~w: hay contradiccion.',
           [Persona, LugarT, HoraT, LugarR, HoraR]).

explicacion(Persona, Texto) :-
    coartada_detalle(Persona, LugarT, HoraT),
    format(atom(Texto),
           '~w tiene una posible coartada: declaro estar en ~w a las ~w y los registros no lo contradicen.',
           [Persona, LugarT, HoraT]).


% ------------------------------------------------------------
% explicaciones(+Persona, -Explicacion)
% Entrada:   Persona (atomo) que exista en persona/1.
% Salida:    Un texto con una explicacion; con backtracking (;) se
%            obtienen todas las que apliquen. Si ninguna aplica,
%            devuelve un texto indicando que no hay informacion relevante.
% Restricc.: Falla si la persona no existe en persona/1.
% Objetivo:  Justificar con hechos y reglas por que una persona es
%            sospechosa o relevante para la investigacion.
% ------------------------------------------------------------
explicaciones(Persona, Explicacion) :-
    persona(Persona),
    explicacion(Persona, Explicacion).

explicaciones(Persona, Explicacion) :-
    persona(Persona),
    \+ explicacion(Persona, _),
    format(atom(Explicacion),
           'No hay informacion relevante en el caso sobre ~w.',
           [Persona]).


% ------------------------------------------------------------
% si_no(+Meta, -Texto)                (auxiliar de resolver_caso/0)
% Entrada:   Meta (una consulta de Prolog).
% Salida:    'Si' si la meta se cumple; 'No' en caso contrario.
% Restricc.: Ninguna.
% Objetivo:  Mostrar en texto el resultado de una condicion.
% ------------------------------------------------------------
si_no(Meta, Texto) :-
    (   call(Meta)
    ->  Texto = 'Si'
    ;   Texto = 'No'
    ).


% ------------------------------------------------------------
% reporte_responsable(+Persona)       (auxiliar de resolver_caso/0)
% Entrada:   Persona (atomo).
% Salida:    Imprime en pantalla: evidencias, movimientos, accesos,
%            coartada y contradiccion, justificacion logica y la
%            validacion de la solucion.
% Restricc.: Debe existir un hecho evento/3.
% Objetivo:  Presentar toda la informacion que sustenta por que una
%            persona es considerada responsable.
% ------------------------------------------------------------
reporte_responsable(Persona) :-
    ventana_evento(_, _, LugarEvento),
    format('--- Responsable: ~w ---~n', [Persona]),

    % 1) Evidencias relacionadas
    findall(Evidencia, corresponde(Evidencia, Persona), Evidencias),
    format('Evidencias relacionadas: ~w~n', [Evidencias]),

    % 2) Ubicacion y movimientos
    findall(Hora-Lugar, estuvo(Persona, Lugar, Hora), Movimientos0),
    sort(Movimientos0, Movimientos),
    format('Movimientos registrados:~n'),
    forall(member(H-L, Movimientos),
           format('  - a las ~w en ~w~n', [H, L])),

    % 3) Accesos relevantes
    findall(LugarAcc, tiene_acceso(Persona, LugarAcc), Accesos0),
    sort(Accesos0, Accesos),
    format('Lugares con acceso: ~w~n', [Accesos]),
    si_no(tiene_acceso(Persona, LugarEvento), AccesoEvento),
    format('Acceso al lugar del evento (~w): ~w~n', [LugarEvento, AccesoEvento]),

    % 4) Coartada y contradiccion
    (   coartada_detalle(Persona, LugarC, HoraC)
    ->  format('Coartada: Si (declaro estar en ~w a las ~w)~n', [LugarC, HoraC])
    ;   format('Coartada: No~n')
    ),
    (   contradiccion_detalle(Persona, LugarT, HoraT, LugarR, HoraR)
    ->  format('Contradiccion: Si (declaro ~w a las ~w; un registro la ubica en ~w a las ~w)~n',
               [LugarT, HoraT, LugarR, HoraR])
    ;   format('Contradiccion: No~n')
    ),

    % 5) Justificacion logica
    format('Justificacion logica:~n'),
    forall(explicaciones(Persona, Explicacion),
           format('  - ~w~n', [Explicacion])),

    % 6) Validacion de la solucion
    si_no(presente_en_evento(Persona), Presente),
    si_no(tiene_oportunidad(Persona), Oportunidad),
    si_no(\+ tiene_coartada(Persona), SinCoartada),
    format('Validacion de la solucion:~n'),
    format('  - Estuvo en el lugar del evento durante la ventana: ~w~n', [Presente]),
    format('  - Tuvo acceso o tiene evidencia relacionada: ~w~n', [Oportunidad]),
    format('  - No tiene coartada: ~w~n', [SinCoartada]),
    si_no(posible_sospechoso(Persona), Valida),
    format('  => Solucion valida: ~w~n~n', [Valida]).


% ------------------------------------------------------------
% resolver_caso
% Entrada:   ninguna.
% Salida:    Imprime el resultado del analisis: el evento, los posibles
%            responsables y, por cada uno, su reporte completo.
% Restricc.: Si no hay evento o no hay responsables, lo indica con un
%            mensaje (no falla).
% Objetivo:  Resolver el caso por inferencia logica a partir de los
%            hechos, sin tener guardado quien es el responsable.
% ------------------------------------------------------------
resolver_caso :-
    (   evento(Nombre, Lugar, Hora)
    ->  format('=== RESOLUCION DEL CASO ===~n'),
        format('Evento: ~w en ~w a las ~w~n~n', [Nombre, Lugar, Hora]),
        posibles_responsables(Responsables),
        (   Responsables == []
        ->  format('No se encontraron posibles responsables con la informacion disponible.~n')
        ;   format('Posibles responsables: ~w~n~n', [Responsables]),
            forall(member(Responsable, Responsables),
                   reporte_responsable(Responsable))
        )
    ;   format('El caso no tiene un evento definido.~n')
    ).
