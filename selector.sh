#!/bin/bash

clear
counter=1
authn_counter=0

PS3="[$counter][$authn_counter] Enter task: "

select opt in ccp cp az ec2 ec2-long terraform lambda secretless-ssh secretless-psql k8s-deploy k9s tf-cem-plan tf-cem-apply tf-cem-destroy line_count quit; do
  case $opt in
    line_count)
      clear
      echo "wc -l "
      /home/ec2-user/line_count.sh
      read -p "> " foo
      clear
      ;; 
    ccp)
      clear
      echo "retrieving credential directly from epv via central agent (ccp)"
      echo "curl -sk \"https://pvwa.conjur.dev/AIMWebService/api/Accounts?AppID=DEV_CCP_APP_ID&Safe=dev_MYSQL&ObjectName=admin\""
      /home/ec2-user/cccp/ccp/curl-direct-vault.sh
      read -p "> " foo
      clear
      ((counter += 1))
      ((authn_counter +=2))
      PS3="[$counter][$authn_counter] Enter task: "
      ;;
    cp)
      clear
      echo "retrieving credential directly from epv via agent (cp)"
      /home/ec2-user/cccp/cp/00-cp-fetch-MYSQL-PW-simple.sh
      read -p "> " foo
      clear
      ((counter += 1))
      ((authn_counter +=4))
      PS3="[$counter][$authn_counter] Enter task: "
      ;;
    tf-cem-destroy)
      pushd ~/terraform-niwot
      clear
      echo "terraform destroy using AWS credentials..."
      ./destroy-it
      read -p "> " foo
      popd
      clear
      ((counter += 2))
      ((authn_counter +=1))
      PS3="[$counter][$authn_counter] Enter task: "
      ;;
    tf-cem-apply)
      pushd ~/terraform-niwot
      clear
      echo "terraform apply using AWS credentials..."
      ./apply-it
      read -p "> " foo
      popd
      clear
      ((counter += 2))
      ((authn_counter +=1))
      PS3="[$counter][$authn_counter] Enter task: "
      ;;
    tf-cem-plan)
      pushd ~/terraform-niwot
      clear
      echo "terraform plan using AWS credentials..."
      ./plan-it
      read -p "> " foo
      popd
      clear
      ((counter += 2))
      ((authn_counter +=1))
      PS3="[$counter][$authn_counter] Enter task: "
      ;;
    terraform)
      pushd ~/terraform
      clear
      echo "terraform plan using AWS credentials..."
      ./plan-it
      read -p "> " foo
      popd
      clear
      ((counter += 2))
      ((authn_counter +=1))
      PS3="[$counter][$authn_counter] Enter task: "
      ;;
    ec2)
      pushd ~/AWS-IAM-py
      clear
      echo "using IAM role-backed ec2 identity to retrieve credential vaulted in DAP..."
      /home/ec2-user/AWS-IAM-py/direct-demo.sh
      read -p "> " foo
      popd
      clear
      ((counter +=4))
      ((authn_counter +=1))
      PS3="[$counter][$authn_counter] Enter task: "
      ;;
    az)
      pushd ~/AZ
      clear
      echo "using IAM role-backed ec2 identity to retrieve private ssh key vaulted in DAP..."
      /home/ec2-user/AZ/summon-ssh-az.sh
      read -p "> " foo
      popd
      clear
      ((counter +=3))
      ((authn_counter +=2))
      PS3="[$counter][$authn_counter] Enter task: "
      ;;
    ec2-long)
      pushd ~/AWS-IAM-py
      clear
      echo "using IAM role-backed ec2 identity to retrieve credential vaulted in DAP..."
      /home/ec2-user/AWS-IAM-py/get-token.sh
      /home/ec2-user/AWS-IAM-py/direct-demo.sh
      read -p "> " foo
      popd
      clear
      ((counter +=4))
      ((authn_counter +=1))
      PS3="[$counter][$authn_counter] Enter task: "
      ;;
    lambda)
      clear
      echo "aws lambda invoke --function-name ussewest-dap-ac /tmp/lambda-out.json && cat /tmp/lambda-out.json"
      ~/AWS-IAM-py/lambda-demo.sh
      read -p "> " foo
      clear
      ((counter +=4))
      ((authn_counter +=1))
      PS3="[$counter][$authn_counter] Enter task: "
      ;;
    secretless-ssh)
      clear
      echo "ssh -p 2221 user@localhost"
      ~/secretless/ssh-sad.sh
      read -p "> " foo
      echo "ssh -p 2222 user@localhost"
      ~/secretless/ssh-happy.sh
      read -p "> " foo
      clear
      ((counter +=1))
      ((authn_counter +=1))
      PS3="[$counter][$authn_counter] Enter task: "
      ;;
    secretless-psql)
      clear
      echo "psql \"host=localhost port=5432 user=secretless dbname=quickstart sslmode=disable\" -c 'select * from counties;'"
      ~/secretless/psql-sad.sh
      read -p "> " foo
      echo "psql \"host=localhost port=5454 user=secretless dbname=quickstart sslmode=disable\" -c 'select * from counties;'"
      ~/secretless/psql-happy.sh
      read -p "> " foo
      ((counter +=2))
      ((authn_counter +=1))
      PS3="[$counter][$authn_counter] Enter task: "
      clear
      ;;
    k8s-deploy)
      clear
      echo "kubectl apply -f ./testapps-app-sidecar-manifest.yaml --namespace testapps"
      pushd /home/ec2-user/dap-oc-k8s-install/manifests
      kubectl apply -f ./testapps-app-sidecar-manifest.yaml --namespace testapps
      popd
      read -p "> " foo
      clear
      ((counter +=4))
      PS3="[$counter][$authn_counter] Enter task: "
      ;;
    k9s) 
      clear
      kubectx arn:aws:eks:us-west-2:475601244925:cluster/ussewest-devolution
      kubens testapps
      clear
      k9s
      ((counter +=4))
      ((authn_counter +=1))
      PS3="[$counter][$authn_counter] Enter task: "
      ;;
    quit)
      clear
      echo "Total credentials managed by Cyberark: $counter."
      echo "Total authN methods used: $authn_counter."
      break;;
    *)
      clear
      echo "Invalid option $REPLY";;
  esac
done
