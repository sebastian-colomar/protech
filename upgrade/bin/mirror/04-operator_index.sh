date
 
#3.10. Upload the catalog images to the local container registry:
#3.11. Create the CatalogSource object by running the following command to specify the catalogSource.yaml file in your manifests directory:
#3.12. Create the ImageContentSourcePolicy (ICSP) object by running the following command to specify the imageContentSourcePolicy.yaml file in your manifests directory:

index_image_upload() {
  export MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${RH_INDEX_VERSION_NEW}
  export repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}
  tar fvx ${repo_path}.tar -C ${repo_path} --strip-components=1
  cd ${repo_path}
  oc-${RH_INDEX_VERSION_NEW} adm catalog mirror file://${MIRROR_INDEX_REPOSITORY}/${RH_REPOSITORY}/${RH_INDEX}:${RH_INDEX_VERSION_NEW} ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY} --insecure
  sed -i 's|name: .*$|name: '${MIRROR_INDEX_REPOSITORY//./-}'|' ${repo_path}/manifests-${RH_INDEX}-*/catalogSource.yaml
  export target=$( ls ${repo_path}/manifests-${RH_INDEX}-*/catalogSource.yaml | tail -1 )
  oc-${OCP_RELEASE_OLD} apply -f ${target}
  oc-${RH_INDEX_VERSION_NEW} adm catalog mirror ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY}/${RH_REPOSITORY}-${RH_INDEX}:${RH_INDEX_VERSION_NEW} ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY} --insecure --manifests-only
  sed -i 's|name: .*$|name: '${MIRROR_INDEX_REPOSITORY//./-}'|' ${repo_path}/manifests-${RH_REPOSITORY}-${RH_INDEX}-*/imageContentSourcePolicy.yaml
  export target=$( ls ${repo_path}/manifests-${RH_REPOSITORY}-${RH_INDEX}-*/imageContentSourcePolicy.yaml | tail -1 )
  oc-${OCP_RELEASE_OLD} apply -f ${target}
}

# CERTIFIED OPERATOR INDEX
export RH_INDEX=certified-operator-index
for pkg in ${PKGS_CERTIFIED}; do
  index_image_upload
done

# REDHAT OPERATOR INDEX
export RH_INDEX=redhat-operator-index
for pkg in ${PKGS_REDHAT}; do
  index_image_upload
done

date
