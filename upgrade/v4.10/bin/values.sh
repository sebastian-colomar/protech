# Set the required environment variables:

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
export LOCAL_SECRET_JSON=${HOME}/pull-secret.json

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

export SSH_KEY=${HOME}/key.txt

# These variables are derived from the previous ones:
export CONTAINERS_STORAGE_CONF=${REMOVABLE_MEDIA_PATH}/containers/storage.conf
export LOCAL_REGISTRY=${MIRROR_HOST}:${MIRROR_PORT}
export MIRROR_OCP_REPOSITORY=mirror-${OCP_REPOSITORY}-${RELEASE}
export TMPDIR=${REMOVABLE_MEDIA_PATH}/containers/cache
export VERSION=v${MAJOR}.${MINOR}

