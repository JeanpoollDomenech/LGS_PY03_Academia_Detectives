# Guía de pruebas – Academia Detectives

Esta guía recorre **todo** el proyecto: Prolog, backend, frontend, el segundo caso y los casos de error.
Cada prueba dice **qué escribir**, **qué debe aparecer** y, cuando corresponde, qué **captura (C01 a C28)** la documenta en la sección "Pruebas de funcionalidad" de la documentación externa.

Los resultados de las consultas de Prolog (secciones 1 y 2) también están registrados en el archivo `pruebas_prolog.txt`.

---

## 0. Preparación

### 0.1 Programas necesarios
| Programa | Cómo comprobarlo |
|---|---|
| SWI-Prolog | En una terminal: `swipl --version` |
| Node.js | En una terminal: `node --version` |

### 0.2 Obtener el proyecto
1. En GitHub, botón verde **Code → Download ZIP** (o descomprimir el ZIP de la entrega).
2. Descomprimir en una carpeta, por ejemplo `C:\proyectos\academia-detectives`.
3. La carpeta debe contener `programa/backend` y `programa/frontend`.

### 0.3 Instalar dependencias (una sola vez)
Abrir **dos terminales** (o una y repetir):

```
cd programa/backend
npm install
```
```
cd programa/frontend
npm install
```

### 0.4 Si `swipl` no se reconoce en la terminal
El backend usa el comando `swipl`. Si Windows no lo encuentra, indicar la ruta completa **antes** de arrancar el backend:

- **PowerShell:** `$env:SWIPL="C:\Program Files\swipl\bin\swipl.exe"`
- **CMD:** `set SWIPL="C:\Program Files\swipl\bin\swipl.exe"`

(La ruta puede variar según dónde se instaló SWI-Prolog.)

---

## 1. Pruebas de la lógica en Prolog – Caso 1 (museo)

### 1.1 Cargar el programa
1. Abrir una terminal y entrar a la carpeta de Prolog:
   ```
   cd programa/backend/prolog
   swipl predicados.pl
   ```
   *(En Windows también sirve hacer doble clic sobre `predicados.pl`.)*
2. **Debe verse:** el aviso de bienvenida de SWI-Prolog y el prompt `?-`, **sin mensajes de error ni de advertencia**.

- **Captura C01** – Pantalla de SWI-Prolog con el programa cargado sin errores.

> En cada consulta se escribe el texto terminado en **punto** y se pulsa Enter. Si aparece `;` o el programa queda esperando, se pulsa `;` para ver la siguiente solución, o Enter para terminar.

### 1.2 `tiene_acceso/2`
| # | Consulta | Debe aparecer |
|---|---|---|
| 1 | `tiene_acceso(bruno, bodega).` | `true.` |
| 2 | `tiene_acceso(ana, bodega).` | `false.` |
| 3 | `tiene_acceso(P, bodega).` | `P = bruno ;` y luego `P = elena.` |
| 4 | `tiene_acceso(diego, laboratorio).` | `true.` (por la tarjeta, que está en la biblioteca donde Diego estuvo) |

- **Captura C02** – Las cuatro consultas anteriores en una sola captura.

### 1.3 `tiene_contradiccion/1` y `tiene_coartada/1`
| # | Consulta | Debe aparecer |
|---|---|---|
| 1 | `tiene_contradiccion(bruno).` | `true.` |
| 2 | `tiene_contradiccion(carla).` | `true.` |
| 3 | `tiene_contradiccion(ana).` | `false.` |
| 4 | `tiene_coartada(ana).` | `true.` |
| 5 | `tiene_coartada(bruno).` | `false.` |
| 6 | `tiene_coartada(carla).` | `false.` |

- **Captura C03** – Las seis consultas.

### 1.4 `posible_sospechoso/1` y `posibles_responsables/1`
| # | Consulta | Debe aparecer |
|---|---|---|
| 1 | `posible_sospechoso(X).` | `X = bruno.` (y nadie más) |
| 2 | `posible_sospechoso(ana).` | `false.` |
| 3 | `posibles_responsables(L).` | `L = [bruno].` |

- **Captura C04** – Las tres consultas.

### 1.5 `explicaciones/2`
| # | Consulta | Debe aparecer |
|---|---|---|
| 1 | `explicaciones(bruno, E).` y pulsar `;` varias veces | **6** explicaciones: la conclusión de sospechoso, presencia en la bodega a las 1950, acceso a la bodega, evidencia huella, evidencia llave y contradicción (declaró entrada a las 1955, pero un registro lo ubica en bodega a las 1950) |
| 2 | `explicaciones(ana, E).` y `;` | **2**: evidencia documento y posible coartada |
| 3 | `explicaciones(diego, E).` | `E = 'No hay informacion relevante en el caso sobre diego.'` |
| 4 | `explicaciones(zeta, E).` | `false.` (la persona no existe) |

