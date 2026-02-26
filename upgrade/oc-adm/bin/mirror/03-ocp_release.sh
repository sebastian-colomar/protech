date


echo STARTED Allow HTTP connections to the mirror registry:

oc-${RELEASE} patch image.config.openshift.io/cluster --type=merge -p '{"spec":{"registrySources":{"insecureRegistries":["'${LOCAL_REGISTRY}'"]}}}'

echo FINISHED Allow HTTP connections to the mirror registry:

echo STARTED Upload the release images to the local container registry:

repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}

sudo chown -R ${USER}. ${REMOVABLE_MEDIA_PATH}

mkdir -p ${repo_path}

cd ${REMOVABLE_MEDIA_PATH}
tar fvx ${repo_path}.tar

oc-${RELEASE} image mirror "file://openshift/release:${RELEASE}-${ARCH_RELEASE}*" ${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY} --from-dir=${repo_path} --insecure

echo FINISHED Upload the release images to the local container registry:

echo STARTED Create the mirrored release image signature ConfigMap manifest:

targets="${repo_path}/config/signature-sha256-*.yaml"
for target in ${targets}; do
  oc-${RELEASE} apply -f ${target}
done

echo FINISHED Create the mirrored release image signature ConfigMap manifest:

echo STARTED Create the ImageContentSourcePolicy manifest:

target=${repo_path}/config/icsp.yaml
for target in ${targets}; do
  oc-${RELEASE} apply -f ${target}
done

echo FINISHED Create the ImageContentSourcePolicy manifest:

date
