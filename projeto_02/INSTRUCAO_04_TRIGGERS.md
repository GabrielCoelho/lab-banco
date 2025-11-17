# 📋 INSTRUÇÃO 04: TRIGGERS (GATILHOS AUTOMÁTICOS)

## 🎯 OBJETIVO
Gerar triggers para automatizar validações e ações em resposta a eventos no banco de dados do **SGBU**.

---

## 📚 CONTEXTO DO PROJETO

**Projeto:** Sistema de Gerenciamento de Biblioteca Universitária (SGBU)  
**Pré-requisitos:** Scripts 01 e 02 executados  
**Objetivo:** Automatizar regras de negócio e manter integridade de dados via triggers

---

## 📋 TRIGGERS OBRIGATÓRIOS (Mínimo 3)

### 1. `trg_ValidarDisponibilidadeEmprestimo`
**Tipo:** BEFORE INSERT  
**Tabela:** Emprestimos  
**Propósito:** Validar disponibilidade do exemplar ANTES de permitir inserção do empréstimo

**Lógica:**
1. Antes de inserir um novo empréstimo, verificar:
   - Se o exemplar (NEW.id_exemplar) existe
   - Se o status do exemplar é 'Disponível'
2. Se exemplar NÃO está disponível:
   - SIGNAL SQLSTATE '45000' com mensagem de erro
   - Bloquear a inserção
3. Se está disponível:
   - Permitir inserção (trigger não faz nada)

**Exemplo de erro esperado:**
```
ERROR 1644 (45000): Exemplar não está disponível para empréstimo
```

**Código base:**
```sql
CREATE TRIGGER trg_ValidarDisponibilidadeEmprestimo
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    
    SELECT status INTO v_status
    FROM Exemplares
    WHERE id_exemplar = NEW.id_exemplar;
    
    IF v_status != 'Disponível' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Exemplar não está disponível para empréstimo';
    END IF;
END;
```

---

### 2. `trg_AtualizarStatusExemplar_AposEmprestimo`
**Tipo:** AFTER INSERT  
**Tabela:** Emprestimos  
**Propósito:** Atualizar automaticamente o status do exemplar para 'Emprestado' após criação de empréstimo

**Lógica:**
1. Após inserir um novo empréstimo:
   - Atualizar Exemplares SET status = 'Emprestado' WHERE id_exemplar = NEW.id_exemplar
2. Garantir sincronia entre Emprestimos e Exemplares

**Código base:**
```sql
CREATE TRIGGER trg_AtualizarStatusExemplar_AposEmprestimo
AFTER INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    UPDATE Exemplares
    SET status = 'Emprestado'
    WHERE id_exemplar = NEW.id_exemplar;
END;
```

---

### 3. `trg_AtualizarStatusExemplar_AposDevolucao`
**Tipo:** AFTER UPDATE  
**Tabela:** Emprestimos  
**Propósito:** Atualizar status do exemplar para 'Disponível' quando data_devolucao_real for preenchida

**Lógica:**
1. Após atualizar um empréstimo:
   - Verificar se OLD.data_devolucao_real IS NULL (estava ativo)
   - E NEW.data_devolucao_real IS NOT NULL (acabou de ser devolvido)
2. Se condição verdadeira:
   - Atualizar Exemplares SET status = 'Disponível' WHERE id_exemplar = NEW.id_exemplar
3. Manter sincronia entre devolução e disponibilidade

**Código base:**
```sql
CREATE TRIGGER trg_AtualizarStatusExemplar_AposDevolucao
AFTER UPDATE ON Emprestimos
FOR EACH ROW
BEGIN
    -- Detecta devolução (data_devolucao_real foi preenchida)
    IF OLD.data_devolucao_real IS NULL AND NEW.data_devolucao_real IS NOT NULL THEN
        UPDATE Exemplares
        SET status = 'Disponível'
        WHERE id_exemplar = NEW.id_exemplar;
    END IF;
END;
```

---

## 🎯 TRIGGERS ADICIONAIS (Recomendados)

### 4. `trg_ValidarLimiteEmprestimos` (Bônus)
**Tipo:** BEFORE INSERT  
**Tabela:** Emprestimos  
**Propósito:** Bloquear empréstimo se usuário já atingiu limite do seu tipo

