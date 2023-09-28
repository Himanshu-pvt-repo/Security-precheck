#!/bin/bash
function show_help() {
    cat <<EOF
Usage: ${0##*/} [-h] [-t] [-e ENVIRONMENT] [-s SERVICE] [-v CHART_VERSION]
Deploys a Kubernetes Helm chart with in a given environment and namespace.
         -h                     display this help and exit
         -e ENVIRONMENT         environment for which the deployment is perfomed (e.g. dev)
         -s SERVICE             Platform service To Deploy (Jenkins,Prometheus...)
         -n NAMESPACE
         -v CHART_VERSION       Helm chart version
         -d DATADOG_API         API keys for datadog
         -c EKS_CLUSTER_NAME    Name of the EKS Cluster
         -t                     validate only the templates without performing any deployment
EOF
}

 

DRY_RUN=false
while getopts he:v:s:n:d:c:t opt; do
    case $opt in
        h)
           show_help
           exit 0
           ;;
        e)
           ENVIRONMENT=$OPTARG
           ;;
        v)
           CHART_VERSION=$OPTARG
           ;;
        s)
           SERVICE=$OPTARG
           ;;
        n)
           NAMESPACE=$OPTARG
           ;;
        d)
           DATADOG_API=$OPTARG
           ;;
        c)
           EKS_CLUSTER_NAME=$OPTARG
           ;;
        t)
           DRY_RUN=true
           ;;
        *)
           show_help >&2
           exit 1
           ;;
    esac
done

 

#check if aws cli is installed
echo "Check aws cli is installed..."
type aws > /dev/null 2>&1
if [ $? != 0 ]
then
  echo "AWS CLI is not installed...Exitting"
  exit 1
else
  echo "AWS CLI is installed..."
fi
echo "######################################################"
#check if kubectl command is installed
echo "Check kubectl is installed..."
type kubectl > /dev/null 2>&1
if [ $? != 0 ]
then
   echo "Kubectl is not installed...Exitting"
   exit 1
else
   echo "Kubectl is installed..."
fi

 

echo "#####################################################"
#check if helm is installed
echo "Check helm is installed..."
type helm > /dev/null 2>&1
if [ $? != 0 ]
then
    echo "Helm is not installed...Exitting"
    exit 1
else
    echo "Helm is installed..."
fi

 

#Check aws is connected
aws sts get-caller-identity > /dev/null
if [ $? != 0 ]
then
   echo "AWS Credentials are not set to connect with cluster accounts"
   echo -n "Please export AWS_ACCESS_KEY,SECRET_KEY,SESSION_TOKEN..."
   exit 1
else
  echo "AWS Credentials are configured..."
fi
echo "#####################################################################################"
if [[ $ENVIRONMENT == "" && $CHART_VERSION == "" && $SERVICE == "" && $NAMESPACE == "" ]]
then
   echo "Environment, Chart Version, Service, Namespace are mandatory options to proceed..."
   echo "#####################################################################################"
   show_help
   exit 1
fi

 

CHART_REPOSITORY_URL=""
CHART_NAME=""
RELEASE_NAME=""
VALUES_FILE=values/$SERVICE/$ENVIRONMENT/values.yaml

 

kubectl get namespace | grep -q "^$NAMESPACE " || kubectl create namespace $NAMESPACE
if [[ $SERVICE == "jenkins" ]]
then
   CHART_REPOSITORY_URL="https://charts.jenkins.io"
   CHART_NAME="jenkins"
   RELEASE_NAME="jenkins"
   echo "##############################################################"
   echo "INSTALL/UPGRADE JENKINS"
   echo "##############################################################"
   sed -i "s/{{namespace_val}}/$NAMESPACE/g" $VALUES_FILE
   helm plugin install plugins/secretmanager
   helm repo add stable $CHART_REPOSITORY_URL
   helm secretmanager upgrade --install $RELEASE_NAME stable/$CHART_NAME -f $VALUES_FILE  --version $CHART_VERSION -n $NAMESPACE
   # create cluster role binding
   kubectl get clusterrolebinding |grep -q jenkins || kubectl create clusterrolebinding jenkins --clusterrole=jenkins --serviceaccount=$NAMESPACE:jenkins
