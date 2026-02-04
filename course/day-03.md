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
