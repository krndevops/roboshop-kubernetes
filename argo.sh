argocd login argocd.kdevops.online --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo) --insecure 
for i in cart catalogue user payment shipping frontend ; do
argocd app create $i --repo https://github.com/krndevops/$i --path k8s --dest-namespace default --dest-server https://kubernetes.default.svc --directory-recurse --sync-policy none
done
