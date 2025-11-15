# 📚 INSTRUÇÕES PARA GERAÇÃO DO SGBU

## 🎯 O QUE SÃO ESTES ARQUIVOS?

Estes são **7 prompts autocontidos** que você pode usar para gerar cada parte do projeto SGBU com uma IA (Claude, ChatGPT, ou outra).

Cada arquivo markdown contém:
- ✅ Contexto completo do projeto
- ✅ Especificações técnicas detalhadas
- ✅ Requisitos de cada componente
- ✅ Exemplos de código
- ✅ Checklist de validação

---

## 📋 ORDEM DE EXECUÇÃO

Execute nesta ordem:

1. **INSTRUCAO_01_DDL.md** → Gera `01_create_database.sql`
2. **INSTRUCAO_02_DML.md** → Gera `02_insert_data.sql`
3. **INSTRUCAO_03_PROCEDURES.md** → Gera `03_stored_procedures.sql`
4. **INSTRUCAO_04_TRIGGERS.md** → Gera `04_triggers.sql`
5. **INSTRUCAO_05_VIEWS.md** → Gera `05_views.sql`
6. **INSTRUCAO_06_QUERIES.md** → Gera `06_queries.sql`
7. **INSTRUCAO_07_TESTES.md** → Gera `07_tests_optimization.sql`

---

## 🚀 COMO USAR

### Método 1: Com Claude (ou outra IA)

1. Abra o arquivo `INSTRUCAO_01_DDL.md`
2. Copie TODO o conteúdo
3. Cole em uma nova conversa com a IA
4. A IA irá gerar o arquivo SQL completo
5. Salve o resultado como `01_create_database.sql`
6. Repita para os outros 6 arquivos

### Método 2: Usando Claude Code (CLI)

Se você tem o `claude-code` instalado:

```bash
# Gerar DDL
cat INSTRUCAO_01_DDL.md | claude-code > 01_create_database.sql

# Gerar DML
cat INSTRUCAO_02_DML.md | claude-code > 02_insert_data.sql

# E assim por diante...
```

### Método 3: Automação Completa (Script Bash)

```bash
#!/bin/bash
# Script: gerar_sgbu.sh

for i in {01..07}; do
    case $i in
        01) tipo="DDL" ;;
        02) tipo="DML" ;;
        03) tipo="PROCEDURES" ;;
        04) tipo="TRIGGERS" ;;
        05) tipo="VIEWS" ;;
        06) tipo="QUERIES" ;;
        07) tipo="TESTES" ;;
    esac
    
    echo "Gerando $i - $tipo..."
    cat INSTRUCAO_${i}_${tipo}.md | claude-code > ${i}_arquivo_gerado.sql
    echo "✅ Gerado: ${i}_arquivo_gerado.sql"
done
```

---

## 📦 ESTRUTURA FINAL DO PROJETO

Após gerar todos os arquivos:

```
SGBU_Projeto_Final/
├── 01_create_database.sql      # DDL - Estrutura do banco
├── 02_insert_data.sql           # DML - Dados iniciais
├── 03_stored_procedures.sql    # Procedures de negócio
├── 04_triggers.sql              # Triggers automáticos
├── 05_views.sql                 # Views para relatórios
├── 06_queries.sql               # 10 consultas obrigatórias
└── 07_tests_optimization.sql   # Testes e índices
```

---

## ✅ VALIDAÇÃO

Após gerar cada arquivo, execute-o no MySQL/MariaDB nesta ordem:

```sql
-- 1. Criar banco e tabelas
SOURCE 01_create_database.sql;

-- 2. Popular com dados
SOURCE 02_insert_data.sql;

-- 3. Criar procedures
SOURCE 03_stored_procedures.sql;

-- 4. Criar triggers
SOURCE 04_triggers.sql;

-- 5. Criar views
SOURCE 05_views.sql;

-- 6. Testar queries (não modifica BD)
SOURCE 06_queries.sql;

-- 7. Executar testes e otimizações
SOURCE 07_tests_optimization.sql;
```

---

## 🎓 PARA DOCUMENTAÇÃO DO RELATÓRIO

Use os arquivos gerados como base para o relatório técnico:

### Seção 1: Modelagem (usar INSTRUCAO_01)
- Diagrama ER (mencionar tabelas criadas)
- Justificativa de normalização (já documentada no script)

### Seção 2: Implementação (usar INSTRUCAO_03, 04, 05)
- Procedures: copiar código + explicações
- Triggers: copiar código + casos de uso
- Views: copiar código + propósito

### Seção 3: Consultas (usar INSTRUCAO_06)
- Copiar as 10 queries + explicações

### Seção 4: Testes e Otimização (usar INSTRUCAO_07)
- Cenários de concorrência testados
- Análise de EXPLAIN
- Índices criados + justificativas
- Comparativos antes/depois

---

## ⏱️ TEMPO ESTIMADO

| Etapa | Geração IA | Sua Validação | Total |
|-------|-----------|---------------|-------|
| 01-DDL | 2 min | 10 min | 12 min |
| 02-DML | 3 min | 10 min | 13 min |
| 03-PROC | 3 min | 15 min | 18 min |
| 04-TRIG | 2 min | 10 min | 12 min |
| 05-VIEWS | 2 min | 10 min | 12 min |
| 06-QUERY | 2 min | 15 min | 17 min |
| 07-TEST | 3 min | 20 min | 23 min |
| **TOTAL** | **17 min** | **90 min** | **~2h** |

---

## 🆘 TROUBLESHOOTING

### Se um script der erro:
1. Leia a mensagem de erro do MySQL
2. Verifique se executou os scripts anteriores (dependências)
3. Cole o erro + trecho do código para a IA corrigir
4. A IA pode regenerar apenas a parte problemática

### Se precisar ajustar algo:
Você pode editar os arquivos markdown antes de gerar:
- Adicionar campos em tabelas
- Mudar nomes de procedures
- Ajustar regras de negócio
- Modificar queries

---

## 💡 DICAS IMPORTANTES

1. **Valide cada etapa antes de avançar**
   - Execute o script gerado
   - Verifique se não há erros
   - Só então passe para o próximo

2. **Mantenha os arquivos de instrução**
   - Você pode precisar regenerar algo
   - Útil para futuras modificações
   - Serve de documentação do projeto

3. **Documente seus testes**
   - Capture screenshots de resultados
   - Anote tempos de execução
   - Grave observações sobre concorrência

4. **Backup do banco**
   ```sql
   mysqldump -u usuario -p biblioteca_universitaria > backup.sql
   ```

---

## 🎯 PRÓXIMOS PASSOS

1. ✅ Gerar os 7 arquivos SQL usando as instruções
2. ✅ Validar que todos executam sem erro
3. ✅ Executar testes e capturar resultados
4. ✅ Compilar documentação do relatório
5. ✅ Organizar arquivos para entrega

---

## 📞 SUPORTE

Se precisar de ajuda em alguma etapa:
- Volte para a conversa com o Claude
- Use comandos tipo: `CÓDIGO: gere a procedure X com Y funcionalidade`
- Ou: `VALIDAR: este script está dando erro Z`

---

**Boa sorte com o projeto! 🚀**

*Gerado automaticamente para facilitar o desenvolvimento do SGBU*
