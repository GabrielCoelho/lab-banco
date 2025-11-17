# 📋 INSTRUÇÃO 06: CONSULTAS SQL (10 QUERIES OBRIGATÓRIAS)

## 🎯 OBJETIVO
Gerar 10 consultas SQL de complexidade progressiva para demonstrar domínio de consultas no **SGBU**.

---

## 📚 CONTEXTO DO PROJETO

**Projeto:** Sistema de Gerenciamento de Biblioteca Universitária (SGBU)  
**Pré-requisitos:** Scripts 01, 02 executados (e opcionalmente 03-05)  
**Objetivo:** Demonstrar proficiência em SQL desde consultas básicas até avançadas

---

## 📊 DISTRIBUIÇÃO DE COMPLEXIDADE

**Nível Básico (Queries 1-3):** SELECT simples, WHERE, ORDER BY  
**Nível Intermediário (Queries 4-6):** JOINs múltiplos, funções agregadas básicas  
**Nível Avançado (Queries 7-10):** Subqueries, agregações complexas, correlações

---

## 📋 CONSULTAS OBRIGATÓRIAS

### **QUERY 1: Listagem Simples com Filtro e Ordenação**
**Descrição:** Listar todos os livros da categoria 'Ficção Científica', mostrando título, ano de publicação e ISBN, ordenados por ano decrescente.

**Cláusulas SQL:**
- SELECT
- FROM com JOIN (Livros → Categorias)
- WHERE
- ORDER BY

**Colunas esperadas:**
- `titulo`
- `ano_publicacao`
- `isbn`

**Exemplo de resultado:**
```
Duna (2020) - ISBN: 9780441172719
1984 (1949) - ISBN: 9780451524935
```

---

### **QUERY 2: Contagem com Agrupamento**
**Descrição:** Contar quantos livros existem em cada categoria, exibindo o nome da categoria e a quantidade, ordenado por quantidade decrescente.

**Cláusulas SQL:**
- SELECT
- FROM com JOIN
- GROUP BY
- ORDER BY

**Colunas esperadas:**
- `nome_categoria`
- `total_livros` (COUNT)

**Filtros adicionais:** Apenas categorias com pelo menos 1 livro

---

### **QUERY 3: Usuários Específicos com Filtro de Data**
**Descrição:** Listar todos os usuários do tipo 'Aluno' que se cadastraram nos últimos 6 meses, mostrando nome, email e data de cadastro.

**Cláusulas SQL:**
- SELECT
- FROM com JOIN (Usuarios → TiposUsuario)
- WHERE (tipo E data)
- ORDER BY

**Colunas esperadas:**
- `nome_completo`
- `email`
- `data_cadastro`

**Filtro de data:** `data_cadastro >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)`

---

### **QUERY 4: JOIN Triplo com Informações Completas**
**Descrição:** Listar todos os empréstimos realizados em 2025, mostrando: nome do usuário, título do livro, data de empréstimo e data prevista de devolução.

**Cláusulas SQL:**
- SELECT
- FROM com múltiplos JOINs (Emprestimos → Usuarios, Emprestimos → Exemplares → Livros)
- WHERE (filtro de ano)
- ORDER BY

**Colunas esperadas:**
- `nome_usuario`
- `titulo_livro`
- `data_emprestimo`
- `data_prevista_devolucao`

**Ordenação:** Por data de empréstimo (mais recentes primeiro)

---

### **QUERY 5: Agregação por Relacionamento**
**Descrição:** Para cada autor, mostrar quantos livros ele escreveu (apenas autores com pelo menos 2 livros), exibindo nome do autor e quantidade.

**Cláusulas SQL:**
- SELECT
- FROM com JOINs (Autores → LivrosAutores → Livros)
- GROUP BY
- HAVING
- ORDER BY

**Colunas esperadas:**
- `nome_autor`
- `total_livros` (COUNT)

**Filtro HAVING:** `COUNT(*) >= 2`

---

### **QUERY 6: Média e Estatísticas por Grupo**
**Descrição:** Calcular a média de páginas dos livros agrupados por categoria, mostrando categoria, média de páginas e quantidade de livros. Ordenar por média decrescente.

