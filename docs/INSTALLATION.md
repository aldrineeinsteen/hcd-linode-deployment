# HCD Linode Deployment - Installation Guide

## Prerequisites
- Linode API Token
- Terraform Installed (`>= 1.3.0`)
- Kubectl Installed (`>= 1.23`)
- Linode CLI Installed

## Deployment Steps

### 1. Clone this Repository
```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/hcd-linode-deployment.git
cd hcd-linode-deployment/terraform
```

### 2. Deploy Infra
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

#### 2.1 Verify the Infra
```bash
cd ..
export KUBECONFIG=$(pwd)/terraform/modules/lke/kubeconfig
kubectl get nodes
```

### 3. Installing Mission Control (this is also automated)
```bash
# Install cert manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml
# The following will install mission-control in a no port forward mode
kubectl kots install mission-control \
  --namespace mission-control \
  --license-file "./mission-control/mc_license.yaml" \
  --shared-password="password" \
  --storage-class linode-block-storage-retain \
  --no-port-forward
# To access the kots admin panel
kubectl kots admin-console --namespace mission-control
# Follow the mission control configuration guide
```

### 3.1 Verify the installation
```bash
kubectl get pods -n mission-control
# make sure none of the pods are failing
```

### 3.2 Access the mission control UI
```bash
kubectl port-forward svc/mission-control-ui 8080:8080 -n mission-control

# Alternatively, use the nodePort IP for the UI:
kubectl get nodes -o wide
# grab the external IP of any of the nodes
kubectl get svc -n mission-control
# grab the port of the NodePort (of UI)
```
Access the Mission Control UI using https://127.0.0.1:8080/ui/ or https://EXTERNAL_NODE_IP:NODEPORD/ui/