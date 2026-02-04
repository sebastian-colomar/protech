### DISCLAIMER
The following text is reproduced from the referenced guides and is provided without any express or implied guarantees

---

Red Hat OpenShift Container Platform Update Graph:
- https://access.redhat.com/labs/ocpupgradegraph/update_path/
- https://access.redhat.com/labs/ocpupgradegraph/update_path/?channel=stable-4.8&arch=x86_64&is_show_hot_fix=false&current_ocp_version=4.8.37&target_ocp_version=4.10.64
  - To Select the stable-4.9 channel, run this patch command on the CLI:
    ```
    oc patch clusterversion version --type merge -p '{"spec": {"channel": "stable-4.9"}}'
    ```
    Refer to the Performing a Control Plane Only update documentation if you don't want to update the compute nodes during the intermediate upgrade.
    - https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0?topic=ocp-ocs-upgrade-in-connected-environment-by-using-red-hat-openshift-console-ui
  - Upgrade the cluster from 4.8.37 to 4.9.59.
  - Select the stable-4.10 channel.
  - Upgrade the cluster from 4.9.59 to 4.10.64.

Documentation for IBM Cloud Pak for Data System:
- https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0
- https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0?topic=upgrading-cloud-pak-data-system

Red Hat OpenShift mirror:
- https://mirror.openshift.com/pub/openshift-v4/clients/ocp/
---
# Mirroring images for a disconnected installation
### DISCLAIMER
The following text is reproduced from the referenced guide and is provided without any express or implied guarantees:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/installing/installing-mirroring-installation-images

When you populate your mirror registry with OpenShift Container Platform images, you can follow two scenarios. If you have a host that can access both the internet and your mirror registry, but not your cluster nodes, you can directly mirror the content from that machine. This process is referred to as connected mirroring. If you have no such host, you must mirror the images to a file system and then bring that host or removable media into your restricted environment. This process is referred to as disconnected mirroring.

#### Our case is a disconnected mirroring

## Preparing your mirror host

### Installing the OpenShift CLI by downloading the binary 

```
BINARY_PATH=${HOME}/bin
mkdir -p ${BINARY_PATH}

grep -q ":${BINARY_PATH}:" ~/.bashrc || echo "export PATH=\"${BINARY_PATH}:\${PATH}\"" | tee -a ~/.bashrc
source ~/.bashrc

curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.9.59/openshift-client-linux.tar.gz
tar fxvz openshift-client-linux.tar.gz
rm openshift-client-linux.tar.gz

binaries='kubectl oc'
for binary in ${binaries}
  do
    mv ${binary} ${BINARY_PATH}
  done

oc version
```
## Mirror registry for Red Hat OpenShift introduction

### OPTION 1: HTTP
```
sudo mkdir -p /var/lib/registry
sudo podman run -d --name registry --restart=always -p 5000:5000 -v /var/lib/registry:/var/lib/registry:Z docker.io/library/registry:2
```

### OPTION 2: HTTPS

- https://docs.redhat.com/en/documentation/red_hat_quay/3/html-single/securing_red_hat_quay/index

#### Configuring SSL and TLS for the mirror registry

##### Creating a Certificate Authority

###### Procedure:

1. Create the path for the certificates:
   ```
   sudo mkdir -p /etc/pki/registry
   cd /etc/pki/registry
   ```
1. Generate the root CA key by entering the following command:
   ```
   openssl genrsa -out rootCA.key 2048
   ```
2. Generate the root CA certificate by entering the following command:
   ```
   openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem
   ```
3. Enter the information that will be incorporated into your certificate request, including the server hostname, for example:
   ```
   Country Name (2 letter code) [XX]:IE
   State or Province Name (full name) []:GALWAY
   Locality Name (eg, city) [Default City]:GALWAY
   Organization Name (eg, company) [Default Company Ltd]:QUAY
   Organizational Unit Name (eg, section) []:DOCS
   Common Name (eg, your name or your server's hostname) []:quay-server.example.com
   ```
4. Generate the server key by entering the following command:
   ```
   openssl genrsa -out ssl.key 2048
   ```
5. Generate a signing request by entering the following command:
   ```
   openssl req -new -key ssl.key -out ssl.csr
   ```
6. Enter the information that will be incorporated into your certificate request, including the server hostname, for example:
   ```
   Country Name (2 letter code) [XX]:IE
   State or Province Name (full name) []:GALWAY
   Locality Name (eg, city) [Default City]:GALWAY
   Organization Name (eg, company) [Default Company Ltd]:QUAY
   Organizational Unit Name (eg, section) []:DOCS
   Common Name (eg, your name or your server's hostname) []:quay-server.example.com
   Email Address []:
   ```
7. Create a configuration file `openssl.cnf`, specifying the server hostname, for example:
   ```
   [req]
   req_extensions = v3_req
   distinguished_name = req_distinguished_name
   [req_distinguished_name]
   [ v3_req ]
   basicConstraints = CA:FALSE
   keyUsage = nonRepudiation, digitalSignature, keyEncipherment
   subjectAltName = @alt_names
   [alt_names]
   DNS.1 = <quay-server.example.com>
   IP.1 = 192.168.1.112
   ```
