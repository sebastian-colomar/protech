date

# 1.4. Install the OpenShift CLI by downloading the binary:

cd ${HOME}
mkdir -p ${BINARY_PATH}
grep -q ":${BINARY_PATH}:" ~/.bashrc || echo "export PATH=\"${BINARY_PATH}:\${PATH}\"" | tee -a ~/.bashrc
#source ~/.bashrc
unalias cp mv rm 2>/dev/null || true
for package in ${PACKAGES}; do
  curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${RELEASE}/${package}-linux-${RELEASE}.tar.gz
  tar fxvz ${package}-linux-${RELEASE}.tar.gz
done
for binary in ${BINARIES}; do
  mv -fv ${binary} ${BINARY_PATH}/${binary}-${RELEASE} 
done

rm -fv kubectl
rm -fv README.md

rm -fv ${BINARY_PATH}/oc
rm -fv ${BINARY_PATH}/opm

ln -sfnT ${BINARY_PATH}/oc-${RELEASE} ${BINARY_PATH}/oc-${VERSION}
ln -sfnT ${BINARY_PATH}/opm-${RELEASE} ${BINARY_PATH}/opm-${VERSION}

ln -sfnT ${BINARY_PATH}/oc-${RELEASE} ${BINARY_PATH}/oc
ln -sfnT ${BINARY_PATH}/opm-${RELEASE} ${BINARY_PATH}/opm

date
