---
date: '2025-06-19T21:43:27+02:00'
draft: false
title: 'Homelab Nodes - A hardware decision'
author: 'Álvaro Huertas Díaz'
authorLink: 'https://www.linkedin.com/in/alvarohuertasdiaz/'
resources:
- name: "featured-image"
  src: "featured-image.png"
- name: "featured-image-preview"
  src: "featured-image-preview.png"

tags: ["B.E.L.E.N", "Hardware"]
---

# Why I Chose i7 Power Over N100 Efficiency for My Homelab Kubernetes Cluster

For anyone building a home Kubernetes cluster, the initial hardware choice is a classic dilemma. For weeks, I was deep in the debate: should I build my K8s cluster with multiple, low-power mini-PCs, or go for something with more muscle? The core tension was pitting modern, ultra-efficient Intel N100s against older, refurbished enterprise hardware. The main consideration, as always for a 24/7 homelab, was initial cost versus the long-term energy bill.

After much deliberation, the logical choice seemed to be the Intel N100 for its incredible power efficiency.

So, naturally, I went in a different direction. I bought four **Lenovo M900 Tiny** PCs, each sporting a powerful **Intel Core i7-6700T processor, 16GB of DDR4 RAM, and a 256GB SSD.**

This wasn't a reckless decision. It was a strategic one, prioritizing performance and thread count for a more capable and responsive Kubernetes environment. Let me explain why this was the right move for my specific cluster goals.

### Rethinking "Efficiency" for a Kubernetes Cluster

The initial debate focused heavily on one type of efficiency: power consumption in watts. This is a critical metric for any always-on server. The i7-6700T, with its 35W TDP, is undeniably thirstier than the 6W N100.

However, "efficiency" in a production-grade or serious lab environment isn't just about the electricity meter. For a Kubernetes cluster, efficiency is also about:

* **Deployment Speed:** How quickly can the cluster provision pods and services? How long do my CI/CD pipelines take to build and test container images?
* **Workload Performance:** Can a node handle demanding applications and resource spikes without hitting a CPU bottleneck? Can it run multiple services smoothly?
* **Learning Scope:** Will the hardware limit the complexity of the Kubernetes workloads I can run, forcing me to compromise my learning and experimentation goals?

This is where the i7-6700T's superior performance justifies the power consumption trade-off.

### The Hardware: Powering the Kubernetes Cluster: 4 Nodes as Lenovo M900s

Let's take a look at the heart of the Kubernetes cluster:

| Component | Specification |
| :--- | :--- |
| **Model** | Lenovo ThinkCentre M900 Tiny |
| **CPU** | Intel Core i7-6700T (4 Cores, **8 Threads**, up to 3.60 GHz) |
| **RAM** | 16GB DDR4 (Upgradeable to 32GB) |
| **Storage** | 256GB 2.5" SATA SSD (with M.2 NVMe slot available) |

Here’s a direct comparison of why this specific CPU is a game-changer for a Kubernetes host compared to the more efficient N100:

| Feature | Intel Core i7-6700T | Intel N100 | The Kubernetes Advantage |
| :--- | :--- | :--- | :--- |
| **Cores/Threads** | 4 Cores / **8 Threads** | 4 Cores / 4 Threads | **Hyper-Threading.** This is the killer feature. For container orchestration, where Kubernetes is constantly scheduling dozens of processes and pods, having twice the threads provides a massive performance uplift for multitasking and resource management. |
| **CPU Performance** | Higher single-thread and multi-thread scores. | Excellent for its low power envelope. | **Raw Power.** Benchmarks consistently show the i7-6700T outperforming the N100. This headroom is crucial for running more intensive workloads like GitLab runners, a private container registry (Harbor), or data-intensive applications without node pressure. |
| **RAM Capacity** | Easily supports 32GB. | Often limited to 16GB. | **Future-Proofing.** Starting with 16GB per node is a strong baseline for a Kubernetes cluster. Knowing I can easily jump to 32GB provides a clear and affordable upgrade path as the cluster's demands grow. |
| **Cost** | Excellent value on the refurbished market. | Great value brand new. | **Enterprise-Grade at a Discount.** These Lenovo Tinys are built like tanks for corporate environments. Getting this level of robust, reliable hardware for a price competitive with budget-oriented new PCs is a huge win for a stable homelab. |

### The Road Ahead: From Bare Metal to K8s

The hardware is racked and ready. The real fun of building the Kubernetes cluster is about to begin. The next steps will involve:

1.  **Initial Node Provisioning:** Getting all four Lenovo Tinys flashed, configured with a base OS (likely Debian or Ubuntu Server), and networked.
2.  **Kubernetes Installation:** Choosing and deploying a K8s distribution. I'm leaning towards K3s for its lightweight nature and simplicity, which is ideal for a homelab environment.
3.  **Cluster Networking & Storage:** Designing the CNI (Container Network Interface) strategy and implementing a persistent storage solution for stateful workloads using something like Rook-Ceph or Longhorn.

This journey is all about building a powerful and flexible Kubernetes homelab that won't limit my ambitions. By investing in capable hardware upfront, I've built a foundation that can handle anything I throw at it. Stay tuned as I turn this stack of mini-PCs into a fully functional container orchestration platform!