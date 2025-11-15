-- ============================================================================
-- SISTEMA DE GERENCIAMENTO DE BIBLIOTECA UNIVERSITÁRIA (SGBU)
-- SCRIPT DE INSERÇÃO DE DADOS INICIAIS (DML)
-- ============================================================================
-- Disciplina: Banco de Dados 2
-- Estudante: Gabriel Coelho Soares
-- SGBD: MySQL 8.0+ / MariaDB 10.5+
-- ============================================================================

USE biblioteca_universitaria;

-- ============================================================================
-- SEÇÃO 1: DADOS DE DOMÍNIO
-- ============================================================================

-- Categorias (10 registros)
INSERT INTO Categorias (nome_categoria, descricao) VALUES
('Ficção Literária', 'Romances e contos de ficção'),
('Ficção Científica', 'Literatura de ficção científica e fantasia'),
('Romance', 'Romances contemporâneos e clássicos'),
('Tecnologia e Computação', 'Livros técnicos de programação e TI'),
('Ciências Exatas', 'Matemática, física e química'),
('Ciências Humanas', 'Sociologia, filosofia e psicologia'),
('História', 'História mundial e do Brasil'),
('Biografia', 'Biografias e autobiografias'),
('Autoajuda', 'Desenvolvimento pessoal e profissional'),
('Referência', 'Dicionários, enciclopédias e guias');

-- Editoras (8 registros)
INSERT INTO Editoras (nome_editora, pais, cidade, site) VALUES
('Companhia das Letras', 'Brasil', 'São Paulo', 'www.companhiadasletras.com.br'),
('Editora Globo', 'Brasil', 'Porto Alegre', 'www.editoraglobo.com.br'),
('Aleph', 'Brasil', 'São Paulo', 'www.editoraaleph.com.br'),
('Casa do Código', 'Brasil', 'São Paulo', 'www.casadocodigo.com.br'),
('Penguin Random House', 'Estados Unidos', 'Nova York', 'www.penguinrandomhouse.com'),
('HarperCollins', 'Reino Unido', 'Londres', 'www.harpercollins.co.uk'),
('Planeta', 'Espanha', 'Barcelona', 'www.planetadelibros.com'),
('O''Reilly Media', 'Estados Unidos', 'Sebastopol', 'www.oreilly.com');

-- Autores (20 registros)
INSERT INTO Autores (nome_autor, nacionalidade, data_nascimento) VALUES
('Machado de Assis', 'Brasileira', '1839-06-21'),
('Clarice Lispector', 'Brasileira', '1920-12-10'),
('Paulo Coelho', 'Brasileira', '1947-08-24'),
('Jorge Amado', 'Brasileira', '1912-08-10'),
('Cecília Meireles', 'Brasileira', '1901-11-07'),
('George Orwell', 'Britânica', '1903-06-25'),
('Virginia Woolf', 'Britânica', '1882-01-25'),
('Gabriel García Márquez', 'Colombiana', '1927-03-06'),
('Isaac Asimov', 'Americana', '1920-01-02'),
('Arthur C. Clarke', 'Britânica', '1917-12-16'),
('Robert C. Martin', 'Americana', '1952-12-05'),
('Martin Fowler', 'Britânica', '1963-12-18'),
('Kent Beck', 'Americana', '1961-03-31'),
('Eric Evans', 'Americana', '1960-01-15'),
('Yuval Noah Harari', 'Israelense', '1976-02-24'),
('Stephen Hawking', 'Britânica', '1942-01-08'),
('Carl Sagan', 'Americana', '1934-11-09'),
('Michelle Obama', 'Americana', '1964-01-17'),
('Malala Yousafzai', 'Paquistanesa', '1997-07-12'),
('Viktor Frankl', 'Austríaca', '1905-03-26');

-- ============================================================================
-- SEÇÃO 2: DADOS PRINCIPAIS
-- ============================================================================

