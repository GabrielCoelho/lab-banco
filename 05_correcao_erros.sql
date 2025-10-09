-- Objetivo: Identificar pelo menos 3 erros no código de procedure e trigger
-- fornecidos e fornecer o código SQL corrigido completo
-- ============================================================================
-- CÓDIGO ORIGINAL COM ERROS
-- ============================================================================
/*
DELIMITER //
CREATE PROCEDURE InserirNota (
IN p_id_matricula INT
IN p_valor_nota REAL,
OUT p_mensagem VARCHAR(255)
)
BEGIN
IF p_valor_nota > 10 THEN
SET p_mensagem = 'Nota inválida!';
SIGNAL SQLSTATE '45000' MESSAGE_TEXT = p_mensagem;
ELSE
INSERT INTO Notas (id_matricula valor_nota) VALUES (p_id_matricula, p_valor_nota);
SET p_mensagem = 'Nota inserida!';
END IF
END //
DELIMITER ;

-- Trigger implícito (errado)
CREATE TRIGGER LogNota AFTER INSERT ON Notas
BEGIN
INSERT INTO LogNotas (mensagem) VALUES ('Nova nota inserida');
END;
*/

-- ============================================================================
-- IDENTIFICAÇÃO DOS ERROS - STORED PROCEDURE
-- ============================================================================
-- ERRO 1: Falta vírgula após o primeiro parâmetro IN
  -- ❌ IN p_id_matricula INT
  -- ❌ IN p_valor_nota REAL,
  -- ✅ IN p_id_matricula INT,
-- Explicação: Entre os parâmetros deve haver vírgula separadora

-- ERRO 2: Validação incompleta do valor da nota
  -- ❌ IF p_valor_nota > 10 THEN
  -- ✅ IF p_valor_nota > 10.0 OR p_valor_nota < 0.0 THEN
-- Explicação: Deve validar TANTO limite superior (>10) QUANTO inferior (<0)

-- ERRO 3: Uso inadequado de SIGNAL com parâmetro OUT
  -- ❌ SIGNAL SQLSTATE '45000' MESSAGE_TEXT = p_mensagem;
  -- ✅ Não usar SIGNAL quando há parâmetro OUT (apenas SET p_mensagem)
-- Explicação: SIGNAL aborta a procedure imediatamente, impedindo que o
-- parâmetro OUT retorne a mensagem corretamente. Além disso, a sintaxe
-- correta seria SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT (com SET)

-- ERRO 4: Falta vírgula no INSERT da procedure
  -- ❌ INSERT INTO Notas (id_matricula valor_nota)
  -- ✅ INSERT INTO Notas (id_matricula, valor_nota)
-- Explicação: Campos devem ser separados por vírgula

-- ERRO 5: Falta ponto-e-vírgula após END IF
  -- ❌ END IF
  -- ✅ END IF;
-- Explicação: Comandos dentro de procedures devem terminar com ;

-- ============================================================================
-- IDENTIFICAÇÃO DOS ERROS - TRIGGER
-- ============================================================================
-- ERRO 6: Falta DELIMITER antes do CREATE TRIGGER
  -- Problema: Trigger não está usando DELIMITER //
-- Explicação: Triggers com múltiplas instruções precisam de DELIMITER

-- ERRO 7: Falta FOR EACH ROW no trigger
  -- ❌ CREATE TRIGGER LogNota AFTER INSERT ON Notas
  -- ✅ CREATE TRIGGER LogNota AFTER INSERT ON Notas FOR EACH ROW
-- Explicação: MySQL exige FOR EACH ROW em triggers

-- ERRO 8: Trigger termina com ; ao invés de //
  -- ❌ END;
  -- ✅ END //
-- Explicação: Com DELIMITER //, o trigger deve terminar com //

-- ERRO 9: Tabela LogNotas provavelmente não existe
  -- Problema: Código assume existência de tabela LogNotas
-- Solução: Criar a tabela antes de usar o trigger

-- ============================================================================
-- PREPARAÇÃO: Criar tabela LogNotas necessária para o trigger
-- ============================================================================
DROP TABLE IF EXISTS LogNotas;

