

#3.2. (IF NOT ALREADY PRESENT) Deploy the local container registry using the Distribution container image with the HTTP protocol:   mkdir -p ${REMOVABLE_MEDIA_PATH}/containers
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
