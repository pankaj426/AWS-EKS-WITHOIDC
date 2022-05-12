set -ex

#sed -i '' -e s/ACCOUNTIDHERE/$2/g variables.tf

#sed -i '' -e s/REGIONHERE/$4/g variables.tf

#sed -i '' -e s/NAME_HERE/$6/g variables.tf

#sed -i '' -e s/ADDUSER1/$8/g outputs.tf

#sed -i '' -e s/ADDUSER2/$10/g outputs.tf

sed -i s/ACCOUNTIDHERE/$2/g variables.tf

sed -i s/REGIONHERE/$4/g variables.tf

sed -i s/NAME_HERE/$6/g variables.tf

sed -i s/ADDUSER1/$8/g outputs.tf

sed -i s/ADDUSER2/$10/g outputs.tf

terraform init

terraform plan

terraform apply --autoapprove

kube_config_file_name='kube/conf'

terraform output kubeconfig |grep -v EOT > $kube_config_file_name

account_id=$(terraform output config_map_aws_auth |grep rolearn|awk -F'::' '{print $2}'|awk -F':' '{print $1}')

kubectl --kubeconfig $kube_config_file_name annotate serviceaccount -n kube-system aws-node eks.amazonaws.com/role-arn=arn:aws:iam::${account_id}:role/aws-node --overwrite

kubectl --kubeconfig $kube_config_file_name describe sa -n kube-system aws-node

kubectl --kubeconfig $kube_config_file_name delete pods -n kube-system $(kubectl --kubeconfig $kube_config_file_name get pods -n kube-system |grep aws-load |cut -d " " -f1 )

sleep 10

kubectl --kubeconfig $kube_config_file_name apply -f 2048_full.yaml

kubectl --kubeconfig $kube_config_file_name get ingress -n game-2048 -o yaml |grep hostname |cut -d ':' -f2 |sed s/' '//g
