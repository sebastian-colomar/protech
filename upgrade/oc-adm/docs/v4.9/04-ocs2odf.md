# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# 4.1. Upgrade OCS to ODF (Red Hat OpenShift Data Foundation)

## REFERENCES:
- https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0?topic=ocp-ocs-upgrade-in-connected-environment-by-using-red-hat-openshift-console-ui
- https://docs.redhat.com/en/documentation/red_hat_openshift_data_foundation/5.9/html/upgrading_to_openshift_data_foundation/updating-ocs-to-odf_rhodf


## Procedure

4.1.1. Check that the current custom catalog source of the ocs-operator and local-storage-operator are using the custom mirror catalog as shown:
```
NS=openshift-local-storage
SUB=local-storage-operator

oc get sub ${SUB} -n ${NS} -o jsonpath='{.spec.source}{" / "}{.spec.sourceNamespace}{" / "}{.spec.channel}{"\n"}'

```
```
NS=openshift-storage
SUB=ocs-operator

oc get sub ${SUB} -n ${NS} -o jsonpath='{.spec.source}{" / "}{.spec.sourceNamespace}{" / "}{.spec.channel}{"\n"}'

```
    
4.1.2. Ensure that the OpenShift Container Platform cluster has been successfully updated to version 4.9.59.
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

4.1.7. On the OpenShift Web Console, navigate to OperatorHub:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/operatorhub/ns/openshift-storage

4.1.8. Search for OpenShift Data Foundation using the Filter by keyword box and click on the OpenShift Data Foundation tile:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/operatorhub/ns/openshift-storage?keyword=openshift+data+foundation

4.1.9. Click Install:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/operatorhub/subscribe?pkg=odf-operator&catalog=mirror-redhat-operator-index-v4-9&catalogNamespace=openshift-marketplace&targetNamespace=openshift-storage

4.1.10. On the install Operator page, click Install. Wait for the Operator installation to complete.

### Note
> We recommend using all default settings. Changing it may result in unexpected behavior. Alter only if you are aware of its result.

## Verification steps

4.1.11. Verify that the page displays Succeeded message along with the option to Create StorageSystem.

### WARNING
> For the upgraded clusters, since the storage system is automatically created, do NOT create it again.

4.1.12. On the notification popup, click Refresh web console link to reflect the OpenShift Data Foundation changes in the OpenShift console.
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/operators.coreos.com~v1alpha1~ClusterServiceVersion/odf-operator.v4.9.15

4.1.13. Verify the state of the pods on the OpenShift Web Console. Wait for all the pods in the openshift-storage namespace to restart and reach Running state:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/pods

4.1.14. Enable the ODF console plugin:
```
oc patch console.operator cluster -n openshift-storage --type json -p '[{"op": "add", "path": "/spec/plugins", "value": ["odf-console"]}]'

```
4.1.15. Fix the MCG operator subscription:
```
CHANNEL=stable-4.9
NAMESPACE=openshift-storage
SOURCE=mirror-mcg-operator-v4-9
SOURCE_NAMESPACE=openshift-marketplace
SUB=mcg-operator

oc -n ${NAMESPACE} patch sub ${SUB} --type=merge -p '{"spec":{"channel":"'${CHANNEL}'","source":"'${SOURCE}'","sourceNamespace":"'${SOURCE_NAMESPACE}'"}}'

```

4.1.16. UPDATE the OCS operator subscription:
```
CHANNEL=stable-4.9
NAMESPACE=openshift-storage
SOURCE=mirror-ocs-operator-v4-9
SOURCE_NAMESPACE=openshift-marketplace
SUB=ocs-operator

oc -n ${NAMESPACE} patch sub ${SUB} --type=merge -p '{"spec":{"channel":"'${CHANNEL}'","source":"'${SOURCE}'","sourceNamespace":"'${SOURCE_NAMESPACE}'"}}'

```
4.1.17. Verify that the OpenShift Data Foundation cluster is healthy and data is resilient:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/cluster

4.1.18. Navigate to Storage OpenShift Data foundation Storage Systems tab and then click on the storage system name:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/cluster/systems

4.1.19. Check both Block and File and Object tabs for the green tick on the status card. Green tick indicates that the storage cluster, object service and data resiliency are all healthy:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/system/ocs.openshift.io~v1~storagecluster/ocs-storagecluster/overview/block-file
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/system/ocs.openshift.io~v1~storagecluster/ocs-storagecluster/overview/object

---

# 4.2. Upgrade the local-storage component to 4.9

WARNING:
> You must upgrade the local-storage component to 4.9 after completing the ODF 4.9 installation.

## Procedure

4.2.1. Go to the installed operators under `openshift-local-storage` namespace and click Local Storage operator:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-local-storage/operators.coreos.com~v1alpha1~ClusterServiceVersion/local-storage-operator.4.8.0-202212051626

4.2.2. UPDATE the OpenShift Local Storage operator:
```
CHANNEL=4.9
NAMESPACE=openshift-local-storage
SOURCE=mirror-local-storage-operator-v4-9
SOURCE_NAMESPACE=openshift-marketplace
SUB=local-storage-operator

oc -n ${NAMESPACE} patch sub ${SUB} --type=merge -p '{"spec":{"channel":"'${CHANNEL}'","source":"'${SOURCE}'","sourceNamespace":"'${SOURCE_NAMESPACE}'"}}'

```
4.2.3. Verify the successful update:
```
oc -n openshift-local-storage get sub

oc -n openshift-local-storage get csv

oc -n openshift-local-storage get po

```
