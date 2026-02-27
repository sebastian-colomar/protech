## 2. Verify the mirroring process

### Validate that the ImageContentSourcePolicy for ALL THE OPERATORS has been rendered into a MachineConfig and successfully rolled out to all nodes before proceeding:

#### WARNING
>
> THIS STEP IS VERY IMPORTANT
>
> IF ANY NODES WERE NOT UPDATED WITH THE CORRECT IMAGECONTENTSOURCEPOLICY BEFORE STARTING THE UPGRADE, THE CLUSTER MAY BECOME UNSTABLE OR BROKEN.

#### WARNING
> The RELEASE variable for the version you want to mirror should already be exported

```
if [ -z "${RELEASE}" ]; then
  echo "ERROR: RELEASE is not set or empty"
  exit 1
fi

MAJOR=$( echo ${RELEASE} | cut -d. -f1 )
MINOR=$( echo ${RELEASE} | cut -d. -f2 )
VERSION=v${MAJOR}.${MINOR}

```
```
# PKGS_CERTIFIED contains the operators from the certified-operator-index
# "ako-operator" is just an example for testing purposes, simulating an external operator such as IBM operators
PKGS_CERTIFIED='ako-operator'
# PKGS_REDHAT contains the operators from the redhat-operator-index
PKGS_REDHAT='cluster-logging elasticsearch-operator local-storage-operator mcg-operator ocs-operator odf-csi-addons-operator odf-operator'

```
```
check_icsp_rollout() {
  pkg_fullname=mirror-${pkg}-${VERSION}
  echo CHECKING THAT THE IMAGE CONTENT SOURCE POLICY FOR ${pkg_fullname} HAS BEEN ROLLED OUT TO ALL NODES...
  for n in $(oc get nodes -o name); do
    echo "== $n =="
    oc debug "$n" -q -- chroot /host grep -r ${pkg_fullname} /etc/containers -q && echo FOUND || echo NOT FOUND
  done
}
```
```
export RH_INDEX=certified-operator-index
for pkg in ${PKGS_CERTIFIED}; do
  check_icsp_rollout
done

```
```
echo started '# REDHAT OPERATOR INDEX'
export RH_INDEX=redhat-operator-index
for pkg in ${PKGS_REDHAT}; do
  check_icsp_rollout
done

```

---

You should now have a valid disconnected mirror of the selected `RELEASE`.
To make sure everything worked correctly, check the following resources:
- `CatalogSources`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1alpha1~CatalogSource/instances
  ```
  oc get catsrc -A
  
  ```
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
  oc get imagecontentsourcepolicy
  
  ```
  ```
  oc get imagecontentsourcepolicy | grep v${MAJOR}-${MINOR}
  
  ```
You may also find it helpful to review the following related resources:
- `Subscriptions`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1alpha1~Subscription/instances
  ```
  oc get sub -A
  
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
   if [ -z "${RELEASE}" ]; then
     echo "ERROR: RELEASE is not set or empty"
     exit 1
   fi

   MAJOR=$( echo ${RELEASE} | cut -d. -f1 )
   MINOR=$( echo ${RELEASE} | cut -d. -f2 )
   VERSION=v${MAJOR}.${MINOR}
 
   for n in $(oc get nodes -o name); do echo "== $n =="; oc debug "$n" -q -- chroot /host grep -r -E "${RELEASE}|${VERSION}" /etc/containers || echo "Not found"; done


   ```
   
