-- ============================================================================
-- SISTEMA DE GERENCIAMENTO DE BIBLIOTECA UNIVERSITÁRIA (SGBU)
-- CONSULTAS SQL (10 QUERIES OBRIGATÓRIAS)
-- ============================================================================
-- Disciplina: Banco de Dados 2
-- Estudante: Gabriel Coelho Soares
-- SGBD: MySQL 8.0+ / MariaDB 10.5+
-- ============================================================================

USE biblioteca_universitaria;

-- ============================================================================
-- SEÇÃO 1: CONSULTAS BÁSICAS (Queries 1-3)
-- ============================================================================

-- ============================================================================
-- QUERY 1: Listagem Simples com Filtro e Ordenação
-- Descrição: Livros da categoria 'Ficção Científica' ordenados por ano
-- Complexidade: Básica
-- ============================================================================

SELECT
    l.titulo,
    l.ano_publicacao,
    l.isbn
FROM
    Livros l
    INNER JOIN Categorias c ON l.id_categoria = c.id_categoria
WHERE
    c.nome_categoria = 'Ficção Científica'
ORDER BY
    l.ano_publicacao DESC;

-- Resultado esperado: Livros de ficção científica do mais recente ao mais antigo

-- ============================================================================
-- QUERY 2: Contagem com Agrupamento
-- Descrição: Quantidade de livros por categoria
-- Complexidade: Básica
-- ============================================================================

SELECT
    c.nome_categoria,
    COUNT(l.id_livro) AS total_livros
FROM
    Categorias c
    INNER JOIN Livros l ON c.id_categoria = l.id_categoria
GROUP BY
    c.id_categoria, c.nome_categoria
ORDER BY
    total_livros DESC;

-- Resultado esperado: Lista de categorias com contagem de livros

-- ============================================================================
-- QUERY 3: Usuários Específicos com Filtro de Data
-- Descrição: Alunos cadastrados nos últimos 6 meses
-- Complexidade: Básica
-- ============================================================================

SELECT
    u.nome_completo,
    u.email,
    u.data_cadastro
FROM
    Usuarios u
    INNER JOIN TiposUsuario tu ON u.id_tipo_usuario = tu.id_tipo_usuario
WHERE
    tu.nome_tipo = 'Aluno'
    AND u.data_cadastro >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
ORDER BY
    u.data_cadastro DESC;

-- Resultado esperado: Alunos recentemente cadastrados

-- ============================================================================
-- SEÇÃO 2: CONSULTAS INTERMEDIÁRIAS (Queries 4-6)
-- ============================================================================

-- ============================================================================
-- QUERY 4: JOIN Triplo com Informações Completas
-- Descrição: Empréstimos realizados em 2025
-- Complexidade: Intermediária
-- ============================================================================

SELECT
    u.nome_completo AS nome_usuario,
    l.titulo AS titulo_livro,
    e.data_emprestimo,
    e.data_prevista_devolucao
FROM
    Emprestimos e
    INNER JOIN Usuarios u ON e.id_usuario = u.id_usuario
    INNER JOIN Exemplares ex ON e.id_exemplar = ex.id_exemplar
    INNER JOIN Livros l ON ex.id_livro = l.id_livro
WHERE
    YEAR(e.data_emprestimo) = 2025
ORDER BY
    e.data_emprestimo DESC;

-- Resultado esperado: Lista de empréstimos de 2025 com usuário e livro

-- ============================================================================
-- QUERY 5: Agregação por Relacionamento
-- Descrição: Autores com pelo menos 2 livros
-- Complexidade: Intermediária
-- ============================================================================

SELECT
    a.nome_autor,
    COUNT(DISTINCT la.id_livro) AS total_livros
FROM
    Autores a
    INNER JOIN LivrosAutores la ON a.id_autor = la.id_autor
GROUP BY
    a.id_autor, a.nome_autor
HAVING
    COUNT(DISTINCT la.id_livro) >= 2
ORDER BY
    total_livros DESC;

-- Resultado esperado: Autores prolíficos com contagem de obras

-- ============================================================================
-- QUERY 6: Média e Estatísticas por Grupo
-- Descrição: Média de páginas por categoria
-- Complexidade: Intermediária
-- ============================================================================

SELECT
    c.nome_categoria,
    ROUND(AVG(l.numero_paginas), 0) AS media_paginas,
    COUNT(l.id_livro) AS quantidade_livros
FROM
    Categorias c
    INNER JOIN Livros l ON c.id_categoria = l.id_categoria
WHERE
    l.numero_paginas IS NOT NULL
GROUP BY
    c.id_categoria, c.nome_categoria
ORDER BY
    media_paginas DESC;

-- Resultado esperado: Categorias ordenadas por extensão média dos livros

-- ============================================================================
-- SEÇÃO 3: CONSULTAS AVANÇADAS (Queries 7-10)
-- ============================================================================

