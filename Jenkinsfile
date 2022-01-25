podTemplate(containers: [
    containerTemplate(name: 'golang',  image: 'arm64v8/golang:latest',  ttyEnabled: true, command: 'sleep 99999'),
    containerTemplate(name: 'kubectl', image: 'rancher/kubectl:v1.22.2',ttyEnabled: true, command: 'sleep 99999'),
  ], 
  yaml: """\
kind: Pod
apiVersion: v1
metadata:
  labels:
    k8s-app: jenkins-dynamic-agent01
  name: jenkins-dynamic-agent01
  namespace: devops
spec:
  containers:
    - name: jenkins-dynamic-agent01
      image: jenkins/inbound-agent:latest-jdk11
      imagePullPolicy: IfNotPresent
      resources:
        limits:
          cpu: 1000m
          memory: 2Gi
        requests:
          cpu: 500m
          memory: 512Mi
    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
	  resources:
        limits:
          cpu: 1000m
          memory: 2Gi
        requests:
          cpu: 500m
          memory: 512Mi
      command:
      - /busybox/cat
      tty: true
      volumeMounts:
        - name: kaniko-secret
          mountPath: /kaniko/.docker
  restartPolicy: Never
  volumes:
    - name: kaniko-secret
      secret:
        secretName: docker-cicd-config
    """.stripIndent()
   ) {
    node(POD_LABEL) {
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
                /kaniko/executor -c `pwd`/ -f `pwd`/image/Dockerfile -d 239620982073.dkr.ecr.ap-south-1.amazonaws.com/sundry:hello
                """
            }
       stage('Deploy') {
         withCredentials([file(credentialsId: 'kube-devops-jenkins-dynamic-agent-token', variable: 'KUBECONFIG')]){
           container('kubectl') {
           sh """
              mkdir -p ~/.kube && cp ${KUBECONFIG} ~/.kube/config
              kubectl apply -f deploy/k8s.yaml 
            """
            
           }
         }
       }
    }
}