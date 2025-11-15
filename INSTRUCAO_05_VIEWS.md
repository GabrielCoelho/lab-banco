# 📋 INSTRUÇÃO 05: VIEWS (VISÕES)

## 🎯 OBJETIVO
Gerar views para simplificar consultas complexas e criar relatórios padronizados no **SGBU**.

---

## 📚 CONTEXTO DO PROJETO

**Projeto:** Sistema de Gerenciamento de Biblioteca Universitária (SGBU)  
**Pré-requisitos:** Scripts 01 e 02 executados  
**Objetivo:** Criar camada de abstração para consultas frequentes e relatórios

---

## 📋 VIEWS OBRIGATÓRIAS (Mínimo 3)

### 1. `vw_EmprestimosAtivos`
**Propósito:** Listar todos os empréstimos atualmente em andamento com informações completas

**Colunas esperadas:**
- `id_emprestimo` - ID do empréstimo
- `cpf_usuario` - CPF do usuário
- `nome_usuario` - Nome completo do usuário
- `tipo_usuario` - Tipo (Aluno, Professor, Funcionário)
- `isbn` - ISBN do livro
- `titulo_livro` - Título do livro
- `codigo_exemplar` - Código do exemplar específico
- `data_emprestimo` - Data de realização do empréstimo
- `data_prevista_devolucao` - Prazo de devolução
- `dias_restantes` - Cálculo: dias até vencimento (pode ser negativo se atrasado)
- `situacao` - Calculado: 'No Prazo', 'Vence Hoje', 'Atrasado X dias'

**Joins necessários:**
- Emprestimos → Usuarios → TiposUsuario
- Emprestimos → Exemplares → Livros

**Filtros:**
- Apenas empréstimos com `status_emprestimo = 'Ativo'`
- Ordenar por `data_prevista_devolucao` ASC (vencimentos mais próximos primeiro)

**Exemplo de uso:**
```sql
-- Ver todos empréstimos ativos
SELECT * FROM vw_EmprestimosAtivos;

-- Ver apenas atrasados
SELECT * FROM vw_EmprestimosAtivos WHERE dias_restantes < 0;
```

---

### 2. `vw_LivrosDisponiveis`
**Propósito:** Listar todos os livros que têm pelo menos um exemplar disponível para empréstimo

**Colunas esperadas:**
- `id_livro` - ID do livro
- `isbn` - ISBN
- `titulo` - Título do livro
- `autores` - Lista concatenada de autores (ex: "Autor1; Autor2")
- `categoria` - Nome da categoria
- `editora` - Nome da editora
- `ano_publicacao` - Ano
- `total_exemplares` - Quantidade total de exemplares deste livro
- `exemplares_disponiveis` - Quantidade com status 'Disponível'
- `exemplares_emprestados` - Quantidade com status 'Emprestado'

**Joins necessários:**
- Livros → Categorias
- Livros → Editoras
- Livros → LivrosAutores → Autores
- Livros → Exemplares (agregação por status)

**Lógica especial:**
- Usar GROUP_CONCAT para concatenar múltiplos autores
- Usar COUNT com CASE para contar por status de exemplar
- Filtrar apenas livros com `exemplares_disponiveis > 0`
- Ordenar por `categoria`, depois por `titulo`

**Exemplo de uso:**
```sql
-- Ver livros disponíveis
SELECT * FROM vw_LivrosDisponiveis;

-- Ver livros de uma categoria específica
SELECT * FROM vw_LivrosDisponiveis WHERE categoria = 'Ficção Científica';
```

---

### 3. `vw_UsuariosComPendencias`
**Propósito:** Listar usuários que têm empréstimos atrasados ou multas pendentes

**Colunas esperadas:**
- `id_usuario` - ID do usuário
- `cpf` - CPF
- `nome_completo` - Nome do usuário
- `email` - Email para contato
- `telefone` - Telefone
- `tipo_usuario` - Tipo (Aluno, Professor)
- `emprestimos_atrasados` - Quantidade de empréstimos vencidos
- `total_dias_atraso` - Soma total de dias de atraso
- `multas_pendentes` - Quantidade de multas não pagas
- `valor_total_multas` - Soma de valores pendentes
- `status_conta` - Calculado: 'Crítico' (>30 dias atraso), 'Atenção' (>14 dias), 'Regular'

