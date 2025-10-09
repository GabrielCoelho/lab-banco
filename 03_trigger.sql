-- Remove o trigger se já existir (evita erro de duplicação)
DROP TRIGGER IF EXISTS ValidarNotaAntesInserir;

-- Altera o delimitador para permitir múltiplas instruções no trigger
DELIMITER //

-- Cria o trigger BEFORE INSERT na tabela Notas
CREATE TRIGGER ValidarNotaAntesInserir
BEFORE INSERT ON Notas              -- Executa ANTES de inserir na tabela Notas
FOR EACH ROW                        -- Executa para cada linha sendo inserida
BEGIN
    -- Valida se a nota está fora do intervalo válido [0.0, 10.0]
    IF NEW.valor_nota > 10.0 OR NEW.valor_nota < 0.0 THEN
        -- Lança um erro com código SQLSTATE '45000' (erro genérico definido pelo usuário)
        -- Interrompe a inserção e retorna mensagem de erro
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: valor_nota deve estar entre 0.0 e 10.0';
    END IF;
    -- Se a validação passar (nota entre 0.0 e 10.0), a inserção continua normalmente
END //

-- Restaura o delimitador padrão
DELIMITER ;

-- ============================================================================
-- EXEMPLOS DE USO - TESTANDO O TRIGGER
-- ============================================================================

-- ----------------------------------------
-- TESTE 1: Inserção VÁLIDA (nota = 8.5)
-- ----------------------------------------
-- Resultado esperado: Inserção bem-sucedida
INSERT INTO Notas (id_matricula, valor_nota, tipo_avaliacao)
VALUES (1, 8.5, 'Prova Trigger - Teste Válido');

-- ----------------------------------------
-- TESTE 2: Inserção VÁLIDA (nota = 0.0)
-- ----------------------------------------
-- Resultado esperado: Inserção bem-sucedida (limite inferior válido)
INSERT INTO Notas (id_matricula, valor_nota, tipo_avaliacao)
VALUES (1, 0.0, 'Prova Trigger - Limite Inferior');

-- ----------------------------------------
-- TESTE 3: Inserção VÁLIDA (nota = 10.0)
-- ----------------------------------------
-- Resultado esperado: Inserção bem-sucedida (limite superior válido)
INSERT INTO Notas (id_matricula, valor_nota, tipo_avaliacao)
VALUES (1, 10.0, 'Prova Trigger - Limite Superior');

-- ----------------------------------------
-- TESTE 4: Inserção INVÁLIDA (nota > 10.0)
-- ----------------------------------------
-- Resultado esperado: ERRO - trigger bloqueia a inserção
-- Mensagem: "Erro: valor_nota deve estar entre 0.0 e 10.0"
INSERT INTO Notas (id_matricula, valor_nota, tipo_avaliacao)
VALUES (1, 10.5, 'Prova Trigger - Teste Inválido Maior');

-- ----------------------------------------
-- TESTE 5: Inserção INVÁLIDA (nota < 0.0)
-- ----------------------------------------
-- Resultado esperado: ERRO - trigger bloqueia a inserção
-- Mensagem: "Erro: valor_nota deve estar entre 0.0 e 10.0"
INSERT INTO Notas (id_matricula, valor_nota, tipo_avaliacao)
VALUES (1, -1.5, 'Prova Trigger - Teste Inválido Menor');
