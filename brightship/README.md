# BrightShip Tracker — From Infrastructure Audit to Kubernetes-Native Platform

A two-phase DevOps engagement: first auditing and stabilizing an undocumented, high-risk environment (Project 1), then scaling that foundation into a production-grade Kubernetes platform as the team and traffic grew (Project 2).

> This repository contains the infrastructure code, CI/CD configuration, Kubernetes manifests, operational documentation, and application configuration produced across both phases — built collaboratively with a team of mentees as part of the **Expadox DevOps Mentorship**.

---

## Phase 1: FirstResponse — Stabilizing the Foundation

### The situation

BrightShip Tracker, a Node.js/Express shipment-tracking API, had no documentation, no handover, and a manual SSH-based deployment process.

Credentials were committed to source control, staging and production shared the same database, and there was no monitoring or rollback capability.

### What we did

* Audited the full codebase and infrastructure, documenting security, infrastructure, and operational risks together with their potential blast radius.
* Rotated exposed credentials and moved secrets into **AWS Secrets Manager**.
* Replaced root-account usage with dedicated IAM users, tightened security groups, and enabled **AWS CloudTrail**.
* Imported existing AWS resources into **Terraform**, achieving a zero-diff plan against the live environment.
* Separated staging (**EC2 + Docker Compose + Portainer**) from production (**dedicated RDS instance**).
* Built a **GitHub Actions CI/CD pipeline**:

```text
Lint & Test
    ↓
Build & Tag Image
    ↓
Push to Registry
    ↓
Deploy to Staging
    ↓
Smoke Test
    ↓
Manual Approval
    ↓
Production Deploy
    ↓
Production Smoke Test
```

* Set up **CloudWatch monitoring and alerting**, together with a cost report for finance.

### Outcome

The environment moved from an undocumented and operationally risky setup to a documented, automated, monitored, and properly isolated foundation.

---

# Phase 2: ShipFast — Scaling to Kubernetes

### The situation

Six months later, BrightShip had grown from **8 to 20 engineers across 4 squads**, onboarded **3 enterprise clients**, and the application had grown from one service to three:

* `brightship-api`
* `brightship-jobs`
* `brightship-notify`

The Project 1 pipeline was struggling as squads collided in shared staging, while the CTO required a **99.9% uptime commitment** that the existing setup could not guarantee.

### What we did

* Stood up a dedicated **k3s Kubernetes cluster** for production, separate from the staging environment.
* Created Kubernetes manifests for all three services using **Deployments, Services, ConfigMaps, Secrets, resource limits, and liveness/readiness probes**.
* Installed **Headlamp** as a read-only dashboard so engineers could inspect cluster health without requiring direct `kubectl` access.
* Implemented **Argo CD** for GitOps-based production deployments using an Argo CD `Application` manifest that continuously synchronizes the Kubernetes manifests from Git with the production cluster.
* Expanded staging into **four isolated Portainer stacks**, one per squad, with dedicated Redis and database instances and pipeline routing based on branch naming conventions.
* Used **Claude** to generate a health-aggregation endpoint under time pressure, reviewed the generated code critically, identified a bug in its handling of a failed internal health check, fixed it, and shipped the change through the full pipeline.
* Documented the AI-assisted development process as a case study in **reviewing and validating AI-generated code**.
* Wrote operational runbooks covering likely failure scenarios including crash loops, failed webhook routing, and unresponsive nodes.
* Had runbooks peer-tested by team members who were not their original authors.

### Outcome

Production now runs on Kubernetes with automated GitOps deployment, each squad has an isolated staging environment, and the team can ship without depending on a single DevOps engineer for every change.

---

# My Contribution

I contributed across both phases, with a strong focus on **AWS infrastructure, CI/CD, Kubernetes, GitOps, and deployment troubleshooting**.

## Project 1 — FirstResponse

* Contributed to importing existing AWS infrastructure into **Terraform** and validating the resulting infrastructure state.
* Worked on the **GitHub Actions CI/CD pipeline**, including staging and production deployment workflows.
* Troubleshot deployment and smoke-test failures across AWS and the CI/CD pipeline.
* Worked with **EC2, security groups, CloudWatch, IAM, SSM, Docker, and Portainer**.
* Contributed to infrastructure and security improvements within the team's shared AWS environment.

