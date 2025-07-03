---
date: '2025-07-03T18:59:27+02:00'
draft: false
title: 'Cloud-Ready Secrets for High Availability'
author: 'Álvaro Huertas Díaz'
authorLink: 'https://www.linkedin.com/in/alvarohuertasdiaz/'
resources:
- name: "featured-image"
  src: "featured-image.png"
- name: "featured-image-preview"
  src: "featured-image-preview.png"

tags: ["B.E.L.E.N", "Kubernetes", "GitOps", "Secrets Management", "Security"]
---

## From Homelab to Cloud: The Quest for Uninterrupted Operations

Hey there, fellow tech explorers and aspiring innovators\! Welcome back to my personal blog, where I chronicle my deep dives into IT challenges and share the progress on **Project B.E.L.E.N. (Balanced Efficient Local Ephemeral Nodes)**. Today, I'm pulling back the curtain on a recent, crucial architectural decision: how we're externalizing secrets to ensure high availability and enable seamless replication of our cluster onto a cloud provider in the future. This isn't just about homelab tinkering; it's about building a robust, production-grade foundation.

Our vision for B.E.L.E.N. extends far beyond a single-point-of-failure setup. We're striving for a truly resilient Kubernetes environment. This means our applications must remain operational even in the face of significant outages, whether it's a single node failure or the entire homelab going offline. The key to this resilience lies in being able to rapidly spin up an identical cluster, anywhere – be it a new physical server or an instance in the cloud – and have our applications resume with zero-touch configuration.

For this ambitious goal, secrets (API keys, database credentials, TLS certificates) cannot be an afterthought. They must be:

  * **Version-Controlled & Auditable:** Changes tracked, history preserved.
  * **Automated:** Deployed without manual intervention, eliminating human error.
  * **Portable:** Work identically across diverse environments (homelab, cloud, dev).
  * **Secure:** Absolutely no plaintext secrets in our Git repository.

This demanding set of requirements led us straight to the heart of **GitOps**, making our Git repository the indisputable single source of truth for all cluster configurations, including sensitive data.

## The Best GitOps Secret Management? A Detour Through the Write-Only Wall

With GitOps as our guiding principle, we began exploring the Kubernetes ecosystem for a robust secret management solution. Our initial excitement centered around **External Secrets Operator (ESO)**. ESO is a fantastic tool designed to fetch secrets from various external secret management systems (like HashiCorp Vault, AWS Secrets Manager, Azure Key Vault, etc.) and synchronize them into native Kubernetes `Secret` objects. This seemed like the perfect fit for "externalizing" our secrets.

Given our reliance on GitHub for our GitOps repository, the **GitHub Actions Secrets provider** for ESO immediately caught our attention. The promise was alluring: store our sensitive `HELLO_WORLD` secret directly within GitHub Actions, and let ESO pull it down into our Kubernetes cluster, creating a standard `Secret` that our applications could consume. It felt like a perfectly integrated solution.

We meticulously followed the setup, creating a GitHub App, generating private keys, configuring the `ClusterSecretStore` in Kubernetes, and defining our `ExternalSecret` resource to reference the `HELLO_WORLD` secret in GitHub Actions. FluxCD, our chosen GitOps orchestrator, diligently applied all these manifests to the cluster.

However, when we checked the status of our `ExternalSecret` and delved into the ESO controller logs, we hit a frustrating wall:

```
"error":"error processing spec.data[0] (key: HELLO_WORLD), err: not implemented - this provider supports write-only operations"
```

### Unpacking the "Write-Only" Revelation

This error message was a critical lesson. It clarified a fundamental limitation of the GitHub Actions Secrets provider when used with an `ExternalSecret` (which is designed to *read* secrets from an external source). While ESO's GitHub Actions provider *can* push secrets *from* Kubernetes *to* GitHub Actions (via a `PushSecret` resource, as documented), it is **not capable of pulling (reading) secrets *from* GitHub Actions *into* Kubernetes** using an `ExternalSecret`. This distinction between read and write capabilities, though subtle, completely changed our approach.

