# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

### Important:
> You must upgrade to Cyclops 4.0 before upgrading Red Hat OpenShift Container Platform (OCP) and OpenShift Data Foundation (ODF) to version 4.10. For installation instructions, see the README file:
> - https://download4.boulder.ibm.com/sar/CMA/WSA/0bnji/0/readme.txt

--- 

# Upgrade from version 4.9.59 to 4.10.64

## Red Hat references:

Installing:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.9/pdf/installing/OpenShift_Container_Platform-4.9-Installing-en-US.pdf

Updating clusters:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.9/pdf/updating_clusters/OpenShift_Container_Platform-4.9-Updating_clusters-en-US.pdf
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.10/pdf/updating_clusters/OpenShift_Container_Platform-4.10-Updating_clusters-en-US.pdf

Operators:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.9/pdf/operators/OpenShift_Container_Platform-4.9-Operators-en-US.pdf
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.10/pdf/operators/OpenShift_Container_Platform-4.10-Operators-en-US.pdf

---

## Updating a cluster in a disconnected environment

---

Before continuing, set the `RELEASE` environment variable to match the DESIRED cluster version, which is `4.10.64`.
```
export RELEASE=4.10.64

```
You can now continue with the following steps:

## 1. [Fully disconnected (air-gapped) mirror registry](../01-mirroring.md)
## 2. [Verify the mirroring process](../02-mirror-validation.md)
## 3. [Updating a cluster in a disconnected environment](../03-upgrade.md)
## 4. [Upgrade OpenShift Data Foundation (ODF)](../04-odf.md)
## 5. [Upgrade Elastic Search and Cluster Logging](05-logging.md)
## 6. [Upgrade AKO operator (as an example of external operators)](../06-ako.md)