**Joins necessários:**
- Usuarios → TiposUsuario
- Usuarios → Emprestimos (apenas atrasados)
- Emprestimos → Multas (apenas pendentes)

**Lógica especial:**
- Incluir usuários que têm empréstimos atrasados OU multas pendentes
- Usar LEFT JOIN para agregar empréstimos e multas
- Calcular dias de atraso: DATEDIFF(CURDATE(), data_prevista_devolucao)
- Usar CASE para calcular status_conta
- Ordenar por `valor_total_multas DESC` (piores situações primeiro)

**Exemplo de uso:**
```sql
-- Ver todos com pendências
SELECT * FROM vw_UsuariosComPendencias;

-- Ver situações críticas
SELECT * FROM vw_UsuariosComPendencias WHERE status_conta = 'Crítico';
```

---

## 🎯 VIEWS ADICIONAIS (Recomendadas)

### 4. `vw_EstatisticasGerais` (Bônus)
**Propósito:** Dashboard com métricas principais da biblioteca

**Colunas:**
- `total_livros` - Quantidade de livros cadastrados
- `total_exemplares` - Quantidade de exemplares
- `total_usuarios` - Usuários cadastrados
- `emprestimos_ativos` - Quantidade em andamento
- `emprestimos_atrasados` - Quantidade vencidos
- `multas_pendentes_total` - Valor em R$ de multas não pagas
- `taxa_ocupacao` - % de exemplares emprestados (emprestados/total)

**Tipo:** View com agregações gerais (sem GROUP BY, uma única linha)

---

### 5. `vw_RankingCategoriasMaisEmprestadas` (Bônus)
**Propósito:** Categorias mais populares por volume de empréstimos

**Colunas:**
- `posicao` - Ranking (1, 2, 3...)
- `categoria` - Nome da categoria
- `total_emprestimos` - Quantidade histórica
- `livros_categoria` - Quantidade de livros nesta categoria
- `media_emprestimos_por_livro` - Média de popularidade

**Ordenação:** Por `total_emprestimos DESC`

---

### 6. `vw_HistoricoUsuario` (Bônus - requer parâmetro)
**Propósito:** Histórico completo de empréstimos de um usuário

**Nota:** Views não aceitam parâmetros, então esta seria uma estrutura genérica que pode ser filtrada após SELECT

**Colunas:**
- `id_usuario`, `nome_usuario`, `cpf`
- `id_emprestimo`, `titulo_livro`, `isbn`
- `data_emprestimo`, `data_devolucao_real`
- `status_emprestimo`, `teve_multa` (BOOLEAN)
- `valor_multa` (se houver)

---

## 📐 ESPECIFICAÇÕES TÉCNICAS

### Estrutura Padrão de View:
```sql
CREATE OR REPLACE VIEW nome_view AS
SELECT 
    -- Colunas base
    t1.coluna1,
    t2.coluna2,
    
    -- Colunas calculadas
    DATEDIFF(CURDATE(), t1.data_campo) AS dias_diferenca,
    
    -- Agregações (se necessário)
    COUNT(t3.id) AS total_registros,
    
    -- Expressões CASE
    CASE 
        WHEN condicao1 THEN 'Valor1'
        WHEN condicao2 THEN 'Valor2'
        ELSE 'Valor3'
    END AS coluna_calculada
    
FROM tabela1 t1
INNER JOIN tabela2 t2 ON t1.id = t2.id_fk
LEFT JOIN tabela3 t3 ON t2.id = t3.id_fk
WHERE condicoes
GROUP BY t1.coluna1, t2.coluna2
ORDER BY ordenacao;
```

### Boas Práticas Obrigatórias:
1. ✅ Usar `CREATE OR REPLACE VIEW` para facilitar atualizações
2. ✅ Alias descritivos para tabelas (ex: `u` para Usuarios, `e` para Emprestimos)
3. ✅ Nomes de colunas claros e sem ambiguidade
4. ✅ Comentar lógica de colunas calculadas complexas
5. ✅ Evitar SELECT * em views de produção
6. ✅ Incluir apenas colunas úteis (não expor dados sensíveis desnecessariamente)
7. ✅ Usar IFNULL/COALESCE para evitar NULL em agregações

### Otimização de Performance:
- Evitar subqueries correlacionadas quando possível
- Usar INNER JOIN quando relação é obrigatória
- Usar LEFT JOIN apenas quando necessário
- Indexar colunas usadas em JOINs e WHEREs
- Considerar materialização para views muito pesadas (fora do escopo)