- **Captura C05** – `explicaciones(bruno, E)` con sus explicaciones.
- **Captura C06** – Las consultas de Diego y de `zeta`.

> Para ver todas las explicaciones de una sola vez se puede escribir:
> `forall(explicaciones(bruno, E), (write(E), nl)).`

### 1.6 `resolver_caso/0`
Escribir: `resolver_caso.`

**Debe aparecer**, en este orden:
1. `=== RESOLUCION DEL CASO ===` y `Evento: desaparicion en bodega a las 2000`
2. `Posibles responsables: [bruno]`
3. `--- Responsable: bruno ---` con:
   - `Evidencias relacionadas: [huella,llave]`
   - `Movimientos registrados:` (1910 en entrada y 1950 en bodega)
   - `Lugares con acceso: [bodega,entrada]` y `Acceso al lugar del evento (bodega): Si`
   - `Coartada: No`
   - `Contradiccion: Si (declaro entrada a las 1955; un registro la ubica en bodega a las 1950)`
   - `Justificacion logica:` con las 6 explicaciones
   - `Validacion de la solucion:` con tres `Si` y `=> Solucion valida: Si`

- **Captura C07** – La primera parte del reporte (hasta las evidencias, movimientos y accesos).
- **Captura C08** – La segunda parte (coartada, contradicción, justificación y validación).

Para salir de SWI-Prolog: `halt.`

---

## 2. Pruebas de la lógica en Prolog – Caso 2 (escuela)

El profesor reemplaza `hechos.pl` por otro caso. Esto se simula así:

### 2.1 Cambiar los hechos (solo de forma local)
1. En `programa/backend/prolog`, **renombrar** `hechos.pl` a `hechos_caso1.pl` (es el respaldo).
2. **Copiar** `hechos_caso2.pl` y llamar a la copia `hechos.pl`.
3. Abrir de nuevo: `swipl predicados.pl`

> Este cambio es solo para la prueba. Al terminar la sección se restauran los hechos del caso 1: se borra el `hechos.pl` del caso 2 y `hechos_caso1.pl` vuelve a llamarse `hechos.pl`.

### 2.2 Consultas
| # | Consulta | Debe aparecer |
|---|---|---|
| 1 | `posibles_responsables(L).` | `L = [marta, nicolas].` |
| 2 | `posible_sospechoso(X).` y `;` | `X = marta ;` luego `X = nicolas.` (demuestra el backtracking con dos sospechosos) |
| 3 | `tiene_coartada(olga).` y `tiene_coartada(pablo).` | `true.` en ambas |
| 4 | `tiene_contradiccion(marta).` | `true.` |
| 5 | `tiene_acceso(marta, direccion).` | `true.` (por la llave de la dirección, que está en la sala de profesores) |
| 6 | `explicaciones(rosa, E).` | `E = 'No hay informacion relevante en el caso sobre rosa.'` (Rosa no tiene movimientos) |
| 7 | `resolver_caso.` | Reporte completo de **marta** y de **nicolas**, ambos con `Solucion valida: Si` |

- **Captura C09** – Consultas 1 y 2 (dos sospechosos).
- **Captura C10** – `resolver_caso.` (reporte de Marta y de Nicolás).
- **Captura C11** – `explicaciones(rosa, E).`

**Conclusión de esta parte:** las mismas reglas funcionan con un caso distinto, sin modificar `predicados.pl`.

> La sección 5.4 también usa el caso 2, por lo que puede dejarse puesto hasta terminarla; si esa sección no se va a realizar, se restaura en este punto.

---

## 3. Pruebas del backend (Node + Express)

*(Con `hechos.pl` del **caso 1** restaurado.)*

### 3.1 Arrancar el backend
```
cd programa/backend
node server.js
```
**Debe aparecer:** `Backend escuchando en http://localhost:3001`. Esta terminal debe permanecer abierta.

> Si al abrir `http://localhost:3001/` aparece `Cannot GET /`, es normal: el servidor solo responde en las rutas `/api/...`.

- **Captura C12** – La terminal con ese mensaje.

### 3.2 Probar las rutas desde el navegador
Abrir cada dirección. La respuesta es un JSON con `"ok": true` y un `"resultado"`.

