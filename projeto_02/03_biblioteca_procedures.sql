-- ============================================================================
-- SISTEMA DE GERENCIAMENTO DE BIBLIOTECA UNIVERSITÁRIA (SGBU)
-- STORED PROCEDURES
-- ============================================================================
-- Disciplina: Banco de Dados 2
-- Estudante: Gabriel Coelho Soares
-- SGBD: MySQL 8.0+ / MariaDB 10.5+
-- ============================================================================

USE biblioteca_universitaria;

-- ============================================================================
-- PROCEDURE 1: REALIZAR EMPRÉSTIMO
-- ============================================================================
-- Propósito: Registrar novo empréstimo com validações completas
-- Validações: usuário ativo, sem multas, limite de empréstimos, exemplar disponível

DROP PROCEDURE IF EXISTS sp_RealizarEmprestimo;

DELIMITER $$

CREATE PROCEDURE sp_RealizarEmprestimo(
    IN p_id_usuario INT,
    IN p_id_exemplar INT,
    OUT p_sucesso BOOLEAN,
    OUT p_mensagem VARCHAR(200)
)
sp_RealizarEmprestimo: BEGIN
    DECLARE v_status_usuario VARCHAR(20);
    DECLARE v_multas_pendentes INT;
    DECLARE v_emprestimos_ativos INT;
    DECLARE v_max_emprestimos INT;
    DECLARE v_prazo_dias INT;
    DECLARE v_status_exemplar VARCHAR(20);
    DECLARE v_data_prevista DATE;

    -- Handler para erros
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_sucesso = FALSE;
        SET p_mensagem = 'Erro ao processar empréstimo';
    END;

    START TRANSACTION;

    -- Validação 1: Verificar se usuário existe e está ativo
    SELECT status INTO v_status_usuario
    FROM Usuarios
    WHERE id_usuario = p_id_usuario;

    IF v_status_usuario IS NULL THEN
        SET p_sucesso = FALSE;
        SET p_mensagem = 'Usuário não encontrado';
        ROLLBACK;
        LEAVE sp_RealizarEmprestimo;
    END IF;

    IF v_status_usuario != 'Ativo' THEN
        SET p_sucesso = FALSE;
        SET p_mensagem = 'Usuário não está ativo';
        ROLLBACK;
        LEAVE sp_RealizarEmprestimo;
    END IF;

    -- Validação 2: Verificar se usuário tem multas pendentes
    SELECT COUNT(*) INTO v_multas_pendentes
    FROM Multas m
    JOIN Emprestimos e ON m.id_emprestimo = e.id_emprestimo
    WHERE e.id_usuario = p_id_usuario
    AND m.status_pagamento = 'Pendente';

    IF v_multas_pendentes > 0 THEN
        SET p_sucesso = FALSE;
        SET p_mensagem = 'Usuário possui multas pendentes';
        ROLLBACK;
        LEAVE sp_RealizarEmprestimo;
    END IF;

    -- Validação 3: Verificar limite de empréstimos simultâneos
    SELECT COUNT(*) INTO v_emprestimos_ativos
    FROM Emprestimos
    WHERE id_usuario = p_id_usuario
    AND status_emprestimo = 'Ativo';

    SELECT tu.max_emprestimos, tu.prazo_dias
    INTO v_max_emprestimos, v_prazo_dias
    FROM TiposUsuario tu
    JOIN Usuarios u ON u.id_tipo_usuario = tu.id_tipo_usuario
    WHERE u.id_usuario = p_id_usuario;

    IF v_emprestimos_ativos >= v_max_emprestimos THEN
        SET p_sucesso = FALSE;
        SET p_mensagem = 'Limite de empréstimos simultâneos atingido';
        ROLLBACK;
        LEAVE sp_RealizarEmprestimo;
    END IF;

    -- Validação 4: Verificar se exemplar existe e está disponível
    SELECT status INTO v_status_exemplar
    FROM Exemplares
    WHERE id_exemplar = p_id_exemplar;

    IF v_status_exemplar IS NULL THEN
        SET p_sucesso = FALSE;
        SET p_mensagem = 'Exemplar não encontrado';
        ROLLBACK;
        LEAVE sp_RealizarEmprestimo;
    END IF;

    IF v_status_exemplar != 'Disponível' THEN
        SET p_sucesso = FALSE;
        SET p_mensagem = 'Exemplar não está disponível';
        ROLLBACK;
        LEAVE sp_RealizarEmprestimo;
    END IF;

    -- Calcular data prevista de devolução
    SET v_data_prevista = DATE_ADD(CURDATE(), INTERVAL v_prazo_dias DAY);

    -- Inserir empréstimo
    INSERT INTO Emprestimos (id_usuario, id_exemplar, data_emprestimo, data_prevista_devolucao, status_emprestimo)
    VALUES (p_id_usuario, p_id_exemplar, NOW(), v_data_prevista, 'Ativo');

    -- Atualizar status do exemplar
    UPDATE Exemplares
    SET status = 'Emprestado'
    WHERE id_exemplar = p_id_exemplar;

    COMMIT;

    SET p_sucesso = TRUE;
    SET p_mensagem = CONCAT('Empréstimo realizado com sucesso. Devolução prevista: ', v_data_prevista);