elif [[ $SERVICE == "infra_jenkins" ]]
then
   CHART_REPOSITORY_URL="https://charts.jenkins.io"
   CHART_NAME="jenkins"
   RELEASE_NAME="infra-jenkins"
   #NAMESPACE="infra-cicd"
   echo "##############################################################"
   echo "INSTALL/UPGRADE JENKINS FOR INFRA AUTOMATION"
   echo "##############################################################"
   sed -i "s/{{namespace_val}}/$NAMESPACE/g" $VALUES_FILE
   helm plugin install plugins/secretmanager
   helm repo add stable $CHART_REPOSITORY_URL
   helm secretmanager upgrade --install $RELEASE_NAME stable/$CHART_NAME -f $VALUES_FILE  --version $CHART_VERSION -n $NAMESPACE
elif [[ $SERVICE == "ingress-controller" ]]
then
  CHART_REPOSITORY_URL="https://kubernetes.github.io/ingress-nginx"
  CHART_NAME="ingress-nginx"
  RELEASE_NAME="ingress-controller"
  #NAMESPACE="networking"
  echo "##############################################################"
  echo "INSTALL/UPGRADE NGINX INGRESS CONTROLLER"
  echo "##############################################################"
  helm repo add ingress-nginx $CHART_REPOSITORY_URL
  helm upgrade --install $RELEASE_NAME ingress-nginx/$CHART_NAME -f $VALUES_FILE -n $NAMESPACE --version $CHART_VERSION --set defaultBackend.enabled=true
elif [[ $SERVICE == "fluent-bit" ]]
then
  RELEASE_NAME="fluent-bit"
  #NAMESPACE="monitoring"
  echo "##############################################################"
  echo "INSTALL/UPGRADE FLUENT BIT"
  echo "##############################################################"
  helm upgrade --install $RELEASE_NAME charts/fluent-bit -f $VALUES_FILE -n $NAMESPACE --version $CHART_VERSION
elif [[ $SERVICE == "cert-manager" ]]
then
  CHART_REPOSITORY_URL="https://charts.jetstack.io"
  CHART_NAME="cert-manager"
  RELEASE_NAME="cert-manager"
  #NAMESPACE="security"
  echo "##############################################################"
  echo "INSTALL/UPGRADE CERT MANAGER"
  echo "##############################################################"
  helm repo add cert-manager $CHART_REPOSITORY_URL
  helm upgrade --install $RELEASE_NAME cert-manager/$CHART_NAME -f $VALUES_FILE -n $NAMESPACE --version $CHART_VERSION
elif [[ $SERVICE == "kube2iam" ]]
then
  CHART_REPOSITORY_URL="https://charts.helm.sh/stable"
  CHART_NAME="kube2iam"
  RELEASE_NAME="kube2iam"
  #NAMESPACE="kube-system"
  echo "##############################################################"
  echo "INSTALL/UPGRADE KUBE2IAM"
  echo "##############################################################"
  helm repo add stable $CHART_REPOSITORY_URL
  helm upgrade --install $RELEASE_NAME stable/$CHART_NAME -f $VALUES_FILE -n $NAMESPACE --version $CHART_VERSION
elif [[ $SERVICE == "clair" ]]
then
  RELEASE_NAME="clair"
  #NAMESPACE="clair"
  echo "##############################################################"
  echo "INSTALL/UPGRADE CLAIR"
  echo "##############################################################"
  helm upgrade --install $RELEASE_NAME charts/clair -f $VALUES_FILE -n $NAMESPACE --version $CHART_VERSION
