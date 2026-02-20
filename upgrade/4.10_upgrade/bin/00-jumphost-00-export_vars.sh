   # 1.3. Set the required environment variables:

export ARCH_RELEASE=x86_64
export BINARIES="oc opm"
export BINARY_PATH=${HOME}/bin
#export LOCAL_SECRET_JSON=${XDG_RUNTIME_DIR}/containers/auth.json
#export LOCAL_SECRET_JSON=${HOME}/.docker/config.json
export LOCAL_SECRET_JSON=${HOME}/pull-secret.json
export MIRROR_HOST=mirror.hub.sebastian-colomar.com
export MIRROR_PORT=5000
export MIRROR_PROTOCOL=http
export OCP_RELEASE_NEW=4.10.64
export OCP_RELEASE_OLD=4.9.59
export OCP_REPOSITORY=ocp-release
export PACKAGES="openshift-client opm"
export PRODUCT_REPO=openshift-release-dev
export RELEASE_NAME=ocp-release
export REMOTE_USER=ec2-user
export REMOVABLE_MEDIA_PATH=/mnt/mirror
export SSH_KEY=${HOME}/key.txt

export LOCAL_REGISTRY=${MIRROR_HOST}:${MIRROR_PORT}
export MIRROR_OCP_REPOSITORY=mirror-${OCP_REPOSITORY}
