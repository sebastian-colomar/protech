# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# 2. Using Operator Lifecycle Manager on restricted networks 

## Red Hat references:
> - https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/operators/administrator-tasks
> - https://docs.redhat.com/en/documentation/openshift_container_platform/4.9/html/operators/administrator-tasks

NOTE:
> Run this whole procedure on a Linux machine with internet access and at least 1 TB of mounted storage.
>
> YOU NEED TO BE THE ROOT USER (ID=0).


For OpenShift Container Platform clusters that are installed on restricted networks, also known as disconnected clusters, Operator Lifecycle Manager (OLM) by default cannot access the Red Hat-provided OperatorHub sources hosted on remote registries because those remote sources require full internet connectivity.

However, as a cluster administrator you can still enable your cluster to use OLM in a restricted network if you have a workstation that has full internet access. The workstation, which requires full internet access to pull the remote OperatorHub content, is used to prepare local mirrors of the remote sources, and push the content to a mirror registry.

The mirror registry can be located on a bastion host, which requires connectivity to both your workstation and the disconnected cluster, or a completely disconnected, or airgapped, host, which requires removable media to physically move the mirrored content to the disconnected environment.

## Pruning an index image

An index image, based on the Operator bundle format, is a containerized snapshot of an Operator catalog. You can prune an index of all but a specified list of packages, which creates a copy of the source index containing only the Operators that you want.

### Procedure

2.1. Set up environment variables:
   ```
   export ARCH_CATALOG=amd64
   export ARCH_RELEASE=x86_64
   export CONTAINER_IMAGE=docker.io/library/registry
   export CONTAINER_IMAGE_TAG=2.7
   export CONTAINER_NAME=registry
   export CONTAINER_PORT=5000
   export CONTAINER_VOLUME=/var/lib/registry
   #export LOCAL_SECRET_JSON=${XDG_RUNTIME_DIR}/containers/auth.json
   #export LOCAL_SECRET_JSON=${HOME}/.docker/config.json
   export LOCAL_SECRET_JSON=${HOME}/pull-secret.json
   export MIRROR_HOST=mirror.hub.sebastian-colomar.com
   export MIRROR_PORT=5000
   export MIRROR_PROTOCOL=http
   export OCP_RELEASE_NEW=4.10.64
   export OCP_RELEASE_OLD=4.9.59
   export OCP_REPOSITORY=ocp
   # "ako-operator" is just an example for testing purposes, simulating an external operator such as IBM operators
   # "cluster-logging,elasticsearch-operator,local-storage-operator,mcg-operator,ocs-operator,odf-operator" are the currently existing Red Hat operators in version 4.9
   export PKGS='ako-operator,cluster-logging,elasticsearch-operator,local-storage-operator,ocs-operator,odf-operator'
   export PKGS_CERTIFIED='ako-operator'
   export PKGS_REDHAT='cluster-logging,elasticsearch-operator,local-storage-operator,ocs-operator,odf-operator'
   export PRODUCT_REPO=openshift-release-dev
   export RELEASE_NAME=ocp-release
   export REMOTE_USER=ec2-user
   export REMOVABLE_MEDIA_PATH=/mnt/mirror
   export RH_INDEX_LIST='certified-operator-index redhat-operator-index'
   export RH_INDEX_VERSION_NEW=v4.10
   export RH_INDEX_VERSION_OLD=v4.9
   export RH_REGISTRY=registry.redhat.io
   export RH_REPOSITORY=redhat
   export SSH_KEY=${HOME}/key.txt

   export CONTAINERS_STORAGE_CONF=${REMOVABLE_MEDIA_PATH}/containers/storage.conf
   export LOCAL_REGISTRY=${MIRROR_HOST}:${MIRROR_PORT}
   export MIRROR_OCP_REPOSITORY=mirror-${OCP_REPOSITORY}
   export TMPDIR=${REMOVABLE_MEDIA_PATH}/containers/cache

   ```

2.2. Allow unsigned registries for the Certified Operator Index:

   ```
   sudo sed -i '/"registry.redhat.io": \[/i\
               "registry.redhat.io/redhat/certified-operator-index": [\
                   {\
                       "type": "insecureAcceptAnything"\
                   }\
               ],' /etc/containers/policy.json

   ```

