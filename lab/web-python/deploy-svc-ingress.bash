kubectl create deployment web-first --image=leonardoalvesprates/web-first:v0.1 --port=8080
kubectl expose deployment web-first
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-first-ingress
spec:
  rules:
  - host: web-first.prateslabs.com.br
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-first
            port:
              number: 8080
EOF