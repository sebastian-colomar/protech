# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# ETCD Disaster Recovery for OCP version 4.8.37

Red Hat references:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/backup_and_restore/control-plane-backup-and-restore

# About restoring to a previous cluster state

## WARNING:
> Restoring to a previous cluster state is a destructive and destablizing action to take on a running cluster.
>
> This should only be used as a last resort.
>
> If you are able to retrieve data using the Kubernetes API server, then etcd is available and you should not restore using an etcd backup.

---
# 1. Restoring to a previous cluster state

## Procedure

### 1.1. Select a control plane host to use as the recovery host. This is the host that you will run the restore operation on.

### 1.2. Establish SSH connectivity to each of the control plane nodes, including the recovery host:

  ```  
  export SSH_KEY=${HOME}/key.txt
  export REMOTE_USER=core
  ```
  ```
  oc get no | grep master
  HOST1=$( oc get no | grep master -m1 | awk '{print $1}' )
  HOST2=$( oc get no | grep master -m2 | tail -1 | awk '{print $1}' )
  HOST3=$( oc get no | grep master -m3 | tail -1 | awk '{print $1}' )
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST1}
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST2}
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST3}
  ```

  #### WARNING
  > ALL SSH SESSIONS MUST REMAIN OPEN UNTIL THE PROCEDURE HAS BEEN FULLY COMPLETED

### 1.3. Copy the etcd backup directory to the recovery control plane host:

  ```
  export BACKUP_LOCATION=assets/backup
  ```
  ```
  scp -i ${SSH_KEY} -r ${HOME}/${BACKUP_LOCATION} ${REMOTE_USER}@${HOST1}:
  ```

### 1.4. Stop the static pods on any other control plane nodes:

- #### 1.4.1. Access a control plane host that is not the recovery host. Move the existing `etcd` pod file out of the kubelet manifest directory:
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST} 'sudo mv /etc/kubernetes/manifests/etcd-pod.yaml /tmp'  
  ```
- #### 1.4.2. Verify that the etcd pods are stopped:
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST} 'sudo crictl ps | grep etcd | grep -v operator'  
  ```
  > The output of this command should be empty. If it is not empty, wait a few minutes and check again.
- #### 1.4.3. Move the existing Kubernetes API server pod file out of the kubelet manifest directory:
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST} 'sudo mv /etc/kubernetes/manifests/kube-apiserver-pod.yaml /tmp'  
  ```
- #### 1.4.4. Move the existing Kubernetes API server pod file out of the kubelet manifest directory:
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST} 'sudo mv /etc/kubernetes/manifests/kube-apiserver-pod.yaml /tmp'  
  ```

---

In this example, two files are created in the /home/core/assets/backup/ directory on the control plane host:
- `snapshot_<datetimestamp>.db`: This file is the etcd snapshot. The `cluster-backup.sh` script confirms its validity.
- `static_kuberesources_<datetimestamp>.tar.gz`: This file contains the resources for the static pods. If etcd encryption is enabled, it also contains the encryption keys for the etcd snapshot.

---
# 2. Check if etcd encryption is enabled

## Procedure

### 2.1. Check the API Server Encryption Configuration

  ```
  oc get apiserver cluster -o jsonpath='{.status.conditions}' | grep Encrypted= || echo ENCRYPTION IS NOT ENABLED
  ```

---
# 3. Alternative method for performing an etcd backup

## WARNING: This alternative method is NOT officially supported by Red Hat

## Procedure

### 3.1.
  ```  
  export SSH_KEY=${HOME}/key.txt
  export REMOTE_USER=core
  export BACKUP_LOCATION=assets/backup
  ```

### 3.2.
  ```
  HOST=$(oc get no | grep master -m1 | awk '{print $1}')
  ```

### 3.3.
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST}
  ```
### 3.4.
  ```
  mkdir -p ${HOME}/${BACKUP_LOCATION}
  ```
### 3.5.
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST} "mkdir -p ${BACKUP_LOCATION}"
  ```
### 3.6.
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST} "sudo /usr/local/bin/cluster-backup.sh ${BACKUP_LOCATION}"
  ```
### 3.7.
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST} "sudo chown -R ${REMOTE_USER} ${BACKUP_LOCATION}"
  ```
### 3.8.
  ```
  scp -i ${SSH_KEY} -r ${REMOTE_USER}@${HOST}:assets/backup ${HOME}/${BACKUP_LOCATION}
  ```
### 3.9.
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST} "sudo chown -R root ${BACKUP_LOCATION}"
  ```
