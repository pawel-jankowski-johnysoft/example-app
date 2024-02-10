k3d cluster create --api-port 6550 -p "8081:80@loadbalancer" --agents 2
sleep 10
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/23.0.6/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/23.0.6/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml

kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/23.0.6/kubernetes/kubernetes.yml
# AFTER GENERATE CERTIFICATE, REMEMBER TO IMPORT CERT INTO YOUR OS
openssl req -subj '/CN=keycloak.johnysoft.com/O=Keycloak Johnysoft./C=US' -addext 'subjectAltName = DNS:keycloak.johnysoft.com,DNS:www.keycloak.johnysoft.com' -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem
sleep 10
kubectl create secret tls example-tls-secret --cert certificate.pem --key key.pem

kubectl create secret generic keycloak-db-secret \
  --from-literal=username=postgres \
  --from-literal=password=testpassword

sleep 150
kubectl apply -f keycloak.yml

sleep 30
kubectl get secret example-kc-initial-admin -o jsonpath='{.data.username}' | base64 --decode
kubectl get secret example-kc-initial-admin -o jsonpath='{.data.password}' | base64 --decode