-- Livros (30 registros)
INSERT INTO Livros (isbn, titulo, ano_publicacao, edicao, numero_paginas, idioma, id_categoria, id_editora) VALUES
('9788535908770', 'Dom Casmurro', 1899, 1, 256, 'Português', 1, 1),
('9788520923146', 'A Hora da Estrela', 1977, 1, 88, 'Português', 1, 2),
('9788576843849', 'O Alquimista', 1988, 1, 198, 'Português', 3, 3),
('9788520923207', 'Capitães da Areia', 1937, 1, 280, 'Português', 1, 2),
('9788535911664', '1984', 1949, 1, 416, 'Português', 2, 1),
('9788573269529', 'A Revolução dos Bichos', 1945, 1, 152, 'Português', 2, 1),
('9788574480381', 'Mrs. Dalloway', 1925, 1, 288, 'Português', 1, 7),
('9788535914849', 'Cem Anos de Solidão', 1967, 1, 432, 'Português', 1, 1),
('9788576570486', 'Fundação', 1951, 1, 295, 'Português', 2, 3),
('9788576571278', '2001: Uma Odisseia no Espaço', 1968, 1, 336, 'Português', 2, 3),
('9788576082675', 'Código Limpo', 2008, 1, 425, 'Português', 4, 4),
('9788575225875', 'Refatoração', 1999, 2, 456, 'Português', 4, 4),
('9788577808670', 'Padrões de Projetos', 1994, 1, 364, 'Português', 4, 4),
('9788575226759', 'Domain-Driven Design', 2003, 1, 560, 'Português', 4, 4),
('9788535929186', 'Sapiens: Uma Breve História da Humanidade', 2011, 1, 464, 'Português', 7, 1),
('9788551004401', '21 Lições para o Século 21', 2018, 1, 432, 'Português', 6, 1),
('9788580578133', 'Uma Breve História do Tempo', 1988, 1, 256, 'Português', 5, 2),
('9788535914061', 'Cosmos', 1980, 1, 384, 'Português', 5, 1),
('9788539004379', 'Minha História', 2018, 1, 544, 'Português', 8, 3),
('9788535930207', 'Eu Sou Malala', 2013, 1, 344, 'Português', 8, 1),
('9788575428320', 'Em Busca de Sentido', 1946, 1, 184, 'Português', 9, 2),
('9788576843122', 'O Poder do Hábito', 2012, 1, 408, 'Português', 9, 3),
('9788535928686', 'Romeu e Julieta', 1597, 1, 304, 'Português', 1, 1),
('9788576570769', 'O Senhor dos Anéis: A Sociedade do Anel', 1954, 1, 576, 'Português', 2, 3),
('9788535932447', 'Harry Potter e a Pedra Filosofal', 1997, 1, 264, 'Português', 2, 1),
('9788575225134', 'Clean Architecture', 2017, 1, 432, 'Português', 4, 4),
('9788575227268', 'Microsserviços Prontos Para a Produção', 2016, 1, 280, 'Português', 4, 4),
('9788535931976', 'O Gene Egoísta', 1976, 1, 544, 'Português', 5, 1),
('9788576655442', 'Guia Prático SQL', 2020, 1, 352, 'Português', 10, 4),
('9788535924558', 'Dicionário Houaiss da Língua Portuguesa', 2009, 1, 2922, 'Português', 10, 1);

-- Relacionamento Livros-Autores (38 registros - alguns livros têm múltiplos autores)
INSERT INTO LivrosAutores (id_livro, id_autor, ordem_autoria) VALUES
(1, 1, 1), (2, 2, 1), (3, 3, 1), (4, 4, 1), (5, 6, 1),
(6, 6, 1), (7, 7, 1), (8, 8, 1), (9, 9, 1), (10, 10, 1),
(11, 11, 1), (12, 12, 1), (13, 12, 1), (13, 13, 2),
(14, 14, 1), (15, 15, 1), (16, 15, 1), (17, 16, 1),
(18, 17, 1), (19, 18, 1), (20, 19, 1), (21, 20, 1),
(22, 11, 1), (22, 12, 2), (23, 1, 1), (24, 8, 1),
(25, 3, 1), (26, 11, 1), (27, 12, 1), (27, 14, 2),
(28, 17, 1), (29, 11, 1), (29, 13, 2), (29, 14, 3),
(30, 15, 1), (30, 16, 2);

