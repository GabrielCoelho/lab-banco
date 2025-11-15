# 📋 INSTRUÇÃO 07: TESTES E OTIMIZAÇÃO

## 🎯 OBJETIVO
Gerar scripts de teste de concorrência, análise de performance e criação de índices otimizados para o **SGBU**.

---

## 📚 CONTEXTO DO PROJETO

**Projeto:** Sistema de Gerenciamento de Biblioteca Universitária (SGBU)  
**Pré-requisitos:** Todos os scripts anteriores executados  
**Objetivo:** Validar funcionalidade, testar concorrência e otimizar performance

---

## 📋 COMPONENTES OBRIGATÓRIOS

### PARTE 1: TESTES FUNCIONAIS

#### **1.1 Testes de Procedures**
**Objetivo:** Validar que as stored procedures funcionam corretamente em cenários normais e de exceção

**Testes para `sp_RealizarEmprestimo`:**
```sql
-- Teste 1: Empréstimo válido (deve funcionar)
-- Teste 2: Tentar emprestar exemplar indisponível (deve falhar)
-- Teste 3: Usuário com multa pendente (deve falhar)
-- Teste 4: Usuário no limite de empréstimos (deve falhar)
-- Teste 5: Exemplar inexistente (deve falhar)
```

**Testes para `sp_RealizarDevolucao`:**
```sql
-- Teste 1: Devolução no prazo (sem multa)
-- Teste 2: Devolução com 5 dias de atraso (com multa de R$ 10,00)
-- Teste 3: Devolução de empréstimo inexistente (deve falhar)
-- Teste 4: Devolução de empréstimo já devolvido (deve falhar)
```

**Estrutura de cada teste:**
```sql
-- ================================================================================
-- TESTE X: [Nome Descritivo]
-- Cenário: [Descrição do que está sendo testado]
-- Resultado esperado: [O que deve acontecer]
-- ================================================================================

-- Setup (preparação)
-- Executar operações necessárias

-- Execução
CALL sp_NomeProcedure(parametros, @sucesso, @mensagem);

-- Verificação
SELECT 
    @sucesso AS Sucesso,
    @mensagem AS Mensagem,
    'ESPERADO: [descrição]' AS Esperado;

-- Validação adicional (verificar estado do banco)
SELECT * FROM Tabela WHERE condicao; -- Deve mostrar X linhas

-- Cleanup (opcional)
-- Reverter mudanças se necessário
```

---

#### **1.2 Testes de Triggers**
**Objetivo:** Validar que triggers executam corretamente e bloqueiam operações inválidas

**Teste de `trg_ValidarDisponibilidadeEmprestimo`:**
```sql
-- Teste 1: Tentar inserir empréstimo com exemplar 'Manutenção'
-- Resultado esperado: ERROR 1644 com mensagem específica

-- Teste 2: Inserir empréstimo com exemplar 'Disponível'
-- Resultado esperado: Sucesso + status muda para 'Emprestado'
```

**Teste de `trg_AtualizarStatusExemplar_AposDevolucao`:**
```sql
-- Teste: Atualizar empréstimo preenchendo data_devolucao_real
-- Resultado esperado: Status do exemplar volta para 'Disponível'
```

**Estrutura:**
```sql
-- Teste de Trigger: [Nome]
-- Setup
UPDATE Exemplares SET status = 'Manutenção' WHERE id_exemplar = X;

-- Tentar operação que deve ser bloqueada
INSERT INTO Emprestimos (...) VALUES (...);
-- Deve retornar: ERROR 1644 (45000): Mensagem do trigger

-- Verificar estado
SELECT status FROM Exemplares WHERE id_exemplar = X;
-- Deve continuar 'Manutenção'
```

---

### PARTE 2: TESTES DE CONCORRÊNCIA

#### **2.1 Cenário de Teste 1: Empréstimo Simultâneo do Mesmo Exemplar**
**Objetivo:** Testar comportamento quando 2 usuários tentam emprestar o mesmo exemplar ao mesmo tempo

