# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.


--- 

# Some troubleshooting hints:
   ```
   curl -s ${MIRROR_PROTOCOL}://${LOCAL_REGISTRY}/v2/
   ```
   ```
   curl -s ${MIRROR_PROTOCOL}://${LOCAL_REGISTRY}/v2/_catalog
   ```
   ```
   curl -s ${MIRROR_PROTOCOL}://${LOCAL_REGISTRY}/v2/${OCP_REPOSITORY}-${OCP_RELEASE_NEW}/tags/list | jq .
   ```
   ```
   curl -s ${MIRROR_PROTOCOL}://${LOCAL_REGISTRY}/v2/${OCP_REPOSITORY}-${OCP_RELEASE_OLD}/tags/list | jq .
   ```
   ```
   curl -s ${MIRROR_PROTOCOL}://${LOCAL_REGISTRY}/v2/${OCP_REPOSITORY}-${OCP_RELEASE_NEW}/tags/list | jq -r '.tags[]'
   ```
   ```
   curl -s ${MIRROR_PROTOCOL}://${LOCAL_REGISTRY}/v2/${OCP_REPOSITORY}-${OCP_RELEASE_OLD}/tags/list | jq -r '.tags[]'
   ```
   ```
   for tag in $( curl -s ${MIRROR_PROTOCOL}://${LOCAL_REGISTRY}/v2/${OCP_REPOSITORY}-${OCP_RELEASE_NEW}/tags/list | jq -r '.tags[]' );do
      curl -sIH 'Accept: application/vnd.docker.distribution.manifest.v2+json' ${MIRROR_PROTOCOL}://${LOCAL_REGISTRY}/v2/${OCP_REPOSITORY}-${OCP_RELEASE_NEW}/manifests/${tag} | awk /Docker-Content-Digest/'{print "'${tag}'",$2}'
   done
   ```
   ```
   for tag in $( curl -s ${MIRROR_PROTOCOL}://${LOCAL_REGISTRY}/v2/${OCP_REPOSITORY}-${OCP_RELEASE_OLD}/tags/list | jq -r '.tags[]' );do
      curl -sIH 'Accept: application/vnd.docker.distribution.manifest.v2+json' ${MIRROR_PROTOCOL}://${LOCAL_REGISTRY}/v2/${OCP_REPOSITORY}-${OCP_RELEASE_OLD}/manifests/${tag} | awk /Docker-Content-Digest/'{print "'${tag}'",$2}'
   done
   ```
   ```
   ls ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}/docker/registry/v2/repositories/${OCP_REPOSITORY}-${OCP_RELEASE_NEW}/_manifests/revisions/sha256/
   ```
   ```
   ls ${REMOVABLE_MEDIA_PATH}/${CONTAINER_NAME}/docker/registry/v2/repositories/${OCP_REPOSITORY}-${OCP_RELEASE_OLD}/_manifests/revisions/sha256/
   ```
   ```
   podman exec ${CONTAINER_NAME} ls ${CONTAINER_VOLUME}/docker/registry/v2/repositories/${OCP_REPOSITORY}-${OCP_RELEASE_NEW}/_manifests/revisions/sha256/
   ```
   ```
   podman exec ${CONTAINER_NAME} ls ${CONTAINER_VOLUME}/docker/registry/v2/repositories/${OCP_REPOSITORY}-${OCP_RELEASE_OLD}/_manifests/revisions/sha256/
   ```
- https://console-openshift-console.apps.hub.sebastian-colomar.com/settings/cluster/clusteroperators
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/all-namespaces/operators.coreos.com~v1alpha1~CatalogSource
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/all-namespaces/operators.coreos.com~v1alpha1~ClusterServiceVersion
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/all-namespaces/operators.coreos.com~v1alpha1~Subscription
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/cluster/config.openshift.io~v1~ClusterVersion/version
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/cluster/config.openshift.io~v1~OperatorHub/cluster/sources
- https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/cluster/operator.openshift.io~v1alpha1~ImageContentSourcePolicy/instances
- https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/packages.operators.coreos.com~v1~PackageManifest/instances
- https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1alpha1~InstallPlan/instances
