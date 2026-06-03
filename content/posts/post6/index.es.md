---
date: '2026-06-03T19:00:00+02:00'
draft: false
title: "Claude, ¿cómo va mi dinero?"
author: 'Álvaro Huertas Díaz'
authorLink: 'https://www.linkedin.com/in/alvarohuertasdiaz/'
resources:
- name: "featured-image"
  src: "featured-image.png"
- name: "featured-image-preview"
  src: "featured-image-preview.png"

tags: ["B.E.L.E.N", "Go", "TUI", "Autoalojado", "Actual Budget", "Claude", "OpenID"]
---


Mi clúster BELEN ya ejecuta [Actual Budget](https://actualbudget.org/) — una app de presupuestos elegante, *local-first* y autoalojada. En el navegador es una maravilla. Pero yo vivo en la terminal, y últimamente construyo todo en pareja con Claude Code. Así que tenía una espinita: quería *hablarle* a mi presupuesto desde una TUI y —más interesante aún— quería que **Claude** pudiera leerlo y razonar de verdad sobre mi dinero. Esta es la historia de [`actual-tui`](https://github.com/B-E-L-E-N-Cluster/actual-tui), y de un pivote de lo más satisfactorio.

### El muro: sin API, y una regla cabezota

Aparecieron dos problemas de inmediato.

Primero, **Actual no tiene API REST.** Ofrece un SDK de Node.js que descarga una copia local de tu presupuesto y la sincroniza — potente, pero no es algo a lo que un programa en Go pueda hacerle un simple `curl`.

Segundo, mi línea innegociable: **entro en el Actual de BELEN con Google (OpenID), y me negaba a añadir una contraseña solo para el tooling.** Todas las herramientas de la comunidad autentican con una contraseña de servidor. En un servidor sin contraseña y con OpenID forzado como el mío, nacen muertas.

Así que el camino fácil estaba bloqueado. Bien — esos son los divertidos.

### El avance: entrar como la web, sin contraseña

Esto es lo que hace el cliente web y no hacían las herramientas: nunca *me* pide una contraseña — me rebota por Google y recibe de vuelta un **token de sesión**. ¿Podría una CLI hacer lo mismo?

Resulta que sí. Al iniciar un login OpenID, el servidor de Actual te deja pasar un `returnUrl` — y permite explícitamente `localhost`. Es exactamente el patrón que usa `gh auth login`. Así que `actual-tui login`:

1. levanta un pequeño servidor *loopback* en `http://localhost:PUERTO`,
2. pide al servidor que arranque el flujo OpenID con ese return URL,
3. abre el navegador → entro con Google,
4. el servidor redirige de vuelta a `localhost` con el token de sesión en la URL,
5. el token aterriza a buen recaudo en el llavero (keyring) del sistema.

Sin contraseña. Funciona contra *cualquier* servidor de Actual, esté como esté configurado. La primera vez que imprimió `LoggedIn: true` contra el BELEN real, puede que hiciera un bailecito en la silla.

### El pivote estratégico (tradición de BELEN)

Si has leído mis posts anteriores, sabes que BELEN se mueve por el *arte del pivote estratégico*. Este fue precioso.

Había empezado a construir mi propio puente — un pequeño servicio en Node envolviendo el SDK — y andaba metido hasta el cuello en interioridades engorrosas. Entonces, a mitad de obra, lo encontré: **`@actual-app/cli`**, una CLI *oficial* para Actual, con cobertura completa y salida en JSON. Y el detalle clave: acepta un token de sesión directamente vía `ACTUAL_SESSION_TOKEN`.

Así que tiré mi puente a medida. ¿El token OpenID que tanto me había costado capturar? Encajó directo en la CLI oficial y *simplemente funcionó* — cuentas, transacciones, presupuestos, todo en JSON limpio. Menos código, más robusto, soportado oficialmente. Matar tu propio código favorito en favor de una herramienta mejor es, siempre, la decisión correcta.

### El resultado: [actual-tui](https://github.com/B-E-L-E-N-Cluster/actual-tui)

Lo que acabé teniendo es pequeño y centrado:

- **`actual-tui login` / `whoami` / `logout`** — el gestor de sesión OpenID.
- Una **TUI a pantalla completa, estilo [k9s](https://k9scli.io/)** (hecha con `tview`) para explorar cuentas, transacciones y presupuestos — y editar algunas cosas: conciliar, recategorizar, fijar un importe de presupuesto.
- **`actual-tui exec -- …`** — el puente: inyecta el token del llavero en la CLI oficial para que cualquier cosa (un script, o un agente IA) pueda usarla *sin tocar nunca el token*.

```text
$ actual-tui login --server https://actualbudget.midominio
  → navegador → Google → LoggedIn ✓   (sin contraseña)
$ actual-tui                      # la TUI estilo k9s
$ actual-tui exec accounts list   # CLI oficial, autenticada, JSON de salida
```

**Es open-source.** `actual-tui` está en **[github.com/B-E-L-E-N-Cluster/actual-tui](https://github.com/B-E-L-E-N-Cluster/actual-tui)** — instálalo con una línea:

```sh
curl -fsSL https://raw.githubusercontent.com/B-E-L-E-N-Cluster/actual-tui/main/install.sh | sh
```

(más `npm i -g @actual-app/cli` para la capa de datos.)

### La magia de verdad: Claude como asesor financiero

Ese puente `exec` es el quid de todo. Escribí una pequeña **skill de Claude** que le enseña a manejar la CLI: listar cuentas, resolver los IDs de categoría y payee a nombres, leer un mes de presupuesto, y los *gotchas* (los importes van en céntimos, las transacciones necesitan un rango de fechas, las cuentas *off-budget* no son gasto).

El resultado todavía me sorprende. Puedo preguntar, en lenguaje natural, *"¿cómo voy este mes?"* o *"¿dónde me estoy pasando?"* — y Claude tira de mis números **en vivo** y responde con cifras reales y consejos concretos. Ahora mismo estoy sopesando una compra grande con un plan de pagos a varios años, y Claude leyó mi posición real de liquidez y mi flujo mensual y me dijo —sin rodeos, con números— exactamente lo justo que iba a ir y por dónde recortar. Eso no es un consejo genérico de chatbot. Es asesoramiento anclado en mis propios datos, que nunca salen de mi máquina.

### Reflexión

Todo esto se construyó con Claude Code como pareja: lanzó subagentes, se topó con bugs reales contra el servidor en vivo (un flag obligatorio aquí, un mapeo de ID a nombre allá), y los arreglamos juntos. El patrón que una y otra vez funciona en BELEN se repite — ten un principio cabezota (OpenID, sin contraseña), está dispuesto a pivotar fuerte cuando aparece una herramienta mejor (la CLI oficial), y mantén la superficie pequeña.

Lo siguiente: convertir esa skill de asesor financiero de *"responde a mis preguntas"* a *"vigila mi presupuesto y avísame"*. Pero eso es otro post.
