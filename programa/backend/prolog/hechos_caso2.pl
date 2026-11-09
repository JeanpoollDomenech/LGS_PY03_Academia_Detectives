% ============================================================
% hechos_caso2.pl  -  Academia Detectives
% Segundo caso de prueba: robo en la direccion de una escuela.
%
% Sirve para comprobar que predicados.pl no depende de los datos
% del caso 1. Para probarlo, se copia su contenido dentro de
% hechos.pl (o se cambia la linea :- consult(hechos). de
% predicados.pl por :- consult(hechos_caso2).).
%
% Resultado esperado: dos posibles responsables (marta y nicolas),
% una persona sin movimientos registrados (rosa) y dos personas con
% coartada (olga y pablo).
% ============================================================

:- encoding(utf8).

% PERSONAS
persona(marta).
persona(nicolas).
persona(olga).
persona(pablo).
persona(rosa).

% LUGARES
lugar(patio, "Patio central de la escuela.").
lugar(aula_magna, "Aula magna para actos y reuniones.").
lugar(sala_profesores, "Sala de profesores.").
lugar(direccion, "Oficina de la direccion.").

% OBJETOS
objeto(llave_direccion).
objeto(laptop).
objeto(guante).

% UBICACION DE OBJETOS
ubicado(llave_direccion, sala_profesores).
ubicado(laptop, direccion).
ubicado(guante, patio).

% ACCESO DIRECTO
acceso(marta, sala_profesores).
acceso(nicolas, patio).
acceso(nicolas, direccion).
acceso(olga, aula_magna).
acceso(pablo, patio).
acceso(pablo, sala_profesores).
acceso(rosa, patio).

% ACCESO POR OBJETO
accesoPorObjeto(direccion, llave_direccion).

% REGISTRO DE MOVIMIENTOS (rosa no tiene ningun registro)
estuvo(marta, sala_profesores, 1400).
estuvo(marta, direccion, 1420).
estuvo(nicolas, patio, 1350).
estuvo(nicolas, direccion, 1435).
estuvo(olga, aula_magna, 1415).
estuvo(olga, aula_magna, 1440).
estuvo(pablo, patio, 1410).
estuvo(pablo, sala_profesores, 1425).

% EVENTO CENTRAL
evento(robo, direccion, 1430).

% EVIDENCIAS
evidencia(huella, direccion, 1435).
evidencia(guante, patio, 1445).

% RELACION ENTRE EVIDENCIA Y PERSONA
corresponde(huella, nicolas).
corresponde(guante, pablo).

% TESTIMONIOS
testimonio(marta, sala_profesores, 1425).
testimonio(nicolas, patio, 1430).
testimonio(olga, aula_magna, 1430).
testimonio(pablo, patio, 1410).
