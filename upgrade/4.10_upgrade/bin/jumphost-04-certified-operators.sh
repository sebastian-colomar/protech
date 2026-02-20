# CERTIFIED OPERATOR INDEX
export RH_INDEX=certified-operator-index
for pkg in ${PKGS_CERTIFIED}; do
   index_image_prune
   index_image_download
   index_image_tar
   index_image_transfer
done
