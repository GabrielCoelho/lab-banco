-- ============================================================================
-- SISTEMA DE GERENCIAMENTO DE BIBLIOTECA UNIVERSITÁRIA (SGBU)
-- TRIGGERS (GATILHOS AUTOMÁTICOS)
-- ============================================================================
-- Disciplina: Banco de Dados 2
-- Estudante: Gabriel Coelho Soares
-- SGBD: MySQL 8.0+ / MariaDB 10.5+
-- ============================================================================

USE biblioteca_universitaria;

-- ============================================================================
-- SEÇÃO 1: TRIGGERS DE VALIDAÇÃO (BEFORE)
-- ============================================================================

-- Trigger 1: Validar disponibilidade do exemplar antes de emprestar
-- Bloqueia empréstimo se exemplar não estiver disponível

DROP TRIGGER IF EXISTS trg_ValidarDisponibilidadeEmprestimo;

DELIMITER $$

CREATE TRIGGER trg_ValidarDisponibilidadeEmprestimo
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT status INTO v_status
    FROM Exemplares
    WHERE id_exemplar = NEW.id_exemplar;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Exemplar não encontrado';
    END IF;

    IF v_status != 'Disponível' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Exemplar não está disponível para empréstimo';
    END IF;
END$$

DELIMITER ;

-- Trigger 2: Validar limite de empréstimos simultâneos
-- Bloqueia se usuário já atingiu o limite do seu tipo

DROP TRIGGER IF EXISTS trg_ValidarLimiteEmprestimos;

DELIMITER $$

CREATE TRIGGER trg_ValidarLimiteEmprestimos
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    DECLARE v_emprestimos_ativos INT;
    DECLARE v_max_emprestimos INT;

    -- Contar empréstimos ativos do usuário
    SELECT COUNT(*) INTO v_emprestimos_ativos
    FROM Emprestimos
    WHERE id_usuario = NEW.id_usuario
    AND status_emprestimo = 'Ativo';

    -- Buscar limite do tipo de usuário
    SELECT tu.max_emprestimos INTO v_max_emprestimos
    FROM TiposUsuario tu
    JOIN Usuarios u ON u.id_tipo_usuario = tu.id_tipo_usuario
    WHERE u.id_usuario = NEW.id_usuario;

    IF v_emprestimos_ativos >= v_max_emprestimos THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Limite de empréstimos simultâneos atingido';
    END IF;
END$$

DELIMITER ;

-- Trigger 3: Validar se usuário tem multas pendentes
-- Bloqueia empréstimo se houver multas não pagas

DROP TRIGGER IF EXISTS trg_ValidarMultasAntesEmprestimo;

DELIMITER $$

CREATE TRIGGER trg_ValidarMultasAntesEmprestimo
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    DECLARE v_multas_pendentes INT;

    SELECT COUNT(*) INTO v_multas_pendentes
    FROM Multas m
    JOIN Emprestimos e ON m.id_emprestimo = e.id_emprestimo
    WHERE e.id_usuario = NEW.id_usuario
    AND m.status_pagamento = 'Pendente';

    IF v_multas_pendentes > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário possui multas pendentes';
    END IF;
END$$

DELIMITER ;

-- Trigger 4: Validar status do usuário
-- Bloqueia empréstimo se usuário não estiver ativo

DROP TRIGGER IF EXISTS trg_ValidarStatusUsuario;

DELIMITER $$

CREATE TRIGGER trg_ValidarStatusUsuario
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    DECLARE v_status_usuario VARCHAR(20);

    SELECT status INTO v_status_usuario
    FROM Usuarios
    WHERE id_usuario = NEW.id_usuario;

    IF v_status_usuario != 'Ativo' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário não está ativo no sistema';
    END IF;
END$$

DELIMITER ;

-- Trigger 5: Prevenir exclusão de exemplar com empréstimo ativo
-- Protege integridade referencial

DROP TRIGGER IF EXISTS trg_PrevenirDeleteComEmprestimo;

DELIMITER $$

CREATE TRIGGER trg_PrevenirDeleteComEmprestimo
BEFORE DELETE ON Exemplares
FOR EACH ROW
BEGIN
    DECLARE v_emprestimos_ativos INT;

    SELECT COUNT(*) INTO v_emprestimos_ativos
    FROM Emprestimos
    WHERE id_exemplar = OLD.id_exemplar
    AND status_emprestimo = 'Ativo';

    IF v_emprestimos_ativos > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível excluir exemplar com empréstimos ativos';
    END IF;
END$$

DELIMITER ;

-- ============================================================================
-- SEÇÃO 2: TRIGGERS DE SINCRONIZAÇÃO (AFTER)
-- ============================================================================

-- Trigger 6: Atualizar status do exemplar após empréstimo
-- Sincroniza automaticamente status para 'Emprestado'

DROP TRIGGER IF EXISTS trg_AtualizarStatusExemplar_AposEmprestimo;

DELIMITER $$

CREATE TRIGGER trg_AtualizarStatusExemplar_AposEmprestimo
AFTER INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    UPDATE Exemplares
    SET status = 'Emprestado'
    WHERE id_exemplar = NEW.id_exemplar;
END$$

DELIMITER ;

-- Trigger 7: Atualizar status do exemplar após devolução
-- Sincroniza status para 'Disponível' quando livro é devolvido

DROP TRIGGER IF EXISTS trg_AtualizarStatusExemplar_AposDevolucao;

DELIMITER $$

