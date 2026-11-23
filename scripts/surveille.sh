#!/bin/bash

FICHIER="logs/access.log"
JOURNAL="logs/surveillance.log"

arret() {
    echo "$(date) - Arrêt propre de la surveillance" >> "$JOURNAL"
    exit 0
}

trap arret SIGTERM

while true; do
    HEURE=$(date '+%Y-%m-%d %H:%M:%S')
    LIGNES=$(wc -l < "$FICHIER")
    echo "$HEURE - Nombre de lignes : $LIGNES" >> "$JOURNAL"
    sleep 5
done
