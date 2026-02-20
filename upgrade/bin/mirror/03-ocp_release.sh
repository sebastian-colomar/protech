date


#3.6. Allow HTTP connections to the mirror registry:

oc-${OCP_RELEASE_OLD} patch image.config.openshift.io/cluster --type=merge -p '{"spec":{"registrySources":{"insecureRegistries":["'${LOCAL_REGISTRY}'"]}}}'


#3.7. Upload the release images to the local container registry:

export repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}

tar fvx ${MIRROR_OCP_REPOSITORY}.tar -C ${repo_path} --strip-components=1

sudo mkdir -p ${repo_path}

sudo chown -R ${USER}. ${REMOVABLE_MEDIA_PATH}

oc-${OCP_RELEASE_NEW} image mirror "file://openshift/release:${OCP_RELEASE_NEW}-${ARCH_RELEASE}*" ${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY} --from-dir=${repo_path} --insecure


#3.8. Create the mirrored release image signature ConfigMap manifest:

oc-${OCP_RELEASE_OLD} apply -f ${repo_path}/config/signature-sha256-*.yaml


#3.9. Create the ImageContentSourcePolicy manifest:

oc-${OCP_RELEASE_OLD} apply -f ${repo_path}/config/icsp.yaml


date