Our vision of using GitHub Actions as a central secret store for cluster consumption was, at least with ESO, unattainable. This meant we needed a different strategy for secrets that originate directly within our GitOps repository.

## The Pivot: Embracing Sealed Secrets for Git-Native Encryption

Faced with this "write-only" limitation, we needed a solution that would allow us to safely commit encrypted secrets directly into our Git repository while maintaining our GitOps principles. Our research swiftly led us to **Sealed Secrets**, an excellent open-source project from Bitnami.

### How Sealed Secrets Powers Our GitOps Workflow:

Sealed Secrets offered a robust, secure, and elegantly simple solution:

1.  **Client-Side Encryption:** We use the `kubeseal` CLI tool on our local machine. This tool takes a standard Kubernetes `Secret` manifest, encrypts it using a public key provided by the Sealed Secrets controller running in our cluster, and outputs a `SealedSecret` manifest. The critical point: the plaintext secret *never* leaves our local environment or touches Git unencrypted.
2.  **Secure Git Storage:** The generated `SealedSecret` manifest is now completely safe to commit to our public or private Git repository. Only the Sealed Secrets controller in *our specific cluster*, possessing the corresponding private key, can decrypt it.
3.  **Automated Decryption:** FluxCD detects changes in our Git repository, applies the `SealedSecret` custom resource to our cluster, and the Sealed Secrets controller automatically decrypts it back into a standard Kubernetes `Secret`. Our applications then consume this decrypted `Secret` as usual.
4.  **Effortless Portability:** The same `SealedSecret` manifests can be applied to any Kubernetes cluster where the Sealed Secrets controller is deployed and holds the correct private key. This is absolutely vital for our future cloud replication plans.
5.  **Simplicity & Control:** For secrets that originate directly with our team or are generated locally, `kubeseal` provides an intuitive way to manage them. We even worked through a `kubectl port-forward` and `curl` workaround to fetch the public certificate when a direct `kubeseal --fetch-cert` hit a proxy.

Our journey involved gracefully removing the ESO components, deploying the Sealed Secrets controller via FluxCD's Helm capabilities, mastering the `kubeseal` CLI, and integrating the `SealedSecret` manifests seamlessly into our existing GitOps Kustomization chains.

## Lessons Learned and the Future of B.E.L.E.N.'s Resilience

This experience was a powerful reminder that "best GitOps option" is highly dependent on specific use cases and tool capabilities. While External Secrets Operator remains a powerful solution for integrating with dedicated secret management systems, for securely embedding secrets directly into our Git repository, Sealed Secrets proved to be the perfect fit.

This solution significantly strengthens Project B.E.L.E.N.'s foundation for:

  * **High Availability:** Encrypted secrets live with our code, enabling rapid, automated recovery.
  * **Cloud Readiness:** The entire secret management workflow is portable, paving the way for easy migration and replication to any cloud provider.
  * **Security:** Our sensitive data remains protected throughout the GitOps lifecycle.

We've learned to validate assumptions about tool functionalities early and adapt our architecture when faced with unexpected limitations. This iterative problem-solving is at the heart of building robust, resilient systems.

If you're an engineer passionate about GitOps, cloud-native architectures, and solving complex infrastructure challenges, I'd love to connect and share more about Project B.E.L.E.N. and our journey\!

Stay tuned for more updates on B.E.L.E.N.'s progress\!

## References

- [External Secrets Operator Documentation FluxCD](https://external-secrets.io/latest/examples/gitops-using-fluxcd/)
- [External Secrets Operator GitHub Provider](https://external-secrets.io/latest/provider/github/)
- [Sealed Secrets Repo](https://github.com/bitnami-labs/sealed-secrets)
- [FluxCD Sealed Secrets Integration](https://fluxcd.io/flux/guides/sealed-secrets/)