elif [[ $SERVICE == "spot-termination-handler" ]]
then
  CHART_REPOSITORY_URL="https://charts.helm.sh/stable"
  RELEASE_NAME="spot-termination-handler"
  CHART_NAME="k8s-spot-termination-handler"
  #NAMESPACE="orchestration"
  echo "##############################################################"
  echo "INSTALL/UPGRADE SPOT TERMINATION HANDLER"
  echo "##############################################################"
  helm repo add stable $CHART_REPOSITORY_URL
  helm upgrade --install $RELEASE_NAME stable/$CHART_NAME -n $NAMESPACE --version $CHART_VERSION
elif [[ $SERVICE == "spot-rescheduler" ]]
then
  CHART_REPOSITORY_URL="https://charts.helm.sh/stable"
  RELEASE_NAME="spot-rescheduler"
  CHART_NAME="k8s-spot-rescheduler"
  #NAMESPACE="orchestration"
  echo "##############################################################"
  echo "INSTALL/UPGRADE SPOT RESCHEDULER"
  echo "##############################################################"
  helm repo add stable $CHART_REPOSITORY_URL
  helm upgrade --install $RELEASE_NAME stable/$CHART_NAME -f $VALUES_FILE -n $NAMESPACE --version $CHART_VERSION
elif [[ $SERVICE == "cluster-autoscaler" ]]
then
  CHART_REPOSITORY_URL="https://charts.helm.sh/stable"
  RELEASE_NAME="cluster-autoscaler"
  CHART_NAME="cluster-autoscaler"
  #NAMESPACE="orchestration"
  echo "##############################################################"
  echo "INSTALL/UPGRADE CLUSTER AUTOSCALER"
  echo "##############################################################"
  helm repo add stable $CHART_REPOSITORY_URL
  helm upgrade --install $RELEASE_NAME stable/$CHART_NAME -f $VALUES_FILE -n $NAMESPACE --version $CHART_VERSION
elif [[ $SERVICE == "kube-prometheus-stack" ]]
then
  CHART_REPOSITORY_URL="https://prometheus-community.github.io/helm-charts"
  RELEASE_NAME="kube-prometheus-stack"
  CHART_NAME="kube-prometheus-stack"
  #NAMESPACE="monitoring"
  echo "##############################################################"
  echo "INSTALL/UPGRADE KUBE PROMETHEUS STACK"
  echo "##############################################################"
  helm plugin install plugins/secretmanager
  helm repo add prometheus $CHART_REPOSITORY_URL
  helm secretmanager upgrade --install $RELEASE_NAME prometheus/$CHART_NAME -f $VALUES_FILE -n $NAMESPACE --version $CHART_VERSION
elif [[ $SERVICE == "prometheus-blackbox-exporter" ]]
then
  CHART_REPOSITORY_URL="https://prometheus-community.github.io/helm-charts"
  RELEASE_NAME="prometheus-blackbox-exporter"
  CHART_NAME="prometheus-blackbox-exporter"
  #NAMESPACE="monitoring"
  echo "##############################################################"
  echo "INSTALL/UPGRADE PROMETHEUS BLACKBOX EXPORTER"
  echo "##############################################################"
  helm repo add prometheus $CHART_REPOSITORY_URL
  helm upgrade --install $RELEASE_NAME prometheus/$CHART_NAME -f $VALUES_FILE -n $NAMESPACE --version $CHART_VERSION
elif [[ $SERVICE == "prometheus-pushgateway" ]]
then
  CHART_REPOSITORY_URL="https://prometheus-community.github.io/helm-charts"
  RELEASE_NAME="prometheus-pushgateway"
  CHART_NAME="prometheus-pushgateway"
  #NAMESPACE="monitoring"
  echo "##############################################################"
  echo "INSTALL/UPGRADE PROMETHEUS PUSHGATEWAY"
  echo "##############################################################"
  helm repo add prometheus $CHART_REPOSITORY_URL
  helm upgrade --install $RELEASE_NAME prometheus/$CHART_NAME -f $VALUES_FILE -n $NAMESPACE --version $CHART_VERSION