**Lógica:**
1. Contar empréstimos ativos do usuário (NEW.id_usuario)
2. Buscar max_emprestimos do TipoUsuario do usuário
3. Se contagem >= limite:
   - SIGNAL erro bloqueando inserção

---

### 5. `trg_ValidarMultasAntesEmprestimo` (Bônus)
**Tipo:** BEFORE INSERT  
**Tabela:** Emprestimos  
**Propósito:** Bloquear empréstimo se usuário tem multas pendentes

**Lógica:**
1. Verificar se existe registro em Multas com:
   - Empréstimo do usuário NEW.id_usuario
   - status_pagamento = 'Pendente'
2. Se existir multa pendente:
   - SIGNAL erro com mensagem "Usuário possui multas pendentes"

---

### 6. `trg_LogAlteracaoUsuario` (Bônus - Auditoria)
**Tipo:** AFTER UPDATE  
**Tabela:** Usuarios  
**Propósito:** Registrar alterações em dados de usuários em tabela de log

**Pré-requisito:** Criar tabela auxiliar:
```sql
CREATE TABLE LogUsuarios (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT,
    campo_alterado VARCHAR(50),
    valor_antigo TEXT,
    valor_novo TEXT,
    data_alteracao DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Lógica:**
- Detectar alterações em campos críticos (email, telefone, status)
- Inserir registro de log para cada campo alterado

---

### 7. `trg_PrevenirDeleteComEmprestimo` (Bônus - Segurança)
**Tipo:** BEFORE DELETE  
**Tabela:** Exemplares  
**Propósito:** Impedir exclusão de exemplar que tem empréstimos ativos

**Lógica:**
1. Verificar se exemplar (OLD.id_exemplar) tem empréstimos com status = 'Ativo'
2. Se sim, SIGNAL erro bloqueando delete
3. Prevenir perda de integridade referencial

---

## 📐 ESPECIFICAÇÕES TÉCNICAS

### Estrutura Padrão de Trigger:
```sql
DELIMITER $$

CREATE TRIGGER nome_trigger
{BEFORE | AFTER} {INSERT | UPDATE | DELETE} ON nome_tabela
FOR EACH ROW
BEGIN
    -- Declaração de variáveis (se necessário)
    DECLARE v_variavel TIPO;
    
    -- Lógica do trigger
    -- Usar NEW.campo para valores novos
    -- Usar OLD.campo para valores antigos
    
    -- Para bloquear operação:
    -- SIGNAL SQLSTATE '45000'
    -- SET MESSAGE_TEXT = 'Mensagem de erro';
END$$

