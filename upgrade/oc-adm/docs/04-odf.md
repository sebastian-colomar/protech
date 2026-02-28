# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# 4.1. Upgrade OpenShift Data Foundation (ODF)

## REFERENCES:
- https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0?topic=ocp-ocs-upgrade-in-connected-environment-by-using-red-hat-openshift-console-ui
- https://docs.redhat.com/en/documentation/red_hat_openshift_data_foundation/4.9/html/upgrading_to_openshift_data_foundation/updating-ocs-to-odf_rhodf


## Procedure

4.1.2. Ensure that the OpenShift Container Platform cluster has been successfully updated to version 4.10.64:

```
oc get clusterversion

```
4.1.3. Ensure that the OpenShift Container Storage cluster is healthy and data is resilient:

```
oc -n openshift-storage exec deploy/rook-ceph-tools -- ceph status

```
4.1.4. Navigate to "Storage Overview" and check both "Block and File" and "Object" tabs for the green tick on the status card. Green tick indicates that the storage cluster, object service and data resiliency are all healthy:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/ocs-dashboards/block-file
- https://console-openshift-console.apps.hub.sebastian-colomar.com/ocs-dashboards/object

4.1.5. Ensure that all OpenShift Container Storage Pods, including the operator pods, are in Running state in the `openshift-storage` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/pods

```
oc -n openshift-storage get po

```

4.1.6. Ensure that you have sufficient time to complete the OpenShift Data Foundation update process, as the update time varies depending on the number of OSDs that run in the cluster.

4.1.7. UPDATE the ODF operator subscription:
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
CHANNEL=stable-${MAJOR}.${MINOR}
NS=openshift-storage
SOURCE_NS=openshift-marketplace
SUB=odf-operator

```
```
SOURCE=mirror-${SUB}-v${MAJOR}-${MINOR}

```
```
oc -n ${NS} patch sub ${SUB} --type=merge -p '{"spec":{"channel":"'${CHANNEL}'","source":"'${SOURCE}'","sourceNamespace":"'${SOURCE_NS}'"}}'

```

4.1.8. UPDATE the OCS operator subscription:
```
CHANNEL=stable-${MAJOR}.${MINOR}
NS=openshift-storage
SOURCE_NS=openshift-marketplace
SUB=ocs-operator

```
```
SOURCE=mirror-${SUB}-v${MAJOR}-${MINOR}

```
```
oc -n ${NS} patch sub ${SUB} --type=merge -p '{"spec":{"channel":"'${CHANNEL}'","source":"'${SOURCE}'","sourceNamespace":"'${SOURCE_NS}'"}}'

```

4.1.9. Fix the MCG operator subscription:

```
CHANNEL=stable-${MAJOR}.${MINOR}
NS=openshift-storage
SOURCE_NS=openshift-marketplace
SUB=mcg-operator

```
```
SOURCE=mirror-${SUB}-v${MAJOR}-${MINOR}

```
```
oc -n ${NS} patch sub ${SUB} --type=merge -p '{"spec":{"channel":"'${CHANNEL}'","source":"'${SOURCE}'","sourceNamespace":"'${SOURCE_NS}'"}}'

```

4.1.10. Check the status of the pods:

```
NS=openshift-storage

oc -n ${NS} get po

```

4.1.11. On the OpenShift Web Console, navigate to Installed Operators. Select `openshift-storage` project:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/operators.coreos.com~v1alpha1~ClusterServiceVersion

4.1.12. Wait for the OpenShift Data Foundation Operator Status to change to Up to date.


## Verification steps

4.1.13. Verify the state of the pods on the OpenShift Web Console. Wait for all the pods in the openshift-storage namespace to restart and reach Running state:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/pods

4.1.14. (IF NECESSARY) Enable the ODF console plugin:

```
oc patch console.operator cluster -n openshift-storage --type json -p '[{"op": "add", "path": "/spec/plugins", "value": ["odf-console"]}]'

```
4.1.15. Verify the state of the pods on the OpenShift Web Console. Wait for all the pods in the openshift-storage namespace to restart and reach Running state:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/pods

4.1.16. Verify that the OpenShift Data Foundation cluster is healthy and data is resilient:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/cluster

4.1.17. Navigate to Storage OpenShift Data foundation Storage Systems tab and then click on the storage system name:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/cluster/systems

4.1.18. Check both Block and File and Object tabs for the green tick on the status card. Green tick indicates that the storage cluster, object service and data resiliency are all healthy:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/system/ocs.openshift.io~v1~storagecluster/ocs-storagecluster/overview/block-file
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/system/ocs.openshift.io~v1~storagecluster/ocs-storagecluster/overview/object


# 4.2. Upgrade the local-storage component

WARNING:
> You must upgrade the local-storage component after completing the ODF upgrade.

## Procedure

4.2.1. UPDATE the OpenShift Local Storage operator subscription:


```
CHANNEL=${MAJOR}.${MINOR}
NS=openshift-local-storage
SOURCE_NS=openshift-marketplace
SUB=local-storage-operator

```
```
SOURCE=mirror-${SUB}-v${MAJOR}-${MINOR}

```
```
oc -n ${NS} patch sub ${SUB} --type=merge -p '{"spec":{"channel":"'${CHANNEL}'","source":"'${SOURCE}'","sourceNamespace":"'${SOURCE_NS}'"}}'

```

4.2.2. Verify the successful update:

```
oc -n openshift-local-storage get csv

oc -n openshift-local-storage get po

oc -n openshift-local-storage get sub

```
