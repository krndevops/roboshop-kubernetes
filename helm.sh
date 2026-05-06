aws eks update-kubeconfig --name dev-eks
if [ "$1" == "install" ]; then
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo add elastic https://helm.elastic.co
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update

  helm upgrade -i ngx-ingres ingress-nginx/ingress-nginx
  kubectl apply -f external-dns.yml
  helm upgrade -i filebeat elastic/filebeat -f filebeat.yml
  helm upgrade -i prometheus prometheus-community/kube-prometheus-stack -f prometheus.yml
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  kubectl create namespace argocd
  kubectl apply -n argocd -f argocd.yml
fi

if [ "$1" == "uninstall" ]; then
  helm uninstall ngx-ingres
  kubectl delete -f external-dns.yml
  helm uninstall filebeat
  helm uninstall prometheus
  kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  kubectl delete namespace argocd
fi

#ArgoCD Password

# kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

#argocd login argocd.kdevops.online --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo) --insecure