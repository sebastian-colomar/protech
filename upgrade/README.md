# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.


---

# Upgrading Cloud Pak for Data System

This page describes how to upgrade Cloud Pak for Data System:
- https://www.ibm.com/docs/en/cloud-paks/cloudpak-data-system/2.0.0?topic=upgrading-cloud-pak-data-system

Check in the above link the table that presents which Cloud Pak for Data System components are upgraded in each release, and the upgrade path for each release.

## Note:
> - Cloud Pak for Data upgrade is bundled with the system upgrade package and is part of the upgrade process.
> - Do not upgrade any Cloud Pak for Data services before you upgrade Cloud Pak for Data System. This might cause the system upgrade to fail. If you have already upgraded some of the services, contact IBM Support before upgrading the system.
> - If the system has any user-managed Cloud Pak for Data tenants (on the namespace other than zen or ap-console), those tenants will be upgraded during the service bundle upgrade automatically, unless you pin the installation to a specific version in the ZenService custom resource. For moreinformation, see the Manual upgrade section in Choosing an upgrade plan for the Cloud Pak for Data control plane.
> - Netezza Performance Server and Cloud Pak for Data System releases are independent.
> - The Netezza Performance Server release that is mentioned in the table is the latest release that was available at the time, but it does not mean that only this release is supported. It is always recommended to have the latest Netezza Performance Server/Cloud Pak for Data System version.

# 4.10 upgrade

## Important:
> You must upgrade to Cyclops 4.0 before upgrading Red Hat OpenShift Container Platform (OCP) and OpenShift Data Foundation (ODF) to version 4.10. For installation instructions, see the README file:
> - https://download4.boulder.ibm.com/sar/CMA/WSA/0bnji/0/readme.txt

- [Upgrade from v4.8 to v4.10](4.10_upgrade.md)

# 4.12 upgrade

# 4.14 upgrade

# 4.16 upgrade


