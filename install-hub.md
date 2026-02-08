# Install Red Hat Openshift Container Platform in AWS:

```
sudo su --login root
```
```
export github_branch=v4.8.37
export github_repository=openshift
export github_username=sebastian-colomar
export github_location=${HOME}/${github_repository}-$( date +%s )
```
```
git clone https://github.com/sebastian-colomar/protech
git clone --branch ${github_branch} --single-branch -- https://github.com/${github_username}/${github_repository} ${github_location}
```
```
unalias cp mv rm
cp -fv protech/etc/ocp/00-env.sh ${github_location}/install/
cd ${github_location}/install/
source ocp-aws-install.sh
```
