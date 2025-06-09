# Kubernetes_intro
A simple Kubernetes intro. with pod creation 

Commands used:

dnf install docker -y

sudo systemctl  start docker

sudo systemctl  status docker

sudo docker buildx build -t my-nginx -f Dockerfile2 .

sudo docker run -d -p 8080:80 my-nginx 

docker ps 
// docker container should be running 

# Refer github repo to setup minikube

git clone https://github.com/SaravanaStorageNetwork/Kubernetes_intro

chmod +x setup_minikube.sh 

sh setup_minikube.sh 

minikube status

kubectl get pods -A

kubectl  get pods 

kubectl apply -f   01-pod.yaml 

kubectl get pods 

// You should be able to see the pod
