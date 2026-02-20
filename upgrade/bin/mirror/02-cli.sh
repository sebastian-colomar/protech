  # 3.3. Install the OpenShift CLI:

cd ${HOME}
mkdir -p ${BINARY_PATH}
grep -q ":${BINARY_PATH}:" ~/.bashrc || echo "export PATH=\"${BINARY_PATH}:\${PATH}\"" | tee -a ~/.bashrc
source ~/.bashrc
unalias cp mv rm 2>/dev/null || true
for package in ${PACKAGES}; do
 mv ${REMOVABLE_MEDIA_PATH}/${package}-linux-${OCP_RELEASE_NEW}.tar.gz ${HOME}
 tar fxvz ${package}-linux-${OCP_RELEASE_NEW}.tar.gz
done
for binary in ${BINARIES}; do
 mv ${binary} ${BINARY_PATH}/${binary}-${OCP_RELEASE_NEW}
done
rm -fv ${BINARY_PATH}/oc
rm -fv ${BINARY_PATH}/opm

ln -s ${BINARY_PATH}/oc-${OCP_RELEASE_NEW} ${BINARY_PATH}/oc-${RH_INDEX_VERSION_NEW} || true
ln -s ${BINARY_PATH}/opm-${OCP_RELEASE_NEW} ${BINARY_PATH}/opm-${RH_INDEX_VERSION_NEW} || true

