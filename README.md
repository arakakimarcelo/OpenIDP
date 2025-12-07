# OpenChoreo Production-Ready Setup

This project contains the manifests and scripts to deploy OpenChoreo in a more production-ready manner using Helm charts and Kubernetes manifests.

## Prerequisites

- **Kubernetes Cluster**: A running Kubernetes cluster (e.g., Minikube, GKE, EKS, AKS).
- **kubectl**: Configured to communicate with your cluster.
- **Helm**: Version 3.12+ installed.

## Directory Structure

- `openchoreo-control-plane/`: Extracted Helm chart for the Control Plane.
- `openchoreo-data-plane/`: Extracted Helm chart for the Data Plane.
- `pvc.yaml`: PersistentVolumeClaim for Asgardeo Thunder (required for Control Plane).
- `catalog-entities/`: Example catalog entities (Teams, APIs, Components, Docs).
- `templates/`: Custom software templates (e.g., Java 21 Spring Boot 3).
- `dev-connect.sh`: Script to automatically handle port-forwarding.

## Deployment Steps

### 1. Install Control Plane

The Control Plane manages the OpenChoreo platform, including the API, UI, and core controllers.

**Important:** Before installing, apply the PVC for Asgardeo Thunder and install Gateway API CRDs:

```bash
# Install Gateway API CRDs (Required by cert-manager)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# Create Namespace and PVC
kubectl create namespace openchoreo-system
kubectl apply -f pvc.yaml
```

Then install the chart. **Note:** We override several URLs to `localhost` to allow local login to work without internal DNS resolution.

```bash
helm install openchoreo-control-plane ./openchoreo-control-plane \
  --namespace openchoreo-system
```

### 2. Install Data Plane

The Data Plane is where your applications will be deployed.

**Note:** We disable `cert-manager` (already installed) and enable a temporary volume for Envoy (fix for macOS/Docker).

```bash
helm install openchoreo-data-plane ./openchoreo-data-plane \
  --namespace openchoreo-data-plane \
  --create-namespace \
  --set cert-manager.enabled=false \
  --set gateway.envoy.mountTmpVolume=true
```

### 3. Access the UI (Local Development)

To easily access the UI and handle the necessary port-forwards, run the helper script:

```bash
./dev-connect.sh
```

This will start port-forwarding for both the UI (Port 7007) and the Identity Provider (Port 8090). Keep this script running in your terminal.

Then access [http://localhost:7007](http://localhost:7007) in your browser.

**Credentials:**
- Username: `admin@openchoreo.dev`
- Password: `Admin@123`

## Managing the Catalog and Templates

### Adding Catalog Entities (Teams, APIs, Docs)

1.  Push the `catalog-entities/` folder to a Git repository (e.g., GitHub).
2.  In OpenChoreo UI, go to **Create** -> **Register Existing Component**.
3.  Enter the URL to the raw YAML file (e.g., `https://github.com/your-user/your-repo/blob/main/catalog-entities/team-platform.yaml`).
4.  Click **Analyze** and then **Import**.

### Adding Software Templates (Scaffolding)

1.  Push the `templates/` folder to a Git repository.
2.  In OpenChoreo UI, go to **Create** -> **Register Existing Component**.
3.  Enter the URL to the `template.yaml` file (e.g., `https://github.com/your-user/your-repo/blob/main/templates/spring-boot-3/template.yaml`).
4.  Click **Analyze** and then **Import**.
5.  You will now see "Spring Boot 3 Service (Java 21)" as an option when you click **Create**.

### TechDocs (Documentation)

TechDocs is enabled in "local" mode. To view documentation:
1.  Register the `catalog-entities/component-docs.yaml` component.
2.  Go to the **Docs** tab in the UI.
3.  Select "System Architecture Documentation" to view the rendered site.

### Testing an API

1.  kubectl apply -f https://raw.githubusercontent.com/openchoreo/openchoreo/release-v0.6/samples/from-image/go-greeter-service/greeter-service.yaml
2.  kubectl get component,workload,releasebinding -A
3.  kubectl get component greeter-service
4.  kubectl get releasebinding greeter-service-development
5.  kubectl get deployment -A | grep greeter
6.  kubectl get pods -A | grep greeter
7.  kubectl get httproute -A -o wide
8.  curl http://development.openchoreoapis.localhost:9080/greeter-service/greeter/greet

