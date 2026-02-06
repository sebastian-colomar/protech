## Mirroring the OpenShift Container Platform image repository

### Preparing your mirror host 

#### Installing the OpenShift CLI by downloading the binary

When you populate your mirror registry with OpenShift Container Platform images, you can follow two scenarios. If you have a host that can access both the internet and your mirror registry, but not your cluster nodes, you can directly mirror the content from that machine. This process is referred to as connected mirroring. If you have no such host, you must mirror the images to a file system and then bring that host or removable media into your restricted environment. This process is referred to as disconnected mirroring.

#### Our case is a disconnected mirroring

#### IMPORTANT:

> If you are upgrading a cluster in a disconnected environment, install the oc version that you plan to upgrade to.


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

4. Copy the tarball to the removable media path:

   ```
   sudo mkdir -p ${REMOVABLE_MEDIA_PATH}
   sudo cp -v mirror.tar ${REMOVABLE_MEDIA_PATH}
   ```
   
5. Extract the tar ball with the images:

   ```
   cd ${REMOVABLE_MEDIA_PATH}
   #gunzip -v mirror.tar
   sudo tar xfv mirror.tar
   sudo chown ${USER}. ${REMOVABLE_MEDIA_PATH}/mirror
   ```

6. Mirror the images and configuration manifests to the local container registry:

   ```
   oc image mirror -a ${LOCAL_SECRET_JSON} --from-dir=${REMOVABLE_MEDIA_PATH}/mirror --insecure "file://openshift/release:${OCP_RELEASE}*" ${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}
   ```
   
