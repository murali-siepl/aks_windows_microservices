pipeline {
  agent any 
     environment {
          def regUrl = "k8workshopregistry.azurecr.io"
          def appImage = "spring-demo-api";
          def apiImage = "angular-ui"
          def dockerRepo = "angular-ui"
          def latestTag = "latest";
          buildNumber = "${env.BUILD_ID}"
          branchName = "${env.GIT_BRANCH}"
          def buildTag = "build-${BUILD_NUMBER}";
          def releaseTag = "qa";
          def pullSecret = "acr-secret"
          def environment = "dev"
          def namespace = "jenkins"
          def acr = "k8workshopregistry"
     }
  
    stages {
        stage('Get a Maven project') {
           steps {
            sh 'mvn -Dmaven.test.failure.ignore clean package'
            } 
          }
      
 
            stage('Build Docker Image') {
                steps {
                sh """ 
                echo "Build tag is ${buildTag} "
                docker build -t ${regUrl}/${appImage}:${buildNumber} . 
                docker build -t ${regUrl}/${apiImage}:${buildNumber}  ${dockerRepo}/
                docker push $regUrl/$appImage:${buildNumber}
                docker push $regUrl/$apiImage:${buildNumber}
                """
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
              sh "./spring-demo-api-deployment.sh " +
                "${pullSecret} " + //repo
                "${environment} " + //environment
                "${namespace} " + //namespace
              //  "${IMAGE_NAME} " + //image name
                "${env.BUILD_ID} " + //image version
             //   "${DOCKER_REPO} " + //docker repo
                "${acr} " + //azure registry
                "1" // replica count
               }
            }
           stage("Deploy Angular-UI") {
              steps {
          //  def ticketId = mozart.openAksRfc(buildProdMozartRequest())
          //  withCredentials([prodAzureSecretRepo]) {
              sh "./angular-ui.sh " +
                "${pullSecret} " + //repo
                "${environment} " + //environment
                "${namespace} " + //namespace
              //  "${IMAGE_NAME} " + //image name
                "${env.BUILD_ID} " + //image version
             //   "${DOCKER_REPO} " + //docker repo
                "${acr} " + //azure registry
                "1" // replica count
               }
	   }
           /*  stage('Deploy image'){
		          steps {
                      sh """
        		      kubectl apply -f ./spring-boot-deployment.yaml
		              kubectl apply -f ./spring-angular-ui.yaml
		              kubectl get pods
                      """
		              }
	   	 }*/

        }
 }