-- Exemplares (50 registros - alguns livros têm múltiplas cópias)
INSERT INTO Exemplares (id_livro, codigo_exemplar, status, data_aquisicao, localizacao) VALUES
(1, 'LIV-001-A', 'Disponível', '2020-01-15', 'Prateleira A1'),
(1, 'LIV-001-B', 'Emprestado', '2020-01-15', 'Prateleira A1'),
(2, 'LIV-002-A', 'Disponível', '2020-02-10', 'Prateleira A2'),
(3, 'LIV-003-A', 'Emprestado', '2020-03-05', 'Prateleira A3'),
(3, 'LIV-003-B', 'Disponível', '2020-03-05', 'Prateleira A3'),
(4, 'LIV-004-A', 'Disponível', '2020-04-12', 'Prateleira A4'),
(5, 'LIV-005-A', 'Emprestado', '2019-05-20', 'Prateleira B1'),
(5, 'LIV-005-B', 'Disponível', '2019-05-20', 'Prateleira B1'),
(5, 'LIV-005-C', 'Emprestado', '2021-05-20', 'Prateleira B1'),
(6, 'LIV-006-A', 'Disponível', '2019-06-15', 'Prateleira B2'),
(7, 'LIV-007-A', 'Emprestado', '2020-07-22', 'Prateleira B3'),
(8, 'LIV-008-A', 'Disponível', '2020-08-18', 'Prateleira B4'),
(9, 'LIV-009-A', 'Emprestado', '2021-01-10', 'Prateleira C1'),
(10, 'LIV-010-A', 'Disponível', '2021-02-14', 'Prateleira C2'),
(11, 'LIV-011-A', 'Emprestado', '2021-03-20', 'Prateleira C3'),
(11, 'LIV-011-B', 'Emprestado', '2021-03-20', 'Prateleira C3'),
(11, 'LIV-011-C', 'Disponível', '2022-03-20', 'Prateleira C3'),
(12, 'LIV-012-A', 'Disponível', '2021-04-25', 'Prateleira C4'),
(12, 'LIV-012-B', 'Emprestado', '2021-04-25', 'Prateleira C4'),
(13, 'LIV-013-A', 'Disponível', '2021-05-30', 'Prateleira D1'),
(14, 'LIV-014-A', 'Emprestado', '2021-06-15', 'Prateleira D2'),
(14, 'LIV-014-B', 'Disponível', '2021-06-15', 'Prateleira D2'),
(15, 'LIV-015-A', 'Emprestado', '2022-01-10', 'Prateleira D3'),
(15, 'LIV-015-B', 'Disponível', '2022-01-10', 'Prateleira D3'),
(16, 'LIV-016-A', 'Disponível', '2022-02-20', 'Prateleira D4'),
(17, 'LIV-017-A', 'Emprestado', '2022-03-15', 'Prateleira E1'),
(18, 'LIV-018-A', 'Disponível', '2022-04-22', 'Prateleira E2'),
(19, 'LIV-019-A', 'Emprestado', '2022-05-30', 'Prateleira E3'),
(20, 'LIV-020-A', 'Disponível', '2022-06-18', 'Prateleira E4'),
(21, 'LIV-021-A', 'Emprestado', '2022-07-25', 'Prateleira F1'),
(22, 'LIV-022-A', 'Disponível', '2022-08-14', 'Prateleira F2'),
(23, 'LIV-023-A', 'Manutenção', '2019-09-20', 'Prateleira F3'),
(24, 'LIV-024-A', 'Emprestado', '2023-01-10', 'Prateleira F4'),
(24, 'LIV-024-B', 'Reservado', '2023-01-10', 'Prateleira F4'),
(25, 'LIV-025-A', 'Emprestado', '2023-02-15', 'Prateleira G1'),
(25, 'LIV-025-B', 'Disponível', '2023-02-15', 'Prateleira G1'),
(26, 'LIV-026-A', 'Disponível', '2023-03-20', 'Prateleira G2'),
(27, 'LIV-027-A', 'Emprestado', '2023-04-25', 'Prateleira G3'),
(28, 'LIV-028-A', 'Disponível', '2023-05-30', 'Prateleira G4'),
(29, 'LIV-029-A', 'Manutenção', '2023-06-15', 'Prateleira H1'),
(29, 'LIV-029-B', 'Disponível', '2023-06-15', 'Prateleira H1'),
(30, 'LIV-030-A', 'Disponível', '2023-07-20', 'Prateleira H2'),
(30, 'LIV-030-B', 'Manutenção', '2023-07-20', 'Prateleira H2'),
(1, 'LIV-001-C', 'Reservado', '2023-08-10', 'Prateleira A1'),
(11, 'LIV-011-D', 'Emprestado', '2024-01-15', 'Prateleira C3'),
(15, 'LIV-015-C', 'Emprestado', '2024-02-20', 'Prateleira D3'),
(5, 'LIV-005-D', 'Disponível', '2024-03-10', 'Prateleira B1'),
(12, 'LIV-012-C', 'Disponível', '2024-04-05', 'Prateleira C4'),
(14, 'LIV-014-C', 'Disponível', '2024-05-12', 'Prateleira D2'),
(24, 'LIV-024-C', 'Disponível', '2024-06-18', 'Prateleira F4');

