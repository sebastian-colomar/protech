# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# 1. Upgrade OpenShift Data Foundation (ODF)

## REFERENCES:
- https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0?topic=ocp-ocs-upgrade-in-connected-environment-by-using-red-hat-openshift-console-ui
- https://docs.redhat.com/en/documentation/red_hat_openshift_data_foundation/4.9/html/upgrading_to_openshift_data_foundation/updating-ocs-to-odf_rhodf


## Procedure

1.1. Update the current custom catalog source of the ocs-operator and local-storage-operator to use the new custom mirror catalog as shown:

   ```
   if [ -z "${RELEASE}" ]; then
     echo "ERROR: RELEASE is not set or empty"
     exit 1
   fi

   MAJOR=$( echo ${RELEASE} | cut -d. -f1 )
   MINOR=$( echo ${RELEASE} | cut -d. -f2 )
   PATCH=$( echo ${RELEASE} | cut -d. -f3 )
   VERSION=v${MAJOR}.${MINOR}

   ```
   ```
   NAMESPACE=openshift-storage
   pkg=ocs-operator

   ```
   ```
   MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${VERSION}
   CATALOG_SOURCE=${MIRROR_INDEX_REPOSITORY//./-}

   ```
   ```  
   oc patch sub ${pkg} -n ${NAMESPACE} --type json --patch '[{"op": "replace", "path": "/spec/source", "value": "'${CATALOG_SOURCE}'" }]'

   ```
    Now the same for the `local-storage-operator`
   ```
   NAMESPACE=openshift-local-storage
   pkg=local-storage-operator

   ```
   ```
   MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${VERSION}
   CATALOG_SOURCE=${MIRROR_INDEX_REPOSITORY//./-}

   ```
   ```  
   oc patch sub ${pkg} -n ${NAMESPACE} --type json --patch '[{"op": "replace", "path": "/spec/source", "value": "'${CATALOG_SOURCE}'" }]'

   ```

1.2. Ensure that the OpenShift Container Platform cluster has been successfully updated to the new release:
    ```
    oc get clusterversion

    ```
1.3. Ensure that the OpenShift Container Storage cluster is healthy and data is resilient:

    ```
    oc -n openshift-storage exec deploy/rook-ceph-tools -- ceph status

    ```
1.4. Navigate to "Storage Overview" and check both "Block and File" and "Object" tabs for the green tick on the status card. Green tick indicates that the storage cluster, object service and data resiliency are all healthy:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/ocs-dashboards/block-file
- https://console-openshift-console.apps.hub.sebastian-colomar.com/ocs-dashboards/object

1.5. Ensure that all OpenShift Container Storage Pods, including the operator pods, are in Running state in the `openshift-storage` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/pods

    ```
    oc -n openshift-storage get po

    ```

1.6. Ensure that you have sufficient time to complete the OpenShift Data Foundation update process, as the update time varies depending on the number of OSDs that run in the cluster.

## Verification steps

1.7. Verify the state of the pods on the OpenShift Web Console. Wait for all the pods in the openshift-storage namespace to restart and reach Running state:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/pods

1.8. (IF NECESSARY) Enable the ODF console plugin:

    ```
    oc patch console.operator cluster -n openshift-storage --type json -p '[{"op": "add", "path": "/spec/plugins", "value": ["odf-console"]}]'

    ```
1.9. Verify that the OpenShift Data Foundation cluster is healthy and data is resilient:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/cluster

1.10. Navigate to Storage OpenShift Data foundation Storage Systems tab and then click on the storage system name:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/cluster/systems

1.11. Check both Block and File and Object tabs for the green tick on the status card. Green tick indicates that the storage cluster, object service and data resiliency are all healthy:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/system/ocs.openshift.io~v1~storagecluster/ocs-storagecluster/overview/block-file
- https://console-openshift-console.apps.hub.sebastian-colomar.com/odf/system/ocs.openshift.io~v1~storagecluster/ocs-storagecluster/overview/object



# 2. Upgrade the local-storage component

WARNING:
> You must upgrade the local-storage component after completing the ODF upgrade.

## Procedure

2.1. Go to the installed operators under `openshift-local-storage` namespace and click Local Storage operator:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-local-storage/operators.coreos.com~v1alpha1~ClusterServiceVersion/local-storage-operator.4.8.0-202212051626

2.2. Go to the subscription and update the channel and the source to use 4.9:

    ```
    oc -n openshift-local-storage patch subscription local-storage-operator --type=merge -p '{"spec":{"channel":"4.9","source":"mirror-redhat-operator-index-v4-9","sourceNamespace":"openshift-marketplace"}}'

    ```
2.3. Verify the successful update:

    ```
    oc -n openshift-local-storage get csv

    oc -n openshift-local-storage get po

    oc -n openshift-local-storage get sub

    ```

