---
date: '2025-07-10T19:02:17+02:00'
draft: false
title: 'Project BELEN: From 3D Printing Chaos to a Clean Kubernetes Rack'
author: 'Álvaro Huertas Díaz'
authorLink: 'https://www.linkedin.com/in/alvarohuertasdiaz/'
resources:
- name: "featured-image"
  src: "featured-image.jpg"
- name: "featured-image-preview"
  src: "featured-image-preview.jpg"

tags: ["B.E.L.E.N", "Hardware", "Kubernetes", "3D Printing", "Homelab", "Bare Metal"]
---


In the last post, I laid out the "why" behind choosing four powerful Lenovo M900 Tiny PCs for my Kubernetes cluster. But a stack of mini-PCs on a desk isn't a proper lab; it's just a pile of hardware. The next critical phase of Project BELEN was to get this equipment mounted, powered, and organized in a professional 19" rack.

This part of the journey turned out to be a fantastic lesson in ambition versus reality, and the art of the strategic pivot.

### The Dream: A Fully 3D-Printed Rack

My initial vision was pure DIY. Why buy expensive metal mounts when I have a 3D printer? I thought I'd print four custom, full-sized trays for each of my Lenovo nodes. It was a terrific idea in theory. In practice, my Ender 3 had other plans.

This video says it all. My printer, whether through bad calibration or just a bad day, produced nothing but piles of black plastic spaghetti. It was a spectacular failure.

*(Video of the failed 3D print)*
\<video controls src="[https://storage.googleapis.com/gemini-prod/v1/d57059a444a706599b51829e28e19c34b679b392d477e38260477464a4d6f830](https://www.google.com/search?q=https://storage.googleapis.com/gemini-prod/v1/d57059a444a706599b51829e28e19c34b679b392d477e38260477464a4d6f830)" style="width: 100%;"\>\</video\>

After cleaning up heaps of tangled filament, I knew a full 3D-printed solution was off the table. It was time for Plan B.

-----

### The Pivot: A Hybrid of Bought and Built

If I couldn't print the whole shelf, I'd buy one. I went on Amazon and found this **Pyle 19" rack shelf**, rated for up to 50kg. Overkill for my little PCs, but perfect for peace of mind.

{{< image src="/images/rack-shelf.png" caption="1U rack shelf" width=800 >}}

With the main support sorted, my 3D printing ambition could be scaled back to something more manageable. Instead of a full tray, I'd print small, simple brackets just to keep the Lenovo nodes standing upright and neatly spaced on the shelf.

Of course, it couldn't be that easy. The first model I found online didn't account for the rubber feet on the bottom of the M900s. So, I had to fire up the design software and modify the model myself—a classic homelab task of adapting a solution to fit your specific hardware.

{{< image src="/images/3dprint-support.png" caption="3d printed doubled M900's support" width=600 >}}


-----

### Assembling the Command Center

With my mounting strategy sorted, it was time to build the core infrastructure. The heart of the setup is this **WP-RACK 6U wall-mounted cabinet**. It's compact enough to fit in the space I have but deep enough to allow for good airflow.

{{< image src="/images/WP-RACK_6U_wall-mounted_cabinet.png" caption="WP-RACK 6U wall-mounted cabinet" width=800 >}}

To kit it out, I made a "majestic" purchase on AliExpress for all the essential organizing goodies: a proper 19" Power Distribution Unit (PDU), brush panels for clean cable pass-through, velcro cable ties, and a set of super-short 30cm CAT6 ethernet cables to eliminate clutter...

{{< image src="/images/organizing-goodies.png" caption="Organizing goodies from AliExpress" width=800 >}}

-----

### The Final Touch: A Dedicated Power Station

Just when I thought the hardware phase was done, my father, ever the practical thinker, insisted on one more critical addition. To protect the cluster from power outages or surges, we installed a dedicated electrical box for the rack.

{{< image src="/images/electrical-box.png" caption="Dedicated electrical box with circuit breaker and differential protection" width=400 >}}

This gives the entire setup its own circuit breaker and differential protection, isolating it from the rest of the house's electrical system. It's a pro-level touch that ensures the hardware is safe.

-----

### The Reveal: From Chaos to Order

After days of mounting, printing, wiring, and a little bit of improvisation, we managed to get to the final result.

From tangled wires and failed prints to a clean, organized, and secure home for my Kubernetes nodes. The short cables and brush panel keep everything tidy, and the custom brackets hold the four main nodes perfectly.

Here’s a quick video tour of the rack, with the nodes booting up for the first time in their home. Previously to the cable management.

*(Video tour of the finished rack setup)*
\<video controls src="[https://storage.googleapis.com/gemini-prod/v1/159846b0a1d4b68e778619623e1f2f0175b5a79401aa99c5c9939e65839ff515](https://www.google.com/search?q=https://storage.googleapis.com/gemini-prod/v1/159846b0a1d4b68e778619623e1f2f0175b5a79401aa99c5c9939e65839ff515)" style="width: 100%;"\>\</video\>

And here's a beauty shot of the final, fully wired cabinet. The difference is night and day.

{{< image src="/images/final-rack-setup.jpeg" caption="Final rack setup with Lenovo nodes" width=800 >}}

### Next Steps

The physical build is complete\! The hardware is safe, secure, and ready for action. Now, the *real* fun begins. The next post will cover the bare-metal provisioning: installing the operating system on each node and preparing them to form the Kubernetes cluster. Stay tuned\!

\!([https://storage.googleapis.com/gemini-prod/v1/863618d3c267bd29b0577741d4f260195e263d8d646fd4e40292723091171887](https://www.google.com/search?q=https://storage.googleapis.com/gemini-prod/v1/863618d3c267bd29b0577741d4f260195e263d8d646fd4e40292723091171887))