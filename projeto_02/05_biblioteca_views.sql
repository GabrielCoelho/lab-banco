-- ============================================================================
-- SISTEMA DE GERENCIAMENTO DE BIBLIOTECA UNIVERSITÁRIA (SGBU)
-- VIEWS (VISÕES)
-- ============================================================================
-- Disciplina: Banco de Dados 2
-- Estudante: Gabriel Coelho Soares
-- SGBD: MySQL 8.0+ / MariaDB 10.5+
-- ============================================================================

USE biblioteca_universitaria;

-- ============================================================================
-- SEÇÃO 1: VIEWS OPERACIONAIS
-- ============================================================================

-- View 1: Empréstimos atualmente ativos com informações completas
-- Colunas calculadas: dias_restantes, situacao

DROP VIEW IF EXISTS vw_EmprestimosAtivos;

CREATE OR REPLACE VIEW vw_EmprestimosAtivos AS
SELECT
    e.id_emprestimo,
    u.cpf AS cpf_usuario,
    u.nome_completo AS nome_usuario,
    tu.nome_tipo AS tipo_usuario,
    l.isbn,
    l.titulo AS titulo_livro,
    ex.codigo_exemplar,
    e.data_emprestimo,
    e.data_prevista_devolucao,
    DATEDIFF(e.data_prevista_devolucao, CURDATE()) AS dias_restantes,
    CASE
        WHEN DATEDIFF(CURDATE(), e.data_prevista_devolucao) > 0 THEN
            CONCAT('Atrasado ', DATEDIFF(CURDATE(), e.data_prevista_devolucao), ' dias')
        WHEN DATEDIFF(CURDATE(), e.data_prevista_devolucao) = 0 THEN 'Vence Hoje'
        ELSE 'No Prazo'
    END AS situacao
FROM
    Emprestimos e
    INNER JOIN Usuarios u ON e.id_usuario = u.id_usuario
    INNER JOIN TiposUsuario tu ON u.id_tipo_usuario = tu.id_tipo_usuario
    INNER JOIN Exemplares ex ON e.id_exemplar = ex.id_exemplar
    INNER JOIN Livros l ON ex.id_livro = l.id_livro
WHERE
    e.status_emprestimo = 'Ativo'
ORDER BY
    e.data_prevista_devolucao ASC;

-- View 2: Livros com pelo menos um exemplar disponível
-- Colunas calculadas: autores concatenados, contagens por status

DROP VIEW IF EXISTS vw_LivrosDisponiveis;

CREATE OR REPLACE VIEW vw_LivrosDisponiveis AS
SELECT
    l.id_livro,
    l.isbn,
    l.titulo,
    GROUP_CONCAT(a.nome_autor ORDER BY la.ordem_autoria SEPARATOR '; ') AS autores,
    c.nome_categoria AS categoria,
    e.nome_editora AS editora,
    l.ano_publicacao,
    COUNT(ex.id_exemplar) AS total_exemplares,
    SUM(CASE WHEN ex.status = 'Disponível' THEN 1 ELSE 0 END) AS exemplares_disponiveis,
    SUM(CASE WHEN ex.status = 'Emprestado' THEN 1 ELSE 0 END) AS exemplares_emprestados
FROM
    Livros l
    INNER JOIN Categorias c ON l.id_categoria = c.id_categoria
    LEFT JOIN Editoras e ON l.id_editora = e.id_editora
    LEFT JOIN LivrosAutores la ON l.id_livro = la.id_livro
    LEFT JOIN Autores a ON la.id_autor = a.id_autor
    INNER JOIN Exemplares ex ON l.id_livro = ex.id_livro
GROUP BY
    l.id_livro, l.isbn, l.titulo, c.nome_categoria, e.nome_editora, l.ano_publicacao
HAVING
    exemplares_disponiveis > 0
ORDER BY
    c.nome_categoria, l.titulo;

-- ============================================================================
-- SEÇÃO 2: VIEWS DE CONTROLE
-- ============================================================================

-- View 3: Usuários com empréstimos atrasados ou multas pendentes
-- Colunas calculadas: agregações de empréstimos e multas, status_conta

DROP VIEW IF EXISTS vw_UsuariosComPendencias;