8. Use the configuration file to generate the certificate ssl.cert:
   ```
   openssl x509 -req -in ssl.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out ssl.cert -days 356 -extensions v3_req -extfile openssl.cnf
   ```
9. Confirm your created certificates and files by entering the following command:
   ```
   find .
   ```

##### Configuring Podman to trust the Certificate Authority:

Podman uses two paths to locate the Certificate Authority (CA) file: `/etc/containers/certs.d/` and `/etc/docker/certs.d/`. Use the following procedure to configure Podman to trust the CA.

###### Procedure:

1. Copy the root CA file to one of `/etc/containers/certs.d/` or `/etc/docker/certs.d/`. Use the exact path determined by the server hostname, and name the file `ca.crt`:
   ```
   sudo mkdir -p /etc/containers/certs.d/mirror.sebastian-colomar.com
   sudo cp rootCA.pem /etc/containers/certs.d/mirror.sebastian-colomar.com/ca.crt
   ```
2. Verify that you no longer need to use the `--tls-verify=false` option when logging in to your mirror registry:
   ```
   sudo podman login quay-server.example.com
   ```

##### Configuring the system to trust the certificate authority:

Use the following procedure to configure your system to trust the certificate authority.

###### Procedure:

1. Enter the following command to copy the rootCA.pem file to the consolidated system-wide trust store:
   ```
   sudo cp rootCA.pem /etc/pki/ca-trust/source/anchors/
   ```
2. Enter the following command to update the system-wide trust store configuration:
   ```
   sudo update-ca-trust extract
   ```

#### Run registry with TLS

```
sudo mkdir -p /var/lib/registry
sudo podman run -d --name registry --restart=always -p 5000:5000 -v /var/lib/registry:/var/lib/registry:Z -v /etc/pki/registry:/certs:Z -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/ssl.crt -e REGISTRY_HTTP_TLS_KEY=/certs/ssl.key docker.io/library/registry:2
```




--- 
## Configuring credentials that allow images to be mirrored


---

# Mirroring an Operator catalog:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/operators/administrator-tasks

--- 
# Upgrade the cluster from 4.8.37 to 4.10.64

### DISCLAIMER
The following text is reproduced from the referenced guide and is provided without any express or implied guarantees:
- https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0?topic=ocp-ocs-upgrade-in-connected-environment-by-using-red-hat-openshift-console-ui

## OCP and OCS upgrade in a connected environment by using Red Hat OpenShift console UI
Last Updated: 2025-01-01
This section explains how to upgrade from Red Hat® OpenShift® Container Platform (OCP) 4.8 to 4.10 on Cloud Pak for Data System version 2.0.2.1 with houseconfig setup.

### Before you begin
Make sure that:
- Cloud Pak for Data System version 2.0.2 is configured with houseconfig setup to access external network.
- The cluster is in healthy state by running the following command:
  ```
  oc get nodes
  ```
- The machine config pools (MCP) are up to date by running the following command:
  ```
  oc get mcp
  ```
- All cluster operators are in healthy state by running the following command:
  ```
  oc get co
  ```
- OpenShift Container Storage (OCS) ceph status is HEALTH_OK by running the following command:
  ```
  oc -n openshift-storage rsh `oc get pods -n openshift-storage | grep ceph-tool | cut -d ' ' -f1` ceph status
  ```

#### Note: All the commands that are mentioned here are to be run from e1n1 except where it mentions otherwise.

### Procedure
1. Set up your Red Hat account and link the Red Hat entitlement to your account.
2. Obtain the pull secret file with Red Hat credentials from Red Hat OpenShift cluster manager and saved as pull-secret.json.
3. Validate the external connectivity and Red Hat credentials by running:
   ```
   podman pull --authfile /root/pull-secret.json registry.redhat.io/openshift4/ose-local-storage-mustgather-rhel8
   ```
4. Update the global cluster pull secret file to authenticate on Red Hat registries:
   
   a. Retrieve the current cluster pull secret file by running:
      ```
      oc get secret/pull-secret -n openshift-config --template='{{index .data ".dockerconfigjson" | base64decode}}' > pull_secret_old
      ```
   b. Merge this content into the pull-secret.json and use the merged file to set the global pull-secret on the cluster by running:
      ```
      oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=pull-secret.json
      ```
5. Enable the default catalog sources to access the latest from Red Hat operator sources by running:
   ```
   oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": false}]'
   ```
6. Make sure that the operator pods are in running state under OpenShift-marketplace namespace by running:
   ```
   oc get pods -n openshift-marketplace
   ```
#### Acknowledging manually for upgrading to OpenShift Container Platform (OCP) 4.9
Upgrading to an OCP version higher than 4.8 requires manual acknowledgment from the administrator:
```
oc -n openshift-config patch cm admin-acks --patch '{"data":{"ack-4.8-kube-1.22-api-removals-in-4.9":"true"}}' --type=merge
```

