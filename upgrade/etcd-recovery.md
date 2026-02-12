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
  ```
  oc get no -owide | grep master -m1
  ```

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
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST1} 'sudo ls -l ${HOME}/'${BACKUP_LOCATION}
  ```
  ```
  scp -i ${SSH_KEY} -r ${HOME}/${BACKUP_LOCATION} ${REMOTE_USER}@${HOST1}:
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST1} 'sudo ls -l ${HOME}/'${BACKUP_LOCATION}
  ```

### 1.4. Stop the static pods on any other control plane nodes:

- #### 1.4.1. Access a control plane host that is not the recovery host. Move the existing `etcd` pod file out of the kubelet manifest directory:
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST2} 'sudo mv /etc/kubernetes/manifests/etcd-pod.yaml /tmp'  
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST3} 'sudo mv /etc/kubernetes/manifests/etcd-pod.yaml /tmp'  
  ```
- #### 1.4.2. Verify that the etcd pods are stopped:
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST2} 'sudo crictl ps | grep etcd | grep -v operator || echo etcd POD HAS BEEN REMOVED'  
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST3} 'sudo crictl ps | grep etcd | grep -v operator || echo etcd POD HAS BEEN REMOVED'  
  ```
  > The output of this command should be empty. If it is not empty, wait a few minutes and check again.
- #### 1.4.3. Move the existing Kubernetes API server pod file out of the kubelet manifest directory:
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST2} 'sudo mv /etc/kubernetes/manifests/kube-apiserver-pod.yaml /tmp'  
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST3} 'sudo mv /etc/kubernetes/manifests/kube-apiserver-pod.yaml /tmp'  
  ```
- #### 1.4.4. Verify that the Kubernetes API server pods are stopped:
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST2} 'sudo crictl ps | grep kube-apiserver | grep -v operator || echo kube-apiserver POD HAS BEEN REMOVED'  
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST3} 'sudo crictl ps | grep kube-apiserver | grep -v operator || echo kube-apiserver POD HAS BEEN REMOVED'  
  ```
  > The output of this command should be empty. If it is not empty, wait a few minutes and check again.
- #### 1.4.5. Move the etcd data directory to a different location:
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST2} 'sudo mv /var/lib/etcd/ /tmp'  
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST3} 'sudo mv /var/lib/etcd/ /tmp'  
  ```

### 1.5. Access the recovery control plane host. Run the restore script on the recovery control plane host and pass in the path to the etcd backup directory:

  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST1} "sudo /usr/local/bin/cluster-restore.sh ${BACKUP_LOCATION}"
  ```

### 1.6. Check the nodes to ensure they are in the Ready state:

  ```
  export KUBECONFIG=/etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/node-kubeconfigs/localhost.kubeconfig
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST1} "sudo oc get no --kubeconfig ${KUBECONFIG}"
  ```
  IMPORTANT:
  > If any nodes are in the NotReady state, log in to the nodes and remove all of the PEM files from the `/var/lib/kubelet/pki` directory on each node. You can SSH into the nodes for that purpose.

### 1.7. Restart the kubelet service on all control plane hosts:

  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST1} "sudo systemctl restart kubelet.service"
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST2} "sudo systemctl restart kubelet.service"
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST3} "sudo systemctl restart kubelet.service"
  ```

### 1.8. Approve the pending CSRs:
- #### 1.8.1. Get the list of current CSRs:
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST1} "sudo oc get csr --kubeconfig ${KUBECONFIG}"
  ```
- #### 1.8.2. Approve the list of pending CSRs:
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST1} "for csr in $(oc get csr --no-headers --kubeconfig ${KUBECONFIG} | awk '$4=="Pending"{print $1}'); do oc adm certificate approve "$csr" --kubeconfig ${KUBECONFIG}; done"
  ```
- #### 1.8.1. Get the list of current CSRs:
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST1} "sudo oc get csr --kubeconfig ${KUBECONFIG}"
  ```
- #### 1.8.1. Get the list of current CSRs:
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST1} "sudo oc get csr --kubeconfig ${KUBECONFIG}"
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST3} 'sudo mv /var/lib/etcd/ /tmp'  
  ```
  
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST1} "sudo systemctl restart kubelet.service"
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST2} "sudo systemctl restart kubelet.service"
  ```
  ```
  ssh -i ${SSH_KEY} ${REMOTE_USER}@${HOST3} "sudo systemctl restart kubelet.service"
  ```




