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
              kubectl config set-credentials jenkins-token --token=ZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNkltdFBja1I0T1ZNMGNFUXdZbnB3V1VkYVkxVlRhSFZ6Y1ZGRlRESnNlRzFFYm1GRVoyUlNNMEppWlc4aWZRLmV5SnBjM01pT2lKcmRXSmxjbTVsZEdWekwzTmxjblpwWTJWaFkyTnZkVzUwSWl3aWEzVmlaWEp1WlhSbGN5NXBieTl6WlhKMmFXTmxZV05qYjNWdWRDOXVZVzFsYzNCaFkyVWlPaUprWlhadmNITWlMQ0pyZFdKbGNtNWxkR1Z6TG1sdkwzTmxjblpwWTJWaFkyTnZkVzUwTDNObFkzSmxkQzV1WVcxbElqb2lhbVZ1YTJsdWN5MTBiMnRsYmkxeGJESTFjU0lzSW10MVltVnlibVYwWlhNdWFXOHZjMlZ5ZG1salpXRmpZMjkxYm5RdmMyVnlkbWxqWlMxaFkyTnZkVzUwTG01aGJXVWlPaUpxWlc1cmFXNXpJaXdpYTNWaVpYSnVaWFJsY3k1cGJ5OXpaWEoyYVdObFlXTmpiM1Z1ZEM5elpYSjJhV05sTFdGalkyOTFiblF1ZFdsa0lqb2lNemcxT1RVMk5HRXRZek5sWlMwMFl6SmlMVGd3WkdFdE9XUTJPV1ZtTXpJM05HWXhJaXdpYzNWaUlqb2ljM2x6ZEdWdE9uTmxjblpwWTJWaFkyTnZkVzUwT21SbGRtOXdjenBxWlc1cmFXNXpJbjAuaWhoNm9RcW9VT1BfVzhEdldfSUJTU1V1M0liel9rWGVobldLcWU3bVhOTDNOWEktYlpyWnY3OXVyVWFJUnJEd2JYMVZBTy1JNHp0c3F1bGxsN1ZKcGR6UTdpemROeWw5aGJRYm5LaHVNMUdsNTJXWGpVd1AtaWpEYVNqdFpmdF9kbGpiV2J3NmZfRU1PTWlBb1NjWHRLVXAyeWczbEtLdW5VV1BTeVJma080eVp4czg0cXNSZ29YY2F5dWpoakI3QmpyRzVsMks2LUdzY3JWYVVCbmotN0pFYzFvZldodEtVek5vWVF6WDBQZmtkcHNlaHE3NG5mWWgwM0lTWlBaLUdLQ09vNURueGtfYUdPREM5Zy1aSU9MaXBOclJ6ZjdoRXhwSUw5b1FmRjVlZUJ3Yl9zZmZZX213bnAtMUdDeW0tRGJxaUxzUlRkR0dxOEd5ZWgtQmxB
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