elif [[ $SERVICE == "metrics-server" ]]
then
  CHART_REPOSITORY_URL="https://charts.helm.sh/stable"
  RELEASE_NAME="metrics-server"
  CHART_NAME="metrics-server"
  #NAMESPACE="monitoring"
  echo "##############################################################"
  echo "INSTALL/UPGRADE METRICS SERVER"
  echo "##############################################################"
  helm repo add stable $CHART_REPOSITORY_URL
  helm upgrade --install $RELEASE_NAME stable/$CHART_NAME -f $VALUES_FILE -n $NAMESPACE --version $CHART_VERSION
elif [[ $SERVICE == "prometheus-yace-exporter" ]]
then
  CHART_REPOSITORY_URL="https://mogaal.github.io/helm-charts/"
  RELEASE_NAME="prometheus-yace-exporter"
  CHART_NAME="prometheus-yace-exporter"
  #NAMESPACE="monitoring"
  echo "##############################################################"
  echo "INSTALL/UPGRADE PROMETHEUS YACE EXPORTER"
  echo "##############################################################"
  helm repo add stable $CHART_REPOSITORY_URL
  helm upgrade --install $RELEASE_NAME stable/$CHART_NAME -f $VALUES_FILE -n $NAMESPACE --version $CHART_VERSION
elif [[ $SERVICE == "velero" ]]
then
  CHART_REPOSITORY_URL="https://vmware-tanzu.github.io/helm-charts"
  RELEASE_NAME="velero"
  CHART_NAME="velero"
  #NAMESPACE="disaster-recovery"
  echo "##############################################################"
  echo "INSTALL/UPGRADE VELERO"
  echo "##############################################################"
  helm repo add stable $CHART_REPOSITORY_URL
  helm upgrade --install $RELEASE_NAME stable/$CHART_NAME -f $VALUES_FILE -n $NAMESPACE --version $CHART_VERSION
elif [[ $SERVICE == "efs-csi-driver-addon" ]]
then
  #./prehook-scripts/efs_csi_driver_addon.sh 
  account_id=$(aws sts get-caller-identity --query "Account" --output text)
  fileSystemId=$(aws efs describe-file-systems  --query 'FileSystems[?Name==`ride-platform-applications-efs`].FileSystemId' --region us-east-1 --output text)
  CHART_REPOSITORY_URL="https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  RELEASE_NAME="aws-efs-csi-driver"
  CHART_NAME="aws-efs-csi-driver"
  NAMESPACE="kube-system"
  echo "##############################################################"
  echo "INSTALL/UPGRADE EFS CSI DRIVER ADDON"
  echo "##############################################################"
  sed -i "s/{{file_system_id}}/$fileSystemId/g" values/$SERVICE/storageclass.yaml
  kubectl apply -f values/$SERVICE/storageclass.yaml
  helm repo add aws-efs-csi-driver $CHART_REPOSITORY_URL
  helm upgrade --install $RELEASE_NAME aws-efs-csi-driver/$CHART_NAME --namespace $NAMESPACE \
  --set controller.serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::$account_id:role/EFSCSIDriverIAMRole" \
  --set node.serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::$account_id:role/EFSCSIDriverIAMRole" \
  --set controller.tags.environment="$ENVIRONMENT"

 

elif [[ $SERVICE == "datadog-agent" ]]
then
  aws eks update-kubeconfig --name $EKS_CLUSTER_NAME
  CHART_REPOSITORY_URL="https://helm.datadoghq.com"
  RELEASE_NAME="datadog"
  CHART_NAME="datadog/datadog"
  echo "##############################################################"
  echo "INSTALL/UPGRADE Datadog"
  echo "##############################################################"
  kubectl get namespace | grep -q "^$NAMESPACE " || kubectl create namespace $NAMESPACE
  helm repo add datadog $CHART_REPOSITORY_URL
  helm repo update 
  helm upgrade --install $RELEASE_NAME $CHART_NAME -f $VALUES_FILE -n $NAMESPACE --set datadog.apiKey=$DATADOG_API
fi
