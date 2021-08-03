#!/usr/bin/env bash

# Exit script if any command returns non-zero
set -e

if [ "$#" -ne 6 ]; then
  echo "ERROR: Incorrect number of arguments, 8 required"
  echo "Usage:"
  echo "$0 <pullSecret> <ENVIRONMENT> <NAMESPACE> <IMAGE_NAME> <IMAGE_VERSION> <DOCKER_REPO> <ACR> <REPLICAS>"
  exit 1
fi

PULL_SECRET=$1
ENVIRONMENT=$2
NAMESPACE=$3
#IMAGE_NAME=$4
IMAGE_VERSION=$4
#DOCKER_REPO=$6
ACR=$5
REPLICAS=$6

DEPLOYMENT_NAME="angular-ui-${ENVIRONMENT}-deployment"
DEPLOYMENT_POD="angular-ui-${ENVIRONMENT}-pod"
DEPLOYMENT_SERVICE="angular-ui-${ENVIRONMENT}-service"
HTTPS_CONTAINER_PORT=443
HTTP_CONTAINER_PORT=80
INGRESS_NAME=spring-api

# Prints all executed commands to terminal
set -x

echo "apiVersion: v1
kind: Service
metadata:
  name: ${DEPLOYMENT_SERVICE}
  namespace: ${NAMESPACE}
spec:
  type: ClusterIP
  selector:
    app: angular-ui-${ENVIRONMENT}
  ports:
    - protocol: TCP
      port: 443
      targetPort: ${HTTPS_CONTAINER_PORT}
      name: https
    - protocol: TCP
      port: 80
      targetPort: ${HTTP_CONTAINER_PORT}
      name: http
" > service.yaml

# Create a service to attach to the deployment
kubectl apply -f service.yaml --wait
echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${DEPLOYMENT_NAME}
  namespace: ${NAMESPACE}
  labels:
    app: angular-ui-${ENVIRONMENT}
spec:
  replicas: ${REPLICAS}
  selector:
    matchLabels:
      app: angular-ui-${ENVIRONMENT}
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: angular-ui-${ENVIRONMENT}
    spec:
      containers:
      - name: angular-ui-${ENVIRONMENT}
        image: ${ACR}.azurecr.io/angular-ui:${IMAGE_VERSION}
        imagePullPolicy: Always
        resources:
          requests:
            memory: '200Mi'
            cpu: '100m'
          limits:
            memory: '200Mi'
            cpu: '300m'
        livenessProbe:
          tcpSocket:
            port: ${HTTP_CONTAINER_PORT}
          initialDelaySeconds: 15
          periodSeconds: 3
          timeoutSeconds: 30
          successThreshold: 1
          failureThreshold: 5
      imagePullSecrets:
        - name: ${PULL_SECRET}
" > deployment.yaml

# Deploy the application containers to the cluster with kubernetes
kubectl apply -f deployment.yaml -o json --wait --timeout 90s
#Deploy Igress
echo "apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: "nginx"
  name: ${INGRESS_NAME}
  namespace: jenkins
spec:
  rules:
  - host: ${INGRESS_HOSTNAME_SPRING_API}
    http:
      paths:
      - backend:
          serviceName: ${DEPLOYMENT_SERVICE}
          servicePort: ${HTTP_CONTAINER_PORT}
        path: /
        pathType: Prefix
" > ingress.yaml

#Deploy Ingress
kubectl apply -f ingress.yaml --wait 

