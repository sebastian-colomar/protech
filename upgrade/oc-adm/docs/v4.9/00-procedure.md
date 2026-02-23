# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

### Important:
> You must upgrade to Cyclops 4.0 before upgrading Red Hat OpenShift Container Platform (OCP) and OpenShift Data Foundation (ODF) to version 4.10. For installation instructions, see the README file:
> - https://download4.boulder.ibm.com/sar/CMA/WSA/0bnji/0/readme.txt

--- 

# Upgrade from version 4.8.37 to 4.9.59

Red Hat references:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/installing/installing-mirroring-installation-images
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/updating_clusters/updating-a-cluster-in-a-disconnected-environment
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/operators/administrator-tasks
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.9/html/operators/administrator-tasks


---

## Updating a cluster in a disconnected environment

---

Before continuing, set the `RELEASE` environment variable to match the CURRENT cluster version, which is `4.8.37`.
```
export RELEASE=4.8.37

```
You can now continue with the following steps:

## 1A. [Fully disconnected (air-gapped) mirror registry](../01-mirroring.md)
## 2A. [Verify the mirroring process](../02-mirror-validation.md)
## 3A. [Connect to the new local mirror for the first time](03-mirror-switch.md)

---

Now that your cluster is fully using the sources from the new local mirror, you can begin the actual upgrade.

To do this, run the mirroring process again. This time, set the target release to `4.9.59`.

Before continuing, set the `RELEASE` environment variable to match the CURRENT cluster version, which is `4.9.59`.
```
export RELEASE=4.9.59

```
You can now continue with the following steps:

## 1B. [Fully disconnected (air-gapped) mirror registry](../01-mirroring.md)
## 2B. [Verify the mirroring process](../02-mirror-validation.md)

---

## 2. [Updating a cluster in a disconnected environment](../03-upgrade.md)
## 3. [Upgrade OCS to Red Hat OpenShift Data Foundation (ODF)](04-ocs2odf.md)
## 4. [Upgrade Elastic Search and Cluster Logging](../06-logging.md)
## 5. [Upgrade AKO operator (as an example of external operators)](../07-ako.md)
