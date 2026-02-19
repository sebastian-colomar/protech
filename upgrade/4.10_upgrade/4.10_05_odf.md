# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# 1. Upgrade OCS to Red Hat OpenShift Data Foundation (ODF)

## REFERENCES:
- https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0?topic=ocp-ocs-upgrade-in-connected-environment-by-using-red-hat-openshift-console-ui
- https://docs.redhat.com/en/documentation/red_hat_openshift_data_foundation/4.10/html/updating_openshift_data_foundation/updating-ocs-to-odf_rhodf

#TODO
  
## Procedure

1.1. Update the current custom catalog source of the ocs-operator and local-storage-operator to use the custom mirror catalog as shown:

    alias oc=oc-4.10.64

    export CATALOG_SOURCE=mirror-redhat-operator-index-v4-10
    
    oc patch subscription local-storage-operator -n openshift-local-storage --type json --patch '[{"op": "replace", "path": "/spec/source", "value": "'${CATALOG_SOURCE}'" }]'
    
    oc patch subscription ocs-operator -n openshift-storage --type json --patch '[{"op": "replace", "path": "/spec/source", "value": "'${CATALOG_SOURCE}'" }]'

    oc patch subscription odf-operator -n openshift-storage --type json --patch '[{"op": "replace", "path": "/spec/source", "value": "'${CATALOG_SOURCE}'" }]'

    oc patch subscription mcg-operator -n openshift-storage --type json --patch '[{"op": "replace", "path": "/spec/source", "value": "'${CATALOG_SOURCE}'" }]'


1.2. Ensure that the OpenShift Container Platform cluster has been successfully updated to version 4.10.64:

    oc get clusterversion

1.3. Ensure that the OpenShift Container Storage cluster is healthy and data is resilient:

    oc -n openshift-storage rsh `oc get pods -n openshift-storage | grep ceph-tool | cut -d ' ' -f1` ceph status

1.4. Navigate to "Storage Overview" and check both "Block and File" and "Object" tabs for the green tick on the status card. Green tick indicates that the storage cluster, object service and data resiliency are all healthy:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/ocs-dashboards/block-file
- https://console-openshift-console.apps.hub.sebastian-colomar.com/ocs-dashboards/object

1.5. Ensure that all OpenShift Container Storage Pods, including the operator pods, are in Running state in the `openshift-storage` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/pods

    ```
    oc -n openshift-storage get po
    ```

1.6. Ensure that you have sufficient time to complete the OpenShift Data Foundation update process, as the update time varies depending on the number of OSDs that run in the cluster.

1.7. On the OpenShift Web Console, navigate to Installed Operators. Select `openshift-storage` project:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/operators.coreos.com~v1alpha1~ClusterServiceVersion

1.8. Click the OpenShift Data Foundation operator name:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/operators.coreos.com~v1alpha1~ClusterServiceVersion/odf-operator.v4.9.15

1.9. Click the Subscription tab and click the link under Update Channel:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/operators.coreos.com~v1alpha1~ClusterServiceVersion/odf-operator.v4.9.15/subscription

1.10. Select the Stable-4.10 update channel and Save it.

1.11. On the OpenShift Web Console, navigate to Installed Operators. Select `openshift-storage` project:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/operators.coreos.com~v1alpha1~ClusterServiceVersion

1.12. Wait for the OpenShift Data Foundation Operator Status to change to Up to date.

1.13. Update the current custom catalog source of the `odf-csi-addons-operator` to use the custom mirror catalog as shown:

    alias oc=oc-4.10.64

    export CATALOG_SOURCE=mirror-redhat-operator-index-v4-10
        
    oc patch subscription odf-csi-addons-operator -n openshift-storage --type json --patch '[{"op": "replace", "path": "/spec/source", "value": "'${CATALOG_SOURCE}'" }]'



## Verification steps

1.14. Verify the state of the pods on the OpenShift Web Console. Wait for all the pods in the openshift-storage namespace to restart and reach Running state:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/pods

1.15. Verify that the OpenShift Data Foundation cluster is healthy and data is resilient:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/cluster

1.16. Navigate to Storage OpenShift Data foundation Storage Systems tab and then click on the storage system name:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/cluster/systems

1.17. Check both Block and File and Object tabs for the green tick on the status card. Green tick indicates that the storage cluster, object service and data resiliency are all healthy:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/system/ocs.openshift.io~v1~storagecluster/ocs-storagecluster/overview/block-file
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/system/ocs.openshift.io~v1~storagecluster/ocs-storagecluster/overview/object



# 2. Upgrade the local-storage component to 4.10

WARNING:
> You must upgrade the local-storage component to 4.10 after the completing ODF 4.10 installation.

## Procedure

2.1. Go to the installed operators under `openshift-local-storage` namespace and click Local Storage operator:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-local-storage/operators.coreos.com~v1alpha1~ClusterServiceVersion

2.2. Click the Subscription tab and click the link under Update Channel.

1.10. Select the `4.10` update channel and Save it.

2.3. Verify the successful update:

    oc -n openshift-local-storage get sub

    oc -n openshift-local-storage get csv

