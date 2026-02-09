- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/operators/administrator-tasks#olm-restricted-networks
```
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```

Install the OPM cli by downloading the binary:
```
export BINARY_PATH=${HOME}/bin
export OCP_RELEASE_OLD=4.8.37
export PACKAGE_NAME=opm-linux.tar.gz
```
```
unalias cp mv rm
mkdir -p ${BINARY_PATH}
grep -q ":${BINARY_PATH}:" ~/.bashrc || echo "export PATH=\"${BINARY_PATH}:\${PATH}\"" | tee -a ~/.bashrc
source ~/.bashrc
curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_RELEASE_OLD}/${PACKAGE_NAME}
tar fxvz ${PACKAGE_NAME}
binaries='opm'
for binary in ${binaries}
  do
    mv ${binary} ${BINARY_PATH}
  done    
opm version
```

```
export LOCAL_SECRET_JSON=${HOME}/pull-secret.json
export REMOVABLE_MEDIA_PATH=/mnt/mirror
export RH_INDEX=redhat-operator-index:v4.8
export RH_REGISTRY=registry.redhat.io
export RH_REPOSITORY=redhat
```
```
sudo podman run --authfile ${LOCAL_SECRET_JSON} -d --name index -p 50051:50051 --rm ${RH_REGISTRY}/${RH_REPOSITORY}/${RH_INDEX}
sudo podman run --rm --network host docker.io/fullstorydev/grpcurl:latest -plaintext 127.0.0.1:50051 api.Registry/ListPackages | grep '"name"' | cut -d '"' -f4 | sort -u | tee ${REMOVABLE_MEDIA_PATH}/index.txt
sudo podman rm -f index
```
```
export PKGS=$(oc get subscriptions -A -o jsonpath='{range .items[*]}{.spec.name}{"\n"}{end}' | sort -u | paste -sd, -)
```
```
export ARCHITECTURE=amd64
export MIRROR_PORT=5000
export MIRROR_HOST=mirror.hub.sebastian-colomar.com
```
```
export LOCAL_REGISTRY=${MIRROR_HOST}:${MIRROR_PORT}
export OLM_NAMESPACE=olm
```
```
export INDEX_IMAGE=${RH_REGISTRY}/${RH_REPOSITORY}/${RH_INDEX}
export PRUNED_INDEX_IMAGE=localhost:5000/${RH_REPOSITORY}/${RH_INDEX}
```
```
mkdir -p ${HOME}/.docker
cp -fv ${LOCAL_SECRET_JSON} ${HOME}/.docker/config.json
#podman login ${RH_REGISTRY}
opm index prune -f ${INDEX_IMAGE} -p "${PKGS}" -t ${PRUNED_INDEX_IMAGE}
```
```
export MIRROR_PORT=5000
export CONTAINER_IMAGE=docker.io/library/registry
export CONTAINER_IMAGE_TAG=2.7
export CONTAINER_NAME=registry
export CONTAINER_PORT=5000
export CONTAINER_VOLUME=/var/lib/registry
```
```
sudo mkdir -p ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}
sudo podman run -d --name ${CONTAINER_NAME} --restart=always -p ${MIRROR_PORT}:${CONTAINER_PORT} -v ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}:${CONTAINER_VOLUME}:Z ${CONTAINER_IMAGE}:${CONTAINER_IMAGE_TAG}
```
```
sudo tee /etc/containers/registries.conf.d/99-localhost-insecure.conf >/dev/null <<'EOF'
[[registry]]
location = "localhost:5000"
insecure = true
EOF
sudo podman push ${PRUNED_INDEX_IMAGE}
```
```
mkdir -p ${REMOVABLE_MEDIA_PATH}/${OLM_NAMESPACE}
oc adm catalog mirror ${PRUNED_INDEX_IMAGE} file://${REMOVABLE_MEDIA_PATH}/${OLM_NAMESPACE} -a ${LOCAL_SECRET_JSON} --index-filter-by-os=linux/${ARCHITECTURE} --insecure --dir ${REMOVABLE_MEDIA_PATH}/${OLM_NAMESPACE}
```
```
oc adm catalog mirror file://${REMOVABLE_MEDIA_PATH}/${OLM_NAMESPACE}/index/redhat/${RH_INDEX} ${LOCAL_REGISTRY}/${OLM_NAMESPACE} -a ${REG_CREDS} --insecure
oc adm catalog mirror ${LOCAL_REGISTRY}/${OLM_NAMESPACE}/${RH_INDEX} ${LOCAL_REGISTRY}/{OLM_NAMESPACE} -a ${REG_CREDS} --insecure --manifests-only
```
```
oc apply -f manifests-*/imageContentSourcePolicy.yaml
```
