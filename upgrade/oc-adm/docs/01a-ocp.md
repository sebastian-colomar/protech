# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# 1. Getting your Jumphost ready

NOTE:
> Run this whole procedure on a Linux machine with internet access and at least 1 TB of mounted storage (the Jumphost)
> 
> YOU NEED TO BE THE ROOT USER (ID=0).

When you populate your mirror registry with OpenShift Container Platform images, 
if you do not have a host that can access both the internet and your mirror registry,
you must mirror the images to a file system and then bring that host or removable media into your restricted environment.
This process is referred to as disconnected mirroring.

#### Procedure
1.1. Set up your Red Hat account and link the Red Hat entitlement to your account. For help, see Accessing Red Hat entitlements from your IBM Cloud Pak:
   - https://www.ibm.com/docs/en/cloud-paks/1.0?topic=iocpc-accessing-red-hat-entitlements-from-your-cloud-paks
     
1.2. Obtain the pull secret file with Red Hat credentials from Red Hat OpenShift cluster manager and save as pull-secret.json:
   - https://console.redhat.com/openshift/install/pull-secret
     
1.3. Set the required environment variables:
   
   WARNING
   > The `RELEASE` variable for the version you want to mirror should already be exported)

   ```  
   export ARCH_CATALOG=amd64
   export ARCH_RELEASE=x86_64
   
   export BINARIES="oc opm"
   export BINARY_PATH=${HOME}/bin
   
   export CONTAINER_IMAGE=docker.io/library/registry
   export CONTAINER_IMAGE_TAG=2.7
   export CONTAINER_NAME=registry
   export CONTAINER_PORT=5000
   export CONTAINER_VOLUME=/var/lib/registry
   
   #export LOCAL_SECRET_JSON=${XDG_RUNTIME_DIR}/containers/auth.json
   #export LOCAL_SECRET_JSON=${HOME}/.docker/config.json
   export LOCAL_SECRET_JSON=${HOME}/auth/pull-secret.json
   
   export MAJOR=$( echo ${RELEASE} | cut -d. -f1 )
   export MINOR=$( echo ${RELEASE} | cut -d. -f2 )
   export PATCH=$( echo ${RELEASE} | cut -d. -f3 )
   
   export MIRROR_HOST=mirror.hub.sebastian-colomar.com
   export MIRROR_PORT=5000
   export MIRROR_PROTOCOL=http
   
   export OCP_REPOSITORY=ocp
   export PACKAGES="openshift-client opm"
   
   # PKGS_CERTIFIED contains the operators from the certified-operator-index
   # "ako-operator" is just an example for testing purposes, simulating an external operator such as IBM operators
   export PKGS_CERTIFIED='ako-operator'
   # PKGS_REDHAT contains the operators from the redhat-operator-index
   export PKGS_REDHAT='cluster-logging elasticsearch-operator local-storage-operator mcg-operator ocs-operator odf-csi-addons-operator odf-operator'
   
   export PRODUCT_REPO=openshift-release-dev
   export RELEASE_NAME=ocp-release
   export REMOTE_USER=ec2-user
   export REMOVABLE_MEDIA_PATH=/mnt/mirror
   
   export RH_INDEX_LIST='certified-operator-index redhat-operator-index'
   
   export RH_REGISTRY=registry.redhat.io
   export RH_REPOSITORY=redhat
   
   export SSH_KEY=${HOME}/auth/key.txt
   
   # These variables are derived from the previous ones:
   export CONTAINERS_STORAGE_CONF=${REMOVABLE_MEDIA_PATH}/containers/storage.conf
   export LOCAL_REGISTRY=${MIRROR_HOST}:${MIRROR_PORT}
   export MIRROR_OCP_REPOSITORY=mirror-${OCP_REPOSITORY}-${RELEASE}
   export TMPDIR=${REMOVABLE_MEDIA_PATH}/containers/cache
   export VERSION=v${MAJOR}.${MINOR}

   ```