CREATE TRIGGER trg_AtualizarStatusExemplar_AposDevolucao
AFTER UPDATE ON Emprestimos
FOR EACH ROW
BEGIN
    DECLARE v_tem_reserva INT;
    DECLARE v_id_livro INT;

    -- Detecta devolução (data_devolucao_real foi preenchida)
    IF OLD.data_devolucao_real IS NULL AND NEW.data_devolucao_real IS NOT NULL THEN

        -- Buscar livro do exemplar
        SELECT id_livro INTO v_id_livro
        FROM Exemplares
        WHERE id_exemplar = NEW.id_exemplar;

        -- Verificar se há reservas ativas
        SELECT COUNT(*) INTO v_tem_reserva
        FROM Reservas
        WHERE id_livro = v_id_livro
        AND status_reserva = 'Ativa'
        LIMIT 1;

        -- Se houver reserva, marcar como Reservado; senão, Disponível
        IF v_tem_reserva > 0 THEN
            UPDATE Exemplares
            SET status = 'Reservado'
            WHERE id_exemplar = NEW.id_exemplar;
        ELSE
            UPDATE Exemplares
            SET status = 'Disponível'
            WHERE id_exemplar = NEW.id_exemplar;
        END IF;
    END IF;
END$$

DELIMITER ;

-- ============================================================================
-- SEÇÃO 3: TRIGGERS DE AUDITORIA
-- ============================================================================

-- Tabela auxiliar para auditoria de usuários
DROP TABLE IF EXISTS LogUsuarios;

CREATE TABLE LogUsuarios (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    campo_alterado VARCHAR(50),
    valor_antigo TEXT,
    valor_novo TEXT,
    data_alteracao DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Trigger 8: Registrar alterações em dados de usuários
-- Auditoria de mudanças em campos críticos

DROP TRIGGER IF EXISTS trg_LogAlteracaoUsuario;

DELIMITER $$

CREATE TRIGGER trg_LogAlteracaoUsuario
AFTER UPDATE ON Usuarios
FOR EACH ROW
BEGIN
    -- Log de alteração de email
    IF OLD.email != NEW.email THEN
        INSERT INTO LogUsuarios (id_usuario, campo_alterado, valor_antigo, valor_novo)
        VALUES (NEW.id_usuario, 'email', OLD.email, NEW.email);
    END IF;

    -- Log de alteração de telefone
    IF OLD.telefone != NEW.telefone OR (OLD.telefone IS NULL AND NEW.telefone IS NOT NULL) THEN
        INSERT INTO LogUsuarios (id_usuario, campo_alterado, valor_antigo, valor_novo)
        VALUES (NEW.id_usuario, 'telefone', OLD.telefone, NEW.telefone);
    END IF;

    -- Log de alteração de status
    IF OLD.status != NEW.status THEN
        INSERT INTO LogUsuarios (id_usuario, campo_alterado, valor_antigo, valor_novo)
        VALUES (NEW.id_usuario, 'status', OLD.status, NEW.status);
    END IF;
END$$

DELIMITER ;

-- ============================================================================
-- EXEMPLOS DE TESTE
-- ============================================================================

-- Teste 1: Tentar emprestar exemplar indisponível (deve BLOQUEAR)
-- UPDATE Exemplares SET status = 'Manutenção' WHERE id_exemplar = 10;
-- INSERT INTO Emprestimos (id_usuario, id_exemplar, data_prevista_devolucao)
-- VALUES (1, 10, DATE_ADD(CURDATE(), INTERVAL 14 DAY));
-- Resultado esperado: ERROR 1644 (45000): Exemplar não está disponível

-- Teste 2: Emprestar exemplar disponível (deve FUNCIONAR)
-- UPDATE Exemplares SET status = 'Disponível' WHERE id_exemplar = 10;
-- INSERT INTO Emprestimos (id_usuario, id_exemplar, data_prevista_devolucao, status_emprestimo)
-- VALUES (1, 10, DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'Ativo');
-- SELECT status FROM Exemplares WHERE id_exemplar = 10;
-- Resultado esperado: Status mudou para 'Emprestado' automaticamente

-- Teste 3: Tentar emprestar com multas pendentes (deve BLOQUEAR)
-- Primeiro garanta que usuário 13 tem multa pendente (veja dados inseridos)
-- INSERT INTO Emprestimos (id_usuario, id_exemplar, data_prevista_devolucao)
-- VALUES (13, 10, DATE_ADD(CURDATE(), INTERVAL 14 DAY));
-- Resultado esperado: ERROR 1644 (45000): Usuário possui multas pendentes

-- Teste 4: Simular devolução (deve atualizar status para Disponível)
-- UPDATE Emprestimos SET data_devolucao_real = NOW() WHERE id_emprestimo = 1;
-- SELECT status FROM Exemplares WHERE id_exemplar IN (SELECT id_exemplar FROM Emprestimos WHERE id_emprestimo = 1);
-- Resultado esperado: Status volta para 'Disponível'

-- Teste 5: Auditoria de alteração de usuário
-- UPDATE Usuarios SET email = 'novo.email@email.com' WHERE id_usuario = 1;
-- SELECT * FROM LogUsuarios WHERE id_usuario = 1 ORDER BY data_alteracao DESC;
-- Resultado esperado: Registro de log com valor antigo e novo

-- Teste 6: Tentar deletar exemplar emprestado (deve BLOQUEAR)
-- DELETE FROM Exemplares WHERE id_exemplar = 2;
-- Resultado esperado: ERROR 1644 (45000): Não é possível excluir exemplar com empréstimos ativos