---

## 🎯 REQUISITOS DO SCRIPT A GERAR

### Estrutura do Arquivo:
```sql
-- Cabeçalho com informações
-- Seção 1: Views Operacionais (empréstimos, disponibilidade)
--   - vw_EmprestimosAtivos
--   - vw_LivrosDisponiveis
-- Seção 2: Views de Controle (pendências, problemas)
--   - vw_UsuariosComPendencias
-- Seção 3: Views Estatísticas (se implementadas)
--   - vw_EstatisticasGerais
--   - vw_RankingCategoriasMaisEmprestadas
-- Seção 4: Exemplos de consultas usando as views
```

### Características Obrigatórias:
1. ✅ Mínimo 3 views obrigatórias implementadas
2. ✅ Cada view com comentário explicando:
   - Propósito
   - Colunas calculadas (se houver)
   - Casos de uso típicos
3. ✅ Código formatado e indentado
4. ✅ Exemplos de consulta ao final
5. ✅ Views testadas e funcionais

---

## 📤 FORMATO DE SAÍDA ESPERADO

**Nome do arquivo:** `05_views.sql`

**Estrutura:**
- Comentários explicativos para cada view
- Organizado por categoria (operacionais, controle, estatísticas)
- Exemplos de uso incluídos
- Pronto para executar após scripts anteriores

---

## ✅ CHECKLIST DE VALIDAÇÃO

Antes de considerar completo, verificar:
- [ ] 3 views obrigatórias implementadas
- [ ] Todas executam sem erros
- [ ] Colunas calculadas retornam valores corretos:
  - [ ] `dias_restantes` considera data atual
  - [ ] `situacao` classifica corretamente
  - [ ] `autores` concatena todos nomes
  - [ ] `status_conta` calcula baseado em critérios corretos
- [ ] Agregações retornam resultados esperados
- [ ] JOINs cobrem todos os dados necessários
- [ ] Exemplos de consulta funcionam

---

## 💡 DICAS DE IMPLEMENTAÇÃO

### Concatenação de Autores (MySQL):
```sql
GROUP_CONCAT(a.nome_autor ORDER BY la.ordem_autoria SEPARATOR '; ') AS autores
```

### Cálculo de Dias Restantes:
```sql
DATEDIFF(e.data_prevista_devolucao, CURDATE()) AS dias_restantes
```

### Campo Calculado com CASE:
```sql
CASE
    WHEN DATEDIFF(CURDATE(), e.data_prevista_devolucao) > 30 THEN 'Crítico'
    WHEN DATEDIFF(CURDATE(), e.data_prevista_devolucao) > 14 THEN 'Atenção'
    WHEN DATEDIFF(CURDATE(), e.data_prevista_devolucao) > 0 THEN 'Atrasado'
    WHEN DATEDIFF(CURDATE(), e.data_prevista_devolucao) = 0 THEN 'Vence Hoje'
    ELSE 'No Prazo'
END AS situacao
```

### Contagem Condicional:
```sql
COUNT(CASE WHEN ex.status = 'Disponível' THEN 1 END) AS exemplares_disponiveis,
COUNT(CASE WHEN ex.status = 'Emprestado' THEN 1 END) AS exemplares_emprestados
```

### Tratamento de NULL em Agregação:
```sql
IFNULL(SUM(m.valor_multa), 0.00) AS valor_total_multas
```

---

## 📊 EXEMPLO DE RESULTADO ESPERADO

### vw_EmprestimosAtivos:
```
+----------------+---------------+-------------------+-----------------------------+
| nome_usuario   | titulo_livro  | dias_restantes    | situacao                    |
+----------------+---------------+-------------------+-----------------------------+
| João Silva     | 1984          | -5                | Atrasado 5 dias             |
| Maria Santos   | Clean Code    | 0                 | Vence Hoje                  |
| Carlos Souza   | Harry Potter  | 7                 | No Prazo                    |
+----------------+---------------+-------------------+-----------------------------+
```

---

## 🚀 PROMPT PARA IA

**"Gere as views seguindo todas as especificações acima. As views devem ser eficientes, bem estruturadas, com colunas calculadas funcionais e comentários explicativos. Inclua exemplos de consulta para cada view."**
