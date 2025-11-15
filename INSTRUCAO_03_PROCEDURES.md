# 📋 INSTRUÇÃO 03: STORED PROCEDURES

## 🎯 OBJETIVO
Gerar stored procedures para automatizar operações críticas do **Sistema de Gerenciamento de Biblioteca Universitária (SGBU)**.

---

## 📚 CONTEXTO DO PROJETO

**Projeto:** Sistema de Gerenciamento de Biblioteca Universitária (SGBU)  
**Pré-requisitos:** 
- `01_create_database.sql` executado
- `02_insert_data.sql` executado  
**Objetivo:** Automatizar lógica de negócio complexa com procedures reutilizáveis

---

## 📋 PROCEDURES OBRIGATÓRIAS (Mínimo 4)

### 1. `sp_RealizarEmprestimo`
**Propósito:** Registrar um novo empréstimo com validações completas

**Parâmetros de entrada:**
- `p_id_usuario` (INT) - ID do usuário solicitante
- `p_id_exemplar` (INT) - ID do exemplar a ser emprestado

**Parâmetros de saída:**
- `p_sucesso` (BOOLEAN) - TRUE se empréstimo realizado, FALSE se falhou
- `p_mensagem` (VARCHAR(200)) - Mensagem de sucesso ou erro

**Lógica/Validações:**
1. Verificar se usuário existe e está 'Ativo' (não suspenso)
2. Verificar se usuário tem multas pendentes → bloquear se sim
3. Verificar se usuário já atingiu limite de empréstimos simultâneos (max_emprestimos do tipo)
4. Verificar se exemplar existe e está 'Disponível'
5. Se todas validações OK:
   - Inserir novo registro em Emprestimos
   - Calcular data_prevista_devolucao (data atual + prazo_dias do tipo de usuário)
   - Atualizar status do exemplar para 'Emprestado'
   - Retornar sucesso
6. Se alguma validação falhar:
   - Retornar FALSE com mensagem específica do erro

**Exemplo de uso:**
```sql
CALL sp_RealizarEmprestimo(5, 12, @sucesso, @msg);
SELECT @sucesso, @msg;
```

---

### 2. `sp_RealizarDevolucao`
**Propósito:** Processar devolução de livro e gerar multa se houver atraso

**Parâmetros de entrada:**
- `p_id_emprestimo` (INT) - ID do empréstimo a ser finalizado

**Parâmetros de saída:**
- `p_sucesso` (BOOLEAN) - TRUE se devolução processada
- `p_valor_multa` (DECIMAL(10,2)) - Valor da multa gerada (0.00 se não houver atraso)
- `p_mensagem` (VARCHAR(200)) - Mensagem de status

**Lógica:**
1. Verificar se empréstimo existe e está 'Ativo'
2. Registrar data_devolucao_real = NOW()
3. Calcular dias de atraso:
   - `dias_atraso = DATEDIFF(NOW(), data_prevista_devolucao)`
   - Se dias_atraso <= 0 → sem atraso
4. Se houver atraso (dias_atraso > 0):
   - Calcular multa: valor = dias_atraso * 2.00 (R$ 2,00 por dia)
   - Inserir registro em Multas
   - Atualizar status_emprestimo para 'Atrasado'
   - Retornar valor da multa
5. Se não houver atraso:
   - Atualizar status_emprestimo para 'Devolvido'
   - Retornar 0.00
6. Atualizar status do exemplar para 'Disponível'
7. Verificar se há reservas ativas para este livro:
   - Se sim, atualizar status do exemplar para 'Reservado' e notificar (via mensagem)

**Exemplo de uso:**
```sql
CALL sp_RealizarDevolucao(15, @sucesso, @multa, @msg);
SELECT @sucesso AS Sucesso, @multa AS Multa, @msg AS Mensagem;
```

---

### 3. `sp_CalcularMultasAtrasadas`
**Propósito:** Processar todos os empréstimos ativos vencidos e gerar multas pendentes

**Parâmetros de entrada:** Nenhum

**Parâmetros de saída:**
- `p_total_multas_geradas` (INT) - Quantidade de multas criadas
- `p_valor_total` (DECIMAL(10,2)) - Soma total das multas geradas