## Project 2 — ShipFast

* Worked on the production **k3s Kubernetes environment**.
* Created and restored Kubernetes manifests for BrightShip workloads.
* Worked with **Deployments, Services, ConfigMaps, Secrets, namespaces, probes, and resource configuration**.
* Implemented and troubleshot the **Argo CD/GitOps** deployment setup.
* Configured and troubleshot **Headlamp access and Kubernetes RBAC**.
* Worked on production application configuration and the connection between Kubernetes workloads and **AWS RDS / Secrets Manager**.
* Troubleshot Kubernetes, container, deployment, and infrastructure issues during implementation.
* Coordinated with team members when changes affected shared infrastructure and helped verify deployments.

---

# Architecture

```text
                         GitHub
                           │
                           ▼
                    GitHub Actions
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
        Staging Environment       Production Environment
              │                         │
        Portainer / Docker              │
              │                         ▼
       ┌──────┼──────┐             k3s Cluster
       │      │      │                  │
     Squad  Squad  Squad               │
       A      B      C                  │
                                      Argo CD
                                         │
                         ┌───────────────┼───────────────┐
                         │               │               │
                         ▼               ▼               ▼
                   brightship-api  brightship-jobs  brightship-notify
                         │
                         ▼
                       AWS RDS
                         │
                         ▼
                  AWS Secrets Manager
```

---

# GitOps Flow

The production Kubernetes deployment follows a GitOps model:

```text
Developer pushes changes
          │
          ▼
       GitHub
          │
          ▼
     Argo CD detects
      repository change
          │
          ▼
   Kubernetes manifests
       are applied
          │
          ▼
    Production k3s
          │
          ▼
 Argo CD continuously
 maintains desired state
```

The Argo CD `Application` configuration defines the Git repository, target branch, Kubernetes manifest path, destination namespace, automated synchronization, pruning, and self-healing behaviour.

---

# Technology Stack

### Cloud & Infrastructure

`AWS` · `EC2` · `RDS` · `IAM` · `Secrets Manager` · `CloudTrail` · `CloudWatch`

### Infrastructure as Code

`Terraform`

### Containers

`Docker` · `Docker Compose` · `Portainer`

### Kubernetes

`Kubernetes` · `k3s` · `Argo CD` · `Headlamp`

### CI/CD

`GitHub Actions` · `GitHub Container Registry`

### Application

`Node.js` · `Express` · `PostgreSQL` · `Redis`

---

# Repository Structure

```text
brightship-tracker/
├── brightship/              # Application source
├── terraform/               # AWS infrastructure as code
├── k3s/                     # Kubernetes manifests
├── argocd/                  # Argo CD configuration
├── .github/workflows/       # CI/CD pipelines
├── database/                # Database schema
├── docs/                    # Documentation and architecture decisions
└── scripts/                 # Deployment and operational scripts
```

---

# Project Journey

```text
Project 1 — FirstResponse
        │
        ├── Infrastructure Audit
        ├── Security Improvements
        ├── Terraform
        ├── CI/CD
        ├── Staging / Production Separation
        └── Monitoring
                │
                ▼
Project 2 — ShipFast
        │
        ├── Kubernetes / k3s
        ├── Argo CD / GitOps
        ├── Multiple Application Services
        ├── Isolated Squad Staging
        ├── Operational Runbooks
        └── Kubernetes Observability
```

---

# What This Project Demonstrates

This project demonstrates practical experience with:

* Infrastructure as Code
* AWS infrastructure and security
* CI/CD automation
* Docker and containerized applications
* Kubernetes and k3s
* GitOps with Argo CD
* Kubernetes RBAC
* Secrets management
* Monitoring and alerting
* Production troubleshooting
* Infrastructure migration and stabilization
* Reviewing and validating AI-generated code
* Collaborative DevOps delivery

---

# Expadox DevOps Mentorship

This project was completed collaboratively as part of the **Expadox DevOps Mentorship**, with work distributed across multiple team members and squads.

The repository preserves the development history from both project phases, including the infrastructure, CI/CD, Kubernetes, GitOps, and deployment work contributed throughout the engagement.

