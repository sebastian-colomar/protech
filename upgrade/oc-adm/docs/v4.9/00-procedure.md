# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

### Important:
> You must upgrade to Cyclops 4.0 before upgrading Red Hat OpenShift Container Platform (OCP) and OpenShift Data Foundation (ODF) to version 4.10. For installation instructions, see the README file:
> - https://download4.boulder.ibm.com/sar/CMA/WSA/0bnji/0/readme.txt

--- 

# Upgrade from version 4.8.37 to 4.9.59

## Red Hat references:

Installing:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/pdf/installing/OpenShift_Container_Platform-4.8-Installing-en-US.pdf
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.9/pdf/installing/OpenShift_Container_Platform-4.9-Installing-en-US.pdf

Updating clusters:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/pdf/updating_clusters/OpenShift_Container_Platform-4.8-Updating_clusters-en-US.pdf
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.9/pdf/updating_clusters/OpenShift_Container_Platform-4.9-Updating_clusters-en-US.pdf

Operators:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/pdf/operators/OpenShift_Container_Platform-4.8-Operators-en-US.pdf
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.9/pdf/operators/OpenShift_Container_Platform-4.9-Operators-en-US.pdf

---

## Updating a cluster in a disconnected environment

---

Before continuing, set the `RELEASE` environment variable to match the CURRENT cluster version, which is `4.8.37`.
```
export RELEASE=4.8.37

```
You can now continue with the following steps:

## 1. [Fully disconnected (air-gapped) mirror registry](../01-mirroring.md)
## 2. [Verify the mirroring process](../02-mirror-validation.md)
## 2B. [Connect to the new local mirror for the first time](02b-mirror-switch.md)

---

Now that your cluster is fully using the sources from the new local mirror, you can begin the actual upgrade.

To do this, run the mirroring process again. This time, set the target release to `4.9.59`.

Before continuing, set the `RELEASE` environment variable to match the DESIRED cluster version, which is `4.9.59`.
```
export RELEASE=4.9.59

```
You can now continue with the following steps:

## 1-bis. [Fully disconnected (air-gapped) mirror registry](../01-mirroring.md)
## 2-bis. [Verify the mirroring process](../02-mirror-validation.md)

---

### IMPORTANT
> Upgrading to an OCP version higher than 4.8 requires manual acknowledgment from the administrator. For more information, see Preparing to upgrade to OpenShift Container Platform 4.9:
   - https://access.redhat.com/articles/6329921

```
oc -n openshift-config patch cm admin-acks --patch '{"data":{"ack-4.8-kube-1.22-api-removals-in-4.9":"true"}}' --type=merge

```

## 3. [Updating a cluster in a disconnected environment](../03-upgrade.md)
## 4. [Upgrade OCS to ODF (Red Hat OpenShift Data Foundation)](04-ocs2odf.md)
## 5. [Upgrade Elastic Search and Cluster Logging](05-logging.md)
## 6. [Upgrade AKO operator (as an example of external operators)](../06-ako.md)