DELIMITER ;
```

### Boas Práticas Obrigatórias:
1. ✅ Usar nomes descritivos que indicam momento e ação (ex: `trg_AposInserir_NomeTabela`)
2. ✅ Comentar propósito do trigger
3. ✅ Usar SIGNAL para bloquear operações inválidas em BEFORE triggers
4. ✅ Evitar lógica complexa/pesada em triggers (performance)
5. ✅ Não chamar procedures que usam transações dentro de triggers
6. ✅ Testar triggers com casos normais E casos de exceção
7. ✅ Documentar efeitos colaterais (ex: "este trigger atualiza tabela X")

### Uso de NEW e OLD:
- **BEFORE/AFTER INSERT:** Apenas `NEW.*` disponível
- **BEFORE/AFTER UPDATE:** Ambos `NEW.*` e `OLD.*` disponíveis
- **BEFORE/AFTER DELETE:** Apenas `OLD.*` disponível

### Quando Usar BEFORE vs AFTER:
- **BEFORE:** Para validações e bloqueios (SIGNAL)
- **AFTER:** Para efeitos colaterais e sincronizações

---

## 🎯 REQUISITOS DO SCRIPT A GERAR

### Estrutura do Arquivo:
```sql
-- Cabeçalho com informações
-- Seção 1: Triggers de Validação (BEFORE)
--   - trg_ValidarDisponibilidadeEmprestimo
--   - [outros BEFORE triggers]
-- Seção 2: Triggers de Sincronização (AFTER)
--   - trg_AtualizarStatusExemplar_AposEmprestimo
--   - trg_AtualizarStatusExemplar_AposDevolucao
--   - [outros AFTER triggers]
-- Seção 3: Triggers de Auditoria (se implementados)
-- Seção 4: Exemplos de teste dos triggers
```

### Características Obrigatórias:
1. ✅ Mínimo 3 triggers implementados (os obrigatórios)
2. ✅ Cada trigger com comentário explicando:
   - Propósito
   - Momento de execução (BEFORE/AFTER)
   - Evento (INSERT/UPDATE/DELETE)
   - Efeitos colaterais
3. ✅ Uso correto de SIGNAL para bloqueios
4. ✅ Código indentado e legível
5. ✅ Testes de exemplo comentados ao final

---

## 📤 FORMATO DE SAÍDA ESPERADO

**Nome do arquivo:** `04_triggers.sql`

**Estrutura:**
- Comentários explicativos para cada trigger
- Organizado por tipo (validação, sincronização, auditoria)
- Exemplos de teste incluídos
- Pronto para executar após scripts anteriores

---

## ✅ CHECKLIST DE VALIDAÇÃO

Antes de considerar completo, verificar:
- [ ] 3 triggers obrigatórios implementados
- [ ] Triggers BEFORE usam SIGNAL para bloquear operações inválidas
- [ ] Triggers AFTER realizam sincronizações necessárias
- [ ] Código compilável sem erros de sintaxe
- [ ] Cada trigger tem comentário explicativo
- [ ] Exemplos de teste fornecidos demonstrando:
  - [ ] Trigger bloqueando operação inválida
  - [ ] Trigger permitindo operação válida
  - [ ] Efeitos colaterais funcionando

---

## 💡 DICAS DE IMPLEMENTAÇÃO

### Template de Trigger com Validação:
```sql
DELIMITER $$

CREATE TRIGGER trg_ValidarAlgo
BEFORE INSERT ON Tabela
FOR EACH ROW
BEGIN
    DECLARE v_valido BOOLEAN DEFAULT FALSE;
    
    -- Lógica de validação
    SELECT (condição) INTO v_valido FROM ...;
    
    IF NOT v_valido THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Descrição do erro';
    END IF;
END$$

DELIMITER ;
```

### Template de Trigger com Sincronização:
```sql
DELIMITER $$

CREATE TRIGGER trg_SincronizarAlgo
AFTER INSERT ON Tabela
FOR EACH ROW
BEGIN
    -- Atualização automática
    UPDATE TabelaRelacionada
    SET campo = valor
    WHERE id = NEW.id_relacionado;
END$$

DELIMITER ;
```

### Exemplo de Teste:
```sql
-- Teste 1: Tentar emprestar exemplar indisponível (deve falhar)
-- UPDATE Exemplares SET status = 'Manutenção' WHERE id_exemplar = 1;
-- INSERT INTO Emprestimos (id_usuario, id_exemplar, data_prevista_devolucao)
-- VALUES (1, 1, DATE_ADD(CURDATE(), INTERVAL 14 DAY));
-- Resultado esperado: ERROR 1644 (45000): Exemplar não está disponível

-- Teste 2: Emprestar exemplar disponível (deve funcionar)
-- UPDATE Exemplares SET status = 'Disponível' WHERE id_exemplar = 1;
-- INSERT INTO Emprestimos ... (mesmo comando)
-- Resultado esperado: Sucesso + status do exemplar muda para 'Emprestado'
```

---

## 🚨 CUIDADOS IMPORTANTES

### Evitar:
1. ❌ Triggers recursivos (trigger A chama B que chama A)
2. ❌ Lógica pesada que degrada performance
3. ❌ Múltiplas atualizações na mesma tabela do evento
4. ❌ Procedures com transações dentro de triggers

### Priorizar:
1. ✅ Validações simples e rápidas
2. ✅ Sincronizações diretas
3. ✅ Mensagens de erro claras
4. ✅ Testabilidade

---

## 🚀 PROMPT PARA IA

**"Gere os triggers seguindo todas as especificações acima. O código deve ser eficiente, com validações claras, mensagens de erro descritivas e comentários explicativos. Inclua exemplos de teste para cada trigger."**
