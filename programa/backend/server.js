// Rol: recibir la peticion de React, ejecutar Prolog y devolver el texto que Prolog imprime
// TODA la logica del caso vive en Prolog (prolog/predicados.pl); aqui no se decide nada

import express from 'express';
import { execFile } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const app = express();
const PUERTO = 3001;

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ARCHIVO_PROLOG = path.join(__dirname, 'prolog', 'predicados.pl');

// Si "swipl" no esta en el PATH, se puede indicar la ruta completa con la variable SWIPL
const SWIPL = process.env.SWIPL || 'swipl';

// Codigo de salida con el que Prolog avisa que la persona no existe en persona/1
const CODIGO_PERSONA_INEXISTENTE = 3;

// ejecutarProlog(meta)
// Entrada:   meta = texto con la meta de Prolog a ejecutar (sin el punto final)
// Salida:    Promise con el texto que Prolog imprimio
// Restricc.: usa execFile (no exec), asi el texto nunca pasa por una terminal
// Objetivo:  cargar predicados.pl, ejecutar la meta y cerrar Prolog
function ejecutarProlog(meta) {
  const argumentos = ['-q', '-s', ARCHIVO_PROLOG, '-g', meta, '-t', 'halt'];
  return new Promise((resolve, reject) => {
    execFile(SWIPL, argumentos, { timeout: 5000, cwd: __dirname }, (error, stdout, stderr) => {
      if (error && error.code === CODIGO_PERSONA_INEXISTENTE) {
        const noExiste = new Error('La persona no existe en el caso.');
        noExiste.estado = 404;
        reject(noExiste);
      } else if (error) {
        const detalle = (stderr || error.message).trim().split('\n')[0];
        reject(new Error(`Prolog no pudo responder: ${detalle}`));
      } else {
        resolve(stdout.trim());
      }
    });
  });
}

// responder(res, meta)
// Entrada:   res de Express y la meta de Prolog
// Salida:    JSON { ok, resultado } o { ok, error }, siempre con este formato
// Objetivo:  evitar repetir el mismo try/catch en cada ruta
async function responder(res, meta) {
  try {
    const resultado = await ejecutarProlog(meta);
    res.json({ ok: true, resultado });
  } catch (error) {
    res.status(error.estado ?? 500).json({ ok: false, error: error.message });
  }
}

// GET /api/personas lista de personas del caso
app.get('/api/personas', (req, res) => {
  responder(res, "findall(P, persona(P), L), format('~w~n', [L])");
});

// GET /api/lugares un lugar por linea, con su descripcion
app.get('/api/lugares', (req, res) => {
  responder(res, "forall(lugar(N, D), format('~w: ~w~n', [N, D]))");
});

// GET /api/objetos lista de objetos del caso
app.get('/api/objetos', (req, res) => {
  responder(res, "findall(O, objeto(O), L), format('~w~n', [L])");
});

// Un nombre de persona valido empieza con letra minuscula y sigue con letras, numeros o "_".
// Asi nunca puede ser una variable de Prolog (empieza con "_" o mayuscula) ni traer
// caracteres especiales (comillas, ";", espacios) que cambien la meta
const NOMBRE_VALIDO = /^[a-z][a-z0-9_]*$/;

// rutaPersona(ruta, construirMeta)
// Entrada:   ruta base ('/api/acceso') y una funcion que arma la meta de Prolog
//            a partir del nombre de la persona.
// Salida:    registra GET <ruta>/:persona en Express.
// Restricc.: rechaza con 400 los nombres que no cumplan NOMBRE_VALIDO y con 404
//            los que no existan en persona/1.
// Objetivo:  validar el nombre una sola vez para todas las consultas por persona.
function rutaPersona(ruta, construirMeta) {
  app.get(`${ruta}/:persona`, (req, res) => {
    const { persona } = req.params;
    if (!NOMBRE_VALIDO.test(persona)) {
      return res.status(400).json({ ok: false, error: 'Nombre de persona invalido' });
    }
    // Si la persona no esta en persona/1, Prolog termina con el codigo 3 (error 404)
    // Si existe, ejecuta la consulta normal
    responder(
      res,
      `( \\+ persona(${persona}) -> halt(${CODIGO_PERSONA_INEXISTENTE}) ; ( ${construirMeta(persona)} ) )`
    );
  });
}

// Lugares a los que una persona tiene acceso (sort/2 quita los repetidos)
rutaPersona('/api/acceso', (p) =>
  `findall(L, tiene_acceso(${p}, L), L0), sort(L0, Ls), format('~w~n', [Ls])`);

// Consultas de tipo Si/No
rutaPersona('/api/coartada', (p) =>
  `(tiene_coartada(${p}) -> writeln('Si') ; writeln('No'))`);
rutaPersona('/api/contradiccion', (p) =>
  `(tiene_contradiccion(${p}) -> writeln('Si') ; writeln('No'))`);
rutaPersona('/api/sospechoso', (p) =>
  `(posible_sospechoso(${p}) -> writeln('Si') ; writeln('No'))`);

// GET /api/responsables lista de personas que son posibles sospechosos
app.get('/api/responsables', (req, res) => {
  responder(res, "posibles_responsables(L), format('~w~n', [L])");
});

// GET /api/explicaciones/:persona una explicacion por linea (backtracking de Prolog)
rutaPersona('/api/explicaciones', (p) =>
  `forall(explicaciones(${p}, E), format('~w~n', [E]))`);

// GET /api/resolver reporte completo que imprime resolver_caso/0
app.get('/api/resolver', (req, res) => {
  responder(res, 'resolver_caso');
});

app.listen(PUERTO, () => {
  console.log(`Backend escuchando en http://localhost:${PUERTO}`);
});