CREATE OR REPLACE VIEW vw_UsuariosComPendencias AS
SELECT
    u.id_usuario,
    u.cpf,
    u.nome_completo,
    u.email,
    u.telefone,
    tu.nome_tipo AS tipo_usuario,
    COUNT(DISTINCT CASE
        WHEN e.status_emprestimo = 'Ativo'
        AND e.data_prevista_devolucao < CURDATE()
        THEN e.id_emprestimo
    END) AS emprestimos_atrasados,
    IFNULL(SUM(CASE
        WHEN e.status_emprestimo = 'Ativo'
        AND e.data_prevista_devolucao < CURDATE()
        THEN DATEDIFF(CURDATE(), e.data_prevista_devolucao)
        ELSE 0
    END), 0) AS total_dias_atraso,
    COUNT(DISTINCT CASE
        WHEN m.status_pagamento = 'Pendente'
        THEN m.id_multa
    END) AS multas_pendentes,
    IFNULL(SUM(CASE
        WHEN m.status_pagamento = 'Pendente'
        THEN m.valor_multa
        ELSE 0
    END), 0.00) AS valor_total_multas,
    CASE
        WHEN MAX(DATEDIFF(CURDATE(), e.data_prevista_devolucao)) > 30 THEN 'Crítico'
        WHEN MAX(DATEDIFF(CURDATE(), e.data_prevista_devolucao)) > 14 THEN 'Atenção'
        ELSE 'Regular'
    END AS status_conta
FROM
    Usuarios u
    INNER JOIN TiposUsuario tu ON u.id_tipo_usuario = tu.id_tipo_usuario
    LEFT JOIN Emprestimos e ON u.id_usuario = e.id_usuario
    LEFT JOIN Multas m ON e.id_emprestimo = m.id_emprestimo
GROUP BY
    u.id_usuario, u.cpf, u.nome_completo, u.email, u.telefone, tu.nome_tipo
HAVING
    emprestimos_atrasados > 0 OR multas_pendentes > 0
ORDER BY
    valor_total_multas DESC, total_dias_atraso DESC;

-- ============================================================================
-- SEÇÃO 3: VIEWS ESTATÍSTICAS
-- ============================================================================

-- View 4: Dashboard com estatísticas gerais da biblioteca
-- Retorna uma única linha com métricas principais

DROP VIEW IF EXISTS vw_EstatisticasGerais;

CREATE OR REPLACE VIEW vw_EstatisticasGerais AS
SELECT
    (SELECT COUNT(*) FROM Livros) AS total_livros,
    (SELECT COUNT(*) FROM Exemplares) AS total_exemplares,
    (SELECT COUNT(*) FROM Usuarios WHERE status = 'Ativo') AS total_usuarios,
    (SELECT COUNT(*) FROM Emprestimos WHERE status_emprestimo = 'Ativo') AS emprestimos_ativos,
    (SELECT COUNT(*) FROM Emprestimos
     WHERE status_emprestimo = 'Ativo'
     AND data_prevista_devolucao < CURDATE()) AS emprestimos_atrasados,
    (SELECT IFNULL(SUM(valor_multa), 0.00) FROM Multas
     WHERE status_pagamento = 'Pendente') AS multas_pendentes_total,
    ROUND(
        (SELECT COUNT(*) FROM Exemplares WHERE status = 'Emprestado') * 100.0 /
        (SELECT COUNT(*) FROM Exemplares),
        2
    ) AS taxa_ocupacao_percentual;

-- View 5: Ranking de categorias mais emprestadas
-- Ordenado por volume de empréstimos
-- CORREÇÃO: Removido uso de variável @posicao e implementado ROW_NUMBER()
-- Window function compatível com MariaDB 10.5+ e MySQL 8.0+

DROP VIEW IF EXISTS vw_RankingCategoriasMaisEmprestadas;

CREATE OR REPLACE VIEW vw_RankingCategoriasMaisEmprestadas AS
SELECT
    ROW_NUMBER() OVER (ORDER BY total_emprestimos DESC) AS posicao,
    categoria,
    total_emprestimos,
    livros_categoria,
    media_emprestimos_por_livro
