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