**Lógica:**
1. Buscar todos os empréstimos com status 'Ativo' onde data_prevista_devolucao < CURDATE()
2. Para cada empréstimo encontrado:
   - Calcular dias_atraso = DATEDIFF(CURDATE(), data_prevista_devolucao)
   - Calcular valor_multa = dias_atraso * 2.00
   - Verificar se já existe multa para este empréstimo → evitar duplicação
   - Se não existir, inserir nova multa
   - Atualizar status_emprestimo para 'Atrasado'
3. Retornar contagem e valor total

**Observação:** Esta procedure seria executada diariamente por um job/scheduler

**Exemplo de uso:**
```sql
CALL sp_CalcularMultasAtrasadas(@total, @valor);
SELECT @total AS MultasGeradas, @valor AS ValorTotal;
```

---

### 4. `sp_RelatorioLivrosMaisEmprestados`
**Propósito:** Gerar ranking dos livros mais emprestados em um período

**Parâmetros de entrada:**
- `p_data_inicio` (DATE) - Data inicial do período
- `p_data_fim` (DATE) - Data final do período
- `p_limite` (INT) - Quantidade de livros no ranking (ex: TOP 10)

**Parâmetros de saída:** 
- Retorna um RESULT SET (não usa OUT parameters)

**Colunas do resultado:**
- `posicao` - Ranking (1, 2, 3...)
- `isbn` - ISBN do livro
- `titulo` - Título do livro
- `nome_categoria` - Categoria do livro
- `total_emprestimos` - Quantidade de vezes emprestado
- `total_exemplares` - Quantidade de exemplares disponíveis

**Lógica:**
1. JOIN entre Emprestimos → Exemplares → Livros → Categorias
2. Filtrar por data_emprestimo BETWEEN p_data_inicio AND p_data_fim
3. Agrupar por livro (id_livro)
4. Contar empréstimos por livro
5. Ordenar por total_emprestimos DESC
6. Limitar resultado a p_limite linhas
7. Adicionar número de posição (variável de ranking)

**Exemplo de uso:**
```sql
CALL sp_RelatorioLivrosMaisEmprestados('2025-01-01', '2025-03-31', 10);
```

---

## 🎯 PROCEDURES ADICIONAIS (Opcional, recomendado)

### 5. `sp_RenovarEmprestimo` (Bônus)
**Propósito:** Renovar prazo de empréstimo (se permitido)

**Parâmetros:**
- IN: `p_id_emprestimo`, `p_dias_extensao`
- OUT: `p_sucesso`, `p_nova_data_prevista`, `p_mensagem`

**Lógica:**
- Validar se empréstimo está ativo e não atrasado
- Validar se livro não tem reservas ativas
- Estender data_prevista_devolucao
- Limite de 1 renovação por empréstimo

---

### 6. `sp_ReservarLivro` (Bônus)
**Propósito:** Criar reserva para livro indisponível

**Parâmetros:**
- IN: `p_id_usuario`, `p_id_livro`
- OUT: `p_sucesso`, `p_posicao_fila`, `p_mensagem`

**Lógica:**
- Verificar se livro tem exemplares disponíveis → bloquear reserva se sim
- Verificar se usuário já tem reserva ativa para este livro
- Criar registro de reserva com data_validade = 7 dias
- Retornar posição na fila

---

## 📐 ESPECIFICAÇÕES TÉCNICAS

### Padrões de Código:
```sql
DELIMITER $$

CREATE PROCEDURE sp_NomeProcedure(
    IN p_parametro1 TIPO,
    OUT p_parametro2 TIPO
)
BEGIN
    -- Declaração de variáveis locais
    DECLARE v_variavel TIPO;
    
    -- Declaração de handler para erros
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_sucesso = FALSE;
        SET p_mensagem = 'Erro na execução';
    END;
    
    -- Início de transação (quando aplicável)
    START TRANSACTION;
    
    -- Lógica da procedure
    -- ...
    
    -- Commit (se transação)
    COMMIT;
END$$

DELIMITER ;
```

### Boas Práticas Obrigatórias:
1. ✅ Usar transações (START TRANSACTION/COMMIT/ROLLBACK) em procedures que modificam dados
2. ✅ Implementar tratamento de erros (DECLARE HANDLER)
3. ✅ Validar parâmetros de entrada antes de processar
4. ✅ Usar nomes de variáveis com prefixos:
   - `p_` para parâmetros (IN/OUT/INOUT)
   - `v_` para variáveis locais