2.3. Run the source index image that you want to prune in a container:
   ```
   mkdir -p ${REMOVABLE_MEDIA_PATH}/containers
   mkdir -p ${REMOVABLE_MEDIA_PATH}/containers/cache
   mkdir -p ${REMOVABLE_MEDIA_PATH}/containers/containers
   mkdir -p ${REMOVABLE_MEDIA_PATH}/containers/containers-run

   tee ${REMOVABLE_MEDIA_PATH}/containers/storage.conf 0<<EOF
   [storage]
   driver = "overlay"
   graphroot = "${REMOVABLE_MEDIA_PATH}/containers/containers"
   runroot = "${REMOVABLE_MEDIA_PATH}/containers/containers-run"
   EOF

   semanage fcontext -a -t container_file_t "${REMOVABLE_MEDIA_PATH}/containers/containers(/.*)?"
   semanage fcontext -a -t container_var_run_t "${REMOVABLE_MEDIA_PATH}/containers/containers-run(/.*)?"
   restorecon -Rv ${REMOVABLE_MEDIA_PATH}/containers/containers ${REMOVABLE_MEDIA_PATH}/containers/containers-run

   podman info | egrep 'graphRoot:|runRoot:|imageCopyTmpDir:'

   ```
   ```
   for RH_INDEX in ${RH_INDEX_LIST}; do
     podman run --authfile ${LOCAL_SECRET_JSON} -d --name ${RH_INDEX}-${RH_INDEX_VERSION_NEW} -p 50051 --rm ${RH_REGISTRY}/${RH_REPOSITORY}/${RH_INDEX}:${RH_INDEX_VERSION_NEW}
   done

   ```

2.4. Use the grpcurl command to get a list of the packages provided by the index:
   ```
   for RH_INDEX in ${RH_INDEX_LIST}; do
      node_port=$( podman port ${RH_INDEX}-${RH_INDEX_VERSION_NEW} | cut -d: -f2 )
      podman run --rm --network host docker.io/fullstorydev/grpcurl:latest -plaintext localhost:${node_port} api.Registry/ListPackages | grep '"name"' | cut -d '"' -f4 | sort -u | tee ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${RH_INDEX_VERSION_NEW}.txt
   done

   ```
   
2.5. Inspect the `${RH_INDEX}-${version}.txt` file and identify which package names from this list you want to keep in your pruned index.

   Alternatively, list your current subscriptions:
   ```
   export PKGS=$(oc-${OCP_RELEASE_OLD} get subscriptions -A -o jsonpath='{range .items[*]}{.spec.name}{"\n"}{end}' | sort -u | paste -sd, -)

   ```

2.6. (IF NOT ALREADY PRESENT) Deploy the local container registry using the Distribution container image with the HTTP protocol:
   ```
   mkdir -p ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}

   podman run -d --name ${CONTAINER_NAME} --restart=always -p ${MIRROR_PORT}:${CONTAINER_PORT} -v ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}:${CONTAINER_VOLUME}:Z ${CONTAINER_IMAGE}:${CONTAINER_IMAGE_TAG}

   podman save > ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}.tar ${CONTAINER_IMAGE}:${CONTAINER_IMAGE_TAG}

   ```
   ```
   tee /etc/containers/registries.conf.d/99-localhost-insecure.conf >/dev/null <<EOF
   [[registry]]
   location = "localhost:${MIRROR_PORT}"
   insecure = true
   EOF

   ```

2.7. Run the following command to prune the source index of all but the specified packages and push the new index image to your target registry:
   ```
   podman info | egrep 'graphRoot:|runRoot:|imageCopyTmpDir:'

   mkdir -p ${HOME}/.docker
   cp -fv ${LOCAL_SECRET_JSON} ${HOME}/.docker/config.json

   ```
   ```
   ln -s ${BINARY_PATH}/oc-${OCP_RELEASE_NEW} ${BINARY_PATH}/oc-${RH_INDEX_VERSION_NEW}
   ln -s ${BINARY_PATH}/opm-${OCP_RELEASE_NEW} ${BINARY_PATH}/opm-${RH_INDEX_VERSION_NEW}

   for RH_INDEX in ${RH_INDEX_LIST}; do
      export INDEX_IMAGE=${RH_REGISTRY}/${RH_REPOSITORY}/${RH_INDEX}:${RH_INDEX_VERSION_NEW}   
      export INDEX_IMAGE_PRUNED=localhost:${MIRROR_PORT}/${RH_REPOSITORY}/${RH_INDEX}:${RH_INDEX_VERSION_NEW}
      opm-${RH_INDEX_VERSION_NEW} index prune -f ${INDEX_IMAGE} -p "${PKGS}" -t ${INDEX_IMAGE_PRUNED}  
      podman push ${INDEX_IMAGE_PRUNED} --remove-signatures
      podman run -d --name ${RH_INDEX}-${RH_INDEX_VERSION_NEW}-pruned -p 50051 --rm ${INDEX_IMAGE_PRUNED}
      export node_port=$( podman port ${RH_INDEX}-${RH_INDEX_VERSION_NEW}-pruned | cut -d: -f2 )
      podman run --rm --network host docker.io/fullstorydev/grpcurl:latest -plaintext localhost:${node_port} api.Registry/ListPackages | grep '"name"' | cut -d '"' -f4 | sort -u | tee ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${RH_INDEX_VERSION_NEW}-pruned.txt
   done

   ```

