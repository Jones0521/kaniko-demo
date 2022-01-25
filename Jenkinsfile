podTemplate(cloud: 'kubernetes',containers: [
    containerTemplate(args: '9999999', command: 'sleep', image: 'arm64v8/golang:latest',name: 'golang',  ttyEnabled: true),
    containerTemplate(args: '9999999', command: 'sleep', image: 'rancher/kubectl:v1.22.2',name: 'kubectl',ttyEnabled: true),
  ], 
  yaml: """\
apiVersion: v1
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command: ['sh', '-c','sleep 99999']
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