5. ✅ Comentar lógica complexa
6. ✅ Retornar mensagens descritivas de erro
7. ✅ Usar EXISTS ao invés de COUNT(*) para checar existência
8. ✅ Evitar múltiplos SELECTs desnecessários (usar variáveis)

### Tratamento de Erros:
- Sempre usar DECLARE HANDLER para capturar exceções
- Fazer ROLLBACK em caso de erro
- Retornar mensagem clara do problema via parâmetro OUT
- Não deixar dados inconsistentes

---

## 🎯 REQUISITOS DO SCRIPT A GERAR

### Estrutura do Arquivo:
```sql
-- Cabeçalho com informações
-- Instrução sobre como executar
-- Seção 1: Procedure sp_RealizarEmprestimo
-- Seção 2: Procedure sp_RealizarDevolucao
-- Seção 3: Procedure sp_CalcularMultasAtrasadas
-- Seção 4: Procedure sp_RelatorioLivrosMaisEmprestados
-- Seção 5: Procedures opcionais (se implementadas)
-- Seção 6: Exemplos de uso/testes
```

### Características Obrigatórias:
1. ✅ Cada procedure com comentário explicando propósito
2. ✅ Código indentado e legível
3. ✅ Validações robustas de entrada
4. ✅ Transações onde necessário
5. ✅ Tratamento de erros implementado
6. ✅ Mensagens de retorno claras
7. ✅ Exemplos de uso comentados no final

---

## 📤 FORMATO DE SAÍDA ESPERADO

**Nome do arquivo:** `03_stored_procedures.sql`

**Estrutura:**
- Comentários explicativos para cada procedure
- Código limpo e organizado
- Exemplos de teste ao final
- Pronto para executar após os scripts anteriores

---

## ✅ CHECKLIST DE VALIDAÇÃO

Antes de considerar completo, verificar:
- [ ] 4 procedures obrigatórias implementadas
- [ ] Todas usam transações quando modificam dados
- [ ] Todas têm tratamento de erros (DECLARE HANDLER)
- [ ] Todas têm parâmetros de saída informativos
- [ ] Validações de negócio implementadas:
  - [ ] Empréstimo não permite usuário suspenso
  - [ ] Empréstimo não permite usuário com multa pendente
  - [ ] Empréstimo respeita limite do tipo de usuário
  - [ ] Devolução calcula multa corretamente
  - [ ] Multas só geradas para atrasos reais
- [ ] Código compilable sem erros de sintaxe
- [ ] Exemplos de uso fornecidos

---

## 💡 DICAS DE IMPLEMENTAÇÃO

### Validação de Limite de Empréstimos:
```sql
-- Contar empréstimos ativos do usuário
SELECT COUNT(*) INTO v_emprestimos_ativos
FROM Emprestimos
WHERE id_usuario = p_id_usuario AND status_emprestimo = 'Ativo';

-- Buscar limite do tipo
SELECT max_emprestimos INTO v_limite
FROM TiposUsuario tu
JOIN Usuarios u ON u.id_tipo_usuario = tu.id_tipo_usuario
WHERE u.id_usuario = p_id_usuario;

-- Validar
IF v_emprestimos_ativos >= v_limite THEN
    SET p_sucesso = FALSE;
    SET p_mensagem = 'Limite de empréstimos atingido';
    LEAVE procedure_label;
END IF;
```

### Cálculo de Multa:
```sql
SET v_dias_atraso = DATEDIFF(NOW(), v_data_prevista);
IF v_dias_atraso > 0 THEN
    SET v_valor_multa = v_dias_atraso * 2.00;
    INSERT INTO Multas (id_emprestimo, valor_multa, dias_atraso)
    VALUES (p_id_emprestimo, v_valor_multa, v_dias_atraso);
END IF;
```

---

## 🚀 PROMPT PARA IA

**"Gere as stored procedures seguindo todas as especificações acima. O código deve ser robusto, com tratamento de erros, validações completas e comentários explicativos. Priorize segurança de dados e consistência transacional."**
