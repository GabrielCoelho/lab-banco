# CLAUDE.md - Instruções para Resolução da Prova de BD2

## 📋 CONTEXTO DO PROJETO

Você está auxiliando Gabriel, estudante de ADS (Análise e Desenvolvimento de Sistemas), na resolução de uma prova de Banco de Dados 2. O estudante possui conhecimento técnico em informática e está revisando conceitos de BD1.

### Objetivo

Resolver 5 questões de prova sobre Banco de Dados, gerando arquivos `.sql` individuais (questao_01.sql até questao_05.sql) com código comentado e explicações técnicas.

---

## 🗄️ BANCO DE DADOS: UNIVERSIDADE

O sistema possui 10 tabelas interrelacionadas:

### Estrutura Principal

- **Cursos** (id_curso, nome_curso, duracao_anos)
- **Departamentos** (id_departamento, nome_departamento, id_chefe)
- **Professores** (id_professor, nome_professor, data_nascimento, id_departamento)
- **Alunos** (id_aluno, nome_aluno, data_nascimento, endereco, id_curso)
- **Disciplinas** (id_disciplina, nome_disciplina, carga_horaria, id_departamento)
- **Salas** (id_sala, numero_sala, capacidade)
- **Turmas** (id_turma, ano, semestre, id_disciplina, id_professor, id_sala)
- **Matriculas** (id_matricula, id_aluno, id_turma, data_matricula)
- **Notas** (id_nota, id_matricula, valor_nota, tipo_avaliacao)
- **Funcionarios** (id_funcionario, nome_funcionario, cargo, data_contratacao)

### Relacionamentos Chave

- Alunos pertencem a Cursos (N:1)
- Professores pertencem a Departamentos (N:1)
- Turmas relacionam Disciplinas, Professores e Salas
- Matriculas relaciona Alunos e Turmas (N:N através de tabela associativa)
- Notas vinculadas a Matriculas

---

## 📝 QUESTÕES DA PROVA

### ✅ Questão 1: Stored Procedures (2 pontos) - RESOLVIDA

Criar procedure `ListarAlunosCurso` que recebe id_curso e retorna nomes de alunos, com tratamento para curso inexistente.

### ✅ Questão 2: Views (2 pontos) - RESOLVIDA

Criar view `ListaProfessoresDepartamentos` com JOIN entre Professores e Departamentos, incluindo justificativa de utilidade.

### ⏳ Questão 3: Triggers (2 pontos) - PENDENTE

Criar trigger `ValidarNotaAntesInserir` do tipo BEFORE INSERT na tabela Notas que valida se valor_nota está entre 0.0 e 10.0, lançando erro com SIGNAL se inválido.

### ⏳ Questão 4: Correção de Erro - Transações (2 pontos) - PENDENTE

Identificar 2+ erros no código de transação fornecido e corrigi-los.

**Código com erro:**

```sql
BEGIN TRANSACTION
INSERT INTO Matriculas (id_aluno id_turma, data_matricula) VALUES (1, 1, '2025-01-01');
COMMIT;
```

### ⏳ Questão 5: Correção de Erro - Stored Procedures e Triggers (2 pontos) - PENDENTE

Identificar 3+ erros no código de procedure e trigger fornecidos e corrigi-los.

**Código com erro:**

```sql
DELIMITER //
CREATE PROCEDURE InserirNota (
IN p_id_matricula INT
IN p_valor_nota REAL,
OUT p_mensagem VARCHAR(255)
)
BEGIN
IF p_valor_nota > 10 THEN
SET p_mensagem = 'Nota inválida!';
SIGNAL SQLSTATE '45000' MESSAGE_TEXT = p_mensagem;
ELSE
INSERT INTO Notas (id_matricula valor_nota) VALUES (p_id_matricula, p_valor_nota);
SET p_mensagem = 'Nota inserida!';
END IF
END //
DELIMITER ;

CREATE TRIGGER LogNota AFTER INSERT ON Notas
BEGIN
INSERT INTO LogNotas (mensagem) VALUES ('Nova nota inserida');
END;
```

---

## 🎯 ABORDAGEM DE ENSINO OBRIGATÓRIA

### 1. Estrutura das Respostas

Para cada questão, criar arquivo .sql com:

- **Cabeçalho**: Número da questão, pontuação, objetivo
- **Conceito**: Explicação teórica ANTES do código
- **Código SQL**: Completo, formatado, com comentários em cada seção
- **Exemplos de uso**: Comandos comentados para testar
- **Justificativa técnica**: Respostas dissertativas nos comentários

### 2. Padrão de Comentários

```sql
-- ============================================================================
-- QUESTÃO X: TÍTULO (X pontos)
-- ============================================================================
-- Objetivo: [descrição]
--
-- CONCEITO: [Explicação teórica]
-- [Vantagens, características, quando usar]
-- ============================================================================

-- Código principal com comentários linha a linha
DROP [OBJETO] IF EXISTS Nome;

DELIMITER //
CREATE [OBJETO] Nome (...)
BEGIN
    -- Explicação de cada bloco lógico
    [código]
END //
DELIMITER ;

-- ============================================================================
-- EXEMPLOS DE USO
-- ============================================================================
-- [Comandos comentados para testar]

-- ============================================================================
-- JUSTIFICATIVA TÉCNICA (Questão Dissertativa):
-- ============================================================================
-- [Resposta completa para partes dissertativas]
```

### 3. Requisitos Técnicos

- **Sempre incluir**: `DROP [OBJETO] IF EXISTS` antes de CREATE
- **Usar DELIMITER**: Para procedures e triggers
- **Nomenclatura**: Prefixos `p_` para parâmetros, `v_` para variáveis
- **Validações**: Tratar casos extremos e erros
- **Ordenação**: ORDER BY quando apropriado

### 4. Conceitos a Reforçar

- **Stored Procedures**: Parâmetros IN/OUT/INOUT, DECLARE, estruturas de controle
- **Views**: Tabelas virtuais, vantagens, casos de uso
- **Triggers**: BEFORE/AFTER, NEW/OLD, SIGNAL para erros
- **Transações**: START TRANSACTION, COMMIT, ROLLBACK
- **Tratamento de erros**: SIGNAL SQLSTATE, validações

---

## 📦 ENTREGA FINAL

Após resolver todas as questões, gerar comando para zipar:

```bash
zip -r prova_bd2_gabriel.zip questao_01.sql questao_02.sql questao_03.sql questao_04.sql questao_05.sql
```

---

## 🚀 PRÓXIMOS PASSOS

1. Resolver Questão 3 (Triggers)
2. Resolver Questão 4 (Correção - Transações)
3. Resolver Questão 5 (Correção - Procedures e Triggers)
4. Fornecer comando zip final

---

## 💡 OBSERVAÇÕES IMPORTANTES

- Cada resposta deve ser pedagogicamente completa
- Código deve ser executável diretamente no MySQL
- Explicações técnicas devem estar NOS COMENTÁRIOS do SQL
- Priorizar clareza e didática sobre concisão excessiva
- Validar lógica do código mentalmente antes de apresentar
- Usar exemplos do banco de dados universidade quando possível
