# xlab

### Starting vm

    vagrant up

## fixing provisioning issues
* dev namespace not created when workloads are being added, re run

    export host=$(yq '.clusters[].cluster.server' /home/vagrant/clusterconfig.yaml)
    export clustercert=$(yq '.clusters[].cluster.certificate-authority-data' /home/vagrant/clusterconfig.yaml)
    export clientcert=$(yq '.users[].user.client-certificate-data' /home/vagrant/clusterconfig.yaml)
    export clientkey=$(yq '.users[].user.client-key-data' /home/vagrant/clusterconfig.yaml)
    terraform plan --var="host=$host" --var="cluster_cert=$clustercert" \
                   --var="client_cert=$clientcert" --var="client_key=$clientkey"

* then apply with
    terraform apply --var="host=$host" --var="cluster_cert=$clustercert" \
                    --var="client_cert=$clientcert" --var="client_key=$clientkey" -auto-approve

## Verify install

Quick test:
    curl http://localhost:$(kubectl get service dev-nginx -n dev -o jsonpath="{..nodePort}")
    curl http://localhost:$(kubectl get service staging-nginx -n dev -o jsonpath="{..nodePort}")


