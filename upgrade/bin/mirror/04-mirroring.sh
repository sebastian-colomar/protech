date

#3.6. Allow HTTP connections to the mirror registry:

oc-${OCP_RELEASE_OLD} patch image.config.openshift.io/cluster --type=merge -p '{"spec":{"registrySources":{"insecureRegistries":["'${LOCAL_REGISTRY}'"]}}}'


#3.7. Upload the release images to the local container registry:


sudo mkdir -p ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}

sudo chown -R ${USER}. ${REMOVABLE_MEDIA_PATH}

oc-${OCP_RELEASE_NEW} image mirror "file://openshift/release:${OCP_RELEASE_NEW}-${ARCH_RELEASE}*" ${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY} --from-dir=${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY} --insecure




#3.8. Create the mirrored release image signature ConfigMap manifest:

oc-${OCP_RELEASE_OLD} apply -f ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}/config/signature-sha256-*.yaml



#3.9. Create the ImageContentSourcePolicy manifest:

oc-${OCP_RELEASE_OLD} apply -f ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}/config/icsp.yaml

  
#3.10. Upload the catalog images to the local container registry:
#3.11. Create the CatalogSource object by running the following command to specify the catalogSource.yaml file in your manifests directory:
#3.12. Create the ImageContentSourcePolicy (ICSP) object by running the following command to specify the imageContentSourcePolicy.yaml file in your manifests directory:

index_image_upload() {
   export MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${RH_INDEX_VERSION_NEW}
   cd ${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}
   oc-${RH_INDEX_VERSION_NEW} adm catalog mirror file://${MIRROR_INDEX_REPOSITORY}/${RH_REPOSITORY}/${RH_INDEX}:${RH_INDEX_VERSION_NEW} ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY} --insecure
   sed -i 's|name: .*$|name: '${MIRROR_INDEX_REPOSITORY//./-}'|' ${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}/manifests-${RH_INDEX}-*/catalogSource.yaml
   export target=$( ls ${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}/manifests-${RH_INDEX}-*/catalogSource.yaml | tail -1 )
   oc-${OCP_RELEASE_OLD} apply -f ${target}
   oc-${RH_INDEX_VERSION_NEW} adm catalog mirror ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY}/${RH_REPOSITORY}-${RH_INDEX}:${RH_INDEX_VERSION_NEW} ${LOCAL_REGISTRY}/${MIRROR_INDEX_REPOSITORY} --insecure --manifests-only
   sed -i 's|name: .*$|name: '${MIRROR_INDEX_REPOSITORY//./-}'|' ${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}/manifests-${RH_REPOSITORY}-${RH_INDEX}-*/imageContentSourcePolicy.yaml
   export target=$( ls ${REMOVABLE_MEDIA_PATH}/${MIRROR_INDEX_REPOSITORY}/manifests-${RH_REPOSITORY}-${RH_INDEX}-*/imageContentSourcePolicy.yaml | tail -1 )
   oc-${OCP_RELEASE_OLD} apply -f ${target}
}

# CERTIFIED OPERATOR INDEX
cd ${REMOVABLE_MEDIA_PATH}
export RH_INDEX=certified-operator-index
for pkg in ${PKGS_CERTIFIED}; do
  index_image_upload
done

# REDHAT OPERATOR INDEX
cd ${REMOVABLE_MEDIA_PATH}
export RH_INDEX=redhat-operator-index
for pkg in ${PKGS_REDHAT}; do
  index_image_upload
done

date
