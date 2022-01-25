podTemplate(cloud: 'kubernetes',containers: [
    containerTemplate(args: '9999999', command: 'sleep', image: 'arm64v8/golang:latest',name: 'golang',  ttyEnabled: true),
    containerTemplate(args: '9999999', command: 'sleep', image: 'public.ecr.aws/nslhub/k8s-kubectl:v1.22.5',name: 'kubectl',ttyEnabled: true),
  ], 
  yaml: """\
apiVersion: v1
kind: Pod
metadata:
  name: kaniko
  namespace: devops
spec:
  containers:
  - name: kaniko
    image: public.ecr.aws/eag/kaniko:latest
    tty: true
    volumeMounts:
      - name: kaniko-secret
        mountPath: /kaniko/.docker/
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
	       withCredentials([string(credentialsId: 'kube-devops-jenkins-dynamic-agent-token', variable: 'KUBECONFIG')]) {
	     // withCredentials([credentialsId: 'kube-devops-jenkins-dynamic-agent-token', variable: 'KUBECONFIG'])
         // withKubeConfig([credentialsId: 'kube-devops-jenkins-dynamic-agent-token',serverUrl: 'https://45F0A226C5356ACE9652E8EF53291533.gr7.ap-south-1.eks.amazonaws.com']){
           container('kubectl') {
           sh """
		      kubectl config set-cluster deveks01 --server=https://45F0A226C5356ACE9652E8EF53291533.gr7.ap-south-1.eks.amazonaws.com 
              kubectl config set-credentials jenkins-token --token=${KUBECONFIG} 
			  kubectl config set-context jenkins-agent --cluster=deveks01 --user=jenkins-token 
		      kubectl config use-context jenkins-agent
			  cat jenkins.kubeconfig
              kubectl apply -f deploy/k8s.yaml 
            """
            
           }
         }
       }
    }
}