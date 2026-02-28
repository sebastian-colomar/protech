# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.


--- 

# 2B. Preparation for the Upgrade: Mirror Switch

## Motivation

> Before starting the cluster release upgrade, we will first verify that the mirrored operator catalog is healthy and consistent.
>
> The cluster release must be upgraded before upgrading any operators. However, since it is not possible to downgrade the cluster release if something goes wrong, we want to ensure that the operator CatalogSources are working correctly before proceeding.
>
> In this step, we will not upgrade any operators. We will only update the operator Subscriptions to point to the new mirrored catalog instead of the original source. The operator versions will remain exactly the same as in the current cluster state.

## Warning

> During this step, we are **not** upgrading the cluster or any operators.
> We are only changing the operator Subscriptions to use the new mirror, while keeping the same versions and releases as before.


## Prerequisites
> You must have a recent etcd backup in case your update fails and you must restore your cluster to a previous state.
>
> You can refer to the link below for detailed instructions on how to create a backup of the cluster:
>
> - [Control plane backup and restore](../cluster-disaster-recovery/etcd-backup.md)

### Before you begin
- https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0?topic=ocp-ocs-upgrade-in-connected-environment-by-using-red-hat-openshift-console-ui
  
Make sure that:
- The cluster is in healthy state by running the following command:
  ```
  oc get nodes
  
  ```
- The machine config pools (MCP) are up to date by running the following command:
  ```
  oc get mcp
  
  ```
- All cluster operators are in healthy state by running the following command:
  ```
  oc get co
  
  ```
- Configuring the Rook-Ceph Toolbox in OpenShift Data Foundation 4.8:
  ```
  oc patch OCSInitialization ocsinit -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
  
  ```
- OpenShift Container Storage (OCS) ceph status is HEALTH_OK by running the following command:
  ```
  oc -n openshift-storage exec deploy/rook-ceph-tools -- ceph status
  
  ```

NOTE:
> All the commands that are mentioned here are to be run from e1n1 except where it mentions otherwise.

### Preparing to upgrade the disconnected cluster

## WARNING
> Before you continue, make sure you have checked and confirmed that the mirroring deployment is working correctly:
> - [Verify the mirroring process](02-mirror-validation.md)

#### Procedure

---

### OpenShift Container Storage operator (OCS)

2B.0. Set the environment variables

   ### WARNING
  
   > Make sure that the **RELEASE** value is still the same as the cluster’s **original release**.
   >
   > **No upgrade must happen at this stage.**

   ```
   if [ -z "${RELEASE}" ]; then
     echo "ERROR: RELEASE is not set or empty"
     exit 1
   fi

   MAJOR=$( echo ${RELEASE} | cut -d. -f1 )
   MINOR=$( echo ${RELEASE} | cut -d. -f2 )
   PATCH=$( echo ${RELEASE} | cut -d. -f3 )
   VERSION=v${MAJOR}.${MINOR}

   MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${VERSION}
   CATALOG_SOURCE=${MIRROR_INDEX_REPOSITORY//./-}

   ```

2B.1. Ensure that all OpenShift Container Storage Pods, including the operator pods, are in Running state in the `openshift-storage` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/pods

    ```
    oc -n openshift-storage get po

    ```

2B.2. Update the current custom catalog source of the `ocs-operator` to use the custom mirror catalog:

   ```
   NAMESPACE=openshift-storage
   pkg=ocs-operator

   MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${VERSION}
   CATALOG_SOURCE=${MIRROR_INDEX_REPOSITORY//./-}

   ```
   ```  
   oc patch sub ${pkg} -n ${NAMESPACE} --type json --patch '[{"op": "replace", "path": "/spec/source", "value": "'${CATALOG_SOURCE}'" }]'

   ```
  
2B.3. Verify that the OpenShift Container Platform cluster is still running the original release and that no upgrade has been performed:

  ```
  oc get clusterversion

  ```
2B.4. Ensure that the OpenShift Container Storage cluster is healthy and data is resilient:
  ```
  oc -n openshift-storage exec deploy/rook-ceph-tools -- ceph status

  ```
2B.5. Navigate to "Storage Overview" and check both "Block and File" and "Object" tabs for the green tick on the status card. Green tick indicates that the storage cluster, object service and data resiliency are all healthy:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/ocs-dashboards/block-file
- https://console-openshift-console.apps.hub.sebastian-colomar.com/ocs-dashboards/object

2B.6. Ensure that all OpenShift Container Storage Pods, including the operator pods, are in Running state in the `openshift-storage` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-storage/pods

    ```
    oc -n openshift-storage get po

    ```

---

### OpenShift Local Storage operator (LSO)

2B.7. Ensure that all OpenShift Local Storage Pods, including the operator pods, are in Running state in the `openshift-local-storage` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-local-storage/pods

    ```
    oc -n openshift-local-storage get po

    ```

2B.8. Update the current custom catalog source of the `local-storage-operator` to use the custom mirror catalog:

   ### WARNING
  
   > Make sure that the **RELEASE** value is still the same as the cluster’s **original release**.
   >
   > **No upgrade must happen at this stage.**

   ```
   NAMESPACE=openshift-local-storage
   pkg=local-storage-operator

   ```
   ```  
   oc patch sub ${pkg} -n ${NAMESPACE} --type json --patch '[{"op": "replace", "path": "/spec/source", "value": "'${CATALOG_SOURCE}'" }]'

   ```
  
2B.9. Ensure that all OpenShift Local Storage Pods, including the operator pods, are in Running state in the `openshift-local-storage` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-local-storage/pods

    ```
    oc -n openshift-local-storage get po

    ```