2.8. Inspect the `${RH_INDEX}-${RH_INDEX_VERSION_NEW}-pruned.txt` file and identify which package names from this list you want to keep in your pruned index.

2.9. Run the following command on your workstation with unrestricted network access to mirror the content to local files:
   ```
   for RH_INDEX in ${RH_INDEX_LIST}; do
      export MIRROR_OLM_REPOSITORY=mirror-${RH_INDEX}
      export MIRROR_INDEX_REPOSITORY=${MIRROR_OLM_REPOSITORY}-${RH_INDEX_VERSION_NEW}
      export INDEX_IMAGE_PRUNED=localhost:${MIRROR_PORT}/${RH_REPOSITORY}/${RH_INDEX}:${RH_INDEX_VERSION_NEW}
      mkdir -p ${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}
      cd ${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}
      oc-${RH_INDEX_VERSION_NEW} adm catalog mirror ${INDEX_IMAGE_PRUNED} file://${MIRROR_INDEX_REPOSITORY} -a ${LOCAL_SECRET_JSON} --index-filter-by-os=linux/${ARCH_CATALOG} --insecure
   done

   ```

2.10. Copy the directory that is generated in your current directory to removable media:
   ```
   cd ${REMOVABLE_MEDIA_PATH}

   for RH_INDEX in ${RH_INDEX_LIST}; do
      tar cfv ${MIRROR_INDEX_REPOSITORY}.tar ${MIRROR_INDEX_REPOSITORY}
   done

   ```

2.11. Upload the generated tarball to the mirror host:
   ```
   export MIRROR_HOST=mirror.sebastian-colomar.com

   ```
   ```
   ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${MIRROR_HOST} "sudo mkdir -p ${REMOVABLE_MEDIA_PATH}"

   ```
   ```
   ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${MIRROR_HOST} "sudo chown -R ${REMOTE_USER}. ${REMOVABLE_MEDIA_PATH}"

   ```
   ```
   for RH_INDEX in ${RH_INDEX_LIST}; do
      scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}.tar ${REMOTE_USER}@${MIRROR_HOST}:${REMOVABLE_MEDIA_PATH}
   done

   scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}.tar ${REMOTE_USER}@${MIRROR_HOST}:${REMOVABLE_MEDIA_PATH}

   ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${MIRROR_HOST} "sudo chown -R ${USER}. ${REMOVABLE_MEDIA_PATH}"

   ```

## (ONLY IF NECESSARY9 Disabling the default OperatorHub sources 

Operator catalogs that source content provided by Red Hat and community projects are configured for OperatorHub by default during an OpenShift Container Platform installation. In a restricted network environment, you must disable the default catalogs as a cluster administrator. You can then configure OperatorHub to use local catalog sources.

### Procedure

- (ONLY IF NECESSARY) Disable the sources for the default catalogs by adding `disableAllDefaultSources: true` to the OperatorHub object:
   ```
   oc-${OCP_RELEASE_OLD} patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
   
   ```

