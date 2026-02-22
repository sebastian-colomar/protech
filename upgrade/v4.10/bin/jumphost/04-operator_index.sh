date

# 2.2. Allow unsigned registries for the Certified Operator Index:

sudo sh -c '
set -euo pipefail
f=/etc/containers/policy.json
tmp=$(mktemp)

jq --arg k registry.redhat.io/redhat/certified-operator-index \
   '"'"'.transports.docker[$k] = [{"type":"insecureAcceptAnything"}]'"'"' \
   $f > $tmp

install -m 0644 $tmp $f
rm -f $tmp
'

# 2.3. Run the source index image that you want to prune in a container:

for RH_INDEX in ${RH_INDEX_LIST}; do
   podman run --authfile ${LOCAL_SECRET_JSON} -d --name ${RH_INDEX}-${RH_INDEX_VERSION_NEW} -p 50051 --replace --rm ${RH_REGISTRY}/${RH_REPOSITORY}/${RH_INDEX}:${RH_INDEX_VERSION_NEW}
done
sleep 10

# 2.4. Use the grpcurl command to get a list of the packages provided by the index:

for RH_INDEX in ${RH_INDEX_LIST}; do
   node_port=$( podman port ${RH_INDEX}-${RH_INDEX_VERSION_NEW} | cut -d: -f2 )
   podman run --network host --rm docker.io/fullstorydev/grpcurl:latest -plaintext localhost:${node_port} api.Registry/ListPackages | grep '"name"' | cut -d '"' -f4 | sort -u | tee ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${RH_INDEX_VERSION_NEW}.txt
   scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${RH_INDEX_VERSION_NEW}.txt ${REMOTE_USER}@${MIRROR_HOST}:${REMOVABLE_MEDIA_PATH}   
done


# 2.7. Run the following command to prune the source index of all but the specified packages and push the new index image to your target registry:
# 2.9. Run the following command on your workstation with unrestricted network access to mirror the content to local files:
# 2.10. Copy the directory that is generated in your current directory to removable media:
# 2.11. Transfer the generated tarball to the mirror host:

ln -sfnT ${BINARY_PATH}/oc-${OCP_RELEASE_NEW} ${BINARY_PATH}/oc-${RH_INDEX_VERSION_NEW}
ln -sfnT ${BINARY_PATH}/opm-${OCP_RELEASE_NEW} ${BINARY_PATH}/opm-${RH_INDEX_VERSION_NEW}

index_image_prune() {
   export INDEX_CONTAINER_NAME=${RH_INDEX}-${RH_INDEX_VERSION_NEW}-${pkg}
   export INDEX_IMAGE=${RH_REGISTRY}/${RH_REPOSITORY}/${RH_INDEX}:${RH_INDEX_VERSION_NEW}   
   export INDEX_IMAGE_PRUNED=localhost:${MIRROR_PORT}/${RH_REPOSITORY}/${RH_INDEX}:${RH_INDEX_VERSION_NEW}
   opm-${RH_INDEX_VERSION_NEW} index prune -f ${INDEX_IMAGE} -p ${pkg} -t ${INDEX_IMAGE_PRUNED}  
   podman push ${INDEX_IMAGE_PRUNED} --remove-signatures
   podman run -d --name ${INDEX_CONTAINER_NAME} -p 50051 --replace --rm ${INDEX_IMAGE_PRUNED}
   sleep 10
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
   scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOVABLE_MEDIA_PATH}/${INDEX_CONTAINER_NAME}.txt ${REMOTE_USER}@${MIRROR_HOST}:${REMOVABLE_MEDIA_PATH}
   scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}.tar ${REMOTE_USER}@${MIRROR_HOST}:${REMOVABLE_MEDIA_PATH}
   ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${MIRROR_HOST} "sudo chown -R ${USER}. ${REMOVABLE_MEDIA_PATH}"
}

index_image_process() {
   if grep $pkg ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${RH_INDEX_VERSION_NEW}.txt; then
      index_image_prune
      index_image_download
      index_image_tar
      index_image_transfer
   else
      echo Skipping $pkg: not in ${RH_INDEX}-${RH_INDEX_VERSION_NEW}
   fi
}

date

# CERTIFIED OPERATOR INDEX
export RH_INDEX=certified-operator-index
for pkg in ${PKGS_CERTIFIED}; do
   index_image_process
done

# REDHAT OPERATOR INDEX
export RH_INDEX=redhat-operator-index
for pkg in ${PKGS_REDHAT}; do
   index_image_process
done

date
date
