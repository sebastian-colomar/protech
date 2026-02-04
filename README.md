# protech

```
export Domain=sebastian-colomar.com
export UnixUser=ubuntu
export YourName=me
export YourKey=~/ProTech/protech00-key.txt
```
```
ssh protech-${YourName}.${Domain} -i ${YourKey} -l ${UnixUser}
```
```
git clone https://github.com/sebastian-colomar/protech
source protech/bin/ec2-config.sh
```
- https://console-openshift-console.apps.hub.sebastian-colomar.com
- https://coreos.github.io/ignition/configuration-v3_1/
- https://mirror.openshift.com/pub/cgw/mirror-registry/latest/mirror-registry-amd64.tar.gz
- https://developers.redhat.com/content-gateway/file/pub/openshift-v4/clients/mirror-registry/1.3.9/mirror-registry.tar.gz
- https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.8.33/openshift-client-linux.tar.gz
- https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.8.33/openshift-install-linux.tar.gz
- https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/oc-mirror.tar.gz
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/installing/validating-an-installation
- https://docs.redhat.com/en/documentation/red_hat_quay/3/html-single/securing_red_hat_quay/index
