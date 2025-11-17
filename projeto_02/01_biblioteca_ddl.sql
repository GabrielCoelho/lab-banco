-- ============================================================================
-- SISTEMA DE GERENCIAMENTO DE BIBLIOTECA UNIVERSITÁRIA (SGBU)
-- ============================================================================
-- Disciplina: Banco de Dados 2
-- Estudante: Gabriel Coelho Soares
-- SGBD: MySQL 8.0+ / MariaDB 10.5+
-- ============================================================================
-- Criação do banco de dados
DROP DATABASE IF EXISTS biblioteca_universitaria;

CREATE DATABASE biblioteca_universitaria CHARACTER
SET
  utf8mb4 COLLATE utf8mb4_unicode_ci;

USE biblioteca_universitaria;

-- ============================================================================
-- TABELAS DE DOMÍNIO (sem dependências externas)
-- ============================================================================
-- Categorias de livros (Ficção, Técnico, Ciências, etc.)
CREATE TABLE Categorias (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nome_categoria VARCHAR(50) NOT NULL UNIQUE,
  descricao TEXT
) ENGINE = InnoDB;

-- Editoras
CREATE TABLE Editoras (
  id_editora INT AUTO_INCREMENT PRIMARY KEY,
  nome_editora VARCHAR(100) NOT NULL,
  pais VARCHAR(50),
  cidade VARCHAR(50),
  site VARCHAR(100)
) ENGINE = InnoDB;

-- Autores
CREATE TABLE Autores (
  id_autor INT AUTO_INCREMENT PRIMARY KEY,
  nome_autor VARCHAR(100) NOT NULL,
  nacionalidade VARCHAR(50),
  data_nascimento DATE
) ENGINE = InnoDB;

-- Tipos de usuário (Aluno, Professor, Funcionário)
CREATE TABLE TiposUsuario (
  id_tipo_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nome_tipo VARCHAR(30) NOT NULL UNIQUE,
  max_emprestimos INT DEFAULT 3 NOT NULL,
  prazo_dias INT DEFAULT 14 NOT NULL,
  CONSTRAINT CHK_max_emprestimos CHECK (max_emprestimos > 0),
  CONSTRAINT CHK_prazo_dias CHECK (prazo_dias > 0)
) ENGINE = InnoDB;

-- ============================================================================
-- TABELAS PRINCIPAIS (com dependências de domínio)
-- ============================================================================
-- Catálogo de livros (informações bibliográficas)
CREATE TABLE Livros (
  id_livro INT AUTO_INCREMENT PRIMARY KEY,
  isbn VARCHAR(13) NOT NULL UNIQUE,
  titulo VARCHAR(200) NOT NULL,
  ano_publicacao SMALLINT UNSIGNED,
  edicao INT DEFAULT 1,
  numero_paginas INT,
  idioma VARCHAR(30) DEFAULT 'Português',
  id_categoria INT NOT NULL,
  id_editora INT,
  CONSTRAINT FK_Livros_Categorias FOREIGN KEY (id_categoria) REFERENCES Categorias (id_categoria) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT FK_Livros_Editoras FOREIGN KEY (id_editora) REFERENCES Editoras (id_editora) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT CHK_edicao CHECK (edicao > 0),
  CONSTRAINT CHK_numero_paginas CHECK (numero_paginas > 0),
  CONSTRAINT CHK_ano_publicacao CHECK (
    ano_publicacao >= 1000
    AND ano_publicacao <= 2100
  )
) ENGINE = InnoDB;

CREATE INDEX IDX_Livros_ISBN ON Livros (isbn);

CREATE INDEX IDX_Livros_Titulo ON Livros (titulo);

