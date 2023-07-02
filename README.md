# Intial implementation based upon xlab code
## Starting vm

    git clone https://github.com/andyburgin/xlab.git
    vagrant up

## fixing provisioning issues
If you encounter issues with vagran provisioning take the following corrective steps:

* dev namespace not created when workloads are being added, re run:
    ```export host=$(yq '.clusters[].cluster.server' /home/vagrant/clusterconfig.yaml)
    export clustercert=$(yq '.clusters[].cluster.certificate-authority-data' /home/vagrant/clusterconfig.yaml)
    export clientcert=$(yq '.users[].user.client-certificate-data' /home/vagrant/clusterconfig.yaml)
    export clientkey=$(yq '.users[].user.client-key-data' /home/vagrant/clusterconfig.yaml)
    terraform plan --var="host=$host" --var="cluster_cert=$clustercert" \
                    --var="client_cert=$clientcert" --var="client_key=$clientkey"
    ```
* then re apply:
    ```
    terraform apply --var="host=$host" --var="cluster_cert=$clustercert" \
                    --var="client_cert=$clientcert" --var="client_key=$clientkey" --auto-approve
    ```
## Verify install

Quick test:

    curl http://localhost:$(kubectl get service dev-nginx -n dev -o jsonpath="{..nodePort}")
    curl http://localhost:$(kubectl get service staging-nginx -n dev -o jsonpath="{..nodePort}")

## Remove resources

Ensure resources are removed prior to 
    terraform destroy --var="host=$host" --var="cluster_cert=$clustercert" \
                    --var="client_cert=$clientcert" --var="client_key=$clientkey"

# Task 01 - simplify-adding-environments

    git checkout 01-simplify-adding-environments

I've decided to adapt the existing implementation of keeping a single file with multiple resources. I've addeed a list of environments and map variables to use with a for_each meta argument on a single deployment and service resource. The maps are used as lookups for labels and nodeports so the generated kubernetes resources are identical to what was there before.

Having all deployments and services handled by a single tf resource doesn't mean that changes to individual k8s resource (e.g dev deployment) will cause the ones for other environments to be recreated (therefore notbreaking service continuity).

There are a few limitiations with this approach:
* Overriding 3 additional variables via comand line will be messy and therefor editing the variables inside the terraform is required. A better solution would be to introduce a variables tfvars file outside of the repo taht could be managed independetly.
* The single namespace isn't how workloads should seperated in kubernestes, each environment should have it's own namespace and authentication and access controls (RBAC and netpols). With this approach the names, labels could be generic, making use of service discovery in k8s with loadbalancer/clusterip service consistent port e.g. servicename.namespacename.svc.cluster.local 
Or add ingress controller and implement as clusterip service


# Task 02 - add-production-environment

    git checkout 02-add-production-environment

I'm going to fix some of the issues with the solution outlined in 01-simplify-adding-environments branch. Firstly adding another production to the environment. Next I'm moving each environment to it's own namespace, introducing generically named objects and ClusterIP services in preference to NodePorts. 

I've also introduced a map for the the lookup of different image/tags per environment.

Although neater still requires the type of resources to be created together rather than each environment created independently. 

## Tesing via Port Forwarding

As we no longer have nodeports we can access the ClusterIP services via port-forwarding

    kubectl port-forward svc/nginx -n production 8000:80
    curl http://localhost:8000/

    kubectl port-forward svc/nginx -n staging 8000:80
    curl http://localhost:8000/

    kubectl port-forward svc/nginx -n dev 8000:80
    curl http://localhost:8000/

# Task 03 - module-environment-refactor

Added module for kubernetes application in modules folder, remember to run terraform init to pull in module dependency.

Separated the varables into seperate file and consolidated all environment specific varables in to a combined per environment map.

    [{ 
        "name" = "dev"
        "image" = "nginx:latest"
    },{ 
        "name" = "staging"
        "image" = "nginx:1.25-alpine-slim"
    },{ 
        "name" = "production"
        "image" = "nginx:1.24-alpine-slim"
    }]

# Task 04 - separate-environment-vars

I've seperated the enmvironment variables into individual files, this enables teams to update and PR new environments as required, creating potential for gitops style CI/CD deployment. A better solution would be to have seperate Kubernetes clusters per environment thus removing dependencies on a single repo and creating the oportunity for separate environmental deployment and management.

For CI/CD pipelines I'd reccomend a paramterised build alowinf the selection of target environment. The pipeline schould be brokeninto the separate steps of init -> validate -> plan -> apply -> test e.g by Jenkinsfile. I would also propose container image scanning pre deployment via tools such as Snyk. 

There's no automated testing added to the repo but through the use of a toos like terratest it would be possible to define unit/integration/end2end test, however to accomplish that level of coverage a significant effort is require. A  risk based approach to deciding what level of testing is appropriate to this solution should be used.