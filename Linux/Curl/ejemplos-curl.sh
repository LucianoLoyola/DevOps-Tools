#!/bin/bash
# Ejemplos de uso de curl

# ===========================================================
# GET con headers de respuesta (-I muestra solo headers)
# ===========================================================
curl -X GET -I https://<your-domain>/health

# GET con headers de respuesta y cuerpo (-i incluye headers + cuerpo)
curl -X GET -i https://<your-domain>/health

# GET simple (solo cuerpo de respuesta)
curl https://<your-domain>/health

# GET con salida formateada (requiere jq instalado)
curl -s https://<your-domain>/health | jq .

# GET con header de autorización (Bearer token)
curl -X GET -I \
  -H "Authorization: Bearer <tu-token>" \
  https://<your-domain>/health

# ===========================================================
# POST con JSON body
# ===========================================================
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}' \
  https://<your-domain>/health

# ===========================================================
# PUT con JSON body
# ===========================================================
curl -X PUT \
  -H "Content-Type: application/json" \
  -d '{"key": "updated-value"}' \
  https://<your-domain>/health

# ===========================================================
# DELETE
# ===========================================================
curl -X DELETE https://<your-domain>/health

# ===========================================================
# Flags útiles
# ===========================================================
# -v              verbose: muestra request y response completos
# -s              silent: sin barra de progreso
# -o archivo.json guarda la respuesta en un archivo
# -w "%{http_code}" imprime solo el código HTTP al final
# --max-time 10   timeout de 10 segundos
# -k              ignora errores de certificado SSL (no usar en prod)

# Ejemplo combinado: verbose + silent + código HTTP
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" \
  -X GET https://<your-domain>/health
