date
 
echo STARTED Upload the catalog images to the local container registry:
echo STARTED Create the CatalogSource object by running the following command to specify the catalogSource.yaml file in your manifests directory:
echo STARTED Create the ImageContentSourcePolicy (ICSP) object by running the following command to specify the imageContentSourcePolicy.yaml file in your manifests directory:

index_image_upload() {
  if grep $pkg ${REMOVABLE_MEDIA_PATH}/${RH_INDEX}-${VERSION}.txt; then
    MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${VERSION}
    repo_path=${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}
    mkdir -p ${repo_path}
    tar fvx ${repo_path}.tar -C ${repo_path} --strip-components=1
    cd ${repo_path}
    oc-${VERSION} adm catalog mirror file://${MIRROR_INDEX_REPOSITORY}/${RH_REPOSITORY}/${RH_INDEX}:${VERSION} ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY} --insecure
    name=${MIRROR_INDEX_REPOSITORY//./-}
    for target in ${repo_path}/manifests-${RH_INDEX}-*/catalogSource.yaml; do
      sed -i "s|name: .*$|name: ${name}|" ${target}
      oc-${RELEASE} apply -f ${target}
    done
    oc-${VERSION} adm catalog mirror ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY}/${RH_REPOSITORY}-${RH_INDEX}:${VERSION} ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY} --insecure --manifests-only
    for target in ${repo_path}/manifests-${RH_REPOSITORY}-${RH_INDEX}-*/imageContentSourcePolicy.yaml; do
      sed -i "s|name: .*$|name: ${name}|" ${target}
      oc-${RELEASE} apply -f ${target}
    done
  else
    echo Skipping $pkg: not in ${RH_INDEX}-${VERSION}
  fi
}

echo STARTED CERTIFIED OPERATOR INDEX

export RH_INDEX=certified-operator-index
for pkg in ${PKGS_CERTIFIED}; do
  index_image_upload
done

echo FINISHED CERTIFIED OPERATOR INDEX

echo STARTED REDHAT OPERATOR INDEX
export RH_INDEX=redhat-operator-index
for pkg in ${PKGS_REDHAT}; do
  index_image_upload
done

echo FINISHED REDHAT OPERATOR INDEX

echo FINISHED Upload the catalog images to the local container registry:
echo FINISHED Create the CatalogSource object by running the following command to specify the catalogSource.yaml file in your manifests directory:
echo FINISHED Create the ImageContentSourcePolicy (ICSP) object by running the following command to specify the imageContentSourcePolicy.yaml file in your manifests directory:

date
