date


# 3.4. Extract the tar archives containing the directory of the mirrored images and catalogs and its contents:

cd ${REMOVABLE_MEDIA_PATH}
tar fvx ${MIRROR_OCP_REPOSITORY}.tar

# CERTIFIED OPERATOR INDEX
export RH_INDEX=certified-operator-index
for pkg in ${PKGS_CERTIFIED}; do
   export MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${RH_INDEX_VERSION_NEW}
   tar fvx ${MIRROR_INDEX_REPOSITORY}.tar
done

# REDHAT OPERATOR INDEX
export RH_INDEX=redhat-operator-index
for pkg in ${PKGS_REDHAT}; do
   export MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${RH_INDEX_VERSION_NEW}
   tar fvx ${MIRROR_INDEX_REPOSITORY}.tar
done


date
