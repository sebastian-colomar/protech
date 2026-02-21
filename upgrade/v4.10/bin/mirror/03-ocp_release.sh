date


#3.6. Allow HTTP connections to the mirror registry:

oc-${OCP_RELEASE_OLD} patch image.config.openshift.io/cluster --type=merge -p '{"spec":{"registrySources":{"insecureRegistries":["'${LOCAL_REGISTRY}'"]}}}'


#3.7. Upload the release images to the local container registry:

export repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}

sudo chown -R ${USER}. ${REMOVABLE_MEDIA_PATH}

mkdir -p ${repo_path}

tar fvx ${repo_path}.tar -C ${repo_path} --strip-components=1

oc-${OCP_RELEASE_NEW} image mirror "file://openshift/release:${OCP_RELEASE_NEW}-${ARCH_RELEASE}*" ${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY} --from-dir=${repo_path} --insecure


#3.8. Create the mirrored release image signature ConfigMap manifest:

targets="${repo_path}/config/signature-sha256-*.yaml"
shopt -s nullglob
for target in ${targets}; do
  oc-${OCP_RELEASE_OLD} apply --dry-run=client -f "${target}" >/dev/null 2>&1 && oc-${OCP_RELEASE_OLD} apply -f "${target}"
done
shopt -u nullglob


#3.9. Create the ImageContentSourcePolicy manifest:

target="${repo_path}/config/icsp.yaml"
shopt -s nullglob
for target in ${targets}; do
  oc-${OCP_RELEASE_OLD} apply --dry-run=client -f "${target}" >/dev/null 2>&1 && oc-${OCP_RELEASE_OLD} apply -f "${target}"
done
shopt -u nullglob


date