-- Usuários (25 registros)
INSERT INTO Usuarios (cpf, nome_completo, email, telefone, id_tipo_usuario, status) VALUES
('12345678901', 'João Silva Santos', 'joao.silva@email.com', '11987654321', 1, 'Ativo'),
('23456789012', 'Maria Oliveira Costa', 'maria.oliveira@email.com', '11876543210', 1, 'Ativo'),
('34567890123', 'Carlos Alberto Souza', 'carlos.souza@email.com', '11765432109', 2, 'Ativo'),
('45678901234', 'Ana Paula Ferreira', 'ana.ferreira@email.com', '11654321098', 1, 'Ativo'),
('56789012345', 'Pedro Henrique Lima', 'pedro.lima@email.com', '11543210987', 1, 'Ativo'),
('67890123456', 'Juliana Rodrigues Alves', 'juliana.alves@email.com', '11432109876', 2, 'Ativo'),
('78901234567', 'Fernando Costa Martins', 'fernando.martins@email.com', '11321098765', 1, 'Ativo'),
('89012345678', 'Beatriz Santos Pereira', 'beatriz.pereira@email.com', '11210987654', 1, 'Ativo'),
('90123456789', 'Rafael Oliveira Barbosa', 'rafael.barbosa@email.com', '11109876543', 3, 'Ativo'),
('01234567890', 'Camila Souza Mendes', 'camila.mendes@email.com', '11998765432', 1, 'Ativo'),
('11223344556', 'Lucas Fernandes Rocha', 'lucas.rocha@email.com', '11887766554', 1, 'Ativo'),
('22334455667', 'Patricia Lima Cardoso', 'patricia.cardoso@email.com', '11776655443', 2, 'Ativo'),
('33445566778', 'Ricardo Almeida Nunes', 'ricardo.nunes@email.com', '11665544332', 1, 'Suspenso'),
('44556677889', 'Fernanda Costa Ribeiro', 'fernanda.ribeiro@email.com', '11554433221', 1, 'Ativo'),
('55667788990', 'Gustavo Santos Dias', 'gustavo.dias@email.com', '11443322110', 2, 'Ativo'),
('66778899001', 'Amanda Pereira Gomes', 'amanda.gomes@email.com', '11332211009', 1, 'Ativo'),
('77889900112', 'Bruno Oliveira Castro', 'bruno.castro@email.com', '11221100998', 3, 'Ativo'),
('88990011223', 'Larissa Rodrigues Silva', 'larissa.silva@email.com', '11110099887', 1, 'Ativo'),
('99001122334', 'Thiago Alves Monteiro', 'thiago.monteiro@email.com', '11009988776', 2, 'Ativo'),
('10111213141', 'Vanessa Lima Teixeira', 'vanessa.teixeira@email.com', '11998877665', 1, 'Ativo'),
('20212223242', 'Diego Souza Araújo', 'diego.araujo@email.com', '11887766554', 3, 'Ativo'),
('30313233343', 'Tatiana Costa Moreira', 'tatiana.moreira@email.com', '11776655443', 2, 'Ativo'),
('40414243444', 'Marcelo Santos Vieira', 'marcelo.vieira@email.com', '11665544332', 1, 'Suspenso'),
('50515253545', 'Gabriela Ferreira Cunha', 'gabriela.cunha@email.com', '11554433221', 1, 'Ativo'),
('60616263646', 'Rodrigo Almeida Pinto', 'rodrigo.pinto@email.com', '11443322110', 1, 'Inativo');