**Setup:**
- 1 exemplar disponível (id_exemplar = 10)
- 2 usuários aptos a emprestar (ids 5 e 8)

**Script Sessão 1:**
```sql
-- ================================================================================
-- SESSÃO 1: Empréstimo Simultâneo
-- Executar em uma janela/aba do MySQL Workbench
-- ================================================================================

START TRANSACTION;

-- Verificar disponibilidade
SELECT status FROM Exemplares WHERE id_exemplar = 10;
-- Deve mostrar 'Disponível'

-- Simular processamento (pause aqui para dar tempo da Sessão 2 começar)
SELECT SLEEP(5);

-- Tentar realizar empréstimo
CALL sp_RealizarEmprestimo(5, 10, @s, @m);
SELECT @s, @m;

COMMIT;

-- Verificar resultado final
SELECT status FROM Exemplares WHERE id_exemplar = 10;
SELECT * FROM Emprestimos WHERE id_exemplar = 10 AND status_emprestimo = 'Ativo';
```

**Script Sessão 2:**
```sql
-- ================================================================================
-- SESSÃO 2: Empréstimo Simultâneo (executar 2 segundos depois da Sessão 1)
-- Executar em outra janela/aba do MySQL Workbench
-- ================================================================================

START TRANSACTION;

-- Verificar disponibilidade (ainda deve mostrar 'Disponível' se Sessão 1 não commitou)
SELECT status FROM Exemplares WHERE id_exemplar = 10;

-- Tentar realizar empréstimo
CALL sp_RealizarEmprestimo(8, 10, @s, @m);
SELECT @s, @m;

COMMIT;

-- Verificar se foi bloqueado
SELECT * FROM Emprestimos WHERE id_usuario = 8 AND id_exemplar = 10;
-- Não deve ter criado empréstimo (ou deve ter falhado)
```

**Resultado esperado:**
- Apenas 1 empréstimo deve ser criado
- O segundo deve falhar ou ficar bloqueado até o primeiro commitar
- Exemplar deve ter status 'Emprestado' ao final

**Análise:**
```sql
-- Verificar logs de lock (se disponível)
SHOW ENGINE INNODB STATUS\G
```

---

#### **2.2 Cenário de Teste 2: Atualização Simultânea de Multa**
**Objetivo:** Testar deadlock potencial em atualizações concorrentes

**Setup:**
- 1 empréstimo atrasado (id_emprestimo = 5)
- 2 sessões tentando atualizar simultaneamente

**Script Sessão 1:**
```sql
-- SESSÃO 1: Atualizar valor da multa
START TRANSACTION;

SELECT * FROM Multas WHERE id_emprestimo = 5 FOR UPDATE;
-- Lock explícito

SELECT SLEEP(3);

UPDATE Multas SET valor_multa = 20.00 WHERE id_emprestimo = 5;

COMMIT;
```

**Script Sessão 2:**
```sql
-- SESSÃO 2: Atualizar status da multa (executar 1 segundo depois)
START TRANSACTION;

UPDATE Multas SET status_pagamento = 'Pago' WHERE id_emprestimo = 5;
-- Deve ficar esperando lock da Sessão 1

COMMIT;
```

**Resultado esperado:**
- Sessão 2 espera Sessão 1 terminar
- Não deve haver deadlock (operações em ordem)
- Ambas atualizações devem ser aplicadas

---

#### **2.3 Configuração de Níveis de Isolamento**
**Incluir no script:**

```sql
-- ================================================================================
-- DEMONSTRAÇÃO DE NÍVEIS DE ISOLAMENTO
-- ================================================================================

-- Verificar nível atual
SELECT @@transaction_isolation;

-- Testar com READ COMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Executar teste de concorrência

-- Testar com REPEATABLE READ (padrão MySQL)
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- Executar teste de concorrência

-- Testar com SERIALIZABLE (mais restritivo)
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- Executar teste de concorrência

-- Documentar diferenças observadas
```

---

### PARTE 3: ANÁLISE DE PERFORMANCE E OTIMIZAÇÃO

