# openobserve-automation

## Setup Instructions
### Prerequisites
  Make sure these tools are installed on your local machine:  
  - [kubectl](https://kubernetes.io/docs/tasks/tools/)
  - [Minikube](https://minikube.sigs.k8s.io/docs/) **or** [Kind](https://kind.sigs.k8s.io/) **or** [k3s](https://k3s.io/)
  - [Helm](https://helm.sh/docs/intro/install/)
  - [Terraform](https://developer.hashicorp.com/terraform/install)
  - [Git](https://git-scm.com/)
  - A [GitHub account](https://github.com/) (for CI/CD pipeline)

   1. Start Your Local Kubernetes Cluster
      Using Minikube example:
      ```
      minikube start
      kubectl get nodes
      ```
    
    
   2. Deploy Nginx Test Application
     Verify cluster works by deploying Nginx:
      ```
      kubectl apply -f k8s/nginx-deployment.yaml
      kubectl get pods
      ```
      Port-forward and test locally:
      ```
      kubectl port-forward svc/nginx-service 8080:80
      ```
      Access in browser:
    
      ```
      http://localhost:8080
      ```
      
  3. Install OpenObserve with Helm  
      Add Helm repo:
  
      ```
      helm repo add openobserve https://openobserve.github.io/helm-charts
      helm repo update
      ```

      Install with custom values:
      ```
      helm install openobserve openobserve/openobserve \
        -n observability --create-namespace \
        -f helm-charts/openobserve-values.yaml
      ```  
      
      Verify pods:
      ```
      kubectl get pods -n observability
      ```

      Port-forward to access the UI:
      ```
      kubectl port-forward svc/openobserve 5080:5080 -n observability
      ```

      Access:
      ```
      http://localhost:5080
      ```
      
   4. Deploy Sample Log-Generating App
       ```
      kubectl apply -f k8s/sample-app-logging.yaml
      ```
    This app emits structured JSON logs to be collected in OpenObserve.

   **Logs have fields: log.level, body.message**
    
   5. Terraform Automation
      Navigate to Terraform directory:
      
      ```
      cd terraform
      terraform init
      terraform plan
      terraform apply
      ```

      To destroy:
      
      ```
      terraform destroy
      ```

## CI/CD Pipeline with GitHub Actions

  1. CI/CD pipeline defined in:
      ```
      .github/workflows/deploy.yml
      ```
      
  Features:
    Trigger: Push to main branch
    Steps:
      - Checkout repository
      - Setup Terraform
      - Initialize and Apply
      - Deploy/update sample applications


  Example Workflow Snippet:
  ```
      on:
        push:
          branches:
            - main
      
      jobs:
        deploy:
          runs-on: ubuntu-latest
          steps:
            - uses: actions/checkout@v4
            - uses: hashicorp/setup-terraform@v3
            - run: terraform init
              working-directory: terraform
            - run: terraform apply -auto-approve
              working-directory: terraform
  ```
 
  How to Use:

  - Commit and push changes to main
  
  - GitHub Actions will automatically deploy resources via Terraform


##  Validation Steps
1. Check Kubernetes resources:
  ```
  kubectl get pods -A
  kubectl get svc -A
  ```

2. Access Services:
  ```
  Nginx: http://localhost:8080
  
  OpenObserve: http://localhost:5080
  ```

3. Verify Logs in OpenObserve:
   Search logs from the sample app
   Filter using:
    ```
    body.message
    
    log.level
    ```

4. Check CI/CD:

Open the Actions tab in your GitHub repo
Verify successful workflow runs
Confirm Terraform applied resources correctly

5. Cleanup
 Remove all resources:
  ```
  terraform destroy
  kubectl delete -f k8s/nginx-deployment.yaml
  kubectl delete -f k8s/sample-app-logging.yaml
  helm uninstall openobserve -n observability
  kubectl delete ns observability
  ```

Delete Minikube cluster:
  ```
  minikube delete
  ```
