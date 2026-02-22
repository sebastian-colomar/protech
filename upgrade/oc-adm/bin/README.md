# How to use the mirroring scripts

- The first script should run on a jumphost with internet access. It will download the mirror images and send them to the mirror host using SSH.
- The second script should run on the mirror host. This host does not have internet access, but it can connect to the OpenShift cluster.
- Both the jumphost and the mirror host must be able to use `oc` commands to connect to the OpenShift API.

## 1. JUMPHOST script

### 1.1. From the `jumphost` execute the following commands:

```
GITHUB_BRANCH=main
GITHUB_REPO=protech
GITHUB_USER=sebastian-colomar

```
```
rm -rf ${GITHUB_REPO}
git clone --branch ${GITHUB_BRANCH} --single-branch -- https://github.com/${GITHUB_USER}/${GITHUB_REPO}

```
### 1.2. Now you can execute the mirroring script:
```
export HOST=jumphost
export RELEASE=4.8.37
#export RELEASE=4.9.59
#export RELEASE=4.10.64
SCRIPT=upgrade/oc-adm/bin/mirroring.sh

```
```
nohup bash ${GITHUB_REPO}/${SCRIPT} 1> ${HOST}.log 2> ${HOST}-errors.log &

```
### 1.3. Once finished, you can transfer the upgrade repository to the mirror host:
```
MIRROR_HOST=mirror.sebastian-colomar.com
REMOTE_USER=ec2-user
SSH_KEY=${HOME}/auth/key.txt

```
```
tar cfvz ${GITHUB_REPO}.tgz ${GITHUB_REPO}
scp -i ${SSH_KEY} ${GITHUB_REPO}.tgz ${REMOTE_USER}@${MIRROR_HOST}:

```
### 1.4. Now you can log in into the mirror host and continue there the mirroring process:
```
ssh -i ${SSH_KEY} ${REMOTE_USER}@${MIRROR_HOST}

```


## 2. MIRROR HOST script

### 2.1. From the `mirror host` execute the following commands:

```
GITHUB_REPO=protech
REMOTE_USER=ec2-user

```
```
mkdir -p ${GITHUB_REPO}
sudo mv -fv /home/${REMOTE_USER}/${GITHUB_REPO}.tgz ${HOME}
tar fvxz ${GITHUB_REPO}.tgz -C ${GITHUB_REPO} --strip-components=1

```
### 2.2. Now you can execute the mirroring script:
```
export HOST=mirror
export RELEASE=4.8.37
#export RELEASE=4.9.59
#export RELEASE=4.10.64
SCRIPT=upgrade/oc-adm/bin/mirroring.sh

```
```
nohup bash ${GITHUB_REPO}/${SCRIPT} 1> ${HOST}.log 2> ${HOST}-errors.log &

```
## 3. Verify the mirroring process

You should now have a valid disconnected mirror of the selected `RELEASE`.
To make sure everything worked correctly, check the following resources:
- `CatalogSources`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1alpha1~CatalogSource/instances
  ```
  oc get catsrc -n openshift-marketplace | grep v$( echo ${RELEASE} | cut -d. -f1 )-$( echo ${RELEASE} | cut -d. -f2 )
  
  ```
- `ImageContentSourcePolicies`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/cluster/operator.openshift.io~v1alpha1~ImageContentSourcePolicy/instances
  ```
  oc get imagecontentsourcepolicy | grep v$( echo ${RELEASE} | cut -d. -f1 )-$( echo ${RELEASE} | cut -d. -f2 )
  
  ```
You may also find it helpful to review the following related resources:
- `Subscriptions`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1alpha1~Subscription/instances
  ```
  oc get sub -A | grep v$( echo ${RELEASE} | cut -d. -f1 )-$( echo ${RELEASE} | cut -d. -f2 )
  
  ```
- `PackageManifests`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/packages.operators.coreos.com~v1~PackageManifest/instances
  ```
  oc get packagemanifest -A
  
  ```
- `Operators`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/cluster/operators.coreos.com~v1~Operator/instances
  ```
  oc get operator
  
  ```
- `OperatorGroups`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1~OperatorGroup/instances
  ```
  oc get og -A
  
  ```
- `OperatorConditions`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v2~OperatorCondition/instances
  ```
  oc get condition -A
  
  ```
- `InstallPlans`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1alpha1~InstallPlan/instances
  ```
  oc get ip -A
  
  ```
- `ClusterServiceVersions`:
  - https://console-openshift-console.apps.hub.sebastian-colomar.com/api-resource/all-namespaces/operators.coreos.com~v1alpha1~ClusterServiceVersion/instances
  ```
  oc get csv -A
  
  ```
  
