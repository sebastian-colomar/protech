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

1. Download your registry.redhat.io pull secret from the Red Hat OpenShift Cluster Manager and save it to a .json file.
   
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
   oc adm release mirror -a ${LOCAL_SECRET_JSON} --to-dir=${REMOVABLE_MEDIA_PATH}/mirror quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE}
   ```
   
   













   
