# How to use the mirroring scripts

- The first script should run on a jumphost with internet access. It will download the mirror images and send them to the mirror host using SSH.
- The second script should run on the mirror host. This host does not have internet access, but it can connect to the OpenShift cluster.
- Both the jumphost and the mirror host must be able to use `oc` commands to connect to the OpenShift API.

## 1. JUMPHOST script

### 1.1. From the `jumphost` execute the following commands:

```
export GITHUB_BRANCH=main
export GITHUB_USER=sebastian-colomar

export GITHUB_REPO=protech
export SCRIPT=mirror.sh
export VARS=values.sh
export HOST=jumphost

export GITHUB_PATH=${GITHUB_REPO}-$( date +%s )
export BIN=${HOME}/${GITHUB_PATH}/upgrade/v4.10/bin
export FULL_PATH=${BIN}/${HOST}

```
```
git clone --branch ${GITHUB_BRANCH} --single-branch -- https://github.com/${GITHUB_USER}/${GITHUB_REPO} ${GITHUB_PATH}

```
### 1.2. If necessary, modify the environment variables:
```
vi ${BIN}/${VARS}

```
### 1.3. Now you can execute the mirroring script:
```
source ${BIN}/${VARS}
source ${BIN}/${SCRIPT}

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
### 1.5 Now you can log in into the mirror host and continue there the mirroring process:
```
ssh -i ${SSH_KEY} ${REMOTE_USER}@${MIRROR_HOST}

```


## 2. MIRROR HOST script

### 2.1. From the `mirror host` execute the following commands:

```
export GITHUB_REPO=protech
export REMOTE_USER=ec2-user

export SCRIPT=mirror.sh
export VARS=values.sh
export HOST=mirror

export GITHUB_PATH=${GITHUB_REPO}-$( date +%s )
export BIN=${HOME}/${GITHUB_PATH}/upgrade/v4.10/bin
export FULL_PATH=${BIN}/${HOST}

```
```
mkdir -p ${GITHUB_PATH}

sudo mv -fv /home/${REMOTE_USER}/${GITHUB_REPO}.tgz ${HOME}

tar fvxz ${GITHUB_REPO}.tgz -C ${GITHUB_PATH} --strip-components=1

```
### 2.2 If necessary, modify the environment variables:
```
vi ${BIN}/${VARS}

```
### 2.3. Now you can execute the mirroring script:
```
source ${BIN}/${VARS}
source ${BIN}/${SCRIPT}

```
