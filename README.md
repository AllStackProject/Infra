# Privideo Infra & GitOps Deployment Repository

이 레포지토리는 Privideo 서비스의 **인프라 구성 요소**,  
ArgoCD 기반 **GitOps 배포 코드**,  
그리고 온프레미스에 직접 배포되는 **서비스 코드 일부**를 함께 관리하는 저장소입니다.

온프레미스 Kubernetes 클러스터 운영, Ingress, Backend/Frontend 배포  
그리고 로컬 서버에 배포되는 코드까지 **운영에 필요한 모든 구성 요소를 버전 관리**하는 목적을 가지고 있습니다.

---

## 🧭 Repository Purpose

이 저장소는 다음 목적을 위해 사용됩니다:

- Kubernetes 기반 Infrastructure 관리
- ArgoCD GitOps 방식의 애플리케이션 배포 관리
- Backend/Frontend/Ingress의 배포 설정 중앙화
- 온프레미스 환경에 배포되는 서비스 코드 관리
- 운영 환경에 필요한 구성 요소의 버전 이력 추적

📌 이 레포는 **On-Prem Infra Code + GitOps Deployment** 가 한 곳에 모여 있는 통합 운영 레포입니다.

---

### **1. backend/**
- Backend API 서버의 GitOps 배포 디렉터리
- ArgoCD가 주기적으로 Sync하여 Kubernetes에 배포
- 포함 내용:
  - `kustomization.yaml`
  - Deployment / Service / ConfigMap 등 manifest

---

### **2. frontend/**
- 프론트엔드(NGINX 기반 또는 SPA)의 GitOps 배포 디렉터리
- ArgoCD Sync 대상
- 포함 내용:
  - kustomize overlays / base
  - Service, Deployment 등 배포 설정

---

### **3. ingress/**
- Ingress-Nginx 기반 라우팅 규칙 관리
- ArgoCD Sync 대상
- 도메인 라우팅, SSL, path 설정 등 정의됨

---

### **4. code/**
- **온프레미스 서버에 직접 배포되는 코드**
- VM/서버 환경에서 사용됨