-- ============================================================================
-- QUERY 7: Subquery Simples (Filtro por Agregação)
-- Descrição: Livros com mais exemplares que a média geral
-- Complexidade: Avançada
-- ============================================================================

SELECT
    l.titulo,
    l.isbn,
    COUNT(ex.id_exemplar) AS total_exemplares
FROM
    Livros l
    INNER JOIN Exemplares ex ON l.id_livro = ex.id_livro
GROUP BY
    l.id_livro, l.titulo, l.isbn
HAVING
    COUNT(ex.id_exemplar) > (
        SELECT AVG(qtd_exemplares)
        FROM (
            SELECT COUNT(*) AS qtd_exemplares
            FROM Exemplares
            GROUP BY id_livro
        ) AS media_calc
    )
ORDER BY
    total_exemplares DESC;

-- Resultado esperado: Livros com quantidade acima da média de exemplares

-- ============================================================================
-- QUERY 8: Subquery Correlacionada
-- Descrição: Usuários que nunca fizeram empréstimos
-- Complexidade: Avançada
-- ============================================================================

SELECT
    u.nome_completo,
    u.cpf,
    u.email
FROM
    Usuarios u
WHERE
    NOT EXISTS (
        SELECT 1
        FROM Emprestimos e
        WHERE e.id_usuario = u.id_usuario
    )
ORDER BY
    u.nome_completo;

-- Resultado esperado: Usuários sem histórico de empréstimos

-- ============================================================================
-- QUERY 9: Agregação Complexa com Múltiplos JOINs e CASE
-- Descrição: Estatísticas de empréstimos por usuário
-- Complexidade: Avançada
-- ============================================================================

SELECT
    u.nome_completo AS nome_usuario,
    tu.nome_tipo AS tipo_usuario,
    COUNT(e.id_emprestimo) AS total_emprestimos,
    COUNT(CASE
        WHEN e.status_emprestimo = 'Devolvido'
        AND e.data_devolucao_real <= e.data_prevista_devolucao
        THEN 1
    END) AS emprestimos_no_prazo,
    COUNT(CASE
        WHEN e.status_emprestimo = 'Atrasado'
        OR (e.data_devolucao_real IS NOT NULL
            AND e.data_devolucao_real > e.data_prevista_devolucao)
        THEN 1
    END) AS emprestimos_atrasados,
    IFNULL(SUM(CASE
        WHEN m.status_pagamento = 'Pago'
        THEN m.valor_multa
        ELSE 0
    END), 0.00) AS valor_multas_pagas
FROM
    Usuarios u
    INNER JOIN TiposUsuario tu ON u.id_tipo_usuario = tu.id_tipo_usuario
    INNER JOIN Emprestimos e ON u.id_usuario = e.id_usuario
    LEFT JOIN Multas m ON e.id_emprestimo = m.id_emprestimo
GROUP BY
    u.id_usuario, u.nome_completo, tu.nome_tipo
HAVING
    total_emprestimos >= 1
ORDER BY
    total_emprestimos DESC;

-- Resultado esperado: Usuários com estatísticas detalhadas de comportamento

-- ============================================================================
-- QUERY 10: Ranking dos Livros Mais Emprestados (Últimos 3 Meses)
-- Descrição: Top 5 livros mais populares recentemente
-- Complexidade: Avançada
-- ============================================================================

SELECT
    @rank := @rank + 1 AS ranking,
    l.titulo,
    c.nome_categoria AS categoria,
    COUNT(e.id_emprestimo) AS total_emprestimos
FROM
    Emprestimos e
    INNER JOIN Exemplares ex ON e.id_exemplar = ex.id_exemplar
    INNER JOIN Livros l ON ex.id_livro = l.id_livro
    INNER JOIN Categorias c ON l.id_categoria = c.id_categoria
    CROSS JOIN (SELECT @rank := 0) AS rank_init
WHERE
    e.data_emprestimo >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY
    l.id_livro, l.titulo, c.nome_categoria
ORDER BY
    total_emprestimos DESC
LIMIT 5;

-- Resultado esperado: Top 5 livros mais emprestados nos últimos 3 meses

-- ============================================================================
-- RESUMO DAS CONSULTAS
-- ============================================================================
-- Query 1: SELECT básico com JOIN e WHERE
-- Query 2: COUNT com GROUP BY
-- Query 3: Filtro temporal com DATE_SUB
-- Query 4: JOIN triplo com filtro de ano
-- Query 5: Agregação com HAVING
-- Query 6: Função AVG com agrupamento
-- Query 7: Subquery para comparação com média
-- Query 8: Subquery correlacionada com NOT EXISTS
-- Query 9: Agregação complexa com CASE condicional
-- Query 10: Ranking com variável e filtro temporal
-- ============================================================================
