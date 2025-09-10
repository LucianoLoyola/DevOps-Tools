function aws_profile() {
    # Verificar si no se proporcionó ningún argumento
    if [[ -z "$1" ]]; then
        echo "Uso: aws_profile <nombre_de_perfil> o aws_profile off"
        # Mostrar el perfil actual, con un mensaje claro si no hay uno explícito
        echo "Perfil actual: ${AWS_PROFILE:-'default (ninguno explícito)'}"
    # Verificar si el argumento es "off"
    elif [[ "$1" == "off" ]]; then
        unset AWS_PROFILE
        echo "Perfil AWS desactivado. Se usará el perfil 'default'."
    # Si se proporcionó un nombre de perfil
    else
        export AWS_PROFILE="$1"
        echo "Perfil AWS establecido en: $AWS_PROFILE"
    fi
}