#### **3.1 Identificação de Queries Lentas**
**Objetivo:** Analisar planos de execução das queries mais importantes

**Queries a analisar:**
```sql
-- Query 1: Busca de livros disponíveis (frequente)
EXPLAIN SELECT * FROM vw_LivrosDisponiveis WHERE categoria = 'Ficção';

-- Query 2: Empréstimos ativos de um usuário
EXPLAIN SELECT * FROM Emprestimos WHERE id_usuario = 5 AND status_emprestimo = 'Ativo';

-- Query 3: Ranking de livros mais emprestados
EXPLAIN SELECT 
    l.titulo, COUNT(*) as total
FROM Emprestimos e
JOIN Exemplares ex ON e.id_exemplar = ex.id_exemplar
JOIN Livros l ON ex.id_livro = l.id_livro
WHERE e.data_emprestimo >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY l.id_livro
ORDER BY total DESC
LIMIT 10;
```

**Para cada EXPLAIN, documentar:**
- Tipo de acesso (ALL = full scan, ref = índice, etc.)
- Colunas usadas para JOIN/filtro
- Linhas examinadas (rows)
- Extra info (Using where, Using filesort, etc.)

---

#### **3.2 Criação de Índices Otimizados**
**Objetivo:** Criar índices para acelerar queries identificadas como lentas

**Índices obrigatórios:**

```sql
-- ================================================================================
-- ÍNDICES DE OTIMIZAÇÃO
-- ================================================================================

-- Índice 1: Busca por ISBN (consulta frequente)
CREATE INDEX idx_livros_isbn ON Livros(isbn);

-- Índice 2: Busca por CPF de usuário
CREATE INDEX idx_usuarios_cpf ON Usuarios(cpf);

-- Índice 3: Filtro de empréstimos por status e usuário
CREATE INDEX idx_emprestimos_usuario_status 
ON Emprestimos(id_usuario, status_emprestimo);

-- Índice 4: Filtro de exemplares por livro e status (para disponibilidade)
CREATE INDEX idx_exemplares_livro_status 
ON Exemplares(id_livro, status);

-- Índice 5: Filtro temporal de empréstimos (para relatórios)
CREATE INDEX idx_emprestimos_data 
ON Emprestimos(data_emprestimo);

-- Índice 6: Busca de multas pendentes
CREATE INDEX idx_multas_emprestimo_status 
ON Multas(id_emprestimo, status_pagamento);

-- Índice 7: Relacionamento livro-categoria (para filtros)
CREATE INDEX idx_livros_categoria 
ON Livros(id_categoria);
```

**Justificativa de cada índice:**
```sql
-- idx_livros_isbn: 
-- Usado em: Busca de livros por código de barras/ISBN
-- Frequência: Alta (a cada consulta de disponibilidade)
-- Impacto: Reduz scan completo da tabela Livros

-- idx_emprestimos_usuario_status:
-- Usado em: Validação de limite de empréstimos, listagem de ativos por usuário
-- Frequência: Muito alta (a cada empréstimo, em procedures)
-- Impacto: Evita full scan para contar empréstimos ativos
```

---

#### **3.3 Análise Antes vs Depois**
**Objetivo:** Demonstrar impacto dos índices

**Estrutura:**

```sql
-- ================================================================================
-- ANÁLISE COMPARATIVA DE PERFORMANCE
-- ================================================================================

-- ANTES DOS ÍNDICES
-- Executar EXPLAIN e documentar tempo

SET profiling = 1;

SELECT * FROM Emprestimos WHERE id_usuario = 5 AND status_emprestimo = 'Ativo';

SHOW PROFILES;
-- Documentar tempo: ~0.05 segundos

EXPLAIN SELECT ...;
-- Documentar: type=ALL, rows=1000 (exemplo)

-- CRIAR ÍNDICES (executar scripts de índices)

-- DEPOIS DOS ÍNDICES
SET profiling = 1;

SELECT * FROM Emprestimos WHERE id_usuario = 5 AND status_emprestimo = 'Ativo';

SHOW PROFILES;
-- Documentar tempo: ~0.001 segundos

EXPLAIN SELECT ...;
-- Documentar: type=ref, rows=3 (exemplo)

-- CONCLUSÃO:
-- Melhoria: 50x mais rápido
-- Linhas examinadas: redução de 1000 para 3
```