**Cláusulas SQL:**
- SELECT
- FROM com JOIN
- GROUP BY
- Funções: AVG, COUNT
- ORDER BY

**Colunas esperadas:**
- `nome_categoria`
- `media_paginas` (AVG, arredondado para 0 casas decimais)
- `quantidade_livros` (COUNT)

---

### **QUERY 7: Subquery Simples (Filtro por Agregação)**
**Descrição:** Encontrar livros que têm mais exemplares que a média geral de exemplares por livro, mostrando título, ISBN e quantidade de exemplares.

**Cláusulas SQL:**
- SELECT com subquery no WHERE
- GROUP BY para contar exemplares
- HAVING para filtrar

**Lógica:**
1. Calcular média de exemplares por livro: `(SELECT AVG(count) FROM (subquery))`
2. Filtrar livros cuja contagem > média

**Colunas esperadas:**
- `titulo`
- `isbn`
- `total_exemplares` (COUNT)

---

### **QUERY 8: Subquery Correlacionada**
**Descrição:** Listar usuários que nunca fizeram nenhum empréstimo, mostrando nome, CPF e email.

**Cláusulas SQL:**
- SELECT com NOT EXISTS
- Subquery correlacionada

**Lógica:**
```sql
WHERE NOT EXISTS (
    SELECT 1 FROM Emprestimos e 
    WHERE e.id_usuario = u.id_usuario
)
```

**Colunas esperadas:**
- `nome_completo`
- `cpf`
- `email`

---

### **QUERY 9: Agregação Complexa com Múltiplos JOINs e CASE**
**Descrição:** Para cada usuário que tem empréstimos, calcular:
- Total de empréstimos realizados
- Empréstimos devolvidos no prazo
- Empréstimos devolvidos com atraso
- Total de multas pagas

Mostrar apenas usuários com pelo menos 1 empréstimo.

**Cláusulas SQL:**
- SELECT com múltiplas agregações
- FROM com múltiplos LEFT JOINs
- GROUP BY
- Funções condicionais: COUNT(CASE WHEN...)
- HAVING

**Colunas esperadas:**
- `nome_usuario`
- `tipo_usuario`
- `total_emprestimos` (COUNT total)
- `emprestimos_no_prazo` (COUNT com CASE)
- `emprestimos_atrasados` (COUNT com CASE)
- `valor_multas_pagas` (SUM com filtro)

**Ordenação:** Por total de empréstimos decrescente

---

### **QUERY 10: Análise Temporal com Window Functions (ou Alternativa)**
**Descrição:** Ranking dos 5 livros mais emprestados nos últimos 3 meses, mostrando posição no ranking, título, categoria e quantidade de empréstimos.

**Cláusulas SQL:**
- SELECT com agregação
- FROM com múltiplos JOINs
- WHERE (filtro temporal)
- GROUP BY
- ORDER BY
- LIMIT

**Lógica:**
1. Filtrar empréstimos dos últimos 3 meses
2. Agrupar por livro
3. Contar quantidade
4. Ordenar decrescente
5. Limitar aos 5 primeiros

**Colunas esperadas:**
- `ranking` (pode usar variável @rank ou ROW_NUMBER se suportado)
- `titulo`
- `categoria`
- `total_emprestimos` (COUNT)

**Filtro temporal:** `data_emprestimo >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)`

---

## 📐 ESPECIFICAÇÕES TÉCNICAS

### Formatação Padrão:
```sql
-- ================================================================================
-- QUERY X: Título Descritivo
-- Descrição: Explicação do propósito da consulta
-- Complexidade: [Básica|Intermediária|Avançada]
-- ================================================================================

SELECT 
    coluna1,
    coluna2,
    AGG_FUNC(coluna3) AS alias
FROM tabela1 t1
INNER JOIN tabela2 t2 ON t1.id = t2.id_fk
WHERE condicoes
GROUP BY coluna1, coluna2
HAVING condicao_agregada
ORDER BY ordenacao
LIMIT quantidade;

-- Resultado esperado: [Descrição breve do que deve aparecer]
-- Exemplo: "10 linhas mostrando os livros mais recentes..."
```

