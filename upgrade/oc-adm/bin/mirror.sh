set -eux
: "${HOST:?HOST must be defined}"
: "${RELEASE:?RELEASE must be defined}"

export KUBECONFIG=${HOME}/auth/kubeconfig

BIN=$(cd "$(dirname "$0")" && pwd)
BIN_HOST=${BIN}/${HOST}

source ${BIN}/values.sh
source ${BIN_HOST}/*.sh