**Tabela comparativa para incluir no relatório:**

```
| Query                          | Antes      | Depois     | Melhoria |
|--------------------------------|------------|------------|----------|
| Empréstimos ativos por usuário | 0.050s     | 0.001s     | 50x      |
| Busca livro por ISBN           | 0.030s     | 0.0005s    | 60x      |
| Ranking livros emprestados     | 1.200s     | 0.180s     | 6.7x     |
```

---

### PARTE 4: TESTES DE CARGA (OPCIONAL)

**Objetivo:** Simular múltiplas operações simultâneas

```sql
-- Criar procedure de teste de carga
DELIMITER $$

CREATE PROCEDURE sp_TesteCarga()
BEGIN
    DECLARE i INT DEFAULT 1;
    
    WHILE i <= 100 DO
        -- Simular empréstimos aleatórios
        CALL sp_RealizarEmprestimo(
            FLOOR(1 + RAND() * 25),  -- usuário aleatório
            FLOOR(1 + RAND() * 50),  -- exemplar aleatório
            @s, @m
        );
        
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- Executar e medir tempo
SET @inicio = NOW(6);
CALL sp_TesteCarga();
SET @fim = NOW(6);

SELECT TIMESTAMPDIFF(MICROSECOND, @inicio, @fim) / 1000000 AS tempo_segundos;
```

---

## 🎯 REQUISITOS DO SCRIPT A GERAR

### Estrutura do Arquivo:
```sql
-- Cabeçalho com instruções de uso
-- PARTE 1: Testes Funcionais
--   1.1 Testes de Procedures
--   1.2 Testes de Triggers
-- PARTE 2: Testes de Concorrência
--   2.1 Empréstimo Simultâneo
--   2.2 Atualização Concorrente
--   2.3 Níveis de Isolamento
-- PARTE 3: Otimização
--   3.1 Análise de EXPLAIN (antes)
--   3.2 Criação de Índices
--   3.3 Análise de EXPLAIN (depois)
--   3.4 Tabela comparativa
-- PARTE 4: Conclusões e Recomendações
```

### Características Obrigatórias:
1. ✅ Testes cobrem cenários normais e de exceção
2. ✅ Scripts de concorrência com instruções claras de execução
3. ✅ Análise de EXPLAIN antes e depois de índices
4. ✅ Mínimo 5 índices criados com justificativas
5. ✅ Documentação de resultados e melhorias
6. ✅ Comentários explicativos abundantes
7. ✅ Organização clara por seções

---

## 📤 FORMATO DE SAÍDA ESPERADO

**Nome do arquivo:** `07_tests_optimization.sql`

**Estrutura:**
- Testes funcionais executáveis
- Scripts de concorrência com instruções passo-a-passo
- Análise de performance documentada
- Índices implementados
- Comparativos antes/depois

---

## ✅ CHECKLIST DE VALIDAÇÃO

Antes de considerar completo, verificar:
- [ ] Testes de procedures cobrem 4+ cenários cada
- [ ] Testes de triggers incluem bloqueios e sucessos
- [ ] 2+ cenários de concorrência documentados
- [ ] Instruções claras de como executar testes concorrentes
- [ ] Análise de EXPLAIN para queries críticas
- [ ] 5+ índices criados com justificativas
- [ ] Comparação antes/depois documentada
- [ ] Melhorias quantificadas (tempo, linhas examinadas)
- [ ] Todos os scripts testados e funcionais

---

## 🚀 PROMPT PARA IA

**"Gere o script completo de testes e otimização seguindo todas as especificações acima. Inclua testes funcionais, cenários de concorrência, análise de performance e criação de índices otimizados. Documente todos os resultados esperados e melhorias quantificadas."**