| # | Dirección | `resultado` esperado |
|---|---|---|
| 1 | `http://localhost:3001/api/personas` | `[ana,bruno,carla,diego,elena]` |
| 2 | `http://localhost:3001/api/lugares` | Cinco líneas, de `entrada: Entrada principal del museo.` a `oficina: Oficina administrativa.` |
| 3 | `http://localhost:3001/api/objetos` | `[llave_maestra,tarjeta_laboratorio,documento,caja_herramientas]` |
| 4 | `http://localhost:3001/api/acceso/bruno` | `[bodega,entrada]` |
| 5 | `http://localhost:3001/api/coartada/ana` | `Si` |
| 6 | `http://localhost:3001/api/contradiccion/carla` | `Si` |
| 7 | `http://localhost:3001/api/sospechoso/bruno` | `Si` |
| 8 | `http://localhost:3001/api/responsables` | `[bruno]` |
| 9 | `http://localhost:3001/api/explicaciones/bruno` | Las 6 explicaciones, una por línea |
| 10 | `http://localhost:3001/api/resolver` | El reporte completo del caso |

- **Captura C13** – `/api/personas` en el navegador.
- **Captura C14** – `/api/responsables`.
- **Captura C15** – `/api/explicaciones/bruno`.

### 3.3 Persona que no existe
Abrir `http://localhost:3001/api/explicaciones/zeta`.

**Debe aparecer:** `{"ok":false,"error":"La persona no existe en el caso."}`

- **Captura C16** – La respuesta de error de `/api/explicaciones/zeta`.

---

## 4. Pruebas de la interfaz (React)

### 4.1 Arrancar el frontend
Con el backend **todavía corriendo**, abrir una **segunda terminal**:
```
cd programa/frontend
npm run dev
```
**Debe aparecer:** una dirección local, normalmente `http://localhost:5173/`.

- **Captura C17** – La terminal de Vite con la dirección.

Abrir esa dirección en el navegador.

### 4.2 Pantalla inicial
**Debe verse:** el título "Academia Detectives", la lista desplegable **Persona** con `ana, bruno, carla, diego, elena`, los botones de consultas por persona, el botón **Posibles responsables** y la sección **Resolver el caso**.

- **Captura C18** – La pantalla inicial completa.

### 4.3 Consultas por persona
En cada prueba, elegir la persona de la lista y pulsar el botón. El resultado aparece en el recuadro gris.

| # | Persona | Botón | Debe aparecer |
|---|---|---|---|
| 1 | bruno | Lugares con acceso | `[bodega,entrada]` |
| 2 | ana | Lugares con acceso | `[biblioteca,laboratorio,oficina]` |
| 3 | ana | ¿Tiene coartada? | `Si` |
| 4 | bruno | ¿Tiene coartada? | `No` |
| 5 | carla | ¿Tiene contradicción? | `Si` |
| 6 | ana | ¿Tiene contradicción? | `No` |
| 7 | bruno | ¿Es posible sospechoso? | `Si` |
| 8 | ana | ¿Es posible sospechoso? | `No` |
| 9 | bruno | Explicaciones | 6 explicaciones, una por línea |
| 10 | diego | Explicaciones | `No hay informacion relevante en el caso sobre diego.` |

- **Captura C19** – Prueba 1 (acceso de bruno).
- **Captura C20** – Pruebas 3 y 4 (coartada de ana y de bruno).
- **Captura C21** – Prueba 7 (¿Es posible sospechoso? bruno).
- **Captura C22** – Prueba 9 (explicaciones de bruno).

### 4.4 Consultas del caso
| # | Botón | Debe aparecer |
|---|---|---|
| 1 | Posibles responsables | `[bruno]` |
| 2 | Resolver caso | En el recuadro amarillo: el reporte completo, igual que en la prueba 1.6 |

- **Captura C23** – Resultado de **Posibles responsables**.
- **Captura C24** – El recuadro de **Resolver caso** con el reporte.

---

## 5. Pruebas de errores

### 5.1 Nombre inválido en el backend
Abrir `http://localhost:3001/api/acceso/Ana` (con mayúscula).
**Debe aparecer:** `{"ok":false,"error":"Nombre de persona inválido"}`

> Algunos navegadores autocompletan la dirección y cambian `Ana` por `ana` al escribir; si ocurre, se pulsa Esc antes de Enter.

- **Captura C26** – La respuesta de `/api/acceso/Ana`.

### 5.2 Persona inexistente
Abrir `http://localhost:3001/api/acceso/zeta`.
**Debe aparecer:** `{"ok":false,"error":"La persona no existe en el caso."}`

- **Captura C27** – La respuesta de `/api/acceso/zeta`.

