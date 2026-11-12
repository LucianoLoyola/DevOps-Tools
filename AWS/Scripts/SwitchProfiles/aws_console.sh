function aws_console() {
    # Uso:
    #   aws_console                         -> abre la consola con el rol/perfil activo (AWS_PROFILE, ver aws-profile)
    #   aws_console <role-arn> [session]    -> asume el rol indicado y abre la consola
    local creds
    if [[ -z "$1" ]]; then
        # Credenciales del perfil activo (ya resueltas por el CLI si el perfil usa role_arn/SSO)
        creds=$(aws configure export-credentials --format process 2>&1) || {
            echo "Error al obtener credenciales del perfil '${AWS_PROFILE:-default}': $creds"
            return 1
        }
    else
        creds=$(aws sts assume-role \
            --role-arn "$1" \
            --role-session-name "${2:-console-session}" \
            --query 'Credentials' \
            --output json 2>&1) || {
            echo "Error al asumir el rol: $creds"
            return 1
        }
    fi

    local region arn
    region=$(aws configure get region 2>/dev/null)
    arn=${1:-$(aws sts get-caller-identity --query Arn --output text 2>/dev/null)}

    # Las credenciales viajan por stdin, nunca como argumento ni interpolación en el script
    local console_url
    # ACCOUNT habilita multi-sesión: cada cuenta abre en su propia sesión de consola
    console_url=$(REGION="${region:-us-east-1}" ACCOUNT="$(cut -d: -f5 <<< "$arn")" python3 -c '
import json, os, sys, urllib.parse, urllib.request
c = json.load(sys.stdin)
if not c.get("SessionToken"):
    sys.exit("El perfil usa credenciales de largo plazo (IAM user); la federación requiere un rol asumido o SSO.")
session = json.dumps({"sessionId": c["AccessKeyId"], "sessionKey": c["SecretAccessKey"], "sessionToken": c["SessionToken"]})
fed = "https://signin.aws.amazon.com/federation"
token = json.load(urllib.request.urlopen(fed + "?Action=getSigninToken&Session=" + urllib.parse.quote(session)))["SigninToken"]
dest = "https://console.aws.amazon.com/?region=" + os.environ["REGION"]
if os.environ["ACCOUNT"]:
    dest += "&account=" + os.environ["ACCOUNT"]
print(fed + "?Action=login&Issuer=&Destination=" + urllib.parse.quote(dest, safe="") + "&SigninToken=" + token)
' <<< "$creds") || return 1

    echo "Abriendo consola para: $arn"
    xdg-open "$console_url" >/dev/null 2>&1 || open "$console_url" 2>/dev/null || echo "$console_url"
}
