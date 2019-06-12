#image: "gcr.io/${GCP_PROJECT}/echo-app:1.0" .
#Cluster: echo-cluster
#deployment: echo-web
###################
gcloud config list project
export GCP_PROJECT=`gcloud config list core/project --format='value(core.project)'`
gsutil cp gs://${GCP_PROJECT}/* .
tar xvzf echo-web.tar.gz
mkdir docker
cp Dockerfile docker/
cp main.go docker/
cd docker/
docker build -t "gcr.io/${GCP_PROJECT}/echo-app:1.0" .
docker run -d -p 8080:8000 gcr.io/${GCP_PROJECT}/echo-app:1.0

#Habilite el acceso público a la imagen
#Google Container Registry almacena sus imágenes en Google Cloud Storage.

#Paso 1
#Configure Docker para que use gcloud como auxiliar de credenciales de Container Registry (solo se requiere que lo haga una vez).
PATH=/usr/lib/google-cloud-sdk/bin:$PATH
gcloud auth configure-docker -q
docker push gcr.io/${GCP_PROJECT}/echo-app:1.0
#####################
#Verificar 
gcloud container images list
gcloud container images list-tags gcr.io/${GCP_PROJECT}/echo-app
#################################################################################
#REVISAR ZONA
gcloud container clusters create echo-web --machine-type=n1-standard-2 --num-nodes=2 --zone=us-central1-a
#####################################
#Crea un secreto basado en las credenciales existentes de Docker

kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=/home/google3680215_student/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson


# kubectl create secret docker-registry regsecret --docker-server=gcr.io --docker-username=aespindola09 --docker-password=<your-pword> --docker-email=<your-email>

kubectl run echo-web \
    --image=gcr.io/qwiklabs-gcp-a71ee111d9b5991d/echo-app:1.0 \
    --port=8000

kubectl expose deployment echo-web --type="LoadBalancer" --port=80 --target-port=8000

############################ 
MODIFICAR ARCHIVOS YAML CON PROJECTO

#DEPLOYMENT
cd ~/manifests
kubectl apply -f echoweb-deployment.yaml
kubectl get deployment 
kubectl describe deployment echoweb


kubectl get pods
kubectl describe pods <POD>

#INGRESS/SERVICE  se crea ingress echoweb y service echoweb-backend

kubectl apply -f echoweb-ingress-static-ip.yaml
kubectl get ingress
kubectl get svc

kubectl describe ingress echoweb
kubectl describe svc echoweb-backend

Configurar IP INGRESS COMO STATICA ##### INGRESAR EN ARCHIVO IP del comando kubectl get ingress

nano echoweb-service-static-ip.yaml

kubectl apply -f echoweb-service-static-ip.yaml

kubectl describe svc echoweb

kubectl get all
