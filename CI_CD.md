# CI/CD in OpenChoreo

OpenChoreo provides a flexible CI/CD architecture that can either use its **Built-in CI** (powered by Argo Workflows or Tekton) or integrate with **External CI** (like GitHub Actions).

## 1. Built-in CI (Cluster-Side)

By default, OpenChoreo uses a "CI Plane" running inside your Kubernetes cluster.

*   **Engine**: Typically **Argo Workflows** (default) or **Tekton**.
*   **Where it runs**: In the `openchoreo-build-plane` namespace (or similar, depending on configuration).
*   **Configuration**:
    *   **Buildpacks**: OpenChoreo uses Cloud Native Buildpacks (CNB) to automatically detect and build your code without a Dockerfile.
    *   **Customization**: You can customize build configurations in the OpenChoreo Console under the "CI Pipelines" tab for each component.
    *   **Triggers**: Configured to run on git push (Auto Build) or manually.

## 2. External CI (GitHub Actions)

For many teams, using GitHub Actions is preferred. OpenChoreo supports this natively.

*   **How it works**:
    1.  You define a `.github/workflows/build.yaml` in your repository.
    2.  The workflow builds the Docker image and pushes it to a registry.
    3.  The workflow notifies OpenChoreo (via webhook or CLI) that a new image is ready.
    4.  OpenChoreo takes over for **CD** (Promotion across environments).

### Example GitHub Action for OpenChoreo

When you scaffold a new project (like the Spring Boot template), you can include a workflow like this:

```yaml
name: Build and Publish

on:
  push:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up JDK 21
      uses: actions/setup-java@v3
      with:
        java-version: '21'
        distribution: 'temurin'
    - name: Build with Maven
      run: mvn -B package --file pom.xml
    - name: Build and Push Docker Image
      uses: docker/build-push-action@v4
      with:
        push: true
        tags: ghcr.io/my-org/my-app:latest
    # Notify OpenChoreo (Optional, if using GitOps observer)
```

## 3. Deployment (CD)

Regardless of where the *Build* happens, OpenChoreo manages the *Deployment* via the **Deployment Pipeline** defined in `values.yaml`.

*   **Flow**: Development -> QA -> Pre-Production -> Production.
*   **Mechanism**: OpenChoreo watches for new container images or configuration changes and promotes them according to the rules (e.g., manual approval for Prod).
