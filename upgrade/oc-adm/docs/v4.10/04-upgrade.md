# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.


--- 

# 4. Updating a cluster in a disconnected environment without the OpenShift Update Service

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
  oc-${OCP_RELEASE_OLD} get nodes
  
  ```
- The machine config pools (MCP) are up to date by running the following command:
  ```
  oc-${OCP_RELEASE_OLD} get mcp
  
  ```
- All cluster operators are in healthy state by running the following command:
  ```
  oc-${OCP_RELEASE_OLD} get co
  
  ```
- Configuring the Rook-Ceph Toolbox in OpenShift Data Foundation 4.9:
  ```
  oc-${OCP_RELEASE_OLD} patch OCSInitialization ocsinit -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
  
  ```
- OpenShift Container Storage (OCS) ceph status is HEALTH_OK by running the following command:
  ```
  oc -n openshift-storage exec deploy/rook-ceph-tools -- ceph status
  
  ```

NOTE:
> All the commands that are mentioned here are to be run from e1n1 except where it mentions otherwise.

### Upgrading the disconnected cluster

#### Procedure

4.1. Validate that the ImageContentSourcePolicy has been rendered into a MachineConfig and successfully rolled out to all nodes before proceeding:
   ```
   export MIRROR_HOST=mirror.hub.sebastian-colomar.com

   for n in $(oc-${OCP_RELEASE_OLD} get nodes -o name); do echo "== $n =="; oc-${OCP_RELEASE_OLD} debug "$n" -q -- chroot /host grep -R "${MIRROR_HOST}:${MIRROR_PORT}"'"' /etc/containers || echo "Not found"; done

   ```
   
4.2. Retrieve the sha256 sum value for the release from the image signature ConfigMap:

   ```
   export LOCAL_REGISTRY=${MIRROR_HOST}:${MIRROR_PORT}
   export OCP_REPOSITORY=ocp
   export OCP_RELEASE_NEW=4.10.64
   export OCP_RELEASE_OLD=4.9.59
   export RELEASE_NAME=ocp-release

   export MIRROR_OCP_REPOSITORY=mirror-${OCP_REPOSITORY}

   export SHA256_SUM_VALUE=$( cut -d'"' -f14 ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}-${OCP_RELEASE_NEW}/config/signature-sha256-*.yaml | cut -d- -f2 )

   ```

4.3. To Select the stable-4.10 channel, run this patch command on the CLI:

   ```
   oc-${OCP_RELEASE_OLD} patch clusterversion version --type merge -p '{"spec": {"channel": "stable-4.10"}}'

   ```
 
4.6. Update the cluster:

   ```
   oc-${OCP_RELEASE_OLD} adm upgrade --allow-explicit-upgrade --to-image ${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY}-${OCP_RELEASE_NEW}@sha256:${SHA256_SUM_VALUE}

   ```

4.7. (ONLY IF NECESSARY) Force an explicit upgrade with version set:

   ```
   oc-${OCP_RELEASE_OLD} patch clusterversion version --type=merge -p '{"spec":{"desiredUpdate":{"image":"'${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY}@sha256:${SHA256_SUM_VALUE}'","version":"'${OCP_RELEASE_NEW}'","force":true}}}'

   ```

4.8. Monitor the upgrade:
   - https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/cluster/config.openshift.io~v1~ClusterVersion/version
   ```
   oc-${OCP_RELEASE_NEW} get clusterversion version -o jsonpath='{range .status.conditions[*]}{.type}{"\t"}{.status}{"\t"}{.reason}{"\t"}{.message}{"\n"}{end}'

   ```

4.9. Watch the CVO logs while it downloads/unpacks:
   - https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-cluster-version/pods
   ```
   oc-${OCP_RELEASE_NEW} -n openshift-cluster-version logs deploy/cluster-version-operator -f

   ```
