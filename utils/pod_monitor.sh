#!/bin/bash

# This script prints all the pods in my namesapce

name_space="user-pengfei"

while true; do 
kubectl get pods -n $name_space
sleep 2
done