## SUMMARY:

   ```
   # 2.0. (IF NOT ALREADY PRESENT) Deploy the local container registry using the Distribution container image with the HTTP protocol:

   mkdir -p ${REMOVABLE_MEDIA_PATH}/containers
   mkdir -p ${REMOVABLE_MEDIA_PATH}/containers/cache
   mkdir -p ${REMOVABLE_MEDIA_PATH}/containers/containers
   mkdir -p ${REMOVABLE_MEDIA_PATH}/containers/containers-run

   tee ${REMOVABLE_MEDIA_PATH}/containers/storage.conf 0<<EOF
   [storage]
   driver = "overlay"
   graphroot = "${REMOVABLE_MEDIA_PATH}/containers/containers"
   runroot = "${REMOVABLE_MEDIA_PATH}/containers/containers-run"
   EOF

   semanage fcontext -a -t container_file_t "${REMOVABLE_MEDIA_PATH}/containers/containers(/.*)?"
   semanage fcontext -a -t container_var_run_t "${REMOVABLE_MEDIA_PATH}/containers/containers-run(/.*)?"
   restorecon -Rv ${REMOVABLE_MEDIA_PATH}/containers/containers ${REMOVABLE_MEDIA_PATH}/containers/containers-run

   podman info | egrep 'graphRoot:|runRoot:|imageCopyTmpDir:'

   mkdir -p ${HOME}/.docker
   cp -fv ${LOCAL_SECRET_JSON} ${HOME}/.docker/config.json

   mkdir -p ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}

   podman run -d --name ${CONTAINER_NAME} --restart=always -p ${MIRROR_PORT}:${CONTAINER_PORT} -v ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}:${CONTAINER_VOLUME}:Z ${CONTAINER_IMAGE}:${CONTAINER_IMAGE_TAG}

   podman save > ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}.tar ${CONTAINER_IMAGE}:${CONTAINER_IMAGE_TAG}

   tee /etc/containers/registries.conf.d/99-localhost-insecure.conf >/dev/null <<EOF
   [[registry]]
   location = "localhost:${MIRROR_PORT}"
   insecure = true
   EOF

   ```
   ```
   # 2.1. Set up environment variables:
   
   export ARCH_CATALOG=amd64
   export ARCH_RELEASE=x86_64
   export CONTAINER_IMAGE=docker.io/library/registry
   export CONTAINER_IMAGE_TAG=2.7
   export CONTAINER_NAME=registry
   export CONTAINER_PORT=5000
   export CONTAINER_VOLUME=/var/lib/registry
   #export LOCAL_SECRET_JSON=${XDG_RUNTIME_DIR}/containers/auth.json
   #export LOCAL_SECRET_JSON=${HOME}/.docker/config.json
   export LOCAL_SECRET_JSON=${HOME}/pull-secret.json
   export MIRROR_HOST=mirror.hub.sebastian-colomar.com
   export MIRROR_PORT=5000
   export MIRROR_PROTOCOL=http
   export OCP_RELEASE_NEW=4.10.64
   export OCP_RELEASE_OLD=4.9.59
   export OCP_REPOSITORY=ocp
   # "ako-operator" is just an example for testing purposes, simulating an external operator such as IBM operators
   # "cluster-logging,elasticsearch-operator,local-storage-operator,mcg-operator,ocs-operator,odf-operator" are the currently existing Red Hat operators in version 4.9
   export PKGS='ako-operator,cluster-logging,elasticsearch-operator,local-storage-operator,ocs-operator,odf-operator'
   export PKGS_CERTIFIED='ako-operator'
   export PKGS_REDHAT='cluster-logging,elasticsearch-operator,local-storage-operator,ocs-operator,odf-operator'
   export PRODUCT_REPO=openshift-release-dev
   export RELEASE_NAME=ocp-release
   export REMOTE_USER=ec2-user
   export REMOVABLE_MEDIA_PATH=/mnt/mirror
   export RH_INDEX_LIST='certified-operator-index redhat-operator-index'
   export RH_INDEX_VERSION_NEW=v4.10
   export RH_INDEX_VERSION_OLD=v4.9
   export RH_REGISTRY=registry.redhat.io
   export RH_REPOSITORY=redhat
   export SSH_KEY=${HOME}/key.txt

   export CONTAINERS_STORAGE_CONF=${REMOVABLE_MEDIA_PATH}/containers/storage.conf
   export LOCAL_REGISTRY=${MIRROR_HOST}:${MIRROR_PORT}
   export MIRROR_OCP_REPOSITORY=mirror-${OCP_REPOSITORY}
   export TMPDIR=${REMOVABLE_MEDIA_PATH}/containers/cache


   # 2.2. Allow unsigned registries for the Certified Operator Index:

   sudo sed -i '/"registry.redhat.io": \[/i\
               "registry.redhat.io/redhat/certified-operator-index": [\
                   {\
                       "type": "insecureAcceptAnything"\
                   }\
               ],' /etc/containers/policy.json


   # 2.3. Run the source index image that you want to prune in a container:

   for RH_INDEX in ${RH_INDEX_LIST}; do
     podman run --authfile ${LOCAL_SECRET_JSON} -d --name ${RH_INDEX}-${RH_INDEX_VERSION_NEW} -p 50051 --rm ${RH_REGISTRY}/${RH_REPOSITORY}/${RH_INDEX}:${RH_INDEX_VERSION_NEW}
   done


   # 2.4. Use the grpcurl command to get a list of the packages provided by the index:

   for RH_INDEX in ${RH_INDEX_LIST}; do
      node_port=$( podman port ${RH_INDEX}-${RH_INDEX_VERSION_NEW} | cut -d: -f2 )
      podman run --rm --network host docker.io/fullstorydev/grpcurl:latest -plaintext localhost:${node_port} api.Registry/ListPackages | grep '"name"' | cut -d '"' -f4 | sort -u | tee ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${RH_INDEX_VERSION_NEW}.txt
   done


   # 2.7. Run the following command to prune the source index of all but the specified packages and push the new index image to your target registry:
   # 2.9. Run the following command on your workstation with unrestricted network access to mirror the content to local files:
   # 2.10. Copy the directory that is generated in your current directory to removable media:
   # 2.11. Upload the generated tarball to the mirror host:

   ln -s ${BINARY_PATH}/oc-${OCP_RELEASE_NEW} ${BINARY_PATH}/oc-${RH_INDEX_VERSION_NEW}
   ln -s ${BINARY_PATH}/opm-${OCP_RELEASE_NEW} ${BINARY_PATH}/opm-${RH_INDEX_VERSION_NEW}

   index_image_prune() {
      export INDEX_IMAGE=${RH_REGISTRY}/${RH_REPOSITORY}/${RH_INDEX}:${RH_INDEX_VERSION_NEW}   
      export INDEX_IMAGE_PRUNED=localhost:${MIRROR_PORT}/${RH_REPOSITORY}/${RH_INDEX}:${RH_INDEX_VERSION_NEW}
      export INDEX_CONTAINER_NAME=${RH_INDEX}-${RH_INDEX_VERSION_NEW}-${pkg}
      opm-${RH_INDEX_VERSION_NEW} index prune -f ${INDEX_IMAGE} -p "${pkg}" -t ${INDEX_IMAGE_PRUNED}  
      podman push ${INDEX_IMAGE_PRUNED} --remove-signatures
      podman run -d --name ${INDEX_CONTAINER_NAME} -p 50051 --replace --rm ${INDEX_IMAGE_PRUNED}
      export node_port=$( podman port ${INDEX_CONTAINER_NAME} | cut -d: -f2 )
      podman run --network host --rm docker.io/fullstorydev/grpcurl:latest -plaintext localhost:${node_port} api.Registry/ListPackages | grep '"name"' | cut -d '"' -f4 | sort -u | tee ${REMOVABLE_MEDIA_PATH}/${INDEX_CONTAINER_NAME}.txt
   }

   index_image_download() {
      export MIRROR_OLM_REPOSITORY=mirror-${pkg}
      export MIRROR_INDEX_REPOSITORY=${MIRROR_OLM_REPOSITORY}-${RH_INDEX_VERSION_NEW}
      mkdir -p ${REMOVABLE_MEDIA_PATH}/${MIRROR_OLM_REPOSITORY}-${RH_INDEX_VERSION_NEW}
      cd ${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}
      oc-${RH_INDEX_VERSION_NEW} adm catalog mirror ${INDEX_IMAGE_PRUNED} file://${MIRROR_INDEX_REPOSITORY} -a ${LOCAL_SECRET_JSON} --index-filter-by-os=linux/${ARCH_CATALOG} --insecure
   }

   index_image_tar() {
      cd ${REMOVABLE_MEDIA_PATH}
      tar cfv ${MIRROR_INDEX_REPOSITORY}.tar ${MIRROR_INDEX_REPOSITORY}     
   }

   index_image_transfer() {
      export MIRROR_HOST=mirror.sebastian-colomar.com
      tar cfv ${MIRROR_INDEX_REPOSITORY}.tar ${MIRROR_INDEX_REPOSITORY}
      export MIRROR_HOST=mirror.sebastian-colomar.com
      ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${MIRROR_HOST} "sudo mkdir -p ${REMOVABLE_MEDIA_PATH}"
      ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${MIRROR_HOST} "sudo chown -R ${REMOTE_USER}. ${REMOVABLE_MEDIA_PATH}"
      scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}.tar ${REMOTE_USER}@${MIRROR_HOST}:${REMOVABLE_MEDIA_PATH}
      scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}.tar ${REMOTE_USER}@${MIRROR_HOST}:${REMOVABLE_MEDIA_PATH}
      ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${MIRROR_HOST} "sudo chown -R ${USER}. ${REMOVABLE_MEDIA_PATH}"     
   }

   ```
   ```
   # CERTIFIED OPERATOR INDEX
   export RH_INDEX=certified-operator-index
   for pkg in ${PKGS_CERTIFIED}; do
      export pkg
      index_image_prune
      index_image_download
      index_image_tar
      index_image_transfer
   done

   ```
   ```
   # REDHAT OPERATOR INDEX
   export RH_INDEX=redhat-operator-index
   for pkg in ${PKGS_REDHAT}; do
      export pkg
      index_image_prune
      index_image_download
      index_image_tar
      index_image_transfer
   done

   ```
