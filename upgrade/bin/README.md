# How to use the upgrade scripts

- The first script should run on a jumphost with internet access. It will download the mirror images and send them to the mirror host using SSH.
- The second script should run on the mirror host. This host does not have internet access, but it can connect to the OpenShift cluster.
- Both the jumphost and the mirror host must be able to use `oc` commands to connect to the OpenShift API.

## JUMPHOST script

From the `jumphost` execute the following commands:

```
export GITHUB_BRANCH=main
export GITHUB_REPO=protech
export GITHUB_USER=sebastian-colomar
export UPGRADE_BIN=upgrade/bin
export UPGRADE_JUMPHOST_SCRIPT=jumphost.sh
export UPGRADE_JUMPHOST_VARS=jumphost/00-export_vars.sh

```

```
export GITHUB_PATH=${GITHUB_REPO}-$( date +%s )

git clone --branch ${GITHUB_BRANCH} --single-branch -- https://github.com/${GITHUB_USER}/${GITHUB_REPO} ${GITHUB_PATH}

```
If necessary, modify the environment variables:
```
vi ${GITHUB_PATH}/${UPGRADE_BIN}/${UPGRADE_JUMPHOST_VARS}

```
Now you can execute the upgrade script:
```
source ${GITHUB_PATH}/${UPGRADE_BIN}/${UPGRADE_JUMPHOST_SCRIPT}

```
Once finished, you can transfer the upgrade repository to the mirror host:
```
export MIRROR_HOST=mirror.sebastian-colomar.com
export REMOTE_USER=ec2-user
export SSH_KEY=${HOME}/key.txt

```

```
tar cfvz ${GITHUB_REPO}.tgz ${GITHUB_PATH}

scp -i ${SSH_KEY} ${GITHUB_REPO}.tgz ${REMOTE_USER}@{MIRROR_HOST}:

```
Now you can log in into the mirror host and continue there the upgrade process:
```
ssh -i ${SSH_KEY} ${REMOTE_USER}@{MIRROR_HOST}

```


## MIRROR HOST script

From the `mirror host` execute the following commands:

```
export GITHUB_REPO=protech
export UPGRADE_BIN=upgrade/bin
export UPGRADE_MIRRORHOST_SCRIPT=mirror.sh
export UPGRADE_MIRRORHOST_VARS=mirror/00-export_vars.sh

```

```
export GITHUB_PATH=${GITHUB_REPO}-$( date +%s )

mkdir -p ${GITHUB_PATH}

tar fvxz ${GITHUB_REPO}.tgz -C ${GITHUB_PATH} --strip-components=1

```
If necessary, modify the environment variables:
```
vi ${GITHUB_PATH}/${UPGRADE_BIN}/${UPGRADE_MIRRORHOST_VARS}

```
Now you can execute the upgrade script:
```
source ${GITHUB_PATH}/${UPGRADE_BIN}/${UPGRADE_MIRRORHOST_SCRIPT}

```