END sp_RealizarEmprestimo$$

DELIMITER ;

-- ============================================================================
-- PROCEDURE 2: REALIZAR DEVOLUÇÃO
-- ============================================================================
-- Propósito: Processar devolução e gerar multa se houver atraso
-- Cálculo: R$ 2,00 por dia de atraso

DROP PROCEDURE IF EXISTS sp_RealizarDevolucao;

DELIMITER $$

CREATE PROCEDURE sp_RealizarDevolucao(
    IN p_id_emprestimo INT,
    OUT p_sucesso BOOLEAN,
    OUT p_valor_multa DECIMAL(10,2),
    OUT p_mensagem VARCHAR(200)
)
sp_RealizarDevolucao: BEGIN
    DECLARE v_status_emprestimo VARCHAR(20);
    DECLARE v_id_exemplar INT;
    DECLARE v_id_livro INT;
    DECLARE v_data_prevista DATE;
    DECLARE v_dias_atraso INT;
    DECLARE v_tem_reserva INT;

    -- Handler para erros
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_sucesso = FALSE;
        SET p_mensagem = 'Erro ao processar devolução';
    END;

    START TRANSACTION;

    -- Validação: Verificar se empréstimo existe e está ativo
    SELECT status_emprestimo, id_exemplar, data_prevista_devolucao
    INTO v_status_emprestimo, v_id_exemplar, v_data_prevista
    FROM Emprestimos
    WHERE id_emprestimo = p_id_emprestimo;

    IF v_status_emprestimo IS NULL THEN
        SET p_sucesso = FALSE;
        SET p_mensagem = 'Empréstimo não encontrado';
        ROLLBACK;
        LEAVE sp_RealizarDevolucao;
    END IF;

    IF v_status_emprestimo != 'Ativo' THEN
        SET p_sucesso = FALSE;
        SET p_mensagem = 'Empréstimo não está ativo';
        ROLLBACK;
        LEAVE sp_RealizarDevolucao;
    END IF;

    -- Registrar data de devolução
    UPDATE Emprestimos
    SET data_devolucao_real = NOW()
    WHERE id_emprestimo = p_id_emprestimo;

    -- Calcular dias de atraso
    SET v_dias_atraso = DATEDIFF(CURDATE(), v_data_prevista);

    -- Processar atraso se houver
    IF v_dias_atraso > 0 THEN
        SET p_valor_multa = v_dias_atraso * 2.00;

        -- Inserir multa
        INSERT INTO Multas (id_emprestimo, valor_multa, dias_atraso, status_pagamento)
        VALUES (p_id_emprestimo, p_valor_multa, v_dias_atraso, 'Pendente');

        -- Atualizar status do empréstimo
        UPDATE Emprestimos
        SET status_emprestimo = 'Atrasado'
        WHERE id_emprestimo = p_id_emprestimo;

        SET p_mensagem = CONCAT('Devolução com atraso. Multa: R$ ', p_valor_multa);
    ELSE
        SET p_valor_multa = 0.00;

        -- Atualizar status do empréstimo
        UPDATE Emprestimos
        SET status_emprestimo = 'Devolvido'
        WHERE id_emprestimo = p_id_emprestimo;

        SET p_mensagem = 'Devolução realizada sem atraso';
    END IF;

    -- Buscar id do livro
    SELECT id_livro INTO v_id_livro
    FROM Exemplares
    WHERE id_exemplar = v_id_exemplar;

    -- Verificar se há reservas ativas para este livro
    SELECT COUNT(*) INTO v_tem_reserva
    FROM Reservas
    WHERE id_livro = v_id_livro
    AND status_reserva = 'Ativa'
    LIMIT 1;

    -- Atualizar status do exemplar
    IF v_tem_reserva > 0 THEN
        UPDATE Exemplares
        SET status = 'Reservado'
        WHERE id_exemplar = v_id_exemplar;

        SET p_mensagem = CONCAT(p_mensagem, '. Exemplar reservado para próximo usuário');
    ELSE
        UPDATE Exemplares
        SET status = 'Disponível'
        WHERE id_exemplar = v_id_exemplar;
    END IF;

    COMMIT;

    SET p_sucesso = TRUE;

END sp_RealizarDevolucao$$

DELIMITER ;

-- ============================================================================
-- PROCEDURE 3: CALCULAR MULTAS ATRASADAS
-- ============================================================================
-- Propósito: Processar empréstimos vencidos e gerar multas pendentes
-- Executar diariamente via scheduler

