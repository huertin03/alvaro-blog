---
date: '2025-07-10T19:02:17+02:00'
draft: false
title: 'Infraestructura de BELEN: Del Caos de la Impresión 3D a un Rack de Kubernetes Limpio'
author: 'Álvaro Huertas Díaz'
authorLink: 'https://www.linkedin.com/in/alvarohuertasdiaz/'
resources:
- name: "featured-image"
  src: "featured-image.png"
- name: "featured-image-preview"
  src: "featured-image-preview.png"

tags: ["B.E.L.E.N", "Hardware", "Kubernetes", "Impresión 3D", "Homelab", "Bare Metal"]
---


En el último post, expuse el "porqué" de la elección de cuatro potentes mini PCs Lenovo M900 para mi clúster de Kubernetes. Pero una pila de mini-PCs en un escritorio no es un homelab en condiciones; es solo un montón de hardware. La siguiente fase crítica del Proyecto B.E.L.E.N. (Balanced Efficient Local Ephemeral Nodes) era montar, alimentar y organizar este equipo en un rack profesional de 19".

Esta parte del viaje resultó ser una fantástica lección sobre la ambición frente a la realidad, y el arte del pivote estratégico.

### El Sueño: Un Rack Impreso en 3D

Mi visión inicial era puramente DIY (hazlo tú mismo). ¿Por qué comprar caros soportes de metal cuando tengo una impresora 3D? Pensé en imprimir cuatro bandejas personalizadas de tamaño completo para cada uno de mis nodos Lenovo. Era una idea genial en teoría. En la práctica, mi Ender 3 tenía otros planes.

Este vídeo lo dice todo. Mi impresora, ya sea por una mala calibración o simplemente por un mal día, no produjo más que montones de espaguetis de plástico negro. Fue un fracaso espectacular.

{{< vimeo 1100419812 >}}

Después de limpiar montones de filamento enredado, supe que una solución completamente impresa en 3D estaba descartada. Era hora del Plan B.

-----

### El Pivote: Un Híbrido entre Comprado y Construido

Si no podía imprimir la bandeja entera, compraría una. Fui a Amazon y encontré esta **bandeja de rack Pyle de 19"**, con una capacidad de hasta 50 kg. Excesivo para mis pequeños PCs, pero perfecto para mi tranquilidad.

{{< image src="/images/rack-shelf.png" caption="Bandeja de rack 1U" width=800 >}}

Con el soporte principal solucionado, mi ambición de impresión 3D podía reducirse a algo más manejable. En lugar de una bandeja completa, imprimiría pequeños y simples soportes solo para mantener los nodos Lenovo en posición vertical y ordenadamente espaciados en la bandeja.

Por supuesto, no podía ser tan fácil. El primer modelo que encontré en línea no tenía en cuenta las patas de goma de la parte inferior de los M900. Así que tuve que abrir el software de diseño y modificar el modelo yo mismo, una tarea clásica de homelab de adaptar una solución para que se ajuste a tu hardware específico.

{{< image src="/images/3dprint-support.png" caption="Soporte doble impreso en 3D para los M900" width=600 >}}


-----

### Montando el Centro de Mando

Con mi estrategia de montaje resuelta, era hora de construir la infraestructura principal. El corazón de la configuración es este **armario de pared WP-RACK de 6U**. Es lo suficientemente compacto como para caber en el espacio que tengo, pero lo suficientemente profundo como para permitir un buen flujo de aire.

{{< image src="/images/WP-RACK_6U_wall-mounted_cabinet.png" caption="Armario de pared WP-RACK 6U" width=1000 >}}

Para equiparlo, hice una compra "majestuosa" en AliExpress de todos los elementos esenciales de organización: una regleta de alimentación (PDU) de 19" en condiciones, paneles de cepillo para un paso de cables limpio, bridas de velcro para cables y un juego de cables de red CAT6 súper cortos de 30 cm para eliminar el desorden...

{{< image src="/images/organizing-goodies.png" caption="Artículos de organización de AliExpress" width=800 >}}

-----

### El Toque Final: Una Estación de Energía Dedicada

Justo cuando pensaba que la fase de hardware había terminado, mi padre, siempre práctico, insistió en una adición crítica más. Para proteger el clúster de cortes de energía o sobretensiones, instalamos un cuadro eléctrico dedicado para el rack.

{{< image src="/images/electrical-box.png" caption="Cuadro eléctrico dedicado con interruptor automático y protección diferencial" width=400 >}}

Esto le da a toda la configuración su propio interruptor automático y protección diferencial, aislándola del resto del sistema eléctrico de la casa. Es un toque de nivel profesional que garantiza que el hardware esté seguro.

-----

### La Revelación: Del Caos al Orden

Después de días de montaje, impresión, cableado y un poco de improvisación, logramos llegar al resultado final.

De cables enredados e impresiones fallidas a un hogar limpio, organizado y seguro para mis nodos de Kubernetes. Los cables cortos y el panel de cepillo mantienen todo ordenado, y los soportes personalizados sujetan perfectamente los cuatro nodos principales.

Aquí hay un rápido vídeo tour del rack, con los nodos arrancando por primera vez en su hogar. Previo a la gestión del cableado.

{{< vimeo 1100424939 >}}

Y aquí una foto del armario final, completamente cableado. La diferencia es como la noche y el día.

{{< image src="/images/final-rack-setup.jpeg" caption="Configuración final del rack con los nodos Lenovo" width=800 >}}

### Próximos Pasos

¡La construcción física está completa! El hardware está seguro, protegido y listo para la acción. Ahora, comienza la diversión *de verdad*. El próximo post cubrirá la configuración del controlador de ingress que elegí para el clúster de Kubernetes. ¡Estad atentos!