CREATE TABLE LogNotas (
    id_log INTEGER PRIMARY KEY AUTO_INCREMENT,
    mensagem TEXT NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CÓDIGO CORRIGIDO - STORED PROCEDURE
-- ============================================================================
DROP PROCEDURE IF EXISTS InserirNota;

DELIMITER //

CREATE PROCEDURE InserirNota (
    IN p_id_matricula INT,           -- CORREÇÃO 1: Vírgula adicionada
    IN p_valor_nota REAL,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    -- CORREÇÃO 2: Validação completa (limite superior E inferior)
    IF p_valor_nota > 10.0 OR p_valor_nota < 0.0 THEN
        -- CORREÇÃO 3: Quando usamos OUT, NÃO devemos usar SIGNAL
        -- SIGNAL aborta a procedure e impede que OUT seja lido corretamente
        SET p_mensagem = 'ERRO: Nota inválida! Valor deve estar entre 0.0 e 10.0';
    ELSE
        -- CORREÇÃO 4: Vírgula entre os campos do INSERT
        INSERT INTO Notas (id_matricula, valor_nota)
        VALUES (p_id_matricula, p_valor_nota);
        SET p_mensagem = 'SUCESSO: Nota inserida!';
    END IF;  -- CORREÇÃO 5: Ponto-e-vírgula adicionado

END //

DELIMITER ;

-- ============================================================================
-- CÓDIGO CORRIGIDO - TRIGGER
-- ============================================================================
DROP TRIGGER IF EXISTS LogNota;

-- CORREÇÃO 6: DELIMITER // antes do CREATE TRIGGER
DELIMITER //

-- CORREÇÃO 7: FOR EACH ROW adicionado
CREATE TRIGGER LogNota
AFTER INSERT ON Notas
FOR EACH ROW
BEGIN
    -- CORREÇÃO 9: Usando tabela LogNotas que foi criada
    -- Também registramos informações úteis sobre a nota inserida
    INSERT INTO LogNotas (mensagem)
    VALUES (CONCAT('Nova nota inserida: ID=', NEW.id_nota,
                   ', Matrícula=', NEW.id_matricula,
                   ', Valor=', NEW.valor_nota));
END //  -- CORREÇÃO 8: Termina com // ao invés de ;

DELIMITER ;

-- ============================================================================
-- EXEMPLOS DE USO - TESTANDO AS CORREÇÕES
-- ============================================================================

-- ----------------------------------------
-- TESTE 1: Inserção VÁLIDA com nota 8.5
-- ----------------------------------------
-- Resultado esperado: Sucesso, nota inserida e log registrado
CALL InserirNota(1, 8.5, @msg);
SELECT @msg AS Mensagem;

-- Verificar se o log foi criado
SELECT * FROM LogNotas ORDER BY id_log DESC LIMIT 1;

-- ----------------------------------------
-- TESTE 2: Inserção VÁLIDA no limite inferior (0.0)
-- ----------------------------------------
-- Resultado esperado: Sucesso
CALL InserirNota(2, 0.0, @msg);
SELECT @msg AS Mensagem;

-- ----------------------------------------
-- TESTE 3: Inserção VÁLIDA no limite superior (10.0)
-- ----------------------------------------
-- Resultado esperado: Sucesso
CALL InserirNota(3, 10.0, @msg);
SELECT @msg AS Mensagem;

-- ----------------------------------------
-- TESTE 4: Inserção INVÁLIDA (nota > 10)
-- ----------------------------------------
-- Resultado esperado: ERRO - Nota inválida
CALL InserirNota(1, 10.5, @msg);
SELECT @msg AS Mensagem;

-- ----------------------------------------
-- TESTE 5: Inserção INVÁLIDA (nota < 0)
-- ----------------------------------------
-- Resultado esperado: ERRO - Nota inválida
-- (Este erro NÃO seria detectado no código original!)
CALL InserirNota(1, -2.0, @msg);
SELECT @msg AS Mensagem;

-- ----------------------------------------
-- TESTE 6: Verificar todos os logs gerados
-- ----------------------------------------
-- Resultado esperado: Lista de todos os logs criados pelo trigger
SELECT * FROM LogNotas ORDER BY data_hora DESC;

-- ----------------------------------------
-- TESTE 7: Inserção direta (não pela procedure) para testar trigger
-- ----------------------------------------
-- O trigger deve funcionar independente de como a nota é inserida
INSERT INTO Notas (id_matricula, valor_nota, tipo_avaliacao)
VALUES (5, 7.5, 'Prova Final');

-- Verificar o log gerado
SELECT * FROM LogNotas ORDER BY id_log DESC LIMIT 1;
