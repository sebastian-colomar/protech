date

# 3.3. Install the OpenShift CLI:

cd ${HOME}
mkdir -p ${BINARY_PATH}
grep -q ":${BINARY_PATH}:" ~/.bashrc || echo "export PATH=\"${BINARY_PATH}:\${PATH}\"" | tee -a ~/.bashrc
#source ~/.bashrc
unalias cp mv rm 2>/dev/null || true
for package in ${PACKAGES}; do
  mv -fv ${REMOVABLE_MEDIA_PATH}/${package}-linux-${RELEASE}.tar.gz ${HOME} || true
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
