# Updating a cluster in a disconnected environment

- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/updating_clusters/updating-a-cluster-in-a-disconnected-environment

## Mirroring the OpenShift Container Platform image repository

### Preparing your mirror host 

#### Installing the OpenShift CLI by downloading the binary
- SEE DAY-03.MD

IMPORTANT:
- If you are upgrading a cluster in a disconnected environment, install the oc version that you plan to upgrade to.

#### Configuring credentials that allow images to be mirrored 

##### Procedure

1. Download your registry.redhat.io pull secret from the Red Hat OpenShift Cluster Manager.
   
   ALTERNATIVELY:
   
   You can retrieve the secret pull-secret from openshift-config namespace that will contain the necessary credentials:
   - https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-config/secrets/pull-secret
   ```
   ssh -i key.txt -lubuntu protech-me.sebastian-colomar.com
   ```
   ```
   sudo su --login root
   ```
   ```
   export KUBECONFIG=/root/environment/hub.sebastian-colomar.com/auth/kubeconfig
   ```
   ```
   oc -n openshift-config extract secret/pull-secret --to=-
   oc -n openshift-config extract secret/pull-secret --to .
   mv -v .dockerconfigjson /home/ubuntu/
   exit
   ```
   ```
   sudo chmod +r .dockerconfigjson
   ```
   ```
   exit
   ```
   ```
   scp -i key.txt ubuntu@protech-me.sebastian-colomar.com:.dockerconfigjson .
   ```
   
2. Save it to a json file.

   ```
   cat .dockerconfigjson | jq . | tee dockerconfigjson
   ```
   ```
   mkdir -p ${HOME}/.docker
   cp -v dockerconfigjson ${HOME}/.docker/config.json
   ```
   ```
   mkdir -p ${XDG_RUNTIME_DIR}/containers
   cp -v dockerconfigjson ${XDG_RUNTIME_DIR}/containers/auth.json
   ```
   ```
   podman login registry.redhat.io
   ```
   ```
   cat dockerconfigjson
   ```


### Mirroring the OpenShift Container Platform image repository

This procedure should be executed on a Linux machine with internet access and mounted a volume of at least 1TB.

#### Procedure

1. Set the required environment variables:
   
   a. Export the release version:
   
      ```
      export OCP_RELEASE=4.9.59
      ```
      Specify the tag that corresponds to the version of OpenShift Container Platform to which you want to update.
   
   b. Export the local registry name and host port:
   
      ```
      export LOCAL_REGISTRY=mirror.hub.sebastian-colomar.com:5000
      ```
      Specify the registry domain name for your mirror repository, and the port that it serves content on.

   c. Export the local repository name:

      ```
      export LOCAL_REPOSITORY=mirror
      ```
      Specify the name of the repository to create in your registry.

   d. Export the name of the repository to mirror:

      ```
      export PRODUCT_REPO='openshift-release-dev'
      ```

   e. Export the path to your registry pull secret:

      ```
      export LOCAL_SECRET_JSON=${XDG_RUNTIME_DIR}/containers/auth.json
      export LOCAL_SECRET_JSON=${HOME}/.docker/config.json
      ```

   f. Export the release mirror:

      ```
      export RELEASE_NAME="ocp-release"
      ```

   g. Export the type of architecture for your server, such as x86_64:

      ```
      export ARCHITECTURE=$(arch)
      ```

   h. Export the path to the directory to host the mirrored images:

      ```
      export REMOVABLE_MEDIA_PATH=/mnt
      ```

3. Review the images and configuration manifests to mirror:

   ```
   oc adm release mirror -a ${LOCAL_SECRET_JSON} --to-dir=${REMOVABLE_MEDIA_PATH}/mirror quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} --dry-run
   ```

4. Mirror the images and configuration manifests to a directory on the removable media:

   ```
   sudo mkdir -p ${REMOVABLE_MEDIA_PATH}/mirror
   sudo chown ${USER}. ${REMOVABLE_MEDIA_PATH}/mirror
   ```
   ```
   oc adm release mirror -a ${LOCAL_SECRET_JSON} --to-dir=${REMOVABLE_MEDIA_PATH}/mirror quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE}
   ```

5. Create a tar ball with the directory:

   ```
   cd ${REMOVABLE_MEDIA_PATH}
   sudo tar cfv mirror.tar mirror/
   #sudo gzip -v mirror.tar
   ```

5. Upload the tar ball of the directory on the removable media to your mirror host:
   ```
   cd ${HOME}
   scp -i key.txt mirror.tar ec2-user@bastion.hub.sebastian-colomar.com:
   ```
   
   
   
## Mirror registry for Red Hat OpenShift

### OPTION 1: HTTP
```
sudo mkdir -p /var/lib/registry
sudo podman run -d --name registry --restart=always -p 5000:5000 -v /var/lib/registry:/var/lib/registry:Z docker.io/library/registry:2.7
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
   openssl x509 -req -in ssl.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out ssl.crt -days 356 -extensions v3_req -extfile openssl.cnf
   ```
9. Confirm your created certificates and files by entering the following command:
   ```
   find .
   ```

#### Run registry with TLS

```
sudo mkdir -p /var/lib/registry
sudo podman run -d --name registry --restart=always -p 5000:5000 -v /var/lib/registry:/var/lib/registry:Z -v /etc/pki/registry:/certs:Z -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/ssl.crt -e REGISTRY_HTTP_TLS_KEY=/certs/ssl.key docker.io/library/registry:2
```
```
sudo podman login https://127.0.0.1:5000
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
   sudo podman login https://127.0.0.1:5000
   ```

##### Configuring the system to trust the certificate authority:

Use the following procedure to configure your system to trust the certificate authority.

###### Procedure:

1. Enter the following command to copy the rootCA.pem file to the consolidated system-wide trust store:
   ```
   sudo mkdir -p /etc/pki/ca-trust/source/anchors/
   sudo cp rootCA.pem /etc/pki/ca-trust/source/anchors/
   ```
2. Enter the following command to update the system-wide trust store configuration:
   ```
   sudo update-ca-trust extract
   ```














   
