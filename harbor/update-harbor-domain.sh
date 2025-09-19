#!/bin/bash

# 1. Obtener la IP del LoadBalancer
HARBOR_IP=$(kubectl get svc -n harbor harbor -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ -z "$HARBOR_IP" ]; then
  echo "Error: no se ha detectado la IP del LoadBalancer"
  exit 1
fi

# 2. Exportar la variable para que esté disponible fuera del script
export HARBOR_IP

# 3. Actualizar Harbor con helm upgrade (externalURL + TLS commonName)
helm upgrade my-harbor harbor/harbor -n harbor -f values.yaml \
  --set externalURL=https://$HARBOR_IP \
  --set expose.tls.auto.commonName=$HARBOR_IP

# 4. Esperar a que los pods estén listos
echo "Esperando a que los pods de Harbor estén listos..."
kubectl wait --for=condition=Ready pods -l app.kubernetes.io/component=core -n harbor --timeout=300s
kubectl wait --for=condition=Ready pods -l app.kubernetes.io/component=database -n harbor --timeout=300s

# 5. Extraer la cadena completa de certificados TLS de Harbor
echo "Extrayendo la cadena completa de certificados TLS de Harbor..."
echo | openssl s_client -showcerts -servername $HARBOR_IP -connect $HARBOR_IP:443 2>/dev/null \
  | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > harbor-ca.crt

# 6. Instalar certificado en el sistema
echo "Instalando certificado en el sistema..."
sudo mkdir -p /usr/local/share/ca-certificates/harbor
sudo cp harbor-ca.crt /usr/local/share/ca-certificates/harbor/
sudo update-ca-certificates

# 7. Login en Helm registry usando certificado local
export SSL_CERT_FILE=$(pwd)/harbor-ca.crt
echo "Harbor12345" | helm registry login $HARBOR_IP --username admin --password-stdin

# 8. Eliminar certificado temporal
rm -f harbor-ca.crt

# 9. Mensaje final
echo "Actualización completada. Ahora puedes usar https://$HARBOR_IP"