1.4. Install the OpenShift CLI by downloading the binary:
   
   IMPORTANT:
   > If you are upgrading a cluster in a disconnected environment, install the oc version that you plan to upgrade to.

   ```   
   cd ${HOME}
   mkdir -p ${BINARY_PATH}
   grep -q ":${BINARY_PATH}:" ~/.bashrc || echo "export PATH=\"${BINARY_PATH}:\${PATH}\"" | tee -a ~/.bashrc
   #source ~/.bashrc
   unalias cp mv rm 2>/dev/null || true
   for package in ${PACKAGES}; do
     curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${RELEASE}/${package}-linux-${RELEASE}.tar.gz
     tar fxvz ${package}-linux-${RELEASE}.tar.gz
   done
   for binary in ${BINARIES}; do
     mv -fv ${binary} ${BINARY_PATH}/${binary}-${RELEASE} 
   done
   
   rm -fv kubectl
   rm -fv README.md
   
   rm -fv ${BINARY_PATH}/oc
   rm -fv ${BINARY_PATH}/opm
   
   ln -sfnT ${BINARY_PATH}/oc-${RELEASE} ${BINARY_PATH}/oc-${VERSION}
   ln -sfnT ${BINARY_PATH}/opm-${RELEASE} ${BINARY_PATH}/opm-${VERSION}
   
   ln -sfnT ${BINARY_PATH}/oc-${RELEASE} ${BINARY_PATH}/oc
   ln -sfnT ${BINARY_PATH}/opm-${RELEASE} ${BINARY_PATH}/opm
   
   ```

1.5. Check that the Image Pull Secret is in the right location:

   ```
   ls -l ${HOME}/auth/pull-secret.json

   cat ${HOME}/auth/pull-secret.json

   ```

1.6. Mirror the images and configuration manifests to a directory on the removable media:

   ```
   sudo mkdir -p ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}
   sudo chown -R ${USER}. ${REMOVABLE_MEDIA_PATH}
   oc-${RELEASE} adm release mirror -a ${LOCAL_SECRET_JSON} quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${RELEASE}-${ARCH_RELEASE} --to-dir=${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}

   ```

1.7. Retrieve the ImageContentSourcePolicy:

   ```
   oc-${RELEASE} adm release mirror -a ${LOCAL_SECRET_JSON} quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${RELEASE}-${ARCH_RELEASE} --to=${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY} --to-release-image=${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY}:${RELEASE}-${ARCH_RELEASE} --insecure --dry-run | tee ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}/config/icsp.yaml
   sed -i '0,/ImageContentSourcePolicy/d' ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}/config/icsp.yaml
   sed -i 's/name: .*$/name: '${MIRROR_OCP_REPOSITORY}'/' ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}/config/icsp.yaml

   ```

1.8. Create a tar archive containing the directory and its contents:

   ```
   cd ${REMOVABLE_MEDIA_PATH}
   tar cfv ${MIRROR_OCP_REPOSITORY}.tar ${MIRROR_OCP_REPOSITORY}

   ```

1.9. Upload the release and the openshift client tarball to the mirror host:
   ```
   export MIRROR_HOST=mirror.sebastian-colomar.com
   mirror_remote_exec() {
      ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${MIRROR_HOST} "$@"
   }
   mirror_remote_exec "sudo mkdir -p ${REMOVABLE_MEDIA_PATH}"
   mirror_remote_exec "sudo chown -R ${REMOTE_USER}. ${REMOVABLE_MEDIA_PATH}"
   scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}.tar ${REMOTE_USER}@${MIRROR_HOST}:${REMOVABLE_MEDIA_PATH}
   for package in ${PACKAGES}; do
      scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${HOME}/${package}-linux-${RELEASE}.tar.gz ${REMOTE_USER}@${MIRROR_HOST}:${REMOVABLE_MEDIA_PATH}
   done

   ```
