# 📋 INSTRUÇÃO 02: INSERÇÃO DE DADOS INICIAIS (DML)

## 🎯 OBJETIVO
Gerar o script SQL de inserção de dados para popular o banco de dados **SGBU** com pelo menos **150 registros realistas** distribuídos estrategicamente.

---

## 📚 CONTEXTO DO PROJETO

**Projeto:** Sistema de Gerenciamento de Biblioteca Universitária (SGBU)  
**Pré-requisito:** Banco criado via `01_create_database.sql`  
**Objetivo:** Dados de teste realistas para validar funcionalidades e performance  

---

## 📊 DISTRIBUIÇÃO MÍNIMA DE REGISTROS

### Tabelas de Domínio:
- **Categorias:** 10 registros (Ficção, Não-ficção, Técnico, Ciências, História, etc.)
- **Editoras:** 8 registros (nacionais e internacionais)
- **Autores:** 20 registros (variados, nacionais e internacionais)
- **TiposUsuario:** 3 registros (Aluno, Professor, Funcionário)

### Tabelas Principais:
- **Livros:** 30 registros (diversificados em categorias e editoras)
- **LivrosAutores:** 35+ registros (alguns livros têm múltiplos autores)
- **Exemplares:** 50 registros (alguns livros têm múltiplas cópias)
- **Usuarios:** 25 registros (mix de alunos, professores e funcionários)

### Tabelas Transacionais:
- **Emprestimos:** 30 registros (alguns ativos, alguns devolvidos, alguns atrasados)
- **Multas:** 8 registros (apenas para empréstimos atrasados)
- **Reservas:** 5 registros (opcional)

**Total:** 150+ registros

---

## 🎨 REQUISITOS DE REALISMO

### Dados devem ser:
1. **Brasileiros quando aplicável:**
   - Nomes brasileiros para usuários e autores nacionais
   - Cidades brasileiras para editoras nacionais
   - CPFs válidos (formato correto, mesmo que fictícios)

2. **Diversificados:**
   - Mix de gêneros literários
   - Diferentes períodos (livros de 1980 até 2025)
   - Usuários de diferentes tipos com comportamentos variados

3. **Coerentes:**
   - ISBNs no formato correto (13 dígitos)
   - Datas lógicas (data_emprestimo < data_prevista_devolucao)
   - Status consistentes (livro emprestado tem exemplar com status 'Emprestado')
   - Multas só para empréstimos atrasados

4. **Úteis para testes:**
   - Alguns livros SEM exemplares disponíveis (todos emprestados)
   - Alguns usuários COM múltiplos empréstimos ativos
   - Alguns usuários COM multas pendentes
   - Alguns livros COM reservas ativas
   - Casos de sucesso E casos de exceção

---

## 📋 ESPECIFICAÇÕES POR TABELA

### 1. Categorias (10 registros)
```
Exemplos esperados:
- Ficção Literária
- Ficção Científica
- Romance
- Tecnologia e Computação
- Ciências Exatas
- Ciências Humanas
- História
- Biografia
- Autoajuda
- Referência
```

### 2. Editoras (8 registros)
```
Exemplos esperados:
- Companhia das Letras (São Paulo, Brasil)
- Editora Globo (Porto Alegre, Brasil)
- Aleph (São Paulo, Brasil)
- Penguin Random House (EUA)
- HarperCollins (Reino Unido)
- Planeta (Barcelona, Espanha)
- Casa do Código (São Paulo, Brasil)
- O'Reilly Media (EUA)
```

### 3. Autores (20 registros)
```
Mix esperado:
- Autores brasileiros: Machado de Assis, Clarice Lispector, Paulo Coelho, etc.
- Autores internacionais clássicos: George Orwell, Virginia Woolf, etc.
- Autores técnicos: Robert Martin, Martin Fowler, etc.
- Autores contemporâneos variados
```

### 4. TiposUsuario (3 registros)
```
| Tipo       | max_emprestimos | prazo_dias |
|------------|----------------|------------|
| Aluno      | 3              | 14         |
| Professor  | 5              | 30         |
| Funcionário| 3              | 21         |
```

### 5. Livros (30 registros)
```
Distribuição esperada:
- 10 livros de Ficção (vários subgêneros)
- 8 livros técnicos (programação, engenharia, etc.)
- 5 livros de ciências
- 4 livros de história/biografia
- 3 livros de referência

Variação de características:
- Anos: 1950-2025
- Edições: 1ª até 5ª edição
- Páginas: 100-800
- Idiomas: maioria português, alguns inglês/espanhol
```

### 6. LivrosAutores (35+ registros)
```
Distribuição:
- Maioria dos livros (25) tem 1 autor
- 5 livros têm 2 autores (usar ordem_autoria 1 e 2)
- 2 livros têm 3 autores
```

### 7. Exemplares (50 registros)
```
Distribuição de status:
- 25 'Disponível'
- 20 'Emprestado' (devem corresponder a empréstimos ativos)
- 3 'Manutenção'
- 2 'Reservado'

Alguns livros populares devem ter 2-3 cópias
Código de exemplar: formato "LIV-001-A", "LIV-001-B", etc.
```

### 8. Usuarios (25 registros)
```
Distribuição:
- 15 Alunos (60%)
- 7 Professores (28%)
- 3 Funcionários (12%)

Mix de status:
- 22 Ativos
- 2 Suspensos (usuários com multas não pagas)
- 1 Inativo

CPFs devem ter formato 11 dígitos (podem ser fictícios mas formatados corretamente)
Emails devem seguir padrão realista (nome.sobrenome@dominio.com)
```

