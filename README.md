# OpenShift Upgrade from Version 4.8 in an Air-Gapped Environment

## cluster-disaster-recovery

Instructions to create and verify an **etcd backup**, and to restore the cluster if needed.
Always back up etcd before starting the upgrade.

## upgrade

Instructions to upgrade an existing **OpenShift 4.8.37 cluster** in an air-gapped environment.

This section explains how to:

* Create a disconnected mirror of the target release
* Mirror images to the internal registry
* Configure `ImageContentSourcePolicy`
* Run the upgrade using the `oc` CLI
* Validate the cluster after the upgrade

All images must be available in the internal registry before starting the upgrade.
