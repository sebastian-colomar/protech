# source jumphost.sh

set -euv

export UPGRADE_BIN=${HOME}/protech/upgrade/bin

source ${UPGRADE_BIN}/jumphost/00-export_vars.sh
source ${UPGRADE_BIN}/jumphost/01-local_registry.sh
source ${UPGRADE_BIN}/jumphost/02-ocp_release.sh
source ${UPGRADE_BIN}/jumphost/03-mirroring.sh
source ${UPGRADE_BIN}/jumphost/04-operators.sh
