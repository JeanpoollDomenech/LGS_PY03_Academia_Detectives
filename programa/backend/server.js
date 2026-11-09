// server.js - Backend de Academia Detectives
// Rol: recibir la peticion de React, ejecutar Prolog y devolver el texto que Prolog imprime
// TODA la logica del caso vive en Prolog (prolog/predicados.pl)

import express from 'express';
import { execFile } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const app = express();
const PUERTO = 3001;

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ARCHIVO_PROLOG = path.join(__dirname, 'prolog', 'predicados.pl');

// Si swipl no esta en el PATH, se puede indicar la ruta completa con la variable SWIPL
const SWIPL = process.env.SWIPL || 'swipl';

// ejecutarProlog(meta)
// Entrada:   meta = texto con la meta de Prolog a ejecutar (sin el punto final)
// Salida:    Promise con el texto que Prolog imprimio
// Restricc.: usa execFile (no exec), asi el texto nunca pasa por una terminal
// Objetivo:  cargar predicados.pl, ejecutar la meta y cerrar Prolog
function ejecutarProlog(meta) {
  const argumentos = ['-q', '-s', ARCHIVO_PROLOG, '-g', meta, '-t', 'halt'];
  return new Promise((resolve, reject) => {
    execFile(SWIPL, argumentos, { timeout: 5000, cwd: __dirname }, (error, stdout, stderr) => {
      if (error) {
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
    res.status(500).json({ ok: false, error: error.message });
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

app.listen(PUERTO, () => {
  console.log(`Backend escuchando en http://localhost:${PUERTO}`);
});
