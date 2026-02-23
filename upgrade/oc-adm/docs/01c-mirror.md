# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---


# 1C. Mirror registry for Red Hat OpenShift

NOTE:
> Execute this procedure on a Linux machine reachable by the OpenShift cluster and equipped with at least 1 TB of mounted storage.

#### Procedure
1C.1. Set the required environment variables:
   
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

1C.2. Deploy the local container registry using the Distribution container image with the HTTP protocol:
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
   
   mkdir -p ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}
   
   podman load -i ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}.tar
   
   podman run -d -e REGISTRY_STORAGE_DELETE_ENABLED=true --name ${CONTAINER_NAME} --replace --restart=always -p ${MIRROR_PORT}:${CONTAINER_PORT} -v ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}:${CONTAINER_VOLUME}:Z ${CONTAINER_IMAGE}:${CONTAINER_IMAGE_TAG}
   
   tee /etc/containers/registries.conf.d/99-localhost-insecure.conf >/dev/null <<EOF
   [[registry]]
   location = "localhost:${MIRROR_PORT}"
   insecure = true
   EOF

   ```

1C.3. Install the OpenShift CLI:
   
   IMPORTANT:
   > If you are upgrading a cluster in a disconnected environment, install the oc version that you plan to upgrade to.

   ```
   cd ${HOME}
   mkdir -p ${BINARY_PATH}
   grep -q ":${BINARY_PATH}:" ~/.bashrc || echo "export PATH=\"${BINARY_PATH}:\${PATH}\"" | tee -a ~/.bashrc
   #source ~/.bashrc
   unalias cp mv rm 2>/dev/null || true
   for package in ${PACKAGES}; do
     mv -fv ${REMOVABLE_MEDIA_PATH}/${package}-linux-${RELEASE}.tar.gz ${HOME} || true
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

1C.4. Extract the tar archives containing the directory of the mirrored release images and catalogs and its contents:

   ```
   sudo chown -R ${USER}. ${REMOVABLE_MEDIA_PATH}

   repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}
   mkdir -p ${repo_path}
   tar fvx ${repo_path}.tar -C ${repo_path} --strip-components=1

   index_image_extract() {
     if grep $pkg ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${VERSION}.txt; then
       MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${VERSION}
       repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}
       mkdir -p ${repo_path}
       tar fvx ${repo_path}.tar -C ${repo_path} --strip-components=1
     else
       echo Skipping $pkg: not in ${RH_INDEX}-${VERSION}
     fi
   }
   
   # CERTIFIED OPERATOR INDEX
   export RH_INDEX=certified-operator-index
   for pkg in ${PKGS_CERTIFIED}; do
     index_image_extract
   done
   
   # REDHAT OPERATOR INDEX
   export RH_INDEX=redhat-operator-index
   for pkg in ${PKGS_REDHAT}; do
     index_image_extract
   done
   
   ```

1C.5. Login to the OpenShift cluster:

   ```
   oc login

   ```

1C.6. Allow HTTP connections to the mirror registry:

   ```
   oc-${RELEASE} patch image.config.openshift.io/cluster --type=merge -p '{"spec":{"registrySources":{"insecureRegistries":["'${LOCAL_REGISTRY}'"]}}}'

   ```

1C.7. Upload the release images to the local container registry:

   ```
   repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}
   oc-${RELEASE} image mirror "file://openshift/release:${RELEASE}-${ARCH_RELEASE}*" ${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY} --from-dir=${repo_path} --insecure

   ```

1C.8. Create the mirrored release image signature ConfigMap manifest:

   ```
   repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}
   targets="${repo_path}/config/signature-sha256-*.yaml"
   for target in ${targets}; do
     oc-${RELEASE} apply -f ${target}
   done

   ```

1C.9. Create the ImageContentSourcePolicy manifest:

   ```
   repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}
   target=${repo_path}/config/icsp.yaml
   for target in ${targets}; do
     oc-${RELEASE} apply -f ${target}
   done

   ```
     
1C.10. Upload the catalog images to the local container registry:
   ```
   index_image_upload() {
     if grep $pkg ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${VERSION}.txt; then
       MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${VERSION}
       repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}
       cd ${repo_path}
       oc-${VERSION} adm catalog mirror file://${MIRROR_INDEX_REPOSITORY}/${RH_REPOSITORY}/${RH_INDEX}:${VERSION} ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY} --insecure
     else
       echo Skipping $pkg: not in ${RH_INDEX}-${VERSION}
     fi
   }
   
   # CERTIFIED OPERATOR INDEX
   export RH_INDEX=certified-operator-index
   for pkg in ${PKGS_CERTIFIED}; do
     index_image_upload
   done
   
   # REDHAT OPERATOR INDEX
   export RH_INDEX=redhat-operator-index
   for pkg in ${PKGS_REDHAT}; do
     index_image_upload
   done

   ```

1C.11. Create the CatalogSource object by running the following command:
   ```
   create_catalog_source() {
     if grep $pkg ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${VERSION}.txt; then
       MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${VERSION}
       repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}
       name=${MIRROR_INDEX_REPOSITORY//./-}
       for target in ${repo_path}/manifests-${RH_INDEX}-*/catalogSource.yaml; do
         sed -i "s|name: .*$|name: ${name}|" ${target}
         oc-${RELEASE} apply -f ${target}
       done
     else
       echo Skipping $pkg: not in ${RH_INDEX}-${VERSION}
     fi
   }
   
   # CERTIFIED OPERATOR INDEX
   export RH_INDEX=certified-operator-index
   for pkg in ${PKGS_CERTIFIED}; do
     create_catalog_source
   done
   
   # REDHAT OPERATOR INDEX
   export RH_INDEX=redhat-operator-index
   for pkg in ${PKGS_REDHAT}; do
     create_catalog_source
   done

   ```

1C.12. Create the ImageContentSourcePolicy (ICSP) object by running the following command to specify the imageContentSourcePolicy.yaml file in your manifests directory:
   ```
   create_icsp() {
     if grep $pkg ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${VERSION}.txt; then
       MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${VERSION}
       name=${MIRROR_INDEX_REPOSITORY//./-}
       repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}
       cd ${repo_path}
       oc-${VERSION} adm catalog mirror ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY}/${RH_REPOSITORY}-${RH_INDEX}:${VERSION} ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY} --insecure --manifests-only
       for target in ${repo_path}/manifests-${RH_REPOSITORY}-${RH_INDEX}-*/imageContentSourcePolicy.yaml; do
         sed -i "s|name: .*$|name: ${name}|" $target
         oc-${RELEASE} apply -f $target
       done
     else
       echo Skipping $pkg: not in ${RH_INDEX}-${VERSION}
     fi
   }
   
   # CERTIFIED OPERATOR INDEX
   export RH_INDEX=certified-operator-index
   for pkg in ${PKGS_CERTIFIED}; do
     create_icsp
   done
   
   # REDHAT OPERATOR INDEX
   export RH_INDEX=redhat-operator-index
   for pkg in ${PKGS_REDHAT}; do
     create_icsp
   done

   ```

