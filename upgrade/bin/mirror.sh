# source mirror.sh

set -euv

export UPGRADE_BIN=${HOME}/protech/upgrade/bin

source ${UPGRADE_BIN}/mirror/00-export_vars.sh
source ${UPGRADE_BIN}/mirror/01-local_registry.sh
source ${UPGRADE_BIN}/mirror/02-cli.sh
source ${UPGRADE_BIN}/mirror/03-operators.sh
source ${UPGRADE_BIN}/mirror/04-mirroring.sh
