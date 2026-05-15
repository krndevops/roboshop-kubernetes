curl -L https://istio.io/downloadIstio | sh -
cd istio-1.29.2
bin/istioctl install --set profile=demo -y
kubectl apply -f samples/addons/*
bash helm-dev.sh install
kubectl kiali.yml


cat <<EOF > ./istio.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  meshConfig:
    meshMTLS:
      minProtocolVersion: TLSV1_3
EOF

istio-1.29.2/bin/istioctl install -f ./istio.yaml -y

kubectl label namespace default istio-injection=enabled --overwrite

# Policy to require mTLS traffic for all workloads under namespace foo:

apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: default
  namespace: foo
spec:
  mtls:
    mode: STRICT

# Add a DENY policy with HTTP-only fields using the following command:

# tcp-deny.yml
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: tcp-policy
  namespace: foo
spec:
  selector:
    matchLabels:
      app: tcp-echo
  action: DENY
  rules:
   - to:
     - operation:
         ports: ["0", "65535"]

kubectl apply -f samples/httpbin/httpbin.yaml -n foo