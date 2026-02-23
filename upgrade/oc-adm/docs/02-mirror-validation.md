## 2. Verify the mirroring process

You should now have a valid disconnected mirror of the selected `RELEASE`.
To make sure everything worked correctly, check the following resources:
- `CatalogSources`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1alpha1~CatalogSource/instances
  ```
  oc get catsrc -n openshift-marketplace  | grep v${MAJOR}-${MINOR}
  
  ```
  ```
  for catsrc in $( oc get catsrc -n openshift-marketplace -o name | grep v${MAJOR}-${MINOR} );do
    oc get -n openshift-marketplace ${catsrc} -o jsonpath='{.metadata.name}{"\t"}{.status.connectionState.lastObservedState}{"\n"}'
  done
  
  ```
- `ImageContentSourcePolicies`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/cluster/operator.openshift.io~v1alpha1~ImageContentSourcePolicy/instances
  ```
  oc get imagecontentsourcepolicy | grep v${MAJOR}-${MINOR}
  
  ```
You may also find it helpful to review the following related resources:
- `Subscriptions`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1alpha1~Subscription/instances
  ```
  oc get sub -A | grep v${MAJOR}-${MINOR}
  
  ```
- `PackageManifests`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/packages.operators.coreos.com~v1~PackageManifest/instances
  ```
  oc get packagemanifest -A
  
  ```
- `Operators`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/cluster/operators.coreos.com~v1~Operator/instances
  ```
  oc get operator
  
  ```
- `OperatorGroups`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1~OperatorGroup/instances
  ```
  oc get og -A
  
  ```
- `OperatorConditions`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v2~OperatorCondition/instances
  ```
  oc get condition -A
  
  ```
- `InstallPlans`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1alpha1~InstallPlan/instances
  ```
  oc get ip -A
  
  ```
- `ClusterServiceVersions`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1alpha1~ClusterServiceVersion/instances
  ```
  oc get csv -A
  
  ```
- Validate that the ImageContentSourcePolicies have been rendered into a MachineConfig and successfully rolled out to all nodes before proceeding:
   - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/cluster/operator.openshift.io~v1alpha1~ImageContentSourcePolicy/instances
   ```
   export MIRROR_HOST=mirror.hub.sebastian-colomar.com

   for n in oc get nodes -o name); do echo "== $n =="; oc debug "$n" -q -- chroot /host grep -R "${MIRROR_HOST}:${MIRROR_PORT}"'"' /etc/containers || echo "Not found"; done

   ```
   
- Validate the content of the ImageContentSourcePolicy:

   ```

   ```

- Validate the CatalogSources:
   - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1alpha1~CatalogSource/instances
   ```
   oc get catsrc -A  
   ```

- Check the current Subscriptions:
   - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1alpha1~Subscription/instances
   ```
   oc get sub -A
   ```