---

### ElasticSearch operator


2B.10. Ensure that all Elastic Search and OpenShift Cluster Logging Pods, including the operator pods, are in Ready state in the `openshift-logging` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-operators-redhat/pods
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-logging/pods

    ```
    oc -n openshift-operators-redhat get po

    oc -n openshift-logging get po

    ```

2B.11. Ensure that the Elasticsearch cluster is healthy:

    oc exec -n openshift-logging -c elasticsearch svc/elasticsearch -- health
    

2B.12. Update the current custom catalog source of the `elasticsearch-operator` to use the custom mirror catalog:

   ### WARNING
  
   > Make sure that the **RELEASE** value is still the same as the cluster’s **original release**.
   >
   > **No upgrade must happen at this stage.**

   ```
   NAMESPACE=openshift-operators-redhat
   pkg=elasticsearch-operator

   MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${VERSION}
   CATALOG_SOURCE=${MIRROR_INDEX_REPOSITORY//./-}

   ```
   ```  
   oc patch sub ${pkg} -n ${NAMESPACE} --type json --patch '[{"op": "replace", "path": "/spec/source", "value": "'${CATALOG_SOURCE}'" }]'

   ```


2B.13. Ensure that all Elastic Search and OpenShift Cluster Logging Pods, including the operator pods, are in Ready state in the `openshift-logging` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-operators-redhat/pods
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-logging/pods

    ```
    oc -n openshift-operators-redhat get po

    oc -n openshift-logging get po

    ```

2B.14. Ensure that the Elasticsearch cluster is healthy:

    ```
    oc exec -n openshift-logging -c elasticsearch svc/elasticsearch -- health
    
    ```

2B.15. Ensure that the Elasticsearch cron jobs are created:

    ```
    oc -n openshift-logging get cj
    
    ```

2B.16. Verify that the log store is updated and the indices are green. Verify that the output includes the `app-00000x, infra-00000x, audit-00000x, .security` indices:

    ```
    oc exec -n openshift-logging -c elasticsearch svc/elasticsearch-cluster -- indices | grep -E "health|app-|audit-|infra-|.security"
    
    ```

2B.17. Verify that the log collector is healthy:

    ```
    oc -n openshift-logging get ds collector
    
    ```

2B.18. Verify that the pod contains a collector container:

    ```
    oc -n openshift-logging get ds collector -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{"\n"}{end}' | grep collector
    
    ```

2B.19. Verify that the Kibana pod is in Ready status:

    ```
    oc -n openshift-logging get pods -l component=kibana -o jsonpath='{range .items[*]}{.metadata.name}{" -> "}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}'

    ```

---

### Openshift Cluster Logging operator

2B.20. Ensure that all OpenShift Cluster Logging Pods, including the operator pods, are in Ready state in the `openshift-logging` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-logging/pods

    ```
    oc -n openshift-logging get po

    ```

2B.21. Update the current custom catalog source of the `cluster-logging` to use the custom mirror catalog:

   ### WARNING
  
   > Make sure that the **RELEASE** value is still the same as the cluster’s **original release**.
   >
   > **No upgrade must happen at this stage.**

   ```
   NAMESPACE=openshift-logging
   pkg=cluster-logging

   MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${VERSION}
   CATALOG_SOURCE=${MIRROR_INDEX_REPOSITORY//./-}

   ```
   ```  
   oc patch sub ${pkg} -n ${NAMESPACE} --type json --patch '[{"op": "replace", "path": "/spec/source", "value": "'${CATALOG_SOURCE}'" }]'

   ```
  
2B.22. Ensure that all OpenShift Cluster Logging Pods, including the operator pods, are in Ready state in the `openshift-logging` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-logging/pods

    ```
    oc -n openshift-logging get po

    ```

---

### AKO operator provided by VMware (as an example of external provider operator)

2B.23. Ensure that all AKO Pods, including the operator pods, are in Ready state in the `avi-system` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-logging/pods

    ```
    oc -n avi-system get po

    ```

2B.24. Update the current custom catalog source of the `ako-operator` to use the custom mirror catalog:

   ### WARNING
  
   > Make sure that the **RELEASE** value is still the same as the cluster’s **original release**.
   >
   > **No upgrade must happen at this stage.**

   ```
   NAMESPACE=avi-system
   pkg=ako-operator

   MIRROR_INDEX_REPOSITORY=mirror-${pkg}-${VERSION}
   CATALOG_SOURCE=${MIRROR_INDEX_REPOSITORY//./-}

   ```
   ```  
   oc patch sub ${pkg} -n ${NAMESPACE} --type json --patch '[{"op": "replace", "path": "/spec/source", "value": "'${CATALOG_SOURCE}'" }]'

   ```
  
2B.25. Ensure that all AKO Pods, including the operator pods, are in Ready state in the `avi-system` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-logging/pods

    ```
    oc -n avi-system get po

    ```

---

## 2B.26 (ONLY IF NECESSARY) Disabling the default OperatorHub sources 

> Once the sources are switched to the new local mirror, you can disable the default OperatorHub sources.

Operator catalogs that source content provided by Red Hat and community projects are configured for OperatorHub by default during an OpenShift Container Platform installation. In a restricted network environment, you must disable the default catalogs as a cluster administrator. You can then configure OperatorHub to use local catalog sources.

### Procedure

- (ONLY IF NECESSARY) Disable the sources for the default catalogs by adding `disableAllDefaultSources: true` to the OperatorHub object:
   ```
   oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
   
   ```

