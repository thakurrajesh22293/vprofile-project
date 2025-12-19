pipeline {
    agent any

    tools {
        maven "Maven3.9"
        jdk "JDK17"
    }

    environment {
		SNAP_REPO = 'vprofile-snapshot'
        RELEASE_REPO = 'vprofile-release'
        NEXUS_USER = 'admin'
		NEXUS_PASS = 'Mca@bca123'
		CENTRAL_REPO = 'vprofile-maven-central'
		NEXUSIP = '172.31.5.98'
		NEXUSPORT = '8081'
		NEXUS_GRP_REPO = 'vprofile-maven-group'
        NEXUS_LOGIN = 'nexus-server'
        SONARSERVER = 'sonar-scanner'        
        SONARSCANNER = 'sonar-scanner'      
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn -s settings.xml -DskipTests clean install'
            }
            post {
                success {
                    echo "Archiving WAR file"
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }

        stage('Test') {
            steps {
                sh 'mvn -s settings.xml test'
            }
        }

        stage('Checkstyle Analysis') {
            steps {
                sh 'mvn -s settings.xml checkstyle:checkstyle'
            }
        }

        stage('Sonar Analysis') {
            environment {
                scannerHome = tool "${SONARSCANNER}"
            }
            steps {
                withSonarQubeEnv("${SONARSERVER}") {
                    sh """
                    ${scannerHome}/bin/sonar-scanner \
                    -Dsonar.projectKey=vprofile \
                    -Dsonar.projectName=vprofile \
                    -Dsonar.projectVersion=1.0 \
                    -Dsonar.sources=src \
                    -Dsonar.java.binaries=target \
                    -Dsonar.junit.reportsPath=target/surefire-reports \
                    -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml
                    """
                }
            }
        }

        stage('Upload Artifact') {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: "${NEXUSIP}:${NEXUSPORT}",
                    groupId: 'QA',
                    version: "${env.BUILD_NUMBER}",
                    repository: "${RELEASE_REPO}",
                    credentialsId: "${NEXUS_LOGIN}",
                    artifacts: [
                        [
                            artifactId: 'vproapp',
                            classifier: '',
                            file: 'target/vprofile-v2.war',
                            type: 'war'
                        ]
                    ]
                )
            }
        }
    }
}
