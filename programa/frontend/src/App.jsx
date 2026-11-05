// App.jsx - Prueba de punta a punta (Paso 7): React -> Node -> Prolog
import { useEffect, useState } from 'react';
 
export default function App() {
  const [texto, setTexto] = useState('Cargando...');
 
  useEffect(() => {
    fetch('/api/personas')
      .then((respuesta) => respuesta.json())
      .then((datos) => setTexto(datos.ok ? datos.resultado : `Error: ${datos.error}`))
      .catch(() => setTexto('No se pudo contactar al backend. ¿Esta corriendo server.js?'));
  }, []);
 
  return (
    <div style={{ padding: 20 }}>
      <h1>Academia Detectives</h1>
      <h3>Personas del caso</h3>
      <pre>{texto}</pre>
    </div>
  );
}
 