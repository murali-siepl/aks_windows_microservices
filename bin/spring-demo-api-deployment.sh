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

DEPLOYMENT_NAME="spring-demo-api-${ENVIRONMENT}-deployment"
DEPLOYMENT_POD="spring-demo-api-${ENVIRONMENT}-pod"
DEPLOYMENT_SERVICE="spring-demo-api-${ENVIRONMENT}-service"
HTTPS_CONTAINER_PORT=8443
HTTP_CONTAINER_PORT=8080
INGRESS_NAME="spring-demo"

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
    app: spring-demo-api-${ENVIRONMENT}
  ports:
    - protocol: TCP
      port: 8443
      targetPort: ${HTTPS_CONTAINER_PORT}
      name: https
    - protocol: TCP
      port: 8080
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
    app: spring-demo-api-${ENVIRONMENT}
spec:
  replicas: ${REPLICAS}
  selector:
    matchLabels:
      app: spring-demo-api-${ENVIRONMENT}
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: spring-demo-api-${ENVIRONMENT}
    spec:
      containers:
      - name: spring-demo-api-${ENVIRONMENT}
        image: ${ACR}.azurecr.io/spring-demo-api:${IMAGE_VERSION}
        imagePullPolicy: Always
        resources:
          requests:
            memory: '200Mi'
            cpu: '100m'
          limits:
            memory: '200Mi'
            cpu: '300m'
        livenessProbe:
          httpGet:
            port: ${HTTP_CONTAINER_PORT}
            httpHeaders:
            - name: Custom-Header
              value: "Hello World 2021"
          initialDelaySeconds: 15
          periodSeconds: 10
          timeoutSeconds: 30
          successThreshold: 1
          failureThreshold: 5
        readinessProbe:
          httpGet:
            port: ${HTTP_CONTAINER_PORT}
            httpHeaders:
            - name: Custom-Header
              value: "Hello World 2021"
          initialDelaySeconds: 20
          periodSeconds: 3
      imagePullSecrets:
        - name: ${PULL_SECRET}
" > deployment.yaml

# Deploy the application containers to the cluster with kubernetes
kubectl apply -f deployment.yaml -o json --wait --timeout 90s
echo "apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
  name: ${INGRESS_NAME} 
  namespace: jenkins
spec:
  rules:
  - host: ${INGRESS_HOSTNAME_SPRING_DEMO}
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