FROM (
    SELECT
        c.nome_categoria AS categoria,
        COUNT(e.id_emprestimo) AS total_emprestimos,
        COUNT(DISTINCT l.id_livro) AS livros_categoria,
        ROUND(COUNT(e.id_emprestimo) / COUNT(DISTINCT l.id_livro), 2) AS media_emprestimos_por_livro
    FROM
        Categorias c
        INNER JOIN Livros l ON c.id_categoria = l.id_categoria
        INNER JOIN Exemplares ex ON l.id_livro = ex.id_livro
        INNER JOIN Emprestimos e ON ex.id_exemplar = e.id_exemplar
    GROUP BY
        c.id_categoria, c.nome_categoria
) AS ranking
ORDER BY
    total_emprestimos DESC;

-- View 6: Histórico completo de empréstimos por usuário
-- Pode ser filtrado por id_usuario após SELECT

DROP VIEW IF EXISTS vw_HistoricoUsuario;

CREATE OR REPLACE VIEW vw_HistoricoUsuario AS
SELECT
    u.id_usuario,
    u.nome_completo AS nome_usuario,
    u.cpf,
    e.id_emprestimo,
    l.titulo AS titulo_livro,
    l.isbn,
    e.data_emprestimo,
    e.data_devolucao_real,
    e.status_emprestimo,
    CASE WHEN m.id_multa IS NOT NULL THEN TRUE ELSE FALSE END AS teve_multa,
    IFNULL(m.valor_multa, 0.00) AS valor_multa
FROM
    Usuarios u
    INNER JOIN Emprestimos e ON u.id_usuario = e.id_usuario
    INNER JOIN Exemplares ex ON e.id_exemplar = ex.id_exemplar
    INNER JOIN Livros l ON ex.id_livro = l.id_livro
    LEFT JOIN Multas m ON e.id_emprestimo = m.id_emprestimo
ORDER BY
    u.id_usuario, e.data_emprestimo DESC;

-- ============================================================================
-- EXEMPLOS DE CONSULTAS USANDO AS VIEWS
-- ============================================================================

-- Exemplo 1: Ver todos empréstimos ativos
-- SELECT * FROM vw_EmprestimosAtivos;

-- Exemplo 2: Ver apenas empréstimos atrasados
-- SELECT * FROM vw_EmprestimosAtivos WHERE dias_restantes < 0;

-- Exemplo 3: Ver empréstimos que vencem nos próximos 3 dias
-- SELECT * FROM vw_EmprestimosAtivos WHERE dias_restantes BETWEEN 0 AND 3;

-- Exemplo 4: Ver livros disponíveis de uma categoria específica
-- SELECT * FROM vw_LivrosDisponiveis WHERE categoria = 'Ficção Científica';

-- Exemplo 5: Ver livros de um autor específico
-- SELECT * FROM vw_LivrosDisponiveis WHERE autores LIKE '%Machado de Assis%';

-- Exemplo 6: Ver livros com mais de 2 exemplares disponíveis
-- SELECT * FROM vw_LivrosDisponiveis WHERE exemplares_disponiveis >= 2;

-- Exemplo 7: Ver usuários com pendências
-- SELECT * FROM vw_UsuariosComPendencias;

-- Exemplo 8: Ver situações críticas (mais de 30 dias de atraso)
-- SELECT * FROM vw_UsuariosComPendencias WHERE status_conta = 'Crítico';

-- Exemplo 9: Ver usuários com multas acima de R$ 50,00
-- SELECT * FROM vw_UsuariosComPendencias WHERE valor_total_multas > 50.00;

-- Exemplo 10: Ver estatísticas gerais da biblioteca
-- SELECT * FROM vw_EstatisticasGerais;

-- Exemplo 11: Ver top 5 categorias mais emprestadas
-- SELECT * FROM vw_RankingCategoriasMaisEmprestadas LIMIT 5;

-- Exemplo 12: Ver histórico de um usuário específico
-- SELECT * FROM vw_HistoricoUsuario WHERE id_usuario = 1;

-- Exemplo 13: Ver usuários que nunca tiveram multa
-- SELECT DISTINCT id_usuario, nome_usuario, cpf
-- FROM vw_HistoricoUsuario
-- WHERE teve_multa = FALSE
-- GROUP BY id_usuario, nome_usuario, cpf;