### 9. Emprestimos (30 registros)
```
Distribuição de status:
- 15 'Devolvido' (data_devolucao_real preenchida, sem atraso)
- 10 'Ativo' (data_devolucao_real NULL, dentro do prazo)
- 5 'Atrasado' (data_devolucao_real NULL, prazo vencido)

Datas:
- Empréstimos devolvidos: entre 60-10 dias atrás
- Empréstimos ativos: entre 10-1 dias atrás
- Empréstimos atrasados: entre 30-15 dias atrás (vencidos)

Prazo de devolução: usar o prazo_dias do tipo de usuário
```

### 10. Multas (8 registros)
```
Apenas para os 5 empréstimos atrasados + 3 devolvidos com atraso

Cálculo de multa:
- R$ 2,00 por dia de atraso
- dias_atraso = diferença entre data_prevista e data_devolucao_real (ou data atual se ainda não devolvido)
- valor_multa = dias_atraso * 2.00

Status:
- 3 'Pago' (com data_pagamento)
- 5 'Pendente' (data_pagamento NULL)
```

### 11. Reservas (5 registros - opcional)
```
Casos:
- 3 reservas 'Ativa' (para livros todos emprestados)
- 1 'Atendida' (usuário já retirou)
- 1 'Expirada' (passou do prazo de retirada)

data_validade: 7 dias após a reserva
```

---

## 🎯 REQUISITOS DO SCRIPT A GERAR

### Estrutura do Arquivo:
```sql
-- Cabeçalho com informações
-- Comentário sobre ordem de inserção (respeitar FKs)
-- Seção 1: Dados de Domínio (Categorias, Editoras, Autores, TiposUsuario)
-- Seção 2: Dados Principais (Livros, LivrosAutores, Exemplares, Usuarios)
-- Seção 3: Dados Transacionais (Emprestimos, Multas, Reservas)
-- Comentários indicando o que cada bloco insere
```

### Características Obrigatórias:
1. ✅ Usar INSERT com múltiplos VALUES (até 10 por comando)
2. ✅ Comentar blocos explicando tipo de dados inseridos
3. ✅ Dados realistas (nomes, datas, valores plausíveis)
4. ✅ Respeitar ordem de dependências (FKs válidas)
5. ✅ IDs previsíveis (para facilitar referência posterior)
6. ✅ Datas usando formato SQL padrão (YYYY-MM-DD ou YYYY-MM-DD HH:MM:SS)
7. ✅ Caracteres especiais escapados corretamente
8. ✅ Casos de teste variados (incluir situações de exceção)

### Regras de Coerência:
- Todo exemplar 'Emprestado' deve ter um empréstimo ativo correspondente
- Todo empréstimo 'Atrasado' deve ter uma multa correspondente
- Número de empréstimos ativos por usuário não deve exceder max_emprestimos
- Datas devem fazer sentido cronológico
- Status devem ser consistentes entre tabelas relacionadas

---

## 📤 FORMATO DE SAÍDA ESPERADO

**Nome do arquivo:** `02_insert_data.sql`

**Estrutura:**
- Comentários indicando seções
- Dados organizados logicamente
- Fácil de ler e modificar
- Pronto para executar após `01_create_database.sql`

---

## ✅ CHECKLIST DE VALIDAÇÃO

Antes de considerar completo, verificar:
- [ ] Mínimo de 150 registros distribuídos
- [ ] Todos os INSERTs respeitam constraints (NOT NULL, UNIQUE, FK)
- [ ] Dados são realistas e variados
- [ ] Há casos de teste para todas as situações relevantes:
  - [ ] Livros disponíveis e indisponíveis
  - [ ] Usuários com e sem empréstimos ativos
  - [ ] Usuários com e sem multas
  - [ ] Empréstimos em todos os status
  - [ ] Multas pagas e pendentes
- [ ] Datas são coerentes (passado razoável, não futuro)
- [ ] IDs são sequenciais e previsíveis
- [ ] Script executa sem erros após o DDL

---

## 💡 DICAS DE GERAÇÃO

### Para gerar dados realistas rapidamente:
- Use variações de nomes brasileiros comuns
- ISBNs podem ser fictícios mas devem ter 13 dígitos
- CPFs podem usar geradores online ou formato 000.000.000-XX
- Datas: use CURDATE() - INTERVAL X DAY para calcular datas relativas

### Exemplo de INSERT eficiente:
```sql
INSERT INTO Usuarios (cpf, nome_completo, email, telefone, id_tipo_usuario, status) VALUES
('12345678901', 'João Silva Santos', 'joao.silva@email.com', '11987654321', 1, 'Ativo'),
('98765432109', 'Maria Oliveira Costa', 'maria.oliveira@email.com', '11876543210', 1, 'Ativo'),
('45678912345', 'Carlos Alberto Souza', 'carlos.souza@email.com', '11765432109', 2, 'Ativo');
```

---

## 🚀 PROMPT PARA IA

**"Gere o script SQL de inserção de dados seguindo todas as especificações acima. Os dados devem ser realistas, diversificados e criar cenários úteis para testes. Priorize coerência entre tabelas relacionadas e inclua comentários explicativos."**
