export BASE_URL=https://mirror.openshift.com/pub/openshift-v4
export BINARY=oc-mirror
export RELEASE=4.10.64

export CACHE=/mnt/mirror
export FILE=ocp
export ISC=ImageSetConfiguration



if test ! -f $BINARY; then
  curl -L -o $BINARY.tgz $BASE_URL/$(arch)/clients/ocp/$RELEASE/$BINARY.rhel9.tar.gz
  tar fxz $BINARY.tgz
fi
ls -l $BINARY
df -h .

# mirror2disk
mkdir -p $HOME/.docker
cp .dockerconfigjson $HOME/.docker/config.json
chmod +x $BINARY
cp $BINARY /usr/local/bin/$BINARY
$BINARY --v2 --version
$BINARY --v2 --config $ISC.yaml --cache-dir $CACHE file://$FILE
