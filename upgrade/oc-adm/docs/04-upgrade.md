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
  oc -n openshift-storage rsh `oc-${OCP_RELEASE_OLD} get pods -n openshift-storage | grep ceph-tool | cut -d ' ' -f1` ceph status
  
  ```

NOTE:
> All the commands that are mentioned here are to be run from e1n1 except where it mentions otherwise.

### Upgrading the disconnected cluster

#### Procedure

4.1. Validate that the ImageContentSourcePolicy has been rendered into a MachineConfig and successfully rolled out to all nodes before proceeding:
   ```
   export MIRROR_HOST=mirror.hub.sebastian-colomar.com

   for n in oc get nodes -o name); do echo "== $n =="; oc debug "$n" -q -- chroot /host grep -R "${MIRROR_HOST}:${MIRROR_PORT}"'"' /etc/containers || echo "Not found"; done

   ```
   
4.2. Retrieve the sha256 sum value for the release from the image signature ConfigMap:

   ```
   if [ -z "${RELEASE}" ]; then
     echo "ERROR: RELEASE is not set or empty"
     exit 1
   fi

   LOCAL_REGISTRY=${MIRROR_HOST}:${MIRROR_PORT}
   OCP_REPOSITORY=ocp
   RELEASE_NAME=ocp-release

   MIRROR_OCP_REPOSITORY=mirror-${OCP_REPOSITORY}

   SHA256_SUM_VALUE=$( cut -d'"' -f14 ${REMOVABLE_MEDIA_PATH}/${MIRROR_OCP_REPOSITORY}-${RELEASE}/config/signature-sha256-*.yaml | cut -d- -f2 )

   ```

4.3. To Select the channel, run this patch command on the CLI:

   ```
   if [ -z "${VERSION}" ]; then
     echo "ERROR: VERSION is not set or empty"
     exit 1
   fi

   oc patch clusterversion version --type merge -p '{"spec": {"channel": "stable-'${VERSION}'"}}'

   ```

4.4. Upgrading to an OCP version higher than 4.8 requires manual acknowledgment from the administrator. For more information, see Preparing to upgrade to OpenShift Container Platform 4.9:
   - https://access.redhat.com/articles/6329921

   ```
   oc -n openshift-config patch cm admin-acks --patch '{"data":{"ack-4.8-kube-1.22-api-removals-in-4.9":"true"}}' --type=merge

   ```
  
 4.5. UPDATE THE CLUSTER:

   WARNING:
   > THIS WILL UPDATE THE CLUSTER

   ```
   oc adm upgrade --allow-explicit-upgrade --to-image ${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY}-${RELEASE}@sha256:${SHA256_SUM_VALUE}

   ```

4.6. (ONLY IF NECESSARY) Force an explicit upgrade with version set:

   ```
   oc patch clusterversion version --type=merge -p '{"spec":{"desiredUpdate":{"image":"'${LOCAL_REGISTRY}/${MIRROR_OCP_REPOSITORY}@sha256:${SHA256_SUM_VALUE}'","version":"'${OCP_RELEASE_NEW}'","force":true}}}'

   ```

4.7. Monitor the upgrade:
   - https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/cluster/config.openshift.io~v1~ClusterVersion/version
   ```
   oc get clusterversion version -o jsonpath='{range .status.conditions[*]}{.type}{"\t"}{.status}{"\t"}{.reason}{"\t"}{.message}{"\n"}{end}'

   ```

4.8. Watch the CVO logs while it downloads/unpacks:
   - https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-cluster-version/pods
   ```
   oc -n openshift-cluster-version logs deploy/cluster-version-operator -f

   ```
