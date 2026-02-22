# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# 1. Fully disconnected (air-gapped) mirror registry

When you populate your mirror registry with OpenShift Container Platform images, 
if you do not have a host that can access both the internet and your mirror registry,
you must mirror the images to a file system and then bring that host or removable media into your restricted environment.
This process is referred to as disconnected mirroring.

---

The full process is already scripted and available in the following repository:
- ## [How to use the mirroring scripts](../bin/README.md)

---

If you prefer to follow the manual steps or want to understand the full process, you can read the following documentation:
### [1. Getting your Jumphost ready](01-ocp.md)
### [2. Using Operator Lifecycle Manager on restricted networks](02-olm.md)
### [3. Mirror registry for Red Hat OpenShift](03-mirror.md)

---
