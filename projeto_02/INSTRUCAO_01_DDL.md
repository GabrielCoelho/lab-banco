# 📋 INSTRUÇÃO 01: CRIAÇÃO DO BANCO DE DADOS (DDL)

## 🎯 OBJETIVO
Gerar o script SQL completo de criação do banco de dados para o **Sistema de Gerenciamento de Biblioteca Universitária (SGBU)**.

---

## 📚 CONTEXTO DO PROJETO

**Projeto:** Sistema de Gerenciamento de Biblioteca Universitária (SGBU)  
**Disciplina:** Banco de Dados 2  
**SGBD:** MySQL/MariaDB  
**Normalização:** Até 3FN (Terceira Forma Normal)  

### Requisitos Funcionais Principais:
- Cadastro de livros, autores, editoras e usuários
- Controle de empréstimos e devoluções
- Sistema de multas por atraso
- Reservas de livros
- Histórico de transações
- Relatórios estatísticos

---

## 🗂️ ESTRUTURA DE ENTIDADES OBRIGATÓRIAS

### Entidades Principais (10 tabelas mínimas):

1. **Categorias** - Classificação de livros (Ficção, Técnico, Ciências, etc.)
2. **Editoras** - Informações das editoras
3. **Autores** - Cadastro de autores
4. **Livros** - Informações bibliográficas dos livros
5. **LivrosAutores** - Relacionamento N:N entre Livros e Autores
6. **Exemplares** - Cópias físicas de cada livro (controle de estoque)
7. **TiposUsuario** - Perfis de usuário (Aluno, Professor, Funcionário)
8. **Usuarios** - Cadastro de usuários da biblioteca
9. **Emprestimos** - Registro de empréstimos
10. **Multas** - Controle de multas por atraso

### Entidades Complementares (opcional, mas recomendado):
11. **Reservas** - Fila de reserva para livros emprestados
12. **HistoricoEmprestimos** - Auditoria de todas as operações

---

## 📐 ESPECIFICAÇÕES TÉCNICAS

### Regras de Normalização:
- **1FN:** Todos os atributos devem ser atômicos (sem listas ou valores compostos)
- **2FN:** Eliminar dependências parciais (atributos devem depender da PK completa)
- **3FN:** Eliminar dependências transitivas (atributos não-chave não dependem de outros não-chave)

### Padrões de Nomenclatura:
- **Tabelas:** PascalCase no singular (ex: `Livro`, `Usuario`)
- **Colunas:** snake_case (ex: `id_livro`, `data_emprestimo`)
- **Chaves Primárias:** `id_<nome_tabela>` (ex: `id_livro`)
- **Chaves Estrangeiras:** `id_<tabela_referenciada>` (ex: `id_categoria`)

### Constraints Obrigatórias:
- PRIMARY KEY em todas as tabelas (AUTO_INCREMENT)
- FOREIGN KEY com `ON DELETE` e `ON UPDATE` apropriados
- NOT NULL em campos obrigatórios
- UNIQUE em campos que não podem repetir (ex: ISBN, CPF)
- CHECK constraints onde aplicável (ex: data_devolucao >= data_emprestimo)
- DEFAULT values quando relevante

### Índices Básicos:
- Índices automáticos em PKs e FKs
- Índice em ISBN (livros)
- Índice em CPF (usuários)
- Índice composto em (id_livro, status) para exemplares

---

## 📋 CAMPOS ESPECÍFICOS POR TABELA

### 1. Categorias
- `id_categoria` (PK, INT, AUTO_INCREMENT)
- `nome_categoria` (VARCHAR(50), NOT NULL, UNIQUE)
- `descricao` (TEXT)

### 2. Editoras
- `id_editora` (PK, INT, AUTO_INCREMENT)
- `nome_editora` (VARCHAR(100), NOT NULL)
- `pais` (VARCHAR(50))
- `cidade` (VARCHAR(50))
- `site` (VARCHAR(100))

### 3. Autores
- `id_autor` (PK, INT, AUTO_INCREMENT)
- `nome_autor` (VARCHAR(100), NOT NULL)
- `nacionalidade` (VARCHAR(50))
- `data_nascimento` (DATE)

### 4. Livros
- `id_livro` (PK, INT, AUTO_INCREMENT)
- `isbn` (VARCHAR(13), UNIQUE, NOT NULL)
- `titulo` (VARCHAR(200), NOT NULL)
- `ano_publicacao` (YEAR)
- `edicao` (INT, DEFAULT 1)
- `numero_paginas` (INT)
- `idioma` (VARCHAR(30), DEFAULT 'Português')
- `id_categoria` (FK → Categorias)
- `id_editora` (FK → Editoras)

### 5. LivrosAutores (tabela associativa)
- `id_livro` (FK → Livros, parte da PK composta)
- `id_autor` (FK → Autores, parte da PK composta)
- `ordem_autoria` (INT, DEFAULT 1) - para autores principais vs. secundários
- PRIMARY KEY (id_livro, id_autor)

### 6. Exemplares
- `id_exemplar` (PK, INT, AUTO_INCREMENT)
- `id_livro` (FK → Livros, NOT NULL)
- `codigo_exemplar` (VARCHAR(20), UNIQUE, NOT NULL) - código de barras/localização
- `status` (ENUM('Disponível', 'Emprestado', 'Reservado', 'Manutenção', 'Perdido'), DEFAULT 'Disponível')
- `data_aquisicao` (DATE)
- `localizacao` (VARCHAR(50)) - ex: "Prateleira A3"

