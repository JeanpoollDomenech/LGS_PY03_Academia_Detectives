// App.jsx: manejo de errores (backend apagado, respuestas invalidas, resultados vacios)
import { useEffect, useState } from 'react';

// Consultas por persona: texto del boton y ruta del backend
const CONSULTAS = [
  { etiqueta: 'Lugares con acceso', ruta: '/api/acceso' },
  { etiqueta: '¿Tiene coartada?', ruta: '/api/coartada' },
  { etiqueta: '¿Tiene contradicción?', ruta: '/api/contradiccion' },
  { etiqueta: '¿Es posible sospechoso?', ruta: '/api/sospechoso' },
  { etiqueta: 'Explicaciones', ruta: '/api/explicaciones' },
];

// Consultas del caso completo (no dependen de la persona elegida)
const GENERALES = [
  { etiqueta: 'Posibles responsables', ruta: '/api/responsables' },
];

// pedir(url)
// Entrada:   ruta del backend ('/api/personas')
// Salida:    Promise con el texto que devolvio Prolog
// Restricc.: lanza un Error con un mensaje claro si no hay conexion, si el backend
//            no responde con JSON o si responde { ok: false }
// Objetivo:  una sola funcion para hablar con el backend
async function pedir(url) {
  let respuesta;
  try {
    respuesta = await fetch(url);
  } catch {
    throw new Error('No se pudo contactar al servidor. Verifica que el frontend esté corriendo (npm run dev).');
  }
  let datos;
  try {
    datos = await respuesta.json();
  } catch {
    throw new Error('El backend no responde. Verifica que server.js esté corriendo en el puerto 3001.');
  }
  if (!datos.ok) throw new Error(datos.error);
  return datos.resultado;
}

// listaProlog(texto)
// Entrada:   texto de una lista impresa por Prolog, "[ana,bruno]".
// Salida:    arreglo de nombres, ['ana', 'bruno'] ([] si la lista esta vacia)
function listaProlog(texto) {
  const limpio = texto.trim().replace(/^\[|\]$/g, '');
  return limpio === '' ? [] : limpio.split(',').map((nombre) => nombre.trim());
}

export default function App() {
  const [personas, setPersonas] = useState([]);
  const [persona, setPersona] = useState('');
  const [resultado, setResultado] = useState('');
  const [cargando, setCargando] = useState(false);
  const [error, setError] = useState('');
  const [reporte, setReporte] = useState('');
  const [resolviendo, setResolviendo] = useState(false);

  useEffect(() => {
    pedir('/api/personas')
      .then((texto) => {
        const lista = listaProlog(texto);
        setPersonas(lista);
        setPersona(lista[0] ?? '');
      })
      .catch((e) => setError(`No se pudieron cargar las personas: ${e.message}`));
  }, []);

  // consultar(url)
  // Entrada:   url completa de la consulta ('/api/coartada/ana' o '/api/responsables')
  // Objetivo:  pedir la consulta y mostrar el resultado o el error
  async function consultar(url) {
    setCargando(true);
    setError('');
    setResultado('');
    try {
      setResultado((await pedir(url)) || 'Sin resultados para esta consulta.');
    } catch (e) {
      setError(e.message);
    } finally {
      setCargando(false);
    }
  }

  // resolverCaso()
  // Objetivo:  pedir el reporte completo de resolver_caso/0 y mostrarlo en el area destacada
  async function resolverCaso() {
    setResolviendo(true);
    setError('');
    setReporte('');
    try {
      setReporte((await pedir('/api/resolver')) || 'El caso no produjo ningún reporte.');
    } catch (e) {
      setError(e.message);
    } finally {
      setResolviendo(false);
    }
  }

  return (
    <div style={{ padding: 20, maxWidth: 800, margin: '0 auto' }}>
      <h1>Academia Detectives</h1>

      <label>
        Persona:{' '}
        <select value={persona} onChange={(e) => setPersona(e.target.value)}>
          {personas.map((nombre) => (
            <option key={nombre} value={nombre}>{nombre}</option>
          ))}
        </select>
      </label>

      <h3>Consultas sobre la persona elegida</h3>
      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 16 }}>
        {CONSULTAS.map((c) => (
          <button key={c.ruta} disabled={!persona || cargando} onClick={() => consultar(`${c.ruta}/${persona}`)}>
            {c.etiqueta}
          </button>
        ))}
      </div>

      <h3>Consultas del caso</h3>
      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 16 }}>
        {GENERALES.map((c) => (
          <button key={c.ruta} disabled={cargando} onClick={() => consultar(c.ruta)}>
            {c.etiqueta}
          </button>
        ))}
      </div>

      {cargando && <p>Cargando...</p>}
      {error && <p style={{ color: 'crimson' }}>{error}</p>}
      <pre style={{ background: '#f4f4f4', color: '#111', padding: 12, minHeight: 60, whiteSpace: 'pre-wrap' }}>{resultado}</pre>

      <hr style={{ margin: '24px 0' }} />

      <h2>Resolver el caso</h2>
      <button
        disabled={resolviendo}
        onClick={resolverCaso}
        style={{ fontSize: 18, padding: '10px 24px', fontWeight: 'bold' }}
      >
        {resolviendo ? 'Resolviendo...' : 'Resolver caso'}
      </button>
      <pre
        style={{
          background: '#fffbe6',
          color: '#111',
          border: '2px solid #d4a72c',
          borderRadius: 6,
          padding: 16,
          marginTop: 16,
          minHeight: 200,
          fontSize: 15,
          whiteSpace: 'pre-wrap',
        }}
      >
        {reporte || 'El reporte del caso aparecera aqui.'}
      </pre>
    </div>
  );
}
