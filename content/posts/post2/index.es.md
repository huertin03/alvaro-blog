---
date: '2025-06-19T21:43:27+02:00'
draft: false
title: 'Nodos del Homelab - Una decisión de hardware'
author: 'Álvaro Huertas Díaz'
authorLink: 'https://www.linkedin.com/in/alvarohuertasdiaz/'
resources:
- name: "featured-image"
  src: "featured-image.png"
- name: "featured-image-preview"
  src: "featured-image-preview.png"

tags: ["B.E.L.E.N", "Hardware"]
---

# Por qué Elegí la Potencia del i7 sobre la Eficiencia del N100 para el proyecto B.E.L.E.N.

Para cualquiera que esté construyendo su propio clúster de Kubernetes en casa, la elección inicial del hardware es un dilema clásico. Durante semanas, estuve sumergido en el debate: ¿debería construir mi clúster K8s con múltiples mini-PCs de bajo consumo, o apostar por algo con más músculo? La tensión principal era enfrentar los modernos y ultra-eficientes Intel N100 contra hardware empresarial más antiguo y reacondicionado. La consideración principal, como siempre para un homelab 24/7, era el costo inicial versus la factura energética a lo largo del tiempo.

Después de mucha deliberación, la elección lógica parecía ser el Intel N100 por su increíble eficiencia energética.

Así que, naturalmente, fui en una dirección diferente. Compré cuatro PCs **Lenovo M900 Tiny**, cada uno con un potente **procesador Intel Core i7-6700T, 16GB de RAM DDR4 y un SSD de 256GB.**

Esta no fue una decisión imprudente. Fue una decisión estratégica, priorizando el rendimiento y el número de hilos para un entorno Kubernetes más capaz y reactivo. Déjame explicar por qué esta fue la decisión correcta para mis objetivos específicos del clúster.

### Repensando la "Eficiencia"

El debate inicial se centró mucho en un tipo de eficiencia: el consumo de energía en vatios. Esta es una métrica crítica para cualquier servidor que esté siempre encendido. El i7-6700T, con su TDP de 35W, es innegablemente más demandante que el N100 de 6W.

Sin embargo, la "eficiencia" en un entorno de laboratorio serio o de grado de producción no se trata solo del medidor eléctrico. Para un clúster de Kubernetes, la eficiencia también se trata de:

* **Velocidad de Despliegue:** ¿Qué tan rápido puede el clúster aprovisionar pods y servicios? ¿Cuánto tardan mis pipelines de CI/CD en construir y probar imágenes de contenedores?
* **Rendimiento de Cargas de Trabajo:** ¿Puede un nodo manejar aplicaciones exigentes y picos de recursos sin llegar a un cuello de botella de CPU? ¿Puede ejecutar múltiples servicios sin problemas?
* **Alcance de Aprendizaje:** ¿Limitará el hardware la complejidad de las cargas de trabajo de Kubernetes que puedo ejecutar, forzándome a comprometer mis objetivos de aprendizaje y experimentación?

Aquí es donde el rendimiento superior del i7-6700T justifica el compromiso del consumo de energía.

### El Hardware que Alimenta el Clúster de Kubernetes

Echemos un vistazo al corazón del clúster de Kubernetes:

{{< image src="/images/4nodes.jpeg" caption="4 nodos Lenovo M900" width=400 >}}

| Componente | Especificación |
| :--- | :--- |
| **Modelo** | Lenovo ThinkCentre M900 Tiny |
| **CPU** | Intel Core i7-6700T (4 Núcleos, **8 Hilos**, hasta 3.60 GHz) |
| **RAM** | 16GB DDR4 (Ampliable a 32GB) |
| **Almacenamiento** | SSD SATA de 256GB 2.5" (con ranura M.2 NVMe disponible) |

Aquí hay una comparación directa de por qué esta CPU específica es un cambio de juego para un host de Kubernetes comparado con el más eficiente N100:

| Característica | Intel Core i7-6700T | Intel N100 | La Ventaja de Kubernetes |
| :--- | :--- | :--- | :--- |
| **Núcleos/Hilos** | 4 Núcleos / **8 Hilos** | 4 Núcleos / 4 Hilos | **Hyper-Threading.** Esta es la característica estrella. Para la orquestación de contenedores, donde Kubernetes está constantemente programando docenas de procesos y pods, tener el doble de hilos proporciona una mejora masiva de rendimiento para multitarea y gestión de recursos. |
| **Rendimiento de CPU** | Puntuaciones más altas de hilo único y multi-hilo. | Excelente para su bajo consumo de energía. | **Potencia Bruta.** Los benchmarks muestran consistentemente que el i7-6700T supera al N100. Este margen es crucial para ejecutar cargas de trabajo más intensivas como runners de GitLab, un registro privado de contenedores (Harbor), o aplicaciones intensivas en datos sin presión en el nodo. |
| **Capacidad de RAM** | Soporta fácilmente 32GB. | A menudo limitado a 16GB. | **Preparado para el Futuro.** Comenzar con 16GB por nodo es una línea base sólida para un clúster de Kubernetes. Saber que puedo saltar fácilmente a 32GB proporciona un camino de actualización claro y asequible a medida que crezcan las demandas del clúster. |
| **Costo** | Excelente valor en el mercado reacondicionado. | Gran valor nuevo. | **Grado Empresarial con Descuento.** Estos Lenovo Tiny están construidos como tanques para entornos corporativos. Obtener este nivel de hardware robusto y confiable por un precio competitivo con PCs nuevos orientados al presupuesto es una gran ventaja para un homelab estable. |

#### Nodo adicional: CHUWI

También añadiré un mini PC CHUWI con un Intel N100, 12 GB de RAM y 512 GB SSD de almacenamiento al clúster.

El que actualmente está ejecutando mi servidor doméstico.

{{< image src="/images/chuwi-node.jpeg" caption="CHUWI LarkBox X" width=400 >}}

#### Más Hardware

Raspberry Pi 3B como servidor DNS local:

{{< image src="/images/raspberry-pi.jpeg" caption="Raspberry Pi 3B" width=400 >}}

Cualquiera que sea este switch:

{{< image src="/images/switch.webp" caption="Switch" width=400 >}}

### El Camino Por Delante: De Bare Metal a K8s

El hardware listo. La verdadera diversión de construir el clúster de Kubernetes está a punto de comenzar. Los próximos pasos involucrarán:

1.  **Aprovisionamiento Inicial de Nodos:** Hacer que los cuatro Lenovo Tiny estén flasheados, configurados con un OS base (probablemente Debian o Ubuntu Server), y conectados en red.
2.  **Instalación de Kubernetes:** Elegir e implementar una distribución de K8s. Me inclino hacia K3s por su naturaleza ligera y simplicidad, que es ideal para un entorno de homelab.
3.  **Redes y Almacenamiento del Clúster:** Diseñar la estrategia CNI (Container Network Interface) e implementar una solución de almacenamiento persistente para cargas de trabajo con estado usando algo como Rook-Ceph o Longhorn.

Este viaje se trata de construir un homelab de Kubernetes potente y flexible que no limite mis ambiciones. Al invertir en hardware capaz desde el principio, he construido una base que puede manejar cualquier cosa que le lance. ¡Mantente atento mientras convierto esta pila de mini-PCs en una plataforma de orquestación de contenedores completamente funcional!