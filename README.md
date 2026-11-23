# Analyseur de logs API

## Description
Projet Linux et Git/GitHub permettant de générer et d'analyser
des journaux d'accès d'une API backend.
Le script analyse les codes HTTP, les endpoints, les IP suspectes,
les temps de réponse et le nombre de requêtes par heure.

## Utilisation

Générer un journal :
java -cp out GenerateurLogs 8651143 2000 > logs/access.log

Lancer l'analyse :
MATRICULE=8651143 bash scripts/analyse.sh logs/access.log

Afficher les 5 endpoints les plus utilisés :
MATRICULE=8651143 bash scripts/analyse.sh logs/access.log --top 5

Le rapport est enregistré dans le dossier rapports/.

## Auteur
Mairame Thierno Ndiath
Matricule : 8651143
