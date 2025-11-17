#!/bin/bash

# Configurações
DB_USER="gabriel"
DB_NAME="biblioteca_universitaria"  # Ajuste se necessário
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="importacao_${TIMESTAMP}.log"

# Cores para output (opcional)
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para log
log_message() {
    echo -e "${2}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
}

# Início do script
log_message "=== Iniciando importação dos scripts SQL ===" "$GREEN"
log_message "Banco de dados: $DB_NAME" "$YELLOW"
echo ""

# Array com os arquivos a serem importados (do 02 ao 07)
files=(
    "02_biblioteca_dml.sql"
    "03_biblioteca_procedures.sql"
    "04_biblioteca_triggers.sql"
    "05_biblioteca_views.sql"
    "06_biblioteca_queries.sql"
    "07_biblioteca_testes.sql"
)

# Loop pelos arquivos
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        log_message "Processando: $file" "$YELLOW"
        echo "----------------------------------------" >> "$LOG_FILE"

        # Executa o arquivo e captura toda a saída
        mysql -u "$DB_USER" -p "$DB_NAME" -vvv < "$file" >> "$LOG_FILE" 2>&1

        # Verifica o código de saída
        if [ $? -eq 0 ]; then
            log_message "✓ $file importado com sucesso" "$GREEN"
        else
            log_message "✗ Erro ao importar $file" "$RED"
            log_message "Verifique o log: $LOG_FILE" "$RED"
            exit 1
        fi

        echo "" >> "$LOG_FILE"
    else
        log_message "✗ Arquivo não encontrado: $file" "$RED"
        exit 1
    fi
done

log_message "=== Importação concluída ===" "$GREEN"
log_message "Log completo salvo em: $LOG_FILE" "$YELLOW"

# Exibe estatísticas do banco
log_message "Estatísticas do banco:" "$YELLOW"
mysql -u "$DB_USER" -p "$DB_NAME" -e "
    SELECT 'Tabelas criadas' as Tipo, COUNT(*) as Total
    FROM information_schema.tables
    WHERE table_schema = '$DB_NAME' AND table_type = 'BASE TABLE'
    UNION ALL
    SELECT 'Views criadas', COUNT(*)
    FROM information_schema.views
    WHERE table_schema = '$DB_NAME'
    UNION ALL
    SELECT 'Procedures criadas', COUNT(*)
    FROM information_schema.routines
    WHERE routine_schema = '$DB_NAME' AND routine_type = 'PROCEDURE'
    UNION ALL
    SELECT 'Triggers criados', COUNT(*)
    FROM information_schema.triggers
    WHERE trigger_schema = '$DB_NAME';
" | tee -a "$LOG_FILE"
