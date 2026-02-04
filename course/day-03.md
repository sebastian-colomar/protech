### DISCLAIMER
The following text is reproduced from the referenced guides and is provided without any express or implied guarantees

---

Red Hat OpenShift Container Platform Update Graph:
- https://access.redhat.com/labs/ocpupgradegraph/update_path/
- https://access.redhat.com/labs/ocpupgradegraph/update_path/?channel=stable-4.8&arch=x86_64&is_show_hot_fix=false&current_ocp_version=4.8.37&target_ocp_version=4.10.64
  - To Select the stable-4.9 channel, run this patch command on the CLI:
    ```
    oc patch clusterversion version --type merge -p '{"spec": {"channel": "stable-4.9"}}'
    ```
    Refer to the Performing a Control Plane Only update documentation if you don't want to update the compute nodes during the intermediate upgrade.
    - https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0?topic=ocp-ocs-upgrade-in-connected-environment-by-using-red-hat-openshift-console-ui
  - Upgrade the cluster from 4.8.37 to 4.9.59.
  - Select the stable-4.10 channel.
  - Upgrade the cluster from 4.9.59 to 4.10.64.

Documentation for IBM Cloud Pak for Data System:
- https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0
- https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0?topic=upgrading-cloud-pak-data-system

Red Hat OpenShift mirror:
- https://mirror.openshift.com/pub/openshift-v4/clients/ocp/
---
# Mirroring images for a disconnected installation
### DISCLAIMER
The following text is reproduced from the referenced guide and is provided without any express or implied guarantees:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/installing/installing-mirroring-installation-images

When you populate your mirror registry with OpenShift Container Platform images, you can follow two scenarios. If you have a host that can access both the internet and your mirror registry, but not your cluster nodes, you can directly mirror the content from that machine. This process is referred to as connected mirroring. If you have no such host, you must mirror the images to a file system and then bring that host or removable media into your restricted environment. This process is referred to as disconnected mirroring.

#### Our case is a disconnected mirroring

## Preparing your mirror host

### Installing the OpenShift CLI by downloading the binary 
```
BINARY_PATH=${HOME}/bin
mkdir -p ${BINARY_PATH}

grep -q ":${BINARY_PATH}:" ~/.bashrc || echo "export PATH=\"${BINARY_PATH}:\${PATH}\"" | tee -a ~/.bashrc
source ~/.bashrc

curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.9.59/openshift-client-linux.tar.gz
tar fxvz openshift-client-linux.tar.gz
rm openshift-client-linux.tar.gz

binaries='kubectl oc'
for binary in ${binaries}
  do
    mv ${binary} ${BINARY_PATH}
  done

oc version
---

# Mirroring an Operator catalog:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/operators/administrator-tasks

--- 
# Upgrade the cluster from 4.8.37 to 4.10.64

### DISCLAIMER
The following text is reproduced from the referenced guide and is provided without any express or implied guarantees:
- https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0?topic=ocp-ocs-upgrade-in-connected-environment-by-using-red-hat-openshift-console-ui

## OCP and OCS upgrade in a connected environment by using Red Hat OpenShift console UI
Last Updated: 2025-01-01
This section explains how to upgrade from Red Hat® OpenShift® Container Platform (OCP) 4.8 to 4.10 on Cloud Pak for Data System version 2.0.2.1 with houseconfig setup.

### Before you begin
Make sure that:
- Cloud Pak for Data System version 2.0.2 is configured with houseconfig setup to access external network.
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
- OpenShift Container Storage (OCS) ceph status is HEALTH_OK by running the following command:
  ```
  oc -n openshift-storage rsh `oc get pods -n openshift-storage | grep ceph-tool | cut -d ' ' -f1` ceph status
  ```

#### Note: All the commands that are mentioned here are to be run from e1n1 except where it mentions otherwise.

### Procedure
1. Set up your Red Hat account and link the Red Hat entitlement to your account.
2. Obtain the pull secret file with Red Hat credentials from Red Hat OpenShift cluster manager and saved as pull-secret.json.
3. Validate the external connectivity and Red Hat credentials by running:
   ```
   podman pull --authfile /root/pull-secret.json registry.redhat.io/openshift4/ose-local-storage-mustgather-rhel8
   ```
4. Update the global cluster pull secret file to authenticate on Red Hat registries:
   
   a. Retrieve the current cluster pull secret file by running:
      ```
      oc get secret/pull-secret -n openshift-config --template='{{index .data ".dockerconfigjson" | base64decode}}' > pull_secret_old
      ```
   b. Merge this content into the pull-secret.json and use the merged file to set the global pull-secret on the cluster by running:
      ```
      oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=pull-secret.json
      ```
5. Enable the default catalog sources to access the latest from Red Hat operator sources by running:
   ```
   oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": false}]'
   ```
6. Make sure that the operator pods are in running state under OpenShift-marketplace namespace by running:
   ```
   oc get pods -n openshift-marketplace
   ```
#### Acknowledging manually for upgrading to OpenShift Container Platform (OCP) 4.9
Upgrading to an OCP version higher than 4.8 requires manual acknowledgment from the administrator:
```
oc -n openshift-config patch cm admin-acks --patch '{"data":{"ack-4.8-kube-1.22-api-removals-in-4.9":"true"}}' --type=merge
```

