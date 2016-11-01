### Steps to create secrets for CaaS
1. Update(if required) the name of secret in secret.yaml file.(Currently it is set to `caas-secret`)           
2. Update the password field and values with secrets you received from CaaS team                 
3. Run the following command on one of the hosts in our estate (to deploy in DFW)        
   `kubectl create --namespace=team-cache-as-a-service-caas-dfw-sp1-sam-caas -f caas-secret.yaml` 
