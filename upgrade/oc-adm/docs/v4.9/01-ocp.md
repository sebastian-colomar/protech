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
   ```
   export ARCH_RELEASE=x86_64
   export BINARIES="oc opm"
   export BINARY_PATH=${HOME}/bin
   #export LOCAL_SECRET_JSON=${XDG_RUNTIME_DIR}/containers/auth.json
   #export LOCAL_SECRET_JSON=${HOME}/.docker/config.json
   export LOCAL_SECRET_JSON=${HOME}/pull-secret.json
   export MIRROR_HOST=mirror.hub.sebastian-colomar.com
   export MIRROR_PORT=5000
   export MIRROR_PROTOCOL=http
   export OCP_RELEASE_NEW=4.9.59
   export OCP_RELEASE_OLD=4.8.37
   export OCP_REPOSITORY=ocp
   export PACKAGES="openshift-client opm"
   export PRODUCT_REPO=openshift-release-dev
   export RELEASE_NAME=ocp-release
   export REMOTE_USER=ec2-user
   export REMOVABLE_MEDIA_PATH=/mnt/mirror
   export SSH_KEY=${HOME}/key.txt

   export LOCAL_REGISTRY=${MIRROR_HOST}:${MIRROR_PORT}
   export MIRROR_OCP_REPOSITORY=mirror-${OCP_REPOSITORY}

   ```

1.4. Install the OpenShift CLI by downloading the binary:
   
   IMPORTANT:
   > If you are upgrading a cluster in a disconnected environment, install the oc version that you plan to upgrade to.

   ```
   cd ${HOME}
   mkdir -p ${BINARY_PATH}
   grep -q ":${BINARY_PATH}:" ~/.bashrc || echo "export PATH=\"${BINARY_PATH}:\${PATH}\"" | tee -a ~/.bashrc
   source ~/.bashrc

   unalias cp mv rm

   for release in ${OCP_RELEASE_NEW} ${OCP_RELEASE_OLD}; do
      for package in ${PACKAGES}; do
        curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${release}/${package}-linux-${release}.tar.gz
        tar fxvz ${package}-linux-${release}.tar.gz
      done
      for binary in ${BINARIES}; do
        mv ${binary} ${BINARY_PATH}/${binary}-${release}
      done
   done

   rm -fv ${BINARY_PATH}/oc
   rm -fv ${BINARY_PATH}/opm

   ```

1.5. Check that the Image Pull Secret is in the right location:

   ```
   ls -l ${HOME}/pull-secret.json

   cat ${HOME}/pull-secret.json

   ```

1.6. Mirror the images and configuration manifests to a directory on the removable media:

   ```
   for release in ${OCP_RELEASE_NEW} ${OCP_RELEASE_OLD}; do
      sudo mkdir -p ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}-${release}
      sudo chown -R ${USER}. ${REMOVABLE_MEDIA_PATH}
      oc-${release} adm release mirror -a ${LOCAL_SECRET_JSON} quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${release}-${ARCH_RELEASE} --to-dir=${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}-${release}
   done

   ```

1.7. Retrieve the ImageContentSourcePolicy:

   ```
   for release in ${OCP_RELEASE_NEW} ${OCP_RELEASE_OLD}; do
      oc-${release} adm release mirror -a ${LOCAL_SECRET_JSON} quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${release}-${ARCH_RELEASE} --to=${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY}-${release} --to-release-image=${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY}-${release}:${release}-${ARCH_RELEASE} --insecure --dry-run | tee ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}-${release}/config/icsp.yaml
      sed -i '0,/ImageContentSourcePolicy/d' ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}-${release}/config/icsp.yaml
      sed -i 's/name: .*$/name: '${MIRROR_OCP_REPOSITORY}-${release}'/' ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}-${release}/config/icsp.yaml
   done

   ```

1.8. Create a tar archive containing the directory and its contents:

   ```
   for release in ${OCP_RELEASE_NEW} ${OCP_RELEASE_OLD}; do
      cd ${REMOVABLE_MEDIA_PATH}
      tar cfv ${MIRROR_OCP_REPOSITORY}-${release}.tar ${MIRROR_OCP_REPOSITORY}-${release}
   done

   ```

1.9. Upload the release and the openshift client tarball to the mirror host:
   ```
   export MIRROR_HOST=mirror.sebastian-colomar.com

   mirror_remote_exec() {
      ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${MIRROR_HOST} "$@"
   }

   ```
   ```
   mirror_remote_exec "sudo mkdir -p ${REMOVABLE_MEDIA_PATH}"

   ```
   ```
   mirror_remote_exec "sudo chown ${REMOTE_USER}. ${REMOVABLE_MEDIA_PATH}"

   ```
   ```
   for release in ${OCP_RELEASE_NEW} ${OCP_RELEASE_OLD}; do
      scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}-${release}.tar ${REMOTE_USER}@${MIRROR_HOST}:${REMOVABLE_MEDIA_PATH}
      for package in ${PACKAGES}; do
         scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${HOME}/${package}-linux-${release}.tar.gz ${REMOTE_USER}@${MIRROR_HOST}:${REMOVABLE_MEDIA_PATH}
      done
   done

   ```