-- ============================================================================
-- SEÇÃO 3: DADOS TRANSACIONAIS
-- ============================================================================

-- Empréstimos (30 registros - mix de ativos, devolvidos e atrasados)
-- Empréstimos DEVOLVIDOS (15 registros)
INSERT INTO Emprestimos (id_usuario, id_exemplar, data_emprestimo, data_prevista_devolucao, data_devolucao_real, status_emprestimo) VALUES
(1, 2, '2025-09-01 10:00:00', '2025-09-15', '2025-09-14 14:30:00', 'Devolvido'),
(2, 7, '2025-09-05 11:00:00', '2025-09-19', '2025-09-18 16:00:00', 'Devolvido'),
(4, 11, '2025-09-10 09:30:00', '2025-09-24', '2025-09-23 10:00:00', 'Devolvido'),
(5, 17, '2025-09-12 14:00:00', '2025-09-26', '2025-09-25 15:30:00', 'Devolvido'),
(7, 23, '2025-09-15 10:30:00', '2025-09-29', '2025-09-28 11:00:00', 'Devolvido'),
(8, 28, '2025-09-18 13:00:00', '2025-10-02', '2025-10-01 14:00:00', 'Devolvido'),
(10, 33, '2025-09-20 15:00:00', '2025-10-04', '2025-10-03 16:30:00', 'Devolvido'),
(11, 38, '2025-09-22 09:00:00', '2025-10-06', '2025-10-05 10:00:00', 'Devolvido'),
(14, 19, '2025-09-25 11:30:00', '2025-10-09', '2025-10-08 12:00:00', 'Devolvido'),
(16, 24, '2025-09-28 14:30:00', '2025-10-12', '2025-10-11 15:00:00', 'Devolvido'),
(18, 30, '2025-10-01 10:00:00', '2025-10-15', '2025-10-14 11:00:00', 'Devolvido'),
(20, 36, '2025-10-03 13:00:00', '2025-10-17', '2025-10-16 14:00:00', 'Devolvido'),
(1, 41, '2025-10-05 09:30:00', '2025-10-19', '2025-10-18 10:30:00', 'Devolvido'),
(3, 48, '2025-10-08 15:00:00', '2025-11-07', '2025-10-22 16:00:00', 'Devolvido'),
(6, 50, '2025-10-10 11:00:00', '2025-11-09', '2025-10-24 12:00:00', 'Devolvido');

