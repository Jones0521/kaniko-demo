podTemplate(containers: [
    containerTemplate(name: 'golang', image: 'arm64v8/golang:latest', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'kubectl', image: 'rancher/kubectl:v1.22.2', command: 'cat', ttyEnabled: true),
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
            git url: '{{REPO}}'
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