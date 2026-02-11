# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# ETCD backup for OCP version 4.8.37

Red Hat references:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/backup_and_restore/control-plane-backup-and-restore

# Control plane backup and restore

# Backing up etcd

etcd is the key-value store for OpenShift Container Platform, which persists the state of all resource objects.

Back up your cluster’s etcd data regularly and store in a secure location ideally outside the OpenShift Container Platform environment.

It is also recommended to take etcd backups during non-peak usage hours because the etcd snapshot has a high I/O cost.

Be sure to take an etcd backup after you upgrade your cluster. 
This is important because when you restore your cluster, you must use an etcd backup that was taken from the same z-stream release. 
For example, an OpenShift Container Platform 4.y.z cluster must use an etcd backup that was taken from 4.y.z.


After you have an etcd backup, you can restore to a previous cluster state.

---
# 1. Backing up etcd data

IMPORTANT:
> Back up your cluster’s etcd data by performing a single invocation of the backup script on a control plane host (also known as the master host).
>
> Do not take a backup for each control plane host.

Follow these steps to back up etcd data by creating an etcd snapshot and backing up the resources for the static pods. 

This backup can be saved and used at a later time if you need to restore etcd.

## Procedure

1.1. Start an SSH session for a control plane node:

    ```
    export SSH_KEY=${HOME}/key.txt
    export REMOTE_USER=core
    ```
    ```
    HOST=$(oc get no | grep master -m1 | awk '{print $1}')
    ```
    ```
    ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST}
    ```
1.2. Run the `cluster-backup.sh` script and pass in the location to save the backup to:

    ```
    mkdir -p /home/core/assets/backup

    /usr/local/bin/cluster-backup.sh /home/core/assets/backup
    ```

---

In this example, two files are created in the /home/core/assets/backup/ directory on the control plane host:
- `snapshot_<datetimestamp>.db`: This file is the etcd snapshot. The `cluster-backup.sh` script confirms its validity.
- `static_kuberesources_<datetimestamp>.tar.gz`: This file contains the resources for the static pods. If etcd encryption is enabled, it also contains the encryption keys for the etcd snapshot.

---
# 2. Check if etcd encryption is enabled

## Procedure

2.1. Check the API Server Encryption Configuration

    ```
    oc get apiserver cluster -o jsonpath='{.status.conditions}' | grep Encrypted= || echo ENCRYPTION IS NOT ENABLED
    ```
