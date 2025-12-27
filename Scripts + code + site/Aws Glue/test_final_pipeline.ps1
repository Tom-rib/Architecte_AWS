# 1. Vérifier le vrai nom de la table
Write-Host "Toutes les tables du Catalog:"
aws glue get-tables --database-name default --region eu-west-3 | ConvertFrom-Json | Select-Object -ExpandProperty TableList | Select-Object Name

# 2. Vérifier si le Job existe
Write-Host ""
Write-Host "Tous les Jobs:"
aws glue get-jobs --region eu-west-3 | ConvertFrom-Json | Select-Object -ExpandProperty Jobs | Select-Object Name

# 3. Vérifier si le Trigger existe
Write-Host ""
Write-Host "Tous les Triggers:"
aws glue get-triggers --region eu-west-3 | ConvertFrom-Json | Select-Object -ExpandProperty Triggers | Select-Object Name, Type

# 4. Lancer manuellement le Job pour tester
Write-Host ""
Write-Host "Lancer Job manuelement..."
aws glue start-job-run --job-name customers-transform --region eu-west-3