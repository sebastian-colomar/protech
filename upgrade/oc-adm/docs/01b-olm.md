# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# 1B. Using Operator Lifecycle Manager on restricted networks 

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

1B.1. The environment variables should already be set from the previous step.

   - If you start a new session, you must set them again as described in step `1.3` of the document below:
      - [Getting your Jumphost ready](01-ocp.md)


1B.2. Allow unsigned registries for the Certified Operator Index:

   ```
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
   ```

1B.3. Run the source index image that you want to prune in a container:
   ```
   unalias cp mv rm || true
   
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
   
   for RH_INDEX in ${RH_INDEX_LIST}; do
      podman run --authfile ${LOCAL_SECRET_JSON} -d --name ${RH_INDEX}-${VERSION} -p 50051 --replace --rm ${RH_REGISTRY}/${RH_REPOSITORY}/${RH_INDEX}:${VERSION}
   done
   sleep 10

   ```

1B.4. Use the grpcurl command to get a list of the packages provided by the index:
   ```
   remote_transfer() {
      MIRROR_HOST=mirror.sebastian-colomar.com
      ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${MIRROR_HOST} "sudo mkdir -p ${REMOVABLE_MEDIA_PATH}"
      ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${MIRROR_HOST} "sudo chown -R ${REMOTE_USER}. ${REMOVABLE_MEDIA_PATH}"
      scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$@" ${REMOTE_USER}@${MIRROR_HOST}:${REMOVABLE_MEDIA_PATH}
      ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${MIRROR_HOST} "sudo chown -R ${USER}. ${REMOVABLE_MEDIA_PATH}"
   }
   
   for RH_INDEX in ${RH_INDEX_LIST}; do
      node_port=$( podman port ${RH_INDEX}-${VERSION} | cut -d: -f2 )
      podman run --network host --rm docker.io/fullstorydev/grpcurl:latest -plaintext localhost:${node_port} api.Registry/ListPackages | grep '"name"' | cut -d '"' -f4 | sort -u | tee ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${VERSION}.txt
      remote_transfer ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${VERSION}.txt
   done

   ```
   
1B.5. Inspect the `${RH_INDEX}-${version}.txt` file and identify which package names from this list you want to keep in your pruned index.

   Alternatively, list your current subscriptions:
   ```
   export PKGS=$(oc get subscriptions -A -o jsonpath='{range .items[*]}{.spec.name}{"\n"}{end}' | sort -u | paste -sd, -)

   ```

1B.6. Deploy the local container registry using the Distribution container image with the HTTP protocol:
   ```
   mkdir -p ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}
     
   podman run -d -e REGISTRY_STORAGE_DELETE_ENABLED=true --name ${CONTAINER_NAME} --replace --restart=always -p ${MIRROR_PORT}:${CONTAINER_PORT} -v ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}:${CONTAINER_VOLUME}:Z ${CONTAINER_IMAGE}:${CONTAINER_IMAGE_TAG}
   
   rm -fv ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}.tar
   podman save -o ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}.tar ${CONTAINER_IMAGE}:${CONTAINER_IMAGE_TAG}

   remote_transfer ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}.tar
   
   tee /etc/containers/registries.conf.d/99-localhost-insecure.conf >/dev/null <<EOF
   [[registry]]
   location = "localhost:${MIRROR_PORT}"
   insecure = true
   EOF

   ```

1B.7. Prune the source index of all but the specified packages and push the new index image to your target registry. Then mirror the content to local files. AFter that, copy the directory that is generated in your current directory to removable media. Finally, upload the generated tarball to the mirror host:
   ```
   ln -sfnT ${BINARY_PATH}/oc-${RELEASE} ${BINARY_PATH}/oc-${VERSION}
   ln -sfnT ${BINARY_PATH}/opm-${RELEASE} ${BINARY_PATH}/opm-${VERSION}

   index_image_prune() {
      INDEX_CONTAINER_NAME=${RH_INDEX}-${VERSION}-${pkg}
      INDEX_IMAGE=${RH_REGISTRY}/${RH_REPOSITORY}/${RH_INDEX}:${VERSION}   
      INDEX_IMAGE_PRUNED=localhost:${MIRROR_PORT}/${RH_REPOSITORY}/${RH_INDEX}:${VERSION}
      opm-${VERSION} index prune -f ${INDEX_IMAGE} -p ${pkg} -t ${INDEX_IMAGE_PRUNED}  
      podman push ${INDEX_IMAGE_PRUNED} --remove-signatures
      podman run -d --name ${INDEX_CONTAINER_NAME} -p 50051 --replace --rm ${INDEX_IMAGE_PRUNED}
      sleep 10
      node_port=$( podman port ${INDEX_CONTAINER_NAME} | cut -d: -f2 )
      podman run --network host --rm docker.io/fullstorydev/grpcurl:latest -plaintext localhost:${node_port} api.Registry/ListPackages | grep '"name"' | cut -d '"' -f4 | sort -u | tee ${REMOVABLE_MEDIA_PATH}/${INDEX_CONTAINER_NAME}.txt
   }
   
   index_image_download() {
      INDEX_IMAGE_PRUNED=localhost:${MIRROR_PORT}/${RH_REPOSITORY}/${RH_INDEX}:${VERSION}
      MIRROR_OLM_REPOSITORY=mirror-${pkg}
      MIRROR_INDEX_REPOSITORY=${MIRROR_OLM_REPOSITORY}-${VERSION}
      mkdir -p ${REMOVABLE_MEDIA_PATH}/${MIRROR_OLM_REPOSITORY}-${VERSION}
      cd ${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}
      oc-${VERSION} adm catalog mirror ${INDEX_IMAGE_PRUNED} file://${MIRROR_INDEX_REPOSITORY} -a ${LOCAL_SECRET_JSON} --index-filter-by-os=linux/${ARCH_CATALOG} --insecure
   }
   
   index_image_tar() {
      MIRROR_OLM_REPOSITORY=mirror-${pkg}
      MIRROR_INDEX_REPOSITORY=${MIRROR_OLM_REPOSITORY}-${VERSION}
      cd ${REMOVABLE_MEDIA_PATH}
      tar cfv ${MIRROR_INDEX_REPOSITORY}.tar ${MIRROR_INDEX_REPOSITORY}     
   }
   
   index_image_transfer() {
      INDEX_CONTAINER_NAME=${RH_INDEX}-${VERSION}-${pkg}
      MIRROR_OLM_REPOSITORY=mirror-${pkg}
      MIRROR_INDEX_REPOSITORY=${MIRROR_OLM_REPOSITORY}-${VERSION}
      remote_transfer ${REMOVABLE_MEDIA_PATH}/${INDEX_CONTAINER_NAME}.txt ${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}.tar   
   }
   
   index_image_process() {
      if grep $pkg ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${VERSION}.txt; then
         index_image_prune
         index_image_download
         index_image_tar
         index_image_transfer
      else
         echo Skipping $pkg: not in ${RH_INDEX}-${VERSION}
      fi
   }
   
   date
   
   ```
   ```
   # CERTIFIED OPERATOR INDEX
   export RH_INDEX=certified-operator-index
   for pkg in ${PKGS_CERTIFIED}; do
      export pkg
      index_image_process
   done
   
   ```
   ```
   # REDHAT OPERATOR INDEX
   export RH_INDEX=redhat-operator-index
   for pkg in ${PKGS_REDHAT}; do
      export pkg
      index_image_process
   done

   ```



