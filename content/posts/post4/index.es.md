---
date: '2025-07-03T18:59:27+02:00'
draft: false
title: 'Alta disponibilidad con secretos cifrados en Kubernetes'
author: 'Álvaro Huertas Díaz'
authorLink: 'https://www.linkedin.com/in/alvarohuertasdiaz/'
resources:
- name: "featured-image"
  src: "featured-image.png"
- name: "featured-image-preview"
  src: "featured-image-preview.png"

tags: ["B.E.L.E.N", "Kubernetes", "GitOps", "Gestión de Secretos", "Seguridad"]
---

## Del Homelab a la Nube: La Búsqueda de Operaciones Ininterrumpidas

¡Hola, compañeros exploradores de tecnología e innovadores aspirantes! Bienvenidos de nuevo a mi blog personal, donde narro mis inmersiones profundas en los desafíos de TI y comparto el progreso del **Proyecto B.E.L.E.N. (Balanced Efficient Local Ephemeral Nodes)**. Hoy, voy a desvelar una architectural decision reciente y crucial: cómo estamos externalizando los secretos para garantizar una alta disponibilidad y permitir  en un futuro la replicación sin fisuras de nuestro clúster en cualquier proveedor de servicios de la nube. No se trata solo de experimentar en un homelab; se trata de construir una base robusta con de nivel de producción.

Mi visión para B.E.L.E.N. se extiende mucho más allá de una configuración con un único punto de fallo. Nos esforzamos por conseguir un entorno Kubernetes verdaderamente resiliente. Esto significa que nuestras aplicaciones deben permanecer operativas incluso frente a interrupciones significativas, ya sea el fallo de un solo nodo o que todo el homelab se desconecte. La clave de esta resiliencia reside en poder levantar rápidamente un clúster idéntico, en cualquier lugar —ya sea un nuevo servidor físico o una instancia en la nube— y que nuestras aplicaciones se reanuden con una configuración sin intervención manual.

Para este ambicioso objetivo, los secretos (claves de API, credenciales de bases de datos, certificados TLS) no pueden ser una ocurrencia tardía. Deben ser:

  * **Versionados y Auditables:** Cambios rastreados, historial preservado.
  * **Automatizados:** Desplegados sin intervención manual, eliminando el error humano.
  * **Portables:** Funcionar de manera idéntica en diversos entornos (homelab, nube, desarrollo).
  * **Seguros:** Absolutamente ningún secreto en texto plano en nuestro repositorio Git.

Este exigente conjunto de requisitos nos llevó directamente al corazón de nuestro actual **GitOps**, convirtiendo nuestro repositorio Git en la única fuente de verdad indiscutible para todas las configuraciones del clúster, incluyendo estos datos sensibles.

## ¿La Mejor Gestión de Secretos en GitOps? Un Desvío a Través del Muro de "Solo Escritura"

Con GitOps como nuestro principio rector, comenzamos a explorar el ecosistema de Kubernetes en busca de una solución robusta para la gestión de secretos. Nuestro entusiasmo inicial se centró en **External Secrets Operator (ESO)**. ESO es una herramienta fantástica diseñada para obtener secretos de varios sistemas de gestión de secretos externos (como HashiCorp Vault, AWS Secrets Manager, Azure Key Vault, etc.) y sincronizarlos en objetos `Secret` nativos de Kubernetes. Esto parecía el ajuste perfecto para "externalizar" nuestros secretos.

Dada nuestra dependencia de GitHub para nuestro repositorio GitOps, el proveedor de **GitHub Actions Secrets** para ESO captó inmediatamente nuestra atención. La promesa era atractiva: almacenar nuestro secreto sensible `HELLO_WORLD` directamente en GitHub Actions, y dejar que ESO lo descargara en nuestro clúster de Kubernetes, creando un `Secret` estándar que nuestras aplicaciones pudieran consumir. Parecía una solución perfectamente integrada.

Seguimos meticulosamente la configuración, creando una GitHub App, generando claves privadas, configurando el `ClusterSecretStore` en Kubernetes y definiendo nuestro recurso `ExternalSecret` para hacer referencia al secreto `HELLO_WORLD` en GitHub Actions. FluxCD, nuestro orquestador GitOps elegido, aplicó diligentemente todos estos manifiestos al clúster.

Sin embargo, cuando comprobamos el estado de nuestro `ExternalSecret` y profundizamos en los logs del controlador de ESO, nos topamos con un muro frustrante:

```
"error":"error processing spec.data[0] (key: HELLO_WORLD), err: not implemented - this provider supports write-only operations"
```

### Desentrañando la Revelación de "Solo Escritura"

Este mensaje de error fue una lección crítica. Aclaró una limitación fundamental del proveedor de GitHub Actions Secrets cuando se usa con un `ExternalSecret` (que está diseñado para *leer* secretos de una fuente externa). Aunque el proveedor de GitHub Actions de ESO *puede* enviar secretos *desde* Kubernetes *hacia* GitHub Actions (a través de un recurso `PushSecret`, como está documentado), **no es capaz de obtener (leer) secretos *desde* GitHub Actions *hacia* Kubernetes** usando un `ExternalSecret`. Esta distinción entre las capacidades de lectura y escritura, aunque sutil, cambió por completo nuestro enfoque.

