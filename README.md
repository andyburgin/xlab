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


