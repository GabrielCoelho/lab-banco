-- Altera-se o delimitador de ';' para '//' brevemente afim de que os delimitadores
-- utilizados dentro da procedure, não quebrem ela antes do fim
DELIMITER //

CREATE PROCEDURE ListarAlunosCurso(
    IN p_id_curso INT  -- Parâmetro de entrada: ID do curso a ser consultado
)
BEGIN
    -- Declaração de variável local para verificar existência do curso
    -- DECLARE cria variáveis temporárias válidas apenas dentro da procedure
    DECLARE v_curso_existe INT DEFAULT 0;

    -- Verificação 1: Checar se o curso existe na tabela Cursos
    -- COUNT(*) retorna quantos registros correspondem ao id_curso
    -- INTO armazena o resultado na variável v_curso_existe
    SELECT COUNT(*) INTO v_curso_existe
    FROM Cursos
    WHERE id_curso = p_id_curso;

    -- Estrutura condicional: IF-THEN-ELSE-END IF
    IF v_curso_existe = 0 THEN
        -- Caso o curso não exista: retorna mensagem informativa
        -- Usa SELECT como forma de retornar uma mensagem ao cliente
        SELECT CONCAT('ERRO: Curso com ID ', p_id_curso, ' não existe no sistema.') AS Mensagem;
    ELSE
        -- Caso o curso exista: lista os alunos matriculados
        -- JOIN implícito através da FK id_curso presente em ambas as tabelas
        SELECT
            A.nome_aluno AS 'Nome do Aluno',
            C.nome_curso AS 'Curso',
            C.duracao_anos AS 'Duração (anos)'
        FROM Alunos A
        INNER JOIN Cursos C ON A.id_curso = C.id_curso
        WHERE A.id_curso = p_id_curso
        ORDER BY A.nome_aluno ASC;  -- Ordenação alfabética por nome

        -- Observação: Se o curso existir mas não tiver alunos,
        -- o SELECT retornará um conjunto vazio (0 linhas)
    END IF;

END //

-- Restauração do delimitador padrão
DELIMITER ;

-- ============================================================================
-- EXEMPLOS DE USO - TESTANDO A STORED PROCEDURE
-- ============================================================================

-- ----------------------------------------
-- TESTE 1: Curso EXISTENTE com alunos (Engenharia de Software, id=1)
-- ----------------------------------------
-- Resultado esperado: Lista de alunos matriculados em Engenharia de Software
CALL ListarAlunosCurso(1);

-- ----------------------------------------
-- TESTE 2: Curso EXISTENTE com alunos (Administração, id=2)
-- ----------------------------------------
-- Resultado esperado: Lista de alunos matriculados em Administração
CALL ListarAlunosCurso(2);

-- ----------------------------------------
-- TESTE 3: Curso EXISTENTE com alunos (Medicina, id=4)
-- ----------------------------------------
-- Resultado esperado: Lista de alunos matriculados em Medicina
CALL ListarAlunosCurso(4);

-- ----------------------------------------
-- TESTE 4: Curso INEXISTENTE (id=999)
-- ----------------------------------------
-- Resultado esperado: Mensagem de erro informando que o curso não existe
-- Mensagem: "ERRO: Curso com ID 999 não existe no sistema."
CALL ListarAlunosCurso(999);

-- ----------------------------------------
-- TESTE 5: ID de curso inválido (id=0)
-- ----------------------------------------
-- Resultado esperado: Mensagem de erro (IDs começam em 1)
CALL ListarAlunosCurso(0);

-- ----------------------------------------
-- TESTE 6: ID de curso negativo (id=-5)
-- ----------------------------------------
-- Resultado esperado: Mensagem de erro informando que o curso não existe
CALL ListarAlunosCurso(-5);
