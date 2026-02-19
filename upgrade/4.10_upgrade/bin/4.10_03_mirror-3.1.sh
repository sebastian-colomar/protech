
  # 3.1. Set the required environment variables:
   
  export ARCH_RELEASE=x86_64
  export BINARIES="oc opm"
  export BINARY_PATH=${HOME}/bin
  export CONTAINER_IMAGE=docker.io/library/registry
  export CONTAINER_IMAGE_TAG=2.7
  export CONTAINER_NAME=registry
  export CONTAINER_PORT=5000
  export CONTAINER_VOLUME=/var/lib/registry
  export MIRROR_HOST=mirror.hub.sebastian-colomar.com
  export MIRROR_PORT=5000
  export MIRROR_PROTOCOL=http
  export OCP_RELEASE_NEW=4.10.64
  export OCP_RELEASE_OLD=4.9.59
  export OCP_REPOSITORY=ocp
  export PACKAGES="openshift-client opm"
  export PKGS='ako-operator,cluster-logging,elasticsearch-operator,local-storage-operator,ocs-operator,odf-operator'
  export PKGS_CERTIFIED='ako-operator'
  export PKGS_REDHAT='cluster-logging,elasticsearch-operator,local-storage-operator,ocs-operator,odf-operator'
  
  export PRODUCT_REPO=openshift-release-dev
  export RELEASE_NAME=ocp-release
  export REMOVABLE_MEDIA_PATH=/mnt/mirror
  export RH_INDEX_LIST='certified-operator-index redhat-operator-index'
  export RH_INDEX_VERSION_NEW=v4.10
  export RH_INDEX_VERSION_OLD=v4.9
  export RH_REGISTRY=registry.redhat.io
  export RH_REPOSITORY=redhat
  
  export CONTAINERS_STORAGE_CONF=${REMOVABLE_MEDIA_PATH}/containers/storage.conf
  export LOCAL_REGISTRY=${MIRROR_HOST}:${MIRROR_PORT}
  export MIRROR_OCP_REPOSITORY=mirror-${OCP_REPOSITORY}-${OCP_RELEASE_NEW}
  export TMPDIR=${REMOVABLE_MEDIA_PATH}/containers/cache

