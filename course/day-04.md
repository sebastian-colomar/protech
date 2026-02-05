# Updating a cluster in a disconnected environment

- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/updating_clusters/updating-a-cluster-in-a-disconnected-environment

## Mirroring the OpenShift Container Platform image repository

### Preparing your mirror host 

#### Installing the OpenShift CLI by downloading the binary
- SEE DAY-03.MD

IMPORTANT:
- If you are upgrading a cluster in a disconnected environment, install the oc version that you plan to upgrade to.

#### Configuring credentials that allow images to be mirrored 

##### Procedure

1. Download your registry.redhat.io pull secret from the Red Hat OpenShift Cluster Manager and save it to a .json file.
   
   ALTERNATIVELY:
   You can retrieve the secret pull-secret from openshift-config namespace that will contain the necessary credentials:
   - https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-config/secrets/pull-secret
   ```
   ssh -i key.txt -lubuntu protech-me.sebastian-colomar.com
   ```
   ```
   sudo su --login root
   ```
   ```
   export KUBECONFIG=/root/environment/hub.sebastian-colomar.com/auth/kubeconfig
   ```
   ```
   oc -n openshift-config extract secret/pull-secret --to=-
   oc -n openshift-config extract secret/pull-secret --to .
   mv -v .dockerconfigjson /home/ubuntu/
   exit
   ```
   ```
   sudo chmod +r .dockerconfigjson
   ```
   ```
   exit
   ```
   ```
   scp -i key.txt ubuntu@protech-me.sebastian-colomar.com:.dockerconfigjson .
   cat .dockerconfigjson | jq . | tee dockerconfigjson
   ```
   ```
   mkdir -p ${HOME}/.docker
   cp -v dockerconfigjson ${HOME}/.docker/config.json
   ```
   ```
   mkdir -p ${XDG_RUNTIME_DIR}/containers
   cp -v dockerconfigjson ${XDG_RUNTIME_DIR}/containers/auth.json
   ```
   ```
   podman login registry.redhat.io
   ```
   ```
   cat dockerconfigjson
   ```
   
   