### Boas Práticas Obrigatórias:
1. ✅ Cada query em bloco separado com comentário explicativo
2. ✅ Código indentado e legível
3. ✅ Alias descritivos para colunas agregadas
4. ✅ Alias de tabelas quando há múltiplos JOINs
5. ✅ Comentar lógica complexa (especialmente em subqueries)
6. ✅ Incluir exemplo de resultado esperado
7. ✅ Testar cada query e documentar número de linhas retornadas

---

## 🎯 REQUISITOS DO SCRIPT A GERAR

### Estrutura do Arquivo:
```sql
-- Cabeçalho com informações do projeto
-- Seção 1: Consultas Básicas (Queries 1-3)
-- Seção 2: Consultas Intermediárias (Queries 4-6)
-- Seção 3: Consultas Avançadas (Queries 7-10)
-- Seção 4: Resumo de Resultados (opcional)
```

### Características Obrigatórias:
1. ✅ 10 queries implementadas conforme especificações
2. ✅ Progressão clara de complexidade
3. ✅ Cada query com:
   - Comentário descritivo
   - Código formatado
   - Exemplo de resultado esperado
4. ✅ Queries testadas e funcionais
5. ✅ Resultados documentados (quantas linhas retornadas, valores exemplo)

---

## 📤 FORMATO DE SAÍDA ESPERADO

**Nome do arquivo:** `06_queries.sql`

**Estrutura:**
- Organizado por nível de complexidade
- Comentários explicativos detalhados
- Código limpo e testado
- Pronto para executar após scripts anteriores

---

## ✅ CHECKLIST DE VALIDAÇÃO

Antes de considerar completo, verificar:
- [ ] 10 queries implementadas
- [ ] Progressão de complexidade clara (1-3 básicas, 4-6 intermediárias, 7-10 avançadas)
- [ ] Todas executam sem erros
- [ ] Cada query retorna resultados relevantes e corretos
- [ ] Cobrem diferentes aspectos:
  - [ ] Filtros simples (WHERE)
  - [ ] Agregações (COUNT, SUM, AVG)
  - [ ] Agrupamento (GROUP BY)
  - [ ] JOINs múltiplos
  - [ ] Subqueries (simples e correlacionadas)
  - [ ] Ordenação complexa
- [ ] Comentários explicam propósito e lógica
- [ ] Resultados documentados

---

## 💡 DICAS DE IMPLEMENTAÇÃO

### Contagem Condicional (QUERY 9):
```sql
COUNT(CASE 
    WHEN e.data_devolucao_real <= e.data_prevista_devolucao 
    THEN 1 
END) AS emprestimos_no_prazo
```

### Subquery no WHERE (QUERY 7):
```sql
WHERE (
    SELECT COUNT(*) 
    FROM Exemplares ex 
    WHERE ex.id_livro = l.id_livro
) > (
    SELECT AVG(qtd) 
    FROM (
        SELECT COUNT(*) AS qtd 
        FROM Exemplares 
        GROUP BY id_livro
    ) AS media_exemplares
)
```

### Variável para Ranking (QUERY 10):
```sql
SET @rank = 0;
SELECT 
    (@rank := @rank + 1) AS ranking,
    ...
```

### Filtro Temporal:
```sql
WHERE data_emprestimo >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
```

---

## 📊 EXEMPLO DE DOCUMENTAÇÃO DE RESULTADO

```sql
-- QUERY 1: Livros de Ficção Científica
-- Resultado: 8 linhas retornadas
-- Exemplo de linha: "Duna | 2020 | 9780441172719"

-- QUERY 5: Autores Prolíficos
-- Resultado: 3 linhas retornadas
-- Exemplo: "Isaac Asimov | 5 livros"
```

---

## 🚀 PROMPT PARA IA

**"Gere as 10 consultas SQL seguindo todas as especificações acima. As queries devem demonstrar progressão de complexidade, estar bem documentadas, formatadas e testadas. Inclua comentários explicativos e exemplos de resultados esperados para cada uma."**
