# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# 1. Upgrade AKO operator:

## Procedure

1.1.Update te AKO operator:

    alias oc=oc-4.10.64

    export CATALOG_SOURCE=mirror-certified-operator-index-v4-10

    oc patch subscription ako-operator -n openshift-storage --type json --patch '[{"op": "replace", "path": "/spec/source", "value": "'${CATALOG_SOURCE}'" }]'

