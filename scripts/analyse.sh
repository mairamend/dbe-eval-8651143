#!/bin/bash
set -euo pipefail

usage() {
    echo "Usage : bash scripts/analyse.sh <fichier.log> [--top N]" >&2
    exit 1
}

if [[ $# -lt 1 || $# -gt 3 ]]; then
    usage
fi

FICHIER="$1"
TOP=3

if [[ $# -eq 3 ]]; then
    [[ "$2" == "--top" && "$3" =~ ^[0-9]+$ ]] || usage
    TOP="$3"
fi

if [[ ! -f "$FICHIER" ]]; then
    echo "Erreur : fichier introuvable" >&2
    exit 2
fi

if [[ ! -s "$FICHIER" ]]; then
    echo "Erreur : fichier vide" >&2
    exit 3
fi

if [[ -z "${MATRICULE:-}" ]]; then
    echo "Erreur : MATRICULE non défini" >&2
    exit 4
fi
compter_statuts() {
    echo "=== Codes HTTP ==="
    for code in 2 3 4 5; do
        nombre=$(awk -v c="$code" '$9 ~ "^" c {n++} END {print n+0}' "$FICHIER")
        echo "${code}xx : $nombre"
    done
}

top_endpoints() {
    echo "=== Top $TOP endpoints ==="
    awk -F'"' '{print $2}' "$FICHIER" |
        awk '{print $2}' |
        cut -d'?' -f1 |
        sort | uniq -c | sort -nr | head -n "$TOP"
}

ip_suspecte() {
    echo "=== IP avec le plus de réponses 401 sur /api/auth/login ==="
    awk '$9 == 401 && $7 == "/api/auth/login" {print $1}' "$FICHIER" |
        sort | uniq -c | sort -nr | head -1
}

moyenne_temps() {
    echo "=== Durée moyenne des réponses 200 ==="
    awk '$9 == 200 {d=$11; sub(/ms/, "", d); somme+=d; n++}
    END {if(n>0) printf "%.1f ms\n", somme/n; else print "Aucune requête 200"}' "$FICHIER"
}
DATE=$(date +%Y%m%d_%H%M)
RAPPORT="rapports/rapport_${MATRICULE}_${DATE}.txt"

{
    echo "RAPPORT D'ANALYSE DES LOGS"
    echo "Date : $(date)"
    echo "Utilisateur / Machine : $(whoami)@$(hostname)"
    echo "Matricule : $MATRICULE"
    echo "SHA256 : $(sha256sum "$FICHIER" | awk '{print $1}')"
    echo

    compter_statuts
    echo
    top_endpoints
    echo
    ip_suspecte
    echo
    moyenne_temps

} > "$RAPPORT"

echo "Rapport créé : $RAPPORT"
