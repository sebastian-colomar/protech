# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# 6. Upgrade AKO operator:

## Procedure

6.1. Verify the current state of the operator:
```
NS=avi-system

oc -n ${NS} get sub

oc -n ${NS} get csv

oc -n ${NS} get po

```

6.2.UPDATE the AKO operator:
```
if [ -z "${RELEASE}" ]; then
 echo "ERROR: RELEASE is not set or empty"
 exit 1
fi

MAJOR=$( echo ${RELEASE} | cut -d. -f1 )
MINOR=$( echo ${RELEASE} | cut -d. -f2 )
VERSION=v${MAJOR}.${MINOR}

```
```
CHANNEL=stable
NS=avi-system
SOURCE_NS=openshift-marketplace
SUB=ako-operator

```
```
SOURCE=mirror-${SUB}-v${MAJOR}-${MINOR}

oc -n ${NS} patch sub ${SUB} --type=merge -p '{"spec":{"channel":"'${CHANNEL}'","source":"'${SOURCE}'","sourceNamespace":"'${SOURCE_NS}'"}}'

```
6.3. Verify the success of the update:
```
NS=avi-system

oc -n ${NS} get sub

oc -n ${NS} get csv

oc -n ${NS} get po

```
