pipeline {
  agent any 
     environment {
          def regUrl = "k8workshopregistry.azurecr.io"
          def appImage = "spring-demo-api";
          def apiImage = "angular-ui"
          def dockerRepo = "angular-ui"
          def latestTag = "latest";
          def buildNumber = "${env.BUILD_ID}"
          def branchName = "${env.GIT_BRANCH}"
          def buildTag = "build-${BUILD_NUMBER}";
          def releaseTag = "qa";
          def pullSecret = "acr-secret"
          def environment = "dev"
          def namespace = "jenkins"
          def acr = "k8workshopregistry"
          def AKS_SRVC_USER = "e544388b-8114-4c6b-bf63-622229700801"
          def AKS_SRVC_PASSWORD = "Y-QE.u749jYprWEL5egYCiWSgxaghkj3CC"
          def TENANT_ID = "5f9d8183-ac49-417b-95c3-f12d0b218595"
          def RESOURCE_GROUP = "RSG-AKSDemo"
	  def CLUSTER_NAME = "DemoMicroservices"
          def INGRESS_HOSTNAME_SPRING_DEMO = "${appImage}-app.aks.cloudapp.azure.com"
          def INGRESS_HOSTNAME_SPRING_API = "${apiImage}-app.aks.cloudapp.azure.com"
        
     }
      
    stages {
	    
        stage('Build Maven Spring-Boot-Demo API Project') {
           steps {
            sh 'mvn -Dmaven.test.failure.ignore clean package'
            } 
          }
      
 
            stage('Build Spring-boot-demo API Docker Image') {
                steps {
                sh """ 
                echo "Build tag is ${buildTag} "
                docker build -t ${regUrl}/${appImage}:${buildNumber} . 
                docker push ${regUrl}/${appImage}:${buildNumber}
                """
                    }
            }
		stage('Build Angular-UI Docker Image') {
 	               steps {
        	        sh """ 
                	echo "Build tag is ${buildTag} "
	                docker build -t ${regUrl}/${apiImage}:${buildNumber}  ${dockerRepo}/
                	docker push $regUrl/$apiImage:${buildNumber}
	                """
                    }
            }                 

	     stage("Authenticate Service Account") {
     		         steps {
               // withCredentials([azureServiceAccount, azureTenantId, devSixClusterName, resourceGroup]) {
               //   sh 'chmod -R 777 ./bin/aks'
                  sh "./bin/authenticate-az-service-account.sh " +
                    "${env.AKS_SRVC_USER} " +
                    "${env.AKS_SRVC_PASSWORD} " +
                    "${env.TENANT_ID} " +
                    "${RESOURCE_GROUP} " +
                    "${CLUSTER_NAME}"
                        }
              }
	    /*  stage('Vulnerability Scan w/Twistlock') {
		      steps {
                twistlock.scanImage("k8workshopregistry.azurecr.io/hello-world-java:latest")
    }
	      }	      
                  


        
        stage('Scan') {
            steps {
                // Scan the image
                prismaCloudScanImage ca: '',
                cert: '',
                dockerAddress: 'unix:///var/run/docker.sock',
                image: 'k8workshopregistry.azurecr.io/hello-world-java:latest',
                key: '',
                logLevel: 'info',
                podmanPath: '',
                project: '',
                resultsFile: 'prisma-cloud-scan-results.json',
                ignoreImageBuildTime:true
            }
        }*/
           stage("Deploy Spring Boot Demo API") {
              steps {
          //  def ticketId = mozart.openAksRfc(buildProdMozartRequest())
          //  withCredentials([prodAzureSecretRepo]) {
              sh "ls -l"
              sh "bin/spring-demo-api-deployment.sh " +
                "${pullSecret} " + //repo
                "${environment} " + //environment
                "${namespace} " + //namespace
              //  "${IMAGE_NAME} " + //image name
                "${env.BUILD_ID} " + //image version
             //   "${DOCKER_REPO} " + //docker repo
                "${acr} " + //azure registry
                "3" // replica count
               }
            }
           stage("Deploy Angular-UI") {
              steps {
          //  def ticketId = mozart.openAksRfc(buildProdMozartRequest())
          //  withCredentials([prodAzureSecretRepo]) {
              sh "./bin/angular-ui.sh " +
                "${pullSecret} " + //repo
                "${environment} " + //environment
                "${namespace} " + //namespace
              //  "${IMAGE_NAME} " + //image name
                "${env.BUILD_ID} " + //image version
             //   "${DOCKER_REPO} " + //docker repo
                "${acr} " + //azure registry
                "3" // replica count
               }
	   }
        	 stage("Unauthenticate Service Account") {
	           steps {
		        sh "./bin/unauthenticate-service-account.sh"
      			}
	}
    }
 }

