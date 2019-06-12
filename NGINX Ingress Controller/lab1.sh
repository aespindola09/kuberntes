#NGINX Ingress Controlle

gcloud compute zones list
gcloud config set compute/zone us-central1-a
gcloud container clusters create nginx-tutorial --num-nodes 2

#Instale Helm

#Ahora que tenemos nuestro clúster de Kubernetes en funcionamiento, instalemos Helm. 
#Helm es una herramienta que optimiza la instalación y administración de aplicaciones de Kubernetes. 
#Puede considerarlo como apt, yum o homebrew para Kubernetes. Se recomienda utilizar los charts de Helm, 
#ya que la comunidad de Kubernetes los mantiene y, por lo general, los actualiza. Helm tiene dos partes: 

#un cliente (helm) y un servidor (tiller):

#Tiller se ejecuta dentro de su clúster de Kubernetes y administra las actualizaciones (instalaciones) de sus charts de Helm.
#Helm se ejecuta en su laptop, IC/EC o, en este caso, Cloud Shell.
#Helm viene preconfigurado con una secuencia de comandos de instalación que obtiene automáticamente la versión más reciente del cliente Helm 
#y la instala de forma local. Ejecute el siguiente comando para recuperar la secuencia de comandos:
#>

curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
helm init

#Cómo instalar Tiller
#A partir de Kubernetes v1.8 +, RBAC está habilitado de forma predeterminada. Antes de instalar Tiller, 
#debe asegurarse de que tiene las opciones ServiceAccount y ClusterRoleBinding configuradas correctamente para el servicio de Tiller. 
#Esto permite que Tiller pueda instalar servicios en el espacio de nombres predeterminado.
#Ejecute los siguientes comandos para instalar el Tiller del lado del servidor en el clúster de Kubernetes con RBAC habilitado:

kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

#Implemente el NGINX Ingress Controller

helm install --name nginx-ingress stable/nginx-ingress --set rbac.create=true
kubectl get service nginx-ingress-controller

#Configure el Ingress Resource para usar un NGINX Ingress Controller

#Un objeto de un Ingress Resource es una colección de reglas L7 para enrutar el tráfico entrante a los servicios de Kubernetes. 
#Se pueden definir varias reglas en un Ingress Resource o se pueden dividir en múltiples manifiestos de un Ingress Resource. 
#El Ingress Resource también determina qué controlador utilizar para entregar el tráfico. 
#Esto se puede establecer con una anotación, kubernetes.io/ingress.class, en la sección de metadatos del Ingress Resource. 
#Para el controlador NGINX, utilizará el valor nginx como se muestra a continuación:

#annotations: kubernetes.io/ingress.class: nginx

#En Kubernetes Engine, si no se define una anotación en la sección de metadatos, 
#el Ingress Resource utiliza el balanceador de cargas GCP GCLB L7 para entregar el tráfico. 
#Este método también se puede forzar estableciendo el valor de la anotación en gce, como se muestra a continuación:

#annotations: kubernetes.io/ingress.class: gce

#Vamos a crear un archivo simple YAML de un Ingress Resource que use un NGINX Ingress Controller y tenga una regla de ruta definida. 
#Para esto, escriba los siguientes comandos:

kubectl apply -f ingress-resource.yaml
kubectl get ingress ingress-resource

#Pruebe el Ingress y el backend predeterminado
kubectl get service nginx-ingress-controller

http://external-ip-of-ingress-controller/hello

#Para verificar si el servicio default-backend funciona correctamente, acceda a cualquier ruta 
#(que no sea la ruta /hello definida en el Ingress Resource) y asegúrese de recibir un mensaje 404. Por ejemplo:

http://external-ip-of-ingress-controller/test
