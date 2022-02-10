pipeline {
    agent {
        kubernetes {
            cloud 'kubernetes'
		    slaveConnectTimeout 1200
        yaml '''
apiVersion: v1
kind: Pod
metadata:
  name: kaniko
  namespace: devops
spec:
  containers:
    name: kaniko
    image: public.ecr.aws/eag/kaniko:latest
    imagePullPolicy: IfNotPresent
    tty: true
    volumeMounts:
      - name: kaniko-secret
        mountPath: /kaniko/.docker/
      - name: aws-secret
        mountPath: /root/.aws/
    args:
    -  "9999999"
    command:
    - "sleep"
	image: "public.ecr.aws/docker/library/maven:3-jdk-8"
    imagePullPolicy: "IfNotPresent"
    name: "maven"
	tty: true
	args:
    -  "9999999"
    command:
    - "sleep"
    image: "arm64v8/golang:latest"
    imagePullPolicy: "IfNotPresent"
	name: golang
	tty: true
	args:
    -  "9999999"
    command:
    - "sleep"
    image: "public.ecr.aws/nslhub/k8s-kubectl:v1.22.5"
    imagePullPolicy: "IfNotPresent"
    name: "kubectl"
  restartPolicy: Never
  volumes:
    - name: kaniko-secret
      secret:
        secretName: docker-cicd-config
    - name: aws-secret
      secret:
        secretName: kaniko-aws-secret
'''
        }
    }
    stages { 
        stage('Clone') {
            git branch: 'main', url: 'https://github.com/Jones0521/kaniko-demo.git'
        }
        stage('Compile') {
            container('golang') {
                    sh """
                    make  
                    """
            }
        }
        stage('Build Image')
            container('kaniko') {
                sh """
                /kaniko/executor -c `pwd`/ -f `pwd`/image/Dockerfile -d 239620982073.dkr.ecr.ap-south-1.amazonaws.com/sundry:hello2 -d 239620982073.dkr.ecr.ap-south-1.amazonaws.com/sundry:latest
                """
            }
       stage('Deploy') {
            container('kubectl') {
                withKubeConfig([credentialsId: 'jenkins-admin',serverUrl: 'https://45F0A226C5356ACE9652E8EF53291533.gr7.ap-south-1.eks.amazonaws.com']) {
                    sh "kubectl apply -f deploy/k8s.yaml"
                }
            }
        }
    }
}