### 7. TiposUsuario
- `id_tipo_usuario` (PK, INT, AUTO_INCREMENT)
- `nome_tipo` (VARCHAR(30), UNIQUE, NOT NULL) - ex: Aluno, Professor, Funcionário
- `max_emprestimos` (INT, DEFAULT 3) - limite de empréstimos simultâneos
- `prazo_dias` (INT, DEFAULT 14) - prazo padrão de devolução

### 8. Usuarios
- `id_usuario` (PK, INT, AUTO_INCREMENT)
- `cpf` (VARCHAR(11), UNIQUE, NOT NULL)
- `nome_completo` (VARCHAR(150), NOT NULL)
- `email` (VARCHAR(100), UNIQUE, NOT NULL)
- `telefone` (VARCHAR(15))
- `data_cadastro` (DATE, DEFAULT CURRENT_DATE)
- `id_tipo_usuario` (FK → TiposUsuario, NOT NULL)
- `status` (ENUM('Ativo', 'Suspenso', 'Inativo'), DEFAULT 'Ativo')

### 9. Emprestimos
- `id_emprestimo` (PK, INT, AUTO_INCREMENT)
- `id_usuario` (FK → Usuarios, NOT NULL)
- `id_exemplar` (FK → Exemplares, NOT NULL)
- `data_emprestimo` (DATETIME, DEFAULT CURRENT_TIMESTAMP)
- `data_prevista_devolucao` (DATE, NOT NULL)
- `data_devolucao_real` (DATETIME, NULL) - NULL enquanto não devolvido
- `status_emprestimo` (ENUM('Ativo', 'Devolvido', 'Atrasado'), DEFAULT 'Ativo')
- `observacoes` (TEXT)

### 10. Multas
- `id_multa` (PK, INT, AUTO_INCREMENT)
- `id_emprestimo` (FK → Emprestimos, NOT NULL)
- `valor_multa` (DECIMAL(10,2), NOT NULL)
- `dias_atraso` (INT, NOT NULL)
- `data_geracao` (DATETIME, DEFAULT CURRENT_TIMESTAMP)
- `status_pagamento` (ENUM('Pendente', 'Pago', 'Cancelado'), DEFAULT 'Pendente')
- `data_pagamento` (DATETIME, NULL)

### 11. Reservas (opcional)
- `id_reserva` (PK, INT, AUTO_INCREMENT)
- `id_usuario` (FK → Usuarios, NOT NULL)
- `id_livro` (FK → Livros, NOT NULL)
- `data_reserva` (DATETIME, DEFAULT CURRENT_TIMESTAMP)
- `status_reserva` (ENUM('Ativa', 'Atendida', 'Cancelada', 'Expirada'), DEFAULT 'Ativa')
- `data_validade` (DATE) - prazo para retirar quando disponível

---

## 🎯 REQUISITOS DO SCRIPT A GERAR

### Estrutura do Arquivo:
```sql
-- Cabeçalho com informações do projeto
-- Seção 1: DROP/CREATE DATABASE
-- Seção 2: Tabelas de domínio (sem dependências)
-- Seção 3: Tabelas principais (com FKs para domínio)
-- Seção 4: Tabelas associativas
-- Seção 5: Tabelas transacionais (empréstimos, multas)
-- Seção 6: Índices adicionais (além dos automáticos)
-- Comentários explicativos ao longo de todo o script
```

### Características Obrigatórias:
1. ✅ Criar banco com charset UTF-8 (utf8mb4)
2. ✅ Comentários explicando propósito de cada tabela
3. ✅ Constraints com nomes explícitos (ex: `FK_Livros_Categorias`)
4. ✅ ON DELETE e ON UPDATE consistentes com regras de negócio:
   - `CASCADE` para dependências fortes (ex: Livro → Exemplares)
   - `RESTRICT` para dados críticos (ex: não deletar categoria se tem livros)
   - `SET NULL` quando aplicável
5. ✅ Valores DEFAULT apropriados
6. ✅ CHECK constraints (quando o SGBD suportar)
7. ✅ Ordem de criação respeitando dependências (FKs só referenciam tabelas já criadas)

### Regras de Negócio a Implementar via Constraints:
- Livro deve ter pelo menos 1 autor
- Exemplar só pode ser emprestado se status = 'Disponível'
- Data de devolução prevista deve ser maior que data de empréstimo
- Multa só existe se há atraso (dias_atraso > 0)
- Usuário não pode ter mais empréstimos que o limite do seu tipo

---

## 📤 FORMATO DE SAÍDA ESPERADO

**Nome do arquivo:** `01_create_database.sql`

**Estrutura:**
- Comentários detalhados
- Código limpo e indentado
- Organizado por seções lógicas
- Pronto para executar sem erros
- Compatível com MySQL 8.0+ / MariaDB 10.5+

---

## ✅ CHECKLIST DE VALIDAÇÃO

Antes de considerar completo, verificar:
- [ ] Todas as 10 tabelas obrigatórias foram criadas
- [ ] Normalização 3FN foi respeitada (sem dependências transitivas)
- [ ] Todas as PKs são AUTO_INCREMENT
- [ ] Todas as FKs têm ON DELETE/UPDATE definidos
- [ ] Campos obrigatórios têm NOT NULL
- [ ] Campos únicos têm UNIQUE
- [ ] ENUMs têm valores apropriados
- [ ] Tipos de dados são adequados (VARCHAR tamanhos corretos, DECIMAL para dinheiro)
- [ ] Comentários explicam decisões de design
- [ ] Script executa sem erros no MySQL/MariaDB

---

## 🚀 PROMPT PARA IA

**"Gere o script SQL completo seguindo todas as especificações acima. O arquivo deve ser executável, bem comentado e seguir as melhores práticas de design de banco de dados relacional. Priorize clareza e organização."**
