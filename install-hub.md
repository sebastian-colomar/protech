# Install Red Hat Openshift Container Platform in AWS:

```
sudo su --login root
```
```
export github_branch=master
export github_repository=openshift
export github_username=sebastian-colomar
export github_location=${HOME}/${github_repository}-$( date +%s )
```
```
git clone --branch ${github_branch} --single-branch -- https://github.com/${github_username}/${github_repository} ${github_location}
cp -v ~/protech/etc/ocp/00-env.sh ${github_location}/${github_branch}/install/
cd ${github_location}/${github_branch}/install/
source ocp-aws-install.sh
```