-- Empréstimos ATIVOS (10 registros - dentro do prazo)
INSERT INTO Emprestimos (id_usuario, id_exemplar, data_emprestimo, data_prevista_devolucao, data_devolucao_real, status_emprestimo) VALUES
(2, 4, '2025-11-05 10:00:00', '2025-11-19', NULL, 'Ativo'),
(5, 9, '2025-11-06 11:00:00', '2025-11-20', NULL, 'Ativo'),
(7, 16, '2025-11-07 09:30:00', '2025-11-21', NULL, 'Ativo'),
(10, 21, '2025-11-08 14:00:00', '2025-11-22', NULL, 'Ativo'),
(11, 25, '2025-11-09 10:30:00', '2025-11-23', NULL, 'Ativo'),
(14, 35, '2025-11-10 13:00:00', '2025-11-24', NULL, 'Ativo'),
(16, 45, '2025-11-11 15:00:00', '2025-11-25', NULL, 'Ativo'),
(18, 15, '2025-11-12 09:00:00', '2025-11-26', NULL, 'Ativo'),
(3, 46, '2025-11-13 11:30:00', '2025-12-13', NULL, 'Ativo'),
(6, 27, '2025-11-14 14:30:00', '2025-12-14', NULL, 'Ativo');

-- Empréstimos ATRASADOS (5 registros - prazo vencido)
INSERT INTO Emprestimos (id_usuario, id_exemplar, data_emprestimo, data_prevista_devolucao, data_devolucao_real, status_emprestimo) VALUES
(13, 3, '2025-10-01 10:00:00', '2025-10-15', NULL, 'Atrasado'),
(23, 5, '2025-10-05 11:00:00', '2025-10-19', NULL, 'Atrasado'),
(4, 14, '2025-10-08 09:30:00', '2025-10-22', NULL, 'Atrasado'),
(8, 19, '2025-10-10 14:00:00', '2025-10-24', NULL, 'Atrasado'),
(1, 37, '2025-10-12 10:30:00', '2025-10-26', NULL, 'Atrasado');

-- Multas (8 registros - para empréstimos atrasados)
-- Cálculo: R$ 2,00 por dia de atraso
-- 5 multas para empréstimos ainda atrasados (status Pendente)
INSERT INTO Multas (id_emprestimo, valor_multa, dias_atraso, status_pagamento, data_pagamento) VALUES
(26, 62.00, 31, 'Pendente', NULL),  -- Empréstimo 26: atrasado desde 2025-10-15 (31 dias)
(27, 54.00, 27, 'Pendente', NULL),  -- Empréstimo 27: atrasado desde 2025-10-19 (27 dias)
(28, 48.00, 24, 'Pendente', NULL),  -- Empréstimo 28: atrasado desde 2025-10-22 (24 dias)
(29, 44.00, 22, 'Pendente', NULL),  -- Empréstimo 29: atrasado desde 2025-10-24 (22 dias)
(30, 40.00, 20, 'Pendente', NULL);  -- Empréstimo 30: atrasado desde 2025-10-26 (20 dias)

-- 3 multas para empréstimos devolvidos com atraso (status Pago)
INSERT INTO Multas (id_emprestimo, valor_multa, dias_atraso, status_pagamento, data_pagamento) VALUES
(2, 10.00, 5, 'Pago', '2025-10-05 10:00:00'),   -- Devolvido 5 dias após prazo
(5, 8.00, 4, 'Pago', '2025-10-10 11:00:00'),    -- Devolvido 4 dias após prazo
(9, 6.00, 3, 'Pago', '2025-10-15 14:00:00');    -- Devolvido 3 dias após prazo

-- Reservas (5 registros)
INSERT INTO Reservas (id_usuario, id_livro, data_reserva, status_reserva, data_validade) VALUES
(13, 11, '2025-11-10 10:00:00', 'Ativa', '2025-11-17'),      -- Reserva ativa para livro muito procurado
(23, 15, '2025-11-11 11:00:00', 'Ativa', '2025-11-18'),      -- Reserva ativa
(4, 24, '2025-11-12 09:30:00', 'Ativa', '2025-11-19'),       -- Reserva ativa
(20, 5, '2025-11-01 14:00:00', 'Atendida', '2025-11-08'),    -- Já retirou o livro
(24, 1, '2025-10-20 10:30:00', 'Expirada', '2025-10-27');    -- Passou do prazo de retirada
