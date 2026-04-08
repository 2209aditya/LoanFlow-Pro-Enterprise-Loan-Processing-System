<div align="center">

```
██╗      ██████╗  █████╗ ███╗   ██╗███████╗██╗      ██████╗ ██╗    ██╗    ██████╗ ██████╗  ██████╗
██║     ██╔═══██╗██╔══██╗████╗  ██║██╔════╝██║     ██╔═══██╗██║    ██║    ██╔══██╗██╔══██╗██╔═══██╗
██║     ██║   ██║███████║██╔██╗ ██║█████╗  ██║     ██║   ██║██║ █╗ ██║    ██████╔╝██████╔╝██║   ██║
██║     ██║   ██║██╔══██║██║╚██╗██║██╔══╝  ██║     ██║   ██║██║███╗██║    ██╔═══╝ ██╔══██╗██║   ██║
███████╗╚██████╔╝██║  ██║██║ ╚████║██║     ███████╗╚██████╔╝╚███╔███╔╝    ██║     ██║  ██║╚██████╔╝
╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝     ╚══════╝ ╚═════╝  ╚══╝╚══╝     ╚═╝     ╚═╝  ╚═╝ ╚═════╝
```

# ✦ LoanFlow Pro Enterprise ✦
### Cloud-Native Loan Processing Platform — Azure DevOps Edition

---