### 5.3 Backend apagado
1. En la terminal del backend, pulsar `Ctrl + C` para detenerlo.
2. En la interfaz, elegir cualquier persona y pulsar un botón.
3. **Debe aparecer**, en rojo, un mensaje que indica que el backend no responde y que hay que verificar que `server.js` esté corriendo.

- **Captura C28** – El mensaje de error en la interfaz.

Volver a arrancar el backend (`node server.js`) antes de continuar.

### 5.4 La interfaz con el caso 2
1. Detener el backend (`Ctrl + C`).
2. Hacer el cambio de la sección 2.1 (poner `hechos_caso2.pl` como `hechos.pl`).
3. Arrancar de nuevo el backend (`node server.js`) y **refrescar** la página de la interfaz (`F5`).
4. **Debe verse:** la lista de personas ahora tiene `marta, nicolas, olga, pablo, rosa`.
5. Pulsar **Posibles responsables**: debe aparecer `[marta,nicolas]`.
6. Pulsar **Resolver caso**: debe aparecer el reporte de ambos.

| Persona | Lugares con acceso | Coartada | Contradicción | Sospechoso |
|---|---|---|---|---|
| marta | `[direccion,sala_profesores]` | No | Si | Si |
| nicolas | `[direccion,patio]` | No | Si | Si |
| olga | `[aula_magna]` | Si | No | No |
| pablo | `[direccion,patio,sala_profesores]` | Si | No | No |
| rosa | `[patio]` | No | No | No |

- **Captura C25** – La interfaz con el caso 2 (personas de la escuela y el resultado de **Resolver caso**).

Al terminar se restauran los hechos del caso 1 (ver 2.1).

---

## 6. Resumen de capturas

| Captura | Qué muestra | Sección |
|---|---|---|
| C01 | Programa cargado sin errores | 1.1 |
| C02 | `tiene_acceso/2` | 1.2 |
| C03 | `tiene_contradiccion/1` y `tiene_coartada/1` | 1.3 |
| C04 | `posible_sospechoso/1` y `posibles_responsables/1` | 1.4 |
| C05 | `explicaciones(bruno, E)` | 1.5 |
| C06 | `explicaciones` de Diego y de una persona inexistente | 1.5 |
| C07 | `resolver_caso` (primera parte) | 1.6 |
| C08 | `resolver_caso` (segunda parte) | 1.6 |
| C09 | Caso 2: dos sospechosos | 2.2 |
| C10 | Caso 2: `resolver_caso` | 2.2 |
| C11 | Caso 2: persona sin movimientos | 2.2 |
| C12 | Backend arrancado | 3.1 |
| C13 | `/api/personas` | 3.2 |
| C14 | `/api/responsables` | 3.2 |
| C15 | `/api/explicaciones/bruno` | 3.2 |
| C16 | Error: persona inexistente (explicaciones) | 3.3 |
| C17 | Frontend arrancado | 4.1 |
| C18 | Pantalla inicial | 4.2 |
| C19 | Interfaz: lugares con acceso | 4.3 |
| C20 | Interfaz: coartada | 4.3 |
| C21 | Interfaz: ¿es posible sospechoso? | 4.3 |
| C22 | Interfaz: explicaciones | 4.3 |
| C23 | Interfaz: posibles responsables | 4.4 |
| C24 | Interfaz: resolver caso | 4.4 |
| C25 | Interfaz con el caso 2 | 5.4 |
| C26 | Error: nombre inválido | 5.1 |
| C27 | Error: persona inexistente (acceso) | 5.2 |
| C28 | Interfaz con el backend apagado | 5.3 |

---

## 7. Lista de verificación

| # | Prueba | Resultado |
|---|---|---|
| 1 | Prolog carga sin errores ni advertencias | ☑ |
| 2 | Todos los predicados dan los resultados esperados en el caso 1 | ☑ |
| 3 | Todos los predicados dan los resultados esperados en el caso 2, sin tocar `predicados.pl` | ☑ |
| 4 | Un caso con dos sospechosos usa el backtracking | ☑ |
| 5 | Una persona sin movimientos no rompe nada | ☑ |
| 6 | Todas las rutas del backend responden | ☑ |
| 7 | Todos los botones de la interfaz funcionan | ☑ |
| 8 | Nombre inválido, persona inexistente y backend apagado muestran mensajes claros | ☑ |
| 9 | `hechos.pl` del caso 1 quedó restaurado | ☑ |
| 10 | Probado desde una copia limpia del repositorio (sin carpetas `node_modules` previas) | ☑ |
