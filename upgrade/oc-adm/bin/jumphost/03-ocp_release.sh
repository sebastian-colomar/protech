date

echo STARTED Mirror the images and configuration manifests to a directory on the removable media:

sudo mkdir -p ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}
sudo chown -R ${USER}. ${REMOVABLE_MEDIA_PATH}
oc-${RELEASE} adm release mirror -a ${LOCAL_SECRET_JSON} quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${RELEASE}-${ARCH_RELEASE} --to-dir=${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}


echo FINISHED Mirror the images and configuration manifests to a directory on the removable media:

echo STARTED Retrieve the ImageContentSourcePolicy:

oc-${RELEASE} adm release mirror -a ${LOCAL_SECRET_JSON} quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${RELEASE}-${ARCH_RELEASE} --to=${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY} --to-release-image=${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY}:${RELEASE}-${ARCH_RELEASE} --insecure --dry-run | tee ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}/config/icsp.yaml
sed -i '0,/ImageContentSourcePolicy/d' ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}/config/icsp.yaml
sed -i 's/name: .*$/name: '${MIRROR_OCP_REPOSITORY}'/' ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}/config/icsp.yaml

echo FINISHED Retrieve the ImageContentSourcePolicy:

echo STARTED Create a tar archive containing the directory and its contents:

cd ${REMOVABLE_MEDIA_PATH}
tar cfv ${MIRROR_OCP_REPOSITORY}.tar ${MIRROR_OCP_REPOSITORY}

echo FINISHED Create a tar archive containing the directory and its contents:

echo STARTED Upload the release and the openshift client tarball to the mirror host:

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

echo FINISHED Upload the release and the openshift client tarball to the mirror host:

date