DROP PROCEDURE IF EXISTS sp_CalcularMultasAtrasadas;

DELIMITER $$

CREATE PROCEDURE sp_CalcularMultasAtrasadas(
    OUT p_total_multas_geradas INT,
    OUT p_valor_total DECIMAL(10,2)
)
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_id_emprestimo INT;
    DECLARE v_data_prevista DATE;
    DECLARE v_dias_atraso INT;
    DECLARE v_valor_multa DECIMAL(10,2);
    DECLARE v_multa_existe INT;

    -- Cursor para empréstimos atrasados
    DECLARE cur_atrasados CURSOR FOR
        SELECT id_emprestimo, data_prevista_devolucao
        FROM Emprestimos
        WHERE status_emprestimo = 'Ativo'
        AND data_prevista_devolucao < CURDATE();

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Handler para erros
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_total_multas_geradas = 0;
        SET p_valor_total = 0.00;
    END;

    START TRANSACTION;

    SET p_total_multas_geradas = 0;
    SET p_valor_total = 0.00;

    OPEN cur_atrasados;

    loop_atrasados: LOOP
        FETCH cur_atrasados INTO v_id_emprestimo, v_data_prevista;

        IF v_done THEN
            LEAVE loop_atrasados;
        END IF;

        -- Verificar se já existe multa para este empréstimo
        SELECT COUNT(*) INTO v_multa_existe
        FROM Multas
        WHERE id_emprestimo = v_id_emprestimo;

        -- Gerar multa apenas se não existir
        IF v_multa_existe = 0 THEN
            SET v_dias_atraso = DATEDIFF(CURDATE(), v_data_prevista);
            SET v_valor_multa = v_dias_atraso * 2.00;

            -- Inserir multa
            INSERT INTO Multas (id_emprestimo, valor_multa, dias_atraso, status_pagamento)
            VALUES (v_id_emprestimo, v_valor_multa, v_dias_atraso, 'Pendente');

            -- Atualizar status do empréstimo
            UPDATE Emprestimos
            SET status_emprestimo = 'Atrasado'
            WHERE id_emprestimo = v_id_emprestimo;

            -- Incrementar contadores
            SET p_total_multas_geradas = p_total_multas_geradas + 1;
            SET p_valor_total = p_valor_total + v_valor_multa;
        END IF;

    END LOOP;

    CLOSE cur_atrasados;

    COMMIT;

END$$

DELIMITER ;

-- ============================================================================
-- PROCEDURE 4: RELATÓRIO DE LIVROS MAIS EMPRESTADOS
-- ============================================================================
-- Propósito: Gerar ranking de livros mais emprestados em um período
-- Retorna: Result set com ranking

DROP PROCEDURE IF EXISTS sp_RelatorioLivrosMaisEmprestados;

DELIMITER $$

CREATE PROCEDURE sp_RelatorioLivrosMaisEmprestados(
    IN p_data_inicio DATE,
    IN p_data_fim DATE,
    IN p_limite INT
)
BEGIN
    SELECT
        @posicao := @posicao + 1 AS posicao,
        l.isbn,
        l.titulo,
        c.nome_categoria,
        COUNT(e.id_emprestimo) AS total_emprestimos,
        (SELECT COUNT(*) FROM Exemplares WHERE id_livro = l.id_livro) AS total_exemplares
    FROM
        Emprestimos e
        JOIN Exemplares ex ON e.id_exemplar = ex.id_exemplar
        JOIN Livros l ON ex.id_livro = l.id_livro
        JOIN Categorias c ON l.id_categoria = c.id_categoria
        CROSS JOIN (SELECT @posicao := 0) AS pos_init
    WHERE
        DATE(e.data_emprestimo) BETWEEN p_data_inicio AND p_data_fim
    GROUP BY
        l.id_livro, l.isbn, l.titulo, c.nome_categoria
    ORDER BY
        total_emprestimos DESC
    LIMIT p_limite;

END$$

DELIMITER ;

-- ============================================================================
-- EXEMPLOS DE USO
-- ============================================================================

-- Exemplo 1: Realizar empréstimo
-- CALL sp_RealizarEmprestimo(1, 10, @sucesso, @msg);
-- SELECT @sucesso AS Sucesso, @msg AS Mensagem;

-- Exemplo 2: Realizar devolução
-- CALL sp_RealizarDevolucao(1, @sucesso, @multa, @msg);
-- SELECT @sucesso AS Sucesso, @multa AS Multa, @msg AS Mensagem;

-- Exemplo 3: Calcular multas atrasadas
-- CALL sp_CalcularMultasAtrasadas(@total, @valor);
-- SELECT @total AS MultasGeradas, @valor AS ValorTotal;

-- Exemplo 4: Relatório de livros mais emprestados
-- CALL sp_RelatorioLivrosMaisEmprestados('2025-01-01', '2025-12-31', 10);
