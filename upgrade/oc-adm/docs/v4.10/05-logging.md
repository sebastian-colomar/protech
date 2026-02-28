# DISCLAIMER
The following material is reproduced from the referenced guides and is provided exclusively for educational and training purposes.
It is provided on an "as-is" basis, without any express or implied warranties, and no responsibility is assumed for its accuracy, completeness, or applicability to any particular use.

---

# 5. Upgrade Elastic Search and Cluster Logging

## REFERENCES:
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.9/html/logging/cluster-logging-upgrading


## Procedure

5.1. Ensure that all Elastic Search and OpenShift Cluster Logging Pods, including the operator pods, are in Ready state in the `openshift-logging` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-operators-redhat/pods
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-logging/pods

```
oc -n openshift-operators-redhat get po

oc -n openshift-logging get po

```

5.2. Ensure that the Elasticsearch cluster is healthy:
```
oc exec -n openshift-logging -c elasticsearch svc/elasticsearch -- health
    
```
5.3. Ensure that the Elasticsearch cron jobs are created:
```
oc -n openshift-logging get cj

```
5.4. Verify that the log store is updated and the indices are green. Verify that the output includes the `app-00000x, infra-00000x, audit-00000x, .security` indices:
```
oc exec -n openshift-logging -c elasticsearch svc/elasticsearch-cluster -- indices | grep -E "health|app-|audit-|infra-|.security"

```

5.5. Verify that the log collector is healthy:
```
oc -n openshift-logging get ds collector

```    

5.6. Verify that the pod contains a collector container:
```
oc -n openshift-logging get ds collector -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{"\n"}{end}' | grep collector

``` 

5.7. Verify that the Kibana pod is in Ready status:
```
oc -n openshift-logging get pods -l component=kibana -o jsonpath='{range .items[*]}{.metadata.name}{" -> "}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}'
    
```

5.8. UPDATE the OpenShift Elasticsearch Operator:
    
> WARNING
> 
> This will update the operator

```
CHANNEL=stable-5.6
NAMESPACE=openshift-operators-redhat
SOURCE=mirror-elasticsearch-operator-v4-10
SOURCE_NAMESPACE=openshift-marketplace
SUB=elasticsearch-operator

oc -n ${NAMESPACE} patch sub ${SUB} --type=merge -p '{"spec":{"channel":"'${CHANNEL}'","source":"'${SOURCE}'","sourceNamespace":"'${SOURCE_NAMESPACE}'"}}'    
 
```
5.9. Ensure that all Elastic Search and OpenShift Cluster Logging Pods, including the operator pods, are in Ready state in the `openshift-logging` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-operators-redhat/pods
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-logging/pods

```
watch 'oc -n openshift-operators-redhat get po;echo;oc -n openshift-logging get po'

```

5.10. Ensure that the Elasticsearch cluster is healthy:
```
oc exec -n openshift-logging -c elasticsearch svc/elasticsearch -- health
    
```

5.11. Ensure that the Elasticsearch cron jobs are created:
```
oc -n openshift-logging get cj
    
```

5.12. Verify that the log store is updated and the indices are green. Verify that the output includes the `app-00000x, infra-00000x, audit-00000x, .security` indices:
```
oc exec -n openshift-logging -c elasticsearch svc/elasticsearch-cluster -- indices | grep -E "health|app-|audit-|infra-|.security"
    
```

5.13. Verify that the log collector is healthy:
```
oc -n openshift-logging get ds collector
    
```

5.14. Verify that the pod contains a collector container:
```
oc -n openshift-logging get ds collector -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{"\n"}{end}' | grep collector
    
```

5.15. Verify that the Kibana pod is in Ready status:
```
oc -n openshift-logging get pods -l component=kibana -o jsonpath='{range .items[*]}{.metadata.name}{" -> "}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}'
    
```

5.16. UPDATE the OpenShift Cluster Logging Operator:
    
> WARNING
> 
> This will update the operator

```
CHANNEL=stable-5.6
NAMESPACE=openshift-logging
SOURCE=mirror-cluster-logging-v4-10
SOURCE_NAMESPACE=openshift-marketplace
SUB=cluster-logging

oc -n ${NAMESPACE} patch sub ${SUB} --type=merge -p '{"spec":{"channel":"'${CHANNEL}'","source":"'${SOURCE}'","sourceNamespace":"'${SOURCE_NAMESPACE}'"}}'        
 
```
5.17. Ensure that all Elastic Search and OpenShift Cluster Logging Pods, including the operator pods, are in Ready state in the `openshift-logging` namespace:
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-operators-redhat/pods
- https://console-openshift-console.apps.hub.sebastian-colomar.com/k8s/ns/openshift-logging/pods

```
watch 'oc -n openshift-operators-redhat get po;echo;oc -n openshift-logging get po'

```

5.18. Ensure that the Elasticsearch cluster is healthy:
```
oc exec -n openshift-logging -c elasticsearch svc/elasticsearch -- health
    
```

5.19. Ensure that the Elasticsearch cron jobs are created:
```
oc -n openshift-logging get cj
    
```

5.20. Verify that the log store is updated and the indices are green. Verify that the output includes the `app-00000x, infra-00000x, audit-00000x, .security` indices:
```
oc exec -n openshift-logging -c elasticsearch svc/elasticsearch-cluster -- indices | grep -E "health|app-|audit-|infra-|.security"
    
```

5.21. Verify that the log collector is healthy:
```
oc -n openshift-logging get ds collector
    
```

5.22. Verify that the pod contains a collector container:
```
oc -n openshift-logging get ds collector -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{"\n"}{end}' | grep collector
    
```

5.23. Verify that the Kibana pod is in Ready status:
```
oc -n openshift-logging get pods -l component=kibana -o jsonpath='{range .items[*]}{.metadata.name}{" -> "}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}'

```
