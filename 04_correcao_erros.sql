-- Objetivo: Identificar pelo menos 2 erros no código de transação fornecido
-- e fornecer o código SQL corrigido
-- ============================================================================
-- CÓDIGO ORIGINAL COM ERROS
-- ============================================================================
/*
BEGIN TRANSACTION
INSERT INTO Matriculas (id_aluno id_turma, data_matricula) VALUES (1, 1, '2025-01-01');
COMMIT;
*/

-- ============================================================================
-- IDENTIFICAÇÃO DOS ERROS
-- ============================================================================
-- ERRO 1: Sintaxe incorreta do comando de início de transação
  -- ❌ BEGIN TRANSACTION (sintaxe SQL Server/T-SQL)
  -- ✅ START TRANSACTION (sintaxe MySQL padrão)
-- Explicação: MySQL usa START TRANSACTION, não BEGIN TRANSACTION
--
-- ERRO 2: Falta vírgula entre os campos no INSERT
  -- ❌ INSERT INTO Matriculas (id_aluno id_turma, data_matricula)
  -- ✅ INSERT INTO Matriculas (id_aluno, id_turma, data_matricula)
-- Explicação: Entre id_aluno e id_turma deve haver vírgula separando os campos
--
-- ERRO 3: Falta tratamento de erros
  -- Problema: Não há verificação se a inserção foi bem-sucedida
-- Solução: Adicionar handlers de erro ou validações
--
-- ERRO 4: Falta validação de dados
  -- Problema: Não verifica se id_aluno=1 e id_turma=1 existem nas tabelas
-- Solução: Adicionar verificações antes da inserção
-- ============================================================================



-- ============================================================================
-- CÓDIGO CORRIGIDO (Versão Completa com Validações)
-- ============================================================================

DELIMITER //

CREATE PROCEDURE RegistrarMatriculaSegura(
    IN p_id_aluno INT,
    IN p_id_turma INT,
    IN p_data_matricula DATE
)
BEGIN
    -- Declaração de variáveis para validação
    DECLARE v_aluno_existe INT DEFAULT 0;
    DECLARE v_turma_existe INT DEFAULT 0;
    DECLARE v_matricula_duplicada INT DEFAULT 0;

    -- Handler para capturar erros SQL
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Em caso de erro, desfaz todas as operações
        ROLLBACK;
        SELECT 'ERRO: Transação revertida devido a falha na execução.' AS Mensagem;
    END;

    -- Inicia a transação
    START TRANSACTION;

    -- Validação 1: Verificar se o aluno existe
    SELECT COUNT(*) INTO v_aluno_existe
    FROM Alunos
    WHERE id_aluno = p_id_aluno;

    IF v_aluno_existe = 0 THEN
        ROLLBACK;
        SELECT CONCAT('ERRO: Aluno com ID ', p_id_aluno, ' não existe.') AS Mensagem;
    ELSE
        -- Validação 2: Verificar se a turma existe
        SELECT COUNT(*) INTO v_turma_existe
        FROM Turmas
        WHERE id_turma = p_id_turma;

        IF v_turma_existe = 0 THEN
            ROLLBACK;
            SELECT CONCAT('ERRO: Turma com ID ', p_id_turma, ' não existe.') AS Mensagem;
        ELSE
            -- Validação 3: Verificar se já existe matrícula duplicada
            SELECT COUNT(*) INTO v_matricula_duplicada
            FROM Matriculas
            WHERE id_aluno = p_id_aluno AND id_turma = p_id_turma;

            IF v_matricula_duplicada > 0 THEN
                ROLLBACK;
                SELECT 'ERRO: Aluno já está matriculado nesta turma.' AS Mensagem;
            ELSE
                -- Todas as validações passaram: realizar a inserção
                INSERT INTO Matriculas (id_aluno, id_turma, data_matricula)
                VALUES (p_id_aluno, p_id_turma, p_data_matricula);

                -- Confirma a transação
                COMMIT;
                SELECT 'SUCESSO: Matrícula registrada com sucesso!' AS Mensagem;
            END IF;
        END IF;
    END IF;

END //

DELIMITER ;

-- ============================================================================
-- EXEMPLOS DE USO - TESTANDO AS CORREÇÕES
-- ============================================================================

-- ----------------------------------------
-- TESTE 1: Inserção VÁLIDA usando código corrigido básico
-- ----------------------------------------
-- Resultado esperado: Matrícula inserida com sucesso
START TRANSACTION;
INSERT INTO Matriculas (id_aluno, id_turma, data_matricula)
VALUES (10, 3, '2025-01-15');
COMMIT;

-- Verificar se foi inserido
SELECT * FROM Matriculas WHERE id_aluno = 10 AND id_turma = 3;

-- ----------------------------------------
-- TESTE 2: Usando a procedure segura - Inserção VÁLIDA
-- ----------------------------------------
-- Resultado esperado: "SUCESSO: Matrícula registrada com sucesso!"
CALL RegistrarMatriculaSegura(11, 4, '2025-01-20');

-- ----------------------------------------
-- TESTE 3: Tentativa de matrícula com aluno INEXISTENTE
-- ----------------------------------------
-- Resultado esperado: ERRO - Aluno não existe
CALL RegistrarMatriculaSegura(9999, 1, '2025-01-01');

-- ----------------------------------------
-- TESTE 4: Tentativa de matrícula com turma INEXISTENTE
-- ----------------------------------------
-- Resultado esperado: ERRO - Turma não existe
CALL RegistrarMatriculaSegura(1, 9999, '2025-01-01');

-- ----------------------------------------
-- TESTE 5: Tentativa de matrícula DUPLICADA
-- ----------------------------------------
-- Resultado esperado: ERRO - Aluno já matriculado nesta turma
-- (id_aluno=1 e id_turma=1 já existem no banco de dados)
CALL RegistrarMatriculaSegura(1, 1, '2025-01-01');

-- ----------------------------------------
-- TESTE 6: Demonstração de ROLLBACK em caso de erro
-- ----------------------------------------
-- Este teste mostra como a transação é revertida em caso de erro
START TRANSACTION;

INSERT INTO Matriculas (id_aluno, id_turma, data_matricula)
VALUES (12, 5, '2025-02-01');

-- Simulando um erro intencional (comentado para não quebrar o script)
-- INSERT INTO Matriculas (id_aluno_invalido, id_turma) VALUES (1, 1);

-- Se houvesse erro, usaríamos ROLLBACK:
ROLLBACK;

-- Como não há erro, confirmamos:
COMMIT;

