   # 2.0. Set up environment variables:
   
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