-- Usuários da biblioteca
CREATE TABLE Usuarios (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  cpf VARCHAR(11) NOT NULL UNIQUE,
  nome_completo VARCHAR(150) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  telefone VARCHAR(15),
  data_cadastro DATE DEFAULT (CURRENT_DATE) NOT NULL,
  id_tipo_usuario INT NOT NULL,
  status ENUM ('Ativo', 'Suspenso', 'Inativo') DEFAULT 'Ativo' NOT NULL,
  CONSTRAINT FK_Usuarios_TiposUsuario FOREIGN KEY (id_tipo_usuario) REFERENCES TiposUsuario (id_tipo_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT CHK_cpf_length CHECK (CHAR_LENGTH(cpf) = 11)
) ENGINE = InnoDB;

CREATE INDEX IDX_Usuarios_CPF ON Usuarios (cpf);

CREATE INDEX IDX_Usuarios_Email ON Usuarios (email);

-- ============================================================================
-- TABELAS ASSOCIATIVAS E DEPENDENTES
-- ============================================================================
-- Relacionamento N:N entre Livros e Autores
CREATE TABLE LivrosAutores (
  id_livro INT NOT NULL,
  id_autor INT NOT NULL,
  ordem_autoria INT DEFAULT 1,
  PRIMARY KEY (id_livro, id_autor),
  CONSTRAINT FK_LivrosAutores_Livros FOREIGN KEY (id_livro) REFERENCES Livros (id_livro) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FK_LivrosAutores_Autores FOREIGN KEY (id_autor) REFERENCES Autores (id_autor) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT CHK_ordem_autoria CHECK (ordem_autoria > 0)
) ENGINE = InnoDB;

-- Exemplares físicos dos livros (controle de estoque)
CREATE TABLE Exemplares (
  id_exemplar INT AUTO_INCREMENT PRIMARY KEY,
  id_livro INT NOT NULL,
  codigo_exemplar VARCHAR(20) NOT NULL UNIQUE,
  status ENUM (
    'Disponível',
    'Emprestado',
    'Reservado',
    'Manutenção',
    'Perdido'
  ) DEFAULT 'Disponível' NOT NULL,
  data_aquisicao DATE,
  localizacao VARCHAR(50),
  CONSTRAINT FK_Exemplares_Livros FOREIGN KEY (id_livro) REFERENCES Livros (id_livro) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE INDEX IDX_Exemplares_Livro_Status ON Exemplares (id_livro, status);

CREATE INDEX IDX_Exemplares_Codigo ON Exemplares (codigo_exemplar);

-- ============================================================================
-- TABELAS TRANSACIONAIS (empréstimos, multas, reservas)
-- ============================================================================
-- Registro de empréstimos
CREATE TABLE Emprestimos (
  id_emprestimo INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_exemplar INT NOT NULL,
  data_emprestimo DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  data_prevista_devolucao DATE NOT NULL,
  data_devolucao_real DATETIME NULL,
  status_emprestimo ENUM ('Ativo', 'Devolvido', 'Atrasado') DEFAULT 'Ativo' NOT NULL,
  observacoes TEXT,
  CONSTRAINT FK_Emprestimos_Usuarios FOREIGN KEY (id_usuario) REFERENCES Usuarios (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT FK_Emprestimos_Exemplares FOREIGN KEY (id_exemplar) REFERENCES Exemplares (id_exemplar) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT CHK_data_prevista CHECK (data_prevista_devolucao >= DATE(data_emprestimo)),
  CONSTRAINT CHK_data_devolucao_real CHECK (
    data_devolucao_real IS NULL
    OR data_devolucao_real >= data_emprestimo
  )
) ENGINE = InnoDB;

CREATE INDEX IDX_Emprestimos_Usuario ON Emprestimos (id_usuario);

CREATE INDEX IDX_Emprestimos_Exemplar ON Emprestimos (id_exemplar);

CREATE INDEX IDX_Emprestimos_Status ON Emprestimos (status_emprestimo);

CREATE INDEX IDX_Emprestimos_Data ON Emprestimos (data_emprestimo);

-- Controle de multas por atraso
CREATE TABLE Multas (
  id_multa INT AUTO_INCREMENT PRIMARY KEY,
  id_emprestimo INT NOT NULL,
  valor_multa DECIMAL(10, 2) NOT NULL,
  dias_atraso INT NOT NULL,
  data_geracao DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  status_pagamento ENUM ('Pendente', 'Pago', 'Cancelado') DEFAULT 'Pendente' NOT NULL,
  data_pagamento DATETIME NULL,
  CONSTRAINT FK_Multas_Emprestimos FOREIGN KEY (id_emprestimo) REFERENCES Emprestimos (id_emprestimo) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT CHK_valor_multa CHECK (valor_multa >= 0),
  CONSTRAINT CHK_dias_atraso CHECK (dias_atraso > 0),
  CONSTRAINT CHK_data_pagamento CHECK (
    data_pagamento IS NULL
    OR data_pagamento >= data_geracao
  )
) ENGINE = InnoDB;

CREATE INDEX IDX_Multas_Emprestimo ON Multas (id_emprestimo);

CREATE INDEX IDX_Multas_Status ON Multas (status_pagamento);

-- Sistema de reservas
CREATE TABLE Reservas (
  id_reserva INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_livro INT NOT NULL,
  data_reserva DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  status_reserva ENUM ('Ativa', 'Atendida', 'Cancelada', 'Expirada') DEFAULT 'Ativa' NOT NULL,
  data_validade DATE,
  CONSTRAINT FK_Reservas_Usuarios FOREIGN KEY (id_usuario) REFERENCES Usuarios (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT FK_Reservas_Livros FOREIGN KEY (id_livro) REFERENCES Livros (id_livro) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT CHK_data_validade CHECK (
    data_validade IS NULL
    OR data_validade >= DATE(data_reserva)
  )
) ENGINE = InnoDB;

CREATE INDEX IDX_Reservas_Usuario ON Reservas (id_usuario);

CREATE INDEX IDX_Reservas_Livro ON Reservas (id_livro);

CREATE INDEX IDX_Reservas_Status ON Reservas (status_reserva);

CREATE INDEX IDX_Reservas_Data ON Reservas (data_reserva);

-- ============================================================================
-- DADOS INICIAIS
-- ============================================================================
INSERT INTO
  TiposUsuario (nome_tipo, max_emprestimos, prazo_dias)
VALUES
  ('Aluno', 3, 14),
  ('Professor', 5, 30),
  ('Funcionário', 4, 21),
  ('Visitante', 1, 7);
