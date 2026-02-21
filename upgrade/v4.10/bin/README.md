# How to use the upgrade scripts

- The first script should run on a jumphost with internet access. It will download the mirror images and send them to the mirror host using SSH.
- The second script should run on the mirror host. This host does not have internet access, but it can connect to the OpenShift cluster.
- Both the jumphost and the mirror host must be able to use `oc` commands to connect to the OpenShift API.

## 1. JUMPHOST script

### 1.1. From the `jumphost` execute the following commands:

```
export GITHUB_BRANCH=main
export GITHUB_USER=sebastian-colomar

export GITHUB_REPO=protech
export UPGRADE_BIN=upgrade/v4.10/bin
export UPGRADE_HOST=jumphost
export UPGRADE_SCRIPT=mirror.sh
export UPGRADE_VARS=00-export_vars.sh

export GITHUB_PATH=${GITHUB_REPO}-$( date +%s )
export UPGRADE_FULL_PATH=${HOME}/${GITHUB_PATH}/${UPGRADE_BIN}/${UPGRADE_HOST}

```
```
git clone --branch ${GITHUB_BRANCH} --single-branch -- https://github.com/${GITHUB_USER}/${GITHUB_REPO} ${GITHUB_PATH}

```
### 1.2. If necessary, modify the environment variables:
```
vi ${UPGRADE_FULL_PATH}/${UPGRADE_VARS}

```
### 1.3. Now you can execute the upgrade script:
```
source ${UPGRADE_BIN}/${UPGRADE_SCRIPT}

```
### 1.4. Once finished, you can transfer the upgrade repository to the mirror host:
```
export MIRROR_HOST=mirror.sebastian-colomar.com
export REMOTE_USER=ec2-user
export SSH_KEY=${HOME}/key.txt

```
```
tar cfvz ${GITHUB_REPO}.tgz ${GITHUB_PATH}

scp -i ${SSH_KEY} ${GITHUB_REPO}.tgz ${REMOTE_USER}@${MIRROR_HOST}:

```
### 1.5 Now you can log in into the mirror host and continue there the upgrade process:
```
ssh -i ${SSH_KEY} ${REMOTE_USER}@${MIRROR_HOST}

```


## 2. MIRROR HOST script

### 2.1. From the `mirror host` execute the following commands:

```
export GITHUB_REPO=protech
export REMOTE_USER=ec2-user

export UPGRADE_BIN=upgrade/v4.10/bin
export UPGRADE_HOST=mirror
export UPGRADE_SCRIPT=mirror.sh
export UPGRADE_VARS=00-export_vars.sh

export GITHUB_PATH=${GITHUB_REPO}-$( date +%s )
export UPGRADE_FULL_PATH=${HOME}/${GITHUB_PATH}/${UPGRADE_BIN}

```
```
mkdir -p ${GITHUB_PATH}

sudo mv -fv /home/${REMOTE_USER}/${GITHUB_REPO}.tgz ${HOME}

tar fvxz ${GITHUB_REPO}.tgz -C ${GITHUB_PATH} --strip-components=1

```
### 2.2 If necessary, modify the environment variables:
```
vi ${UPGRADE_FULL_PATH}/${UPGRADE_HOST}/${UPGRADE_VARS}

```
### 2.3. Now you can execute the upgrade script:
```
source ${UPGRADE_FULL_PATH}/${UPGRADE_SCRIPT}

```
