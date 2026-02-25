# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# 1. Upgrade AKO operator:

## Procedure

1.1. Verify the current state of the operator:
```
NS=avi-system

oc -n ${NS} get sub

oc -n ${NS} get csv

oc -n ${NS} get po

```

1.2.UPDATE the AKO operator:
```
CHANNEL=stable
NS=openshift-storage
SOURCE=mirror-ako-operator-v4-9
SOURCE_NS=openshift-marketplace
SUB=ako-operator

oc -n ${NS} patch sub ${SUB} --type=merge -p '{"spec":{"channel":"'${CHANNEL}'","source":"'${SOURCE}'","sourceNamespace":"'${SOURCE_NS}'"}}'

```
1.3. Verify the success of the update:
```
NS=avi-system

oc -n ${NS} get sub

oc -n ${NS} get csv

oc -n ${NS} get po

```
