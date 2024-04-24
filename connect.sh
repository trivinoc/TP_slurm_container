#!/bin/bash

# Initialisation des variables par defaut
user=""

# Fonction d'affichage de l'aide
display_help() {
    echo "Usage: $0 -n <nom_de_l_image> [-u <utilisateur>]"
    echo "Options:"
    echo "  -n, --name           Nom de l'image podman (obligatoire)"
    echo "  -u, --user           Nom de l'utilisateur (facultatf)"
    exit 1
}

# Analyse des options en ligne de commande
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -n|--name)
            name="$2"
            shift
            shift
            ;;
        -u|--user)
            user="$2"
            shift
            shift
            ;;
        *)
            # Option inconnue
            display_help
            ;;
    esac
done

# Verification des options obligatoires
if [[ -z $name ]]; then
    echo "Le nom de l'image MariaDB est obligatoire."
    display_help
fi

# Execution de la commande
if [ -z $user ]; then
  podman-compose exec "$name" bash
else
  podman-compose exec --user "$user" "$name" bash
fi


