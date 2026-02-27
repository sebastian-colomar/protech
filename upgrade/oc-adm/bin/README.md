# How to use the mirroring scripts

- The first script should run on a jumphost with internet access. It will download the mirror images and send them to the mirror host using SSH.
- The second script should run on the mirror host. This host does not have internet access, but it can connect to the OpenShift cluster.
- Both the jumphost and the mirror host must be able to use `oc` commands to connect to the OpenShift API.

## 1. JUMPHOST script

### 1.1. From the `jumphost` execute the following commands:

```
GITHUB_BRANCH=oc-adm
GITHUB_REPO=protech
GITHUB_USER=sebastian-colomar

```
```
cd ${HOME}
rm -rf ${GITHUB_REPO}
git clone --branch ${GITHUB_BRANCH} --single-branch -- https://github.com/${GITHUB_USER}/${GITHUB_REPO}

```
### 1.2. You can now run the mirroring script:

### WARNING
> The RELEASE variable for the version you want to mirror should already be exported

```
if [ -z "${RELEASE}" ]; then
  echo "ERROR: RELEASE is not set or empty"
  exit 1
fi

export HOST=jumphost
export KUBECONFIG=/root/auth/kubeconfig
SCRIPT=upgrade/oc-adm/bin/mirroring.sh

```
```
nohup bash ${HOME}/${GITHUB_REPO}/${SCRIPT} 1> ${HOME}/${HOST}.log 2> ${HOME}/${HOST}-errors.log &

```
### 1.3. After it finishes, you can copy the upgrade repository to the mirror host:
```
MIRROR_HOST=mirror.sebastian-colomar.com
REMOTE_USER=ec2-user
SSH_KEY=${HOME}/auth/key.txt

```
```
cd ${HOME}
tar cfvz ${GITHUB_REPO}.tgz ${GITHUB_REPO}
scp -i ${SSH_KEY} ${GITHUB_REPO}.tgz ${REMOTE_USER}@${MIRROR_HOST}:

```
### 1.4. You can now log in to the mirror host and continue the mirroring process there:
```
ssh -i ${SSH_KEY} ${REMOTE_USER}@${MIRROR_HOST}

```


## 2. MIRROR HOST script

### 2.1. On the `mirror host`, run the following commands:
```
GITHUB_REPO=protech
REMOTE_USER=ec2-user

```
```
sudo mv -fv /home/${REMOTE_USER}/${GITHUB_REPO}.tgz ${HOME}

```
```
cd ${HOME}
tar fvxz ${GITHUB_REPO}.tgz

```
### 2.2. You can now run the mirroring script:

### WARNING
> The RELEASE variable for the version you want to mirror should already be exported

```
export HOST=mirror
export KUBECONFIG=/root/auth/kubeconfig
SCRIPT=upgrade/oc-adm/bin/mirroring.sh

```
```
nohup bash ${HOME}/${GITHUB_REPO}/${SCRIPT} 1> ${HOME}/${HOST}.log 2> ${HOME}/${HOST}-errors.log &

```

## 3. Mirror validation
  - [Verify the mirroring process](../docs/02-mirror-validation.md)
