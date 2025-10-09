-- Cria a view que combina dados de Professores e Departamentos
CREATE VIEW ListaProfessoresDepartamentos AS
SELECT
    p.nome_professor,        -- Nome do professor
    d.nome_departamento      -- Nome do departamento associado
FROM
    Professores p
INNER JOIN                   -- Relaciona professores com seus departamentos
    Departamentos d ON p.id_departamento = d.id_departamento;

-- Explicação da utilidade da view:
-- Esta view seria útil para relatórios administrativos porque:
  -- 1. Facilita consultas rápidas
  -- 2. Simplifica a geração de relatórios gerenciais
  -- 3. é útil para auditorias internas e planejamento de recursos humanos
  -- 4. Pode ser usada como base para dashboards administrativos

-- ============================================================================
-- EXEMPLOS DE USO - TESTANDO A VIEW
-- ============================================================================

-- ----------------------------------------
-- TESTE 1: Consulta SIMPLES - Todos os professores e departamentos
-- ----------------------------------------
-- Resultado esperado: Lista completa com todos os professores e seus departamentos
SELECT * FROM ListaProfessoresDepartamentos;

-- ----------------------------------------
-- TESTE 2: Filtrar por DEPARTAMENTO específico (Departamento de TI)
-- ----------------------------------------
-- Resultado esperado: Apenas professores do Departamento de TI
SELECT *
FROM ListaProfessoresDepartamentos
WHERE nome_departamento = 'Departamento de TI';

-- ----------------------------------------
-- TESTE 3: Filtrar por DEPARTAMENTO (Departamento de Saúde)
-- ----------------------------------------
-- Resultado esperado: Apenas professores do Departamento de Saúde
SELECT *
FROM ListaProfessoresDepartamentos
WHERE nome_departamento = 'Departamento de Saúde';

-- ----------------------------------------
-- TESTE 4: Buscar professor ESPECÍFICO por nome
-- ----------------------------------------
-- Resultado esperado: Dados do professor João Silva e seu departamento
SELECT *
FROM ListaProfessoresDepartamentos
WHERE nome_professor LIKE '%João Silva%';

-- ----------------------------------------
-- TESTE 5: Contar PROFESSORES por departamento
-- ----------------------------------------
-- Resultado esperado: Quantidade de professores em cada departamento
SELECT
    nome_departamento,
    COUNT(*) AS total_professores
FROM ListaProfessoresDepartamentos
GROUP BY nome_departamento
ORDER BY total_professores DESC;

-- ----------------------------------------
-- TESTE 6: Listar professores ORDENADOS alfabeticamente
-- ----------------------------------------
-- Resultado esperado: Todos os professores em ordem alfabética
SELECT *
FROM ListaProfessoresDepartamentos
ORDER BY nome_professor ASC;

-- ----------------------------------------
-- TESTE 7: Busca com padrão LIKE (professores com "Silva" no nome)
-- ----------------------------------------
-- Resultado esperado: Professores que têm "Silva" no nome
SELECT *
FROM ListaProfessoresDepartamentos
WHERE nome_professor LIKE '%Silva%';

-- ============================================================================
-- VERIFICAÇÃO ADICIONAL: Comparar view com consulta tradicional
-- ============================================================================
-- Esta consulta faz o mesmo que a view, mas com JOIN explícito
-- Demonstra a simplificação que a view proporciona
SELECT
    p.nome_professor,
    d.nome_departamento
FROM Professores p
INNER JOIN Departamentos d ON p.id_departamento = d.id_departamento;
