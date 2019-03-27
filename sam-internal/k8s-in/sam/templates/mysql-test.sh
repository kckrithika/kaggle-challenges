#!/bin/sh
set -e
kubectl get pods -n sam-system -o wide | grep 'sql';
kubectl exec -n sam-system mysql-inmem-0 -c mysql-dumper -- mysql -utest -ppass -h127.0.0.1 "SELECT 1;";
kubectl scale statefulset -n sam-system mysql-inmem-0 --replicas=0
kubectl delete pod -n sam-system mysql-inmem-0 --force --grace-period=0
kubectl scale statefulset -n sam-system mysql-inmem-0 --replicas=1
sleep 30;
kubectl exec -n sam-system mysql-inmem-0 -c mysql-dumper -- mysql -utest -ppass -h127.0.0.1 "SELECT 1;";
