# OpenShift Upgrade from Version 4.8 in an Air-Gapped Environment

## cluster-disaster-recovery

Instructions to create and verify an **etcd backup**, and to restore the cluster if needed.
Always back up etcd before starting the upgrade.

## upgrade

Instructions to upgrade an existing **OpenShift 4.8.37 cluster** in an air-gapped environment.

This section explains how to:

* Create a disconnected mirror of the target OpenShift release
* Mirror release images and Operator catalogs to the internal registry
* Update `ImageContentSourcePolicy` and `CatalogSource`
* Upgrade the cluster using the `oc` CLI
* Update Operators using the `oc` CLI
* Validate cluster and Operator health after the upgrade

All release images and Operator images must be mirrored and available in the internal registry before starting the upgrade.
