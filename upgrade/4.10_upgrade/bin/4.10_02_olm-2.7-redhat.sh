   # REDHAT OPERATOR INDEX
   export RH_INDEX=redhat-operator-index
   for pkg in ${PKGS_REDHAT}; do
      index_image_prune
      index_image_download
      index_image_tar
      index_image_transfer
   done
