export BASE_URL=https://mirror.openshift.com/pub/openshift-v4
export BINARY=oc-mirror
export RELEASE=4.10.64

export CACHE=/mnt/mirror
export FILE=ocp
export ISC=ImageSetConfiguration



if test ! -f $BINARY; then
  tar fxz $BINARY.tgz
fi
ls -l $BINARY
df -h .


#disk2mirror
mkdir -p $HOME/.docker
cp .dockerconfigjson-merged $HOME/.docker/config.json
chmod +x $BINARY
cp $BINARY /usr/local/bin/$BINARY
$BINARY --v2 --version
$BINARY --v2 --config $ISC.yaml --cache-dir $CACHE $OPS --from file://$FILE docker://$MIRROR