[![Build Status](https://img.shields.io/azure-devops/build/loanflowpro/LoanFlow-Pro/1?style=for-the-badge&logo=azure-devops&color=0078D4&label=PROD%20BUILD)](https://dev.azure.com/loanflowpro)
[![Release](https://img.shields.io/azure-devops/release/loanflowpro/1/1/1?style=for-the-badge&logo=azure-devops&color=107C10&label=RELEASE)](https://dev.azure.com/loanflowpro)
[![Coverage](https://img.shields.io/badge/COVERAGE-94%25-brightgreen?style=for-the-badge&logo=sonarqube)](https://sonarqube.loanflowpro.com)
[![Security](https://img.shields.io/badge/SECURITY-A%2B-00B388?style=for-the-badge&logo=owasp)](https://security.loanflowpro.com)
[![Uptime](https://img.shields.io/badge/UPTIME-99.99%25-success?style=for-the-badge&logo=azure)](https://status.loanflowpro.com)
[![IaC](https://img.shields.io/badge/IaC-TERRAFORM%201.7-7B42BC?style=for-the-badge&logo=terraform)](https://terraform.io)
[![License](https://img.shields.io/badge/LICENSE-PROPRIETARY-red?style=for-the-badge)](LICENSE)

</div>

---

## 📋 Table of Contents

| Section | Description |
|---------|-------------|
| [🏛️ Architecture Overview](#-architecture-overview) | High-level system design |
| [🌍 Multi-Environment Strategy](#-multi-environment-strategy) | Dev → UAT → PreProd → Prod → DR |
| [🏗️ Infrastructure Setup](#️-infrastructure-setup) | Azure resources & Terraform IaC |
| [🔄 CI/CD Pipelines](#-cicd-pipelines) | Azure DevOps pipeline reference |
| [🛡️ Disaster Recovery](#️-disaster-recovery) | DR strategy, RTO/RPO, runbook |
| [🔐 Security & Compliance](#-security--compliance) | Security controls & standards |
| [📊 Monitoring & Alerting](#-monitoring--alerting) | Observability stack |
| [🚀 Getting Started](#-getting-started) | Onboarding guide |
| [📁 Project Structure](#-project-structure) | Repository layout |
| [👥 Team & Contacts](#-team--contacts) | Ownership & escalation |

---

## 🏛️ Architecture Overview

LoanFlow Pro is a **cloud-native, enterprise-grade** loan processing platform built for scale, resilience, and compliance. The platform processes millions of loan applications with sub-second response times and 99.99% availability.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LOANFLOW PRO — AZURE ARCHITECTURE                   │
│                                                                              │
│   Clients          Global Edge              Primary (East US 2)              │
│  ─────────     ──────────────────    ──────────────────────────────────     │
│  Web App  ──►  Azure Front Door  ──► App Gateway (WAF v2)                   │
│  Mobile   ──►  (CDN + WAF + TLS)     │                                      │
│  Partners                            ▼                                      │
│                                  AKS Cluster ◄── Azure Container Registry   │
│                                  ├── API Pods (4-20)                        │
│                                  ├── Worker Pods (2-10)                     │
│                                  └── Scheduler Pods (2)                     │
│                                      │                                      │
│                              ┌───────┼───────┐                              │
│                              ▼       ▼       ▼                              │
│                            SQL DB  Redis   Blob                             │
│                           (BC Gen5) (P2)  Storage                          │
│                              │                                              │
│                    ┌─────────┘  Geo-Replication                            │
│                    │                                                        │
│               DR (West US 2)                                                │
│              ─────────────                                                  │
│              AKS (Warm Standby) → SQL Secondary → Redis Replica             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Core Azure Services

| Service | Purpose | SKU (Prod) |
|---------|---------|------------|
| **Azure Kubernetes Service** | Container orchestration | Standard Tier, 3 AZs |
| **Azure SQL Database** | Primary transactional DB | Business Critical Gen5 8vCores |
| **Azure Cache for Redis** | Session & application cache | Premium P2 |
| **Azure Container Registry** | Image registry | Premium (geo-replicated) |
| **Azure Key Vault** | Secrets & certificate management | Premium |
| **Azure Front Door** | Global load balancer + CDN + WAF | Standard |
| **Azure Application Gateway** | Regional ingress + WAF | WAF_v2 |
| **Azure Monitor + Log Analytics** | Observability | Per-GB pricing |
| **Azure Bastion** | Secure VM access | Standard |
| **Azure Blob Storage** | File storage | GZRS |
| **Azure Service Bus** | Async messaging | Premium |

---

## 🌍 Multi-Environment Strategy

LoanFlow Pro maintains **5 isolated environments**, each with dedicated infrastructure, access controls, and pipeline gates.

```
  ┌─────────┐     ┌─────────┐     ┌──────────┐     ┌──────────┐
  │   DEV   │────►│   UAT   │────►│ PRE-PROD │────►│   PROD   │
  │ feature/*│    │release/*│    │release/* │    │  main    │
  │Auto-deploy│   │QA Apprvl│    │RM+Sec OK │    │ Dual OK  │
  └─────────┘     └─────────┘     └──────────┘     └──────────┘
                                                          │
                                                          │ Geo-Replication
                                                          ▼
                                                     ┌──────────┐
                                                     │    DR    │
                                                     │ westus2  │
                                                     │ Manual   │
                                                     └──────────┘
```

### Environment Comparison

| Attribute | DEV | UAT | PRE-PROD | PROD | DR |
|-----------|-----|-----|----------|------|-----|
| **Branch** | `feature/*`, `develop` | `release/*` | `release/*` (post-UAT) | `main` | Manual |
| **Region** | East US 2 | East US 2 | East US 2 | East US 2 | **West US 2** |
| **AKS Nodes (App)** | 1–4 | 2–8 | 3–12 | 4–20 | 2–20 |
| **SQL SKU** | GP Gen5 2 | GP Gen5 4 | BC Gen5 4 | **BC Gen5 8** | BC Gen5 8 |
| **Redis SKU** | Basic C0 | Standard C1 | Premium P1 | **Premium P2** | Premium P2 |
| **Auto-scaling** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Geo-redundancy** | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Approval Gates** | None | QA Lead | RM + Security | CTO + Platform | Incident Cmdr |
| **Log Retention** | 30 days | 60 days | 90 days | **365 days** | 365 days |
| **VNET CIDR** | 10.13.0.0/16 | 10.12.0.0/16 | 10.11.0.0/16 | 10.10.0.0/16 | 10.20.0.0/16 |
| **Cost Profile** | Low 💚 | Medium 💛 | High 🟠 | Maximum 🔴 | Standby 🟡 |

### Promotion Flow
```
Developer pushes → feature/* ──(auto)──► DEV
                                          │
QA branch created → release/* ──(QA)──► UAT
                                          │
UAT sign-off ──(RM + Security)──────► PRE-PROD
                                          │
Load test + security pass ──(dual)──► PROD
```

---

## 🏗️ Infrastructure Setup

All infrastructure is managed as **code using Terraform** with remote state stored in Azure Storage.

### Prerequisites

```bash
# Required tools
terraform >= 1.7.0
azure-cli >= 2.58.0
kubectl >= 1.29
helm >= 3.14
```

### First-Time Setup

```bash
# 1. Authenticate with Azure
az login
az account set --subscription "LoanFlow-Pro-Prod"

# 2. Create Terraform state storage (one-time per subscription)
az group create --name rg-loanflow-tfstate --location eastus2
az storage account create \
  --name loanflowtfstateprod \
  --resource-group rg-loanflow-tfstate \
  --sku Standard_GRS \
  --encryption-services blob

az storage container create \
  --name tfstate \
  --account-name loanflowtfstateprod

# 3. Initialize Terraform for an environment
cd infra/terraform
terraform init \
  -backend-config="resource_group_name=rg-loanflow-tfstate" \
  -backend-config="storage_account_name=loanflowtfstateprod" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=prod/terraform.tfstate"

# 4. Plan & Apply
terraform plan -var-file="environments/prod/terraform.tfvars" -out=prod.tfplan
terraform apply prod.tfplan
```

### Deploying Each Environment

```bash
# DEV
terraform workspace new dev
terraform apply -var-file="environments/dev/terraform.tfvars"

# UAT
terraform workspace new uat
terraform apply -var-file="environments/uat/terraform.tfvars"

# PRE-PROD
terraform workspace new preprod
terraform apply -var-file="environments/preprod/terraform.tfvars"

# PROD
terraform workspace new prod
terraform apply -var-file="environments/prod/terraform.tfvars"

# DR (deployed to West US 2)
terraform workspace new dr
terraform apply -var-file="environments/dr/terraform.tfvars"
```

### Terraform Module Structure

```
infra/terraform/
├── main.tf                          # Root orchestration
├── variables.tf                     # Input variable definitions
├── outputs.tf                       # Output values
├── modules/
│   ├── aks/                         # AKS cluster + node pools
│   ├── acr/                         # Container registry
│   ├── networking/                  # VNet, subnets, NSGs, Bastion
│   ├── sql/                         # Azure SQL + failover groups
│   ├── redis/                       # Redis cache + geo-replication
│   ├── keyvault/                    # Key Vault + access policies
│   └── monitoring/                  # Log Analytics + alerts
└── environments/
    ├── dev/terraform.tfvars
    ├── uat/terraform.tfvars
    ├── preprod/terraform.tfvars
    ├── prod/terraform.tfvars
    └── dr/terraform.tfvars
```

### Networking Architecture

```
VNet: 10.10.0.0/16 (PROD example)
├── snet-aks          10.10.1.0/22    ← AKS node pool
├── snet-appgw        10.10.8.0/27    ← Application Gateway
├── snet-privateep    10.10.9.0/27    ← Private Endpoints (SQL, Redis, KV)
├── AzureBastionSubnet 10.10.10.0/27  ← Bastion Host
└── snet-management   10.10.11.0/27   ← DevOps agents / tooling
```

All data services connect via **Private Endpoints** — zero public exposure.

---

## 🔄 CI/CD Pipelines

### Pipeline Overview

```
┌──────────────────────────────────────────────────────────────────────────┐
│                     AZURE DEVOPS PIPELINE ARCHITECTURE                    │
│                                                                            │
│  dev-pipeline.yml     uat-pipeline.yml    preprod-pipeline.yml            │
│  ─────────────────    ───────────────     ───────────────────             │
│  Trigger: feature/*   Trigger: release/*  Trigger: manual/UAT done       │
│  Gate: none           Gate: QA Lead       Gate: RM + Security            │
│  Deploy: auto         Deploy: after gate  Deploy: after gate              │
│                                                     │                     │
│                              prod-pipeline.yml ◄────┘                    │
│                              ───────────────────                          │
│                              Trigger: main                                │
│                              Gate: CTO + Platform Lead                    │
│                              Strategy: Rolling + smoke tests              │
│                              Rollback: Automatic on failure               │
│                                                                            │
│  dr-failover-pipeline.yml   (separate, manual-only)                      │
│  ─────────────────────────                                                │
│  Gate: Incident Commander   Stages: DB → App → DNS cutover               │
└──────────────────────────────────────────────────────────────────────────┘
```

### Pipeline Files

| File | Environment | Trigger | Approval |
|------|-------------|---------|----------|
| `cicd/pipelines/dev-pipeline.yml` | DEV | `feature/*`, `develop` | None |
| `cicd/pipelines/uat-pipeline.yml` | UAT | `release/*` | QA Lead |
| `cicd/pipelines/preprod-pipeline.yml` | PRE-PROD | Manual / UAT complete | Release Mgr + Security |
| `cicd/pipelines/prod-pipeline.yml` | PROD | `main` | CTO + Platform Lead |
| `cicd/pipelines/dr-failover-pipeline.yml` | DR | **Manual only** | Incident Commander |

### Production Pipeline Stages

```
BUILD ──► SECURITY SCAN ──► INFRA VALIDATE ──► [APPROVAL] ──► DEPLOY ──► VERIFY
  │            │                  │                               │           │
  │        SonarQube           Terraform                       Helm        Smoke
  │        OWASP Dep         Plan (no apply)                  Upgrade     Tests
  │        Trivy Scan                                          Rolling     
  │                                                            Update      
  └──────────────────── Blocks on failure ──────────────────────────────────┘
```

### Setting Up Azure DevOps

```bash
# 1. Create service connections for each environment
az devops service-endpoint create \
  --organization https://dev.azure.com/loanflowpro \
  --project LoanFlow-Pro \
  --service-endpoint-configuration service-connections/prod-connection.json

# 2. Create variable groups (in Azure DevOps UI or CLI)
az pipelines variable-group create \
  --name loanflow-prod-secrets \
  --variables TEAMS_WEBHOOK_URL=<webhook> \
              SQL_ADMIN_PASSWORD=<password>

# 3. Create environments with approval gates
# Azure DevOps → Pipelines → Environments → New
# Add "Approvals" check with required approvers per environment

# 4. Import pipelines
az pipelines create \
  --name LoanFlow-Prod-Pipeline \
  --yml-path cicd/pipelines/prod-pipeline.yml \
  --repository LoanFlow-Pro
```

### Deployment Strategy Details

**Production uses Rolling Update:**
- `maxSurge: 1` — one extra pod at a time
- `maxUnavailable: 0` — zero downtime guaranteed
- `--atomic` — auto-rollback on Helm failure
- 5-minute post-deploy monitoring window

**Auto-rollback triggers:**
- Helm deployment timeout
- Smoke test failure
- Pod crash loop detected

---

## 🛡️ Disaster Recovery

### DR At a Glance

| Metric | Target | Notes |
|--------|--------|-------|
| **RTO** | **4 hours** | From incident declaration to full service restoration |
| **RPO** | **1 hour** | Maximum data loss window |
| **DR Tier** | Tier 1 — Business Critical | |
| **Strategy** | Active-Passive Warm Standby | |
| **Failover** | Semi-automatic (pipeline-assisted) | |
| **Data Sync** | Continuous (SQL Failover Group) | ≤30s replication lag |

### DR Activation (Summary)

```bash
# EMERGENCY: Run DR pipeline (requires Incident Commander approval)
# Azure DevOps → Pipelines → dr-failover-pipeline.yml
# Parameters:
#   failoverType: emergency
#   confirmDR: CONFIRM

# The pipeline automates:
# 1. SQL Failover Group promotion (DR → Primary)
# 2. Redis unlink (DR → Standalone primary)
# 3. AKS scale-up in West US 2
# 4. Application deployment to DR AKS
# 5. Azure Front Door traffic cutover
# 6. Smoke test validation
# 7. Stakeholder notification
```

### DR Testing Schedule

| Test | Frequency | Owner |
|------|-----------|-------|
| DR Smoke Test (non-disruptive) | Weekly | Platform Engineering |
| Database Failover Test | Quarterly | DBA Team |
| Full DR Exercise (planned failover) | Bi-annually | All Teams |
| Tabletop Scenario | Annually | Leadership |

Full runbook: [`dr/DR-STRATEGY.md`](dr/DR-STRATEGY.md)

---

## 🔐 Security & Compliance

### Security Controls

| Control | Implementation |
|---------|----------------|
| **Identity** | Azure AD + Managed Identities (no passwords in code) |
| **Secrets** | Azure Key Vault (Premium, HSM-backed) |
| **Network** | Private Endpoints, NSGs, no public DB/Cache endpoints |
| **Container** | Trivy scan in pipeline; ACR quarantine enabled |
| **Code** | SonarQube SAST + OWASP Dependency Check per build |
| **API** | WAF (OWASP 3.2 rules) on Front Door + App Gateway |
| **TLS** | TLS 1.3 minimum, auto-renew via Key Vault |
| **RBAC** | Least-privilege per environment; Kubernetes RBAC enforced |
| **Audit** | All Key Vault + management plane activity logged |
| **Compliance** | SOC 2 Type II, PCI-DSS Level 1 aligned |

### Access Model

```
Developers      → DEV only (reader on UAT/higher)
QA Engineers    → DEV + UAT
Release Mgr     → DEV + UAT + PreProd
Platform Eng    → All environments (PIM-gated for Prod)
Security        → Read-only all environments + security tools
SRE On-call     → Break-glass Prod access (audited, time-limited)
```

---

## 📊 Monitoring & Alerting

### Observability Stack

```
Application ──► App Insights ──► Log Analytics Workspace
                    │                      │
              Custom Metrics           Azure Monitor
              Distributed Traces       Workbooks
              Live Metrics             Dashboards
                    │                      │
              Alert Rules ──────────► Action Groups
                                           │
                              ┌────────────┼────────────┐
                              ▼            ▼            ▼
                           Email       Teams        PagerDuty
                           (P3-P4)   (P2-P3)     (P1 Critical)
```

### Alert Thresholds (Production)

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| API Response Time (p95) | > 500ms | > 2s | PagerDuty P2 |
| Error Rate | > 1% | > 5% | PagerDuty P1 |
| Pod Restart Count | > 3/hr | > 10/hr | Teams alert |
| CPU Utilization | > 70% | > 90% | Auto-scale + alert |
| Memory Utilization | > 75% | > 90% | Teams alert |
| SQL DTU Usage | > 70% | > 90% | DBA alert |
| Failed Logins | > 10/min | > 50/min | Security alert |

### Dashboards

- **Production Health**: [Azure Monitor Workbook](https://portal.azure.com/#workbooks)
- **Cost Dashboard**: Azure Cost Management
- **Security Dashboard**: Microsoft Defender for Cloud
- **DR Status**: Custom workbook in `monitoring/workbooks/dr-status.json`

---

## 🚀 Getting Started

### Developer Onboarding

```bash
# 1. Clone the repository
git clone https://dev.azure.com/loanflowpro/LoanFlow-Pro/_git/devops-infra
cd LoanFlow-Pro

# 2. Install required tools
brew install terraform azure-cli kubectl helm  # macOS
# OR: winget install Hashicorp.Terraform Microsoft.AzureCLI  # Windows

# 3. Login and set subscription
az login
az account set --subscription "LoanFlow-Pro-Dev"

# 4. Get AKS credentials for DEV
az aks get-credentials \
  --resource-group rg-loanflow-pro-dev-main \
  --name aks-loanflow-pro-dev

# 5. Verify cluster access
kubectl get nodes
kubectl get pods -n loanflow-dev

# 6. Run a deployment (DEV)
helm upgrade loanflow-api helm/loanflow-pro \
  --install \
  --namespace loanflow-dev \
  --set image.tag=latest \
  --values helm/loanflow-pro/values-dev.yaml
```

### Running Infrastructure Locally

```bash
# Validate Terraform for DEV
cd infra/terraform
terraform init -backend=false
terraform validate
terraform plan -var-file="environments/dev/terraform.tfvars"
```

### Triggering Pipelines

```bash
# Trigger DEV pipeline manually
az pipelines run --name "LoanFlow-Dev-Pipeline" \
  --branch develop

# Queue UAT pipeline
az pipelines run --name "LoanFlow-UAT-Pipeline" \
  --branch release/1.2.0

# PROD deploy (requires approvals in Azure DevOps UI)
az pipelines run --name "LoanFlow-Prod-Pipeline" \
  --branch main
```

---

## 📁 Project Structure

```
LoanFlow-Pro/                          ← DevOps Repository Root
│
├── 📂 .azure/
│   ├── pipelines/                     ← Shared pipeline templates
│   └── templates/                     ← Reusable YAML templates
│
├── 📂 cicd/
│   ├── pipelines/
│   │   ├── dev-pipeline.yml           ← DEV CI/CD (auto-deploy)
│   │   ├── uat-pipeline.yml           ← UAT CI/CD (QA gate)
│   │   ├── preprod-pipeline.yml       ← PreProd CI/CD (dual gate)
│   │   ├── prod-pipeline.yml          ← PROD CI/CD (approval + rollback)
│   │   └── dr-failover-pipeline.yml   ← DR failover (manual, IC gate)
│   ├── templates/                     ← Shared job/step templates
│   └── scripts/                       ← Pipeline helper scripts
│
├── 📂 infra/
│   └── terraform/
│       ├── main.tf                    ← Root module
│       ├── variables.tf               ← Variable definitions
│       ├── outputs.tf                 ← Outputs
│       ├── modules/
│       │   ├── aks/                   ← AKS cluster module
│       │   ├── acr/                   ← Container registry module
│       │   ├── networking/            ← VNet, subnets, NSGs
│       │   ├── sql/                   ← Azure SQL + failover
│       │   ├── redis/                 ← Redis + geo-replication
│       │   ├── keyvault/              ← Key Vault module
│       │   └── monitoring/            ← Log Analytics + alerts
│       └── environments/
│           ├── dev/terraform.tfvars
│           ├── uat/terraform.tfvars
│           ├── preprod/terraform.tfvars
│           ├── prod/terraform.tfvars
│           └── dr/terraform.tfvars
│
├── 📂 environments/
│   ├── dev/                           ← DEV k8s configs / Helm values
│   ├── uat/                           ← UAT configs
│   ├── preprod/                       ← PreProd configs
│   ├── prod/                          ← Prod configs
│   └── dr/                            ← DR configs
│
├── 📂 dr/
│   ├── DR-STRATEGY.md                 ← Full DR strategy & runbook
│   ├── runbooks/                      ← Step-by-step incident runbooks
│   └── scripts/                       ← DR automation scripts
│
├── 📂 scripts/
│   ├── deployment/
│   │   ├── smoke-tests.sh             ← Post-deploy smoke tests
│   │   └── rollback.sh                ← Emergency rollback
│   ├── maintenance/
│   │   └── sync-keyvault-secrets.sh   ← Cross-region secret sync
│   └── monitoring/
│       └── check-dr-health.sh         ← DR health verification
│
└── 📂 docs/
    ├── ARCHITECTURE.md
    ├── RUNBOOKS.md
    └── ONBOARDING.md
```

---

## 👥 Team & Contacts

| Role | Team | Contact | Escalation |
|------|------|---------|------------|
| **Platform Engineering** | DevOps / SRE | platform@loanflowpro.com | PagerDuty |
| **Release Manager** | Engineering | releases@loanflowpro.com | Slack: #releases |
| **Security** | InfoSec | security@loanflowpro.com | Slack: #security |
| **Database Admin** | Data Platform | dba@loanflowpro.com | PagerDuty |
| **On-call (24/7)** | SRE | — | PagerDuty: loanflow-oncall |
| **Incident Commander** | Engineering Leads | — | PagerDuty: ic-rotation |

### Important Links

| Resource | URL |
|----------|-----|
| Azure DevOps | https://dev.azure.com/loanflowpro |
| Azure Portal | https://portal.azure.com |
| SonarQube | https://sonarqube.loanflowpro.com |
| Grafana / Monitoring | https://monitoring.loanflowpro.com |
| Status Page | https://status.loanflowpro.com |
| PagerDuty | https://loanflowpro.pagerduty.com |
| DR Runbook | [dr/DR-STRATEGY.md](dr/DR-STRATEGY.md) |

---

## 📜 Change Log

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 2.0.0 | 2026-04 | DR pipeline + multi-env Terraform | Platform Eng |
| 1.5.0 | 2025-12 | PreProd environment added | Release Eng |
| 1.0.0 | 2025-06 | Initial DevOps setup | Platform Eng |

---

<div align="center">

---

**Built with ❤️ by the LoanFlow Pro Platform Engineering Team**

*Powered by Azure · Secured by Design · Resilient by Architecture*

[![Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white)](https://helm.sh)

</div>
