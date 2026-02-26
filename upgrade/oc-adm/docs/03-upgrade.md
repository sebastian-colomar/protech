# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.


--- 

# 3. Updating a cluster in a disconnected environment without the OpenShift Update Service

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
- Configuring the Rook-Ceph Toolbox in OpenShift Data Foundation:
  ```
  oc patch OCSInitialization ocsinit -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
  
  ```
- OpenShift Container Storage (OCS) ceph status is HEALTH_OK by running the following command:
  ```
  oc -n openshift-storage exec deploy/rook-ceph-tools -- ceph status
  
  ```
  ```
  oc -n openshift-storage exec deploy/rook-ceph-tools -- ceph progress
  
  ```
  ```
  oc -n openshift-storage exec deploy/rook-ceph-tools -- ceph health detail
    
  ```

NOTE:
> All the commands that are mentioned here are to be run from e1n1 except where it mentions otherwise.

### Upgrading the disconnected cluster

#### Procedure

3.1. Set the necessary environment variables:

WARNING
> The RELEASE variable for the version you want to mirror should already be exported

    ```
    if [ -z "${RELEASE}" ]; then
      echo "ERROR: RELEASE is not set or empty"
      exit 1
    fi

    MAJOR=$( echo ${RELEASE} | cut -d. -f1 )
    MINOR=$( echo ${RELEASE} | cut -d. -f2 )
    MIRROR_HOST=mirror.hub.sebastian-colomar.com
    MIRROR_PORT=5000
    OCP_REPOSITORY=ocp
    REMOVABLE_MEDIA_PATH=/mnt/mirror

    LOCAL_REGISTRY=${MIRROR_HOST}:${MIRROR_PORT}
    MIRROR_OCP_REPOSITORY=mirror-${OCP_REPOSITORY}-${RELEASE}
    VERSION=v${MAJOR}.${MINOR}

    ```
3.2. Validate that the ImageContentSourcePolicy has been rendered into a MachineConfig and successfully rolled out to all nodes before proceeding:
   ```
   for n in $(oc get nodes -o name); do echo "== $n =="; oc debug "$n" -q -- chroot /host grep -r -E "${RELEASE}|${VERSION}" /etc/containers || echo "Not found"; done

   ```
   
3.3. Retrieve the sha256 sum value for the release from the image signature ConfigMap:

   ```
   SHA256_SUM_VALUE=$( cut -d'"' -f14 ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}/config/signature-sha256-*.yaml | cut -d- -f2 )

   ```

3.4. To Select the channel, run this patch command on the CLI:

   ```
   oc patch clusterversion version --type merge -p '{"spec": {"channel": "stable-'${MAJOR}.${MINOR}'"}}'

   ```
  
3.5. UPDATE THE CLUSTER:

   WARNING:
   > THIS WILL UPDATE THE CLUSTER

   Now you can update the cluster clicking the blue button with the label "Update":
   - https://console-openshift-console.apps.hub.sebastian-colomar.com/settings/cluster

   If that is not an option you can proceed manually with the upgrade:
   ```
   oc adm upgrade --allow-explicit-upgrade --to-image ${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY}-${RELEASE}@sha256:${SHA256_SUM_VALUE}

   ```

3.6. (ONLY IF NECESSARY) Force an explicit upgrade with version set:

   ```
   oc patch clusterversion version --type=merge -p '{"spec":{"desiredUpdate":{"image":"'${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY}@sha256:${SHA256_SUM_VALUE}'","version":"'${RELEASE}'","force":true}}}'

   ```

3.7. Monitor the upgrade:
   - https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/cluster/config.openshift.io~v1~ClusterVersion/version
   ```
   oc get clusterversion version -o jsonpath='{range .status.conditions[*]}{.type}{"\t"}{.status}{"\t"}{.reason}{"\t"}{.message}{"\n"}{end}'

   ```

3.8. Watch the CVO logs while it downloads/unpacks:
   - https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-cluster-version/pods
   ```
   oc -n openshift-cluster-version logs deploy/cluster-version-operator -f

   ```
