date
 
#3.10. Upload the catalog images to the local container registry:
#3.11. Create the CatalogSource object by running the following command to specify the catalogSource.yaml file in your manifests directory:
#3.12. Create the ImageContentSourcePolicy (ICSP) object by running the following command to specify the imageContentSourcePolicy.yaml file in your manifests directory:

index_image_upload() {
  if grep $pkg ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${VERSION}.txt; then
    export MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${VERSION}
    export repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}
    mkdir -p ${repo_path}
    tar fvx ${repo_path}.tar -C ${repo_path} --strip-components=1
    cd ${repo_path}
    oc-${VERSION} adm catalog mirror file://${MIRROR_INDEX_REPOSITORY}/${RH_REPOSITORY}/${RH_INDEX}:${VERSION} ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY} --insecure
    shopt -s nullglob
    name=${MIRROR_INDEX_REPOSITORY//./-}
    for target in ${repo_path}/manifests-${RH_INDEX}-*/catalogSource.yaml; do
      sed -i "s|^name: .*$|name: ${name}|" $target
      oc-${RELEASE} apply --dry-run=client -f $target >/dev/null 2>&1 && oc-${RELEASE} apply -f $target
    done
    oc-${VERSION} adm catalog mirror ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY}/${RH_REPOSITORY}-${RH_INDEX}:${VERSION} ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY} --insecure --manifests-only
    for target in ${repo_path}/manifests-${RH_REPOSITORY}-${RH_INDEX}-*/imageContentSourcePolicy.yaml; do
      sed -i "s|^name: .*$|name: ${name}|" $target
      oc-${RELEASE} apply --dry-run=client -f $target >/dev/null 2>&1 && oc-${RELEASE} apply -f $target
    done
    shopt -u nullglob
  else
    echo Skipping $pkg: not in ${RH_INDEX}-${VERSION}
  fi
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
