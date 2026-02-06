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
   #oc image mirror -a ${LOCAL_SECRET_JSON} --from-dir=${REMOVABLE_MEDIA_PATH}/mirror "file://openshift/release:${OCP_RELEASE}*" ${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}
   oc image mirror --from-dir=${REMOVABLE_MEDIA_PATH}/mirror --insecure "file://openshift/release:${OCP_RELEASE}*" ${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}
   ```

6. 

7. Print the mirrored release image signature config map to the standard output:

   ```
   cat ${REMOVABLE_MEDIA_PATH}/mirror/config/signature-sha256-*.yaml
   ```

8. Copy the content of the output and paste it as a new resource in the OpenShift cluster:
   - https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-config-managed/import

---

# Updating a cluster in a disconnected environment without the OpenShift Update Service

## Prerequisites
> You must have a recent etcd backup in case your update fails and you must restore your cluster to a previous state.

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

### Upgrading the disconnected cluster

#### Procedure

1. xxx

   ```
   sudo tee /etc/containers/registries.conf.d/999-insecure-mirror.conf <<EOF
   [[registry]]
   location = "mirror.hub.sebastian-colomar.com:5000"
   insecure = true
   EOF
   ```

1. Retrieve the sha256 sum value for the release from the image signature ConfigMap:

   ```
   SHA256_SUM_VALUE=$( oc get cm -n openshift-config-managed -o name | grep sha256 | cut -d- -f2- )
   export LOCAL_REGISTRY=mirror.hub.sebastian-colomar.com:5000
   export LOCAL_REPOSITORY=mirror
   export RELEASE_NAME="ocp-release"
   oc patch image.config.openshift.io/cluster --type=merge -p '{"spec":{"registrySources":{"insecureRegistries":["mirror.hub.sebastian-colomar.com:5000"]}}}'
   oc adm upgrade --allow-explicit-upgrade --to-image ${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}/${RELEASE_NAME}@sha256:${SHA256_SUM_VALUE}
   ```
3. Update the cluster:

