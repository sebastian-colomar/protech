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
   # 2.11. Transfer the generated tarball to the mirror host:

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
