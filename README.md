Download this repositry

**Method 1

run following shell script:-


          cd EKS ;sh execute.sh --accountid <YOURACCOUNTID> --region <AWSREGION> --name <CLUSTERNAME> --ADDUSER1 <user1> --ADDUSER2 <user2>
 
**Method 2
**
 
 Manual Setup

Update account details, region, clustername  in variables.tf and user details outputs.tf
Run terraform init ,terraform plan , terraform apply.

After completion of job , You will get output with config file content and Kubeconfig.

Save the config to ~/.kube/config file and update the configmap using below command.

kubectl edit configmap aws-auth -n kube-system
Under the map user add the content that you have got from output for mapUser spec given by terraform. .


You need to replace XXXXXXX values with account id.

        kubectl annotate serviceaccount -n kube-system aws-node eks.amazonaws.com/role-arn=arn:aws:iam::XXXXXXXX:role/aws-node
        
 
to check if anotations are added, perform the following 

        kubectl describe sa -n kube-system aws-node 

Once you have annoted you need to delete the amazon load balancer pods , It is necessary to get new pods with annotations of service account for this we have to delete the pods . 
For deleting PODS, You need to run below command.

           kubectl get pods -n kube-system |grep aws-load 

           kubectl delete pods -n kube-system aws-load-balancer-controller-XXXXXXX (Change the value accordingly you get in output)

           kubectl delete pods -n kube-system aws-load-balancer-controller-XXXXXXX

Once both the pods are restarted confirm it with 
kubectl get pods -n kube-system |grep aws-load
It will show up time of pods.

Then apply 

          kubectl apply -f 2048_full.yaml and you will get out put like following:-

  namespace/game-2048 created
  deployment.apps/deployment-2048 created
  service/service-2048 created
  ingress.networking.k8s.io/ingress-2048 created
  
To test if the cluster is successfully created, perform following command:

         kubectl get ingress -n game-2048 
         
after performing this command, you will get the details and endpoints like:-
NAME           CLASS    HOSTS   ADDRESS                                                                  PORTS   AGE
ingress-2048   <none>   *       k8s-game2048-ingress2-4347728cc5-583095857.us-east-1.elb.amazonaws.com   80      4m54s

 
 copy the address collumn and paste it in browser, you will be able to see application running.
 
If Aws-autheticator not found.
         https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
