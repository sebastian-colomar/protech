set -eux

source ${UPGRADE_PATH}/00-export_vars.sh
source ${UPGRADE_PATH}/01-local_registry.sh
source ${UPGRADE_PATH}/02-cli.sh
source ${UPGRADE_PATH}/03-ocp_release.sh
source ${UPGRADE_PATH}/04-operator_index.sh
