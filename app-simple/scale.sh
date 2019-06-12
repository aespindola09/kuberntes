#
#kill all running containers with 
docker kill $(docker ps -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)

gcloud config list project
export GCP_PROJECT=`gcloud config list core/project --format='value(core.project)'`
gsutil cp gs://${GCP_PROJECT}/* .

docker build -t gcr.io/${GCP_PROJECT}/echo-app:v2 .
docker build -t gcr.io/${GCP_PROJECT}/echo-app:v1 .  (have . end commandline)

docker run -d -p 8080:8000 gcr.io/${GCP_PROJECT}/echo-app:v2
docker run -d -p 8080:8000 gcr.io/${GCP_PROJECT}/echo-app:v1

PATH=/usr/lib/google-cloud-sdk/bin:$PATH
gcloud auth configure-docker -q
docker push gcr.io/${GCP_PROJECT}/echo-app:v1
docker push gcr.io/${GCP_PROJECT}/echo-app:v2

kubectl run  echo-web \
    --image=gcr.io/qwiklabs-gcp-b82d9ee54f8ecdae/echo-app:v2 \
    --port=8000

kubectl scale deployment echo-web --replicas=2




mysql> GRANT ALL PRIVILEGES ON wordpress.* TO 'admin'@'%' IDENTIFIED BY 'PASSWORD';