Nuestra visión de usar GitHub Actions como un almacén central de secretos para el consumo del clúster era, al menos con ESO, inalcanzable. Esto significaba que tendría que usar una estrategia diferente para los secretos que se originan directamente en nuestro repositorio GitOps.

## El Pivote: Adoptando Sealed Secrets para el Cifrado Nativo en Git

Frente a esta limitación de "solo escritura", necesitaba una solución que nos permitiera confirmar de forma segura secretos cifrados directamente en nuestro repositorio Git, manteniendo al mismo tiempo nuestros principios de GitOps. Investigando otra solución llegué rápidamente a **Sealed Secrets**, un excelente proyecto de código abierto de Bitnami.

### Cómo Sealed Secrets Potencia El Flujo de Trabajo GitOps:

Sealed Secrets ofreció una solución robusta, segura y elegantemente simple:

1.  **Cifrado del Lado del Cliente:** Se usa la herramienta CLI `kubeseal` en nuestra máquina local. Esta herramienta toma un manifiesto `Secret` estándar de Kubernetes, lo cifra usando una clave pública proporcionada por el controlador de Sealed Secrets que se ejecuta en nuestro clúster, y genera un manifiesto `SealedSecret`. El punto crítico: el secreto en texto plano *nunca* abandona nuestro entorno local ni toca Git sin cifrar.
2.  **Almacenamiento Seguro en Git:** El manifiesto `SealedSecret` generado es ahora completamente seguro para ser confirmado en nuestro repositorio Git público o privado. Solo el controlador de Sealed Secrets en *nuestro clúster específico*, que posee la clave privada correspondiente, puede descifrarlo.
3.  **Descifrado Automatizado:** FluxCD detecta cambios en nuestro repositorio Git, aplica el recurso personalizado `SealedSecret` a nuestro clúster, y el controlador de Sealed Secrets lo descifra automáticamente de nuevo en un `Secret` estándar de Kubernetes. Nuestras aplicaciones consumen entonces este `Secret` descifrado como de costumbre.
4.  **Portabilidad sin Esfuerzo:** Los mismos manifiestos `SealedSecret` pueden aplicarse a cualquier clúster de Kubernetes donde el controlador de Sealed Secrets esté desplegado y tenga la clave privada correcta. Esto es absolutamente vital para nuestros futuros planes de replicación en la nube.
5.  **Simplicidad y Control:** Para los secretos que se originan directamente con nuestro equipo o se generan localmente, `kubeseal` proporciona una forma intuitiva de gestionarlos. Incluso encontramos una solución alternativa con `kubectl port-forward` y `curl` para obtener el certificado público cuando un `kubeseal --fetch-cert` directo se encontraba con un proxy.

Nuestro viaje implicó eliminar elegantemente los componentes de ESO, desplegar el controlador de Sealed Secrets a través de las capacidades Helm de FluxCD, dominar la CLI de `kubeseal` e integrar los manifiestos `SealedSecret` sin problemas en nuestras cadenas de Kustomization de GitOps existentes.

## Lecciones Aprendidas y el Futuro de la Resiliencia de B.E.L.E.N.

Esta experiencia fue un poderoso recordatorio de que la "mejor opción de GitOps" depende en gran medida de los casos de uso específicos y las capacidades de las herramientas. Aunque External Secrets Operator sigue siendo una solución potente para integrarse con sistemas de gestión de secretos dedicados, para incrustar secretos de forma segura directamente en nuestro repositorio Git, Sealed Secrets demostró ser la opción perfecta.

Esta solución fortalece significativamente la base del Proyecto B.E.L.E.N. para:

  * **Alta Disponibilidad:** Los secretos cifrados viven con nuestro código, permitiendo una recuperación rápida y automatizada.
  * **Preparación para la Nube:** Todo el flujo de trabajo de gestión de secretos es portable, allanando el camino para una fácil migración y replicación a cualquier proveedor de la nube.
  * **Seguridad:** Nuestros datos sensibles permanecen protegidos durante todo el ciclo de vida de GitOps.

Hemos aprendido a validar las suposiciones sobre las funcionalidades de las herramientas desde el principio y a adaptar nuestra arquitectura cuando nos enfrentamos a limitaciones inesperadas. Esta resolución iterativa de problemas está en el corazón de la construcción de sistemas robustos y resilientes.

Si eres un ingeniero apasionado por GitOps, las arquitecturas nativas de la nube y la resolución de complejos desafíos de infraestructura, ¡me encantaría conectar y compartir más sobre el Proyecto B.E.L.E.N. y nuestro viaje!

¡Estad atentos para más actualizaciones sobre el progreso de B.E.L.E.N.!

## Referencias

- [External Secrets Operator Documentation FluxCD](https://external-secrets.io/latest/examples/gitops-using-fluxcd/)
- [External Secrets Operator GitHub Provider](https://external-secrets.io/latest/provider/github/)
- [Sealed Secrets Repo](https://github.com/bitnami-labs/sealed-secrets)
- [FluxCD Sealed Secrets Integration](https://fluxcd.io/flux/guides/sealed-secrets/)