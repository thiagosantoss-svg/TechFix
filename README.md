[README.md](https://github.com/user-attachments/files/34239621/README.md)
# TechFix Solutions – Banco de Dados

Trabalho acadêmico da disciplina de **Banco de Dados** – Universidade Cidade de São Paulo (UNICID), 2026.

A TechFix Solutions é uma assistência técnica de pequeno porte que conserta celulares, notebooks e tablets, vende acessórios no balcão e mantém estoque de peças. Hoje tudo é controlado em planilhas e papel, e cada setor enxerga só uma parte da informação. Este projeto propõe um banco de dados central (base de um ERP) que integra atendimento, bancada técnica, estoque e compras, e financeiro.

## Conteúdo do repositório

```
TechFix/
├── README.md
├── database/
│   └── techfix.sql                  # script MySQL: tabelas, dados, consultas e auditorias
└── docs/
    └── TechFix_Documentacao.pdf     # documentação completa do trabalho
```

## O que o sistema cobre

- Cadastros de clientes, aparelhos, funcionários, serviços, produtos e fornecedores
- Ordem de serviço (OS) com diagnóstico, orçamento, aprovação do cliente, serviços executados, peças usadas e técnicos envolvidos
- Controle de estoque por movimentações, compras e vendas de produtos
- Financeiro: contas a receber, contas a pagar e fluxo de caixa
- Relatórios de produtividade, faturamento, serviços, peças e caixa

Fora do escopo desta fase: folha de pagamento e RH, nota fiscal e impostos, integração com bancos e maquininhas, agendamento de atendimentos.

## Como executar

**Opção 1 – Online (OneCompiler):**
abra https://onecompiler.com/mysql/457wbtg55 e clique em **Run**.

**Opção 2 – MySQL local:**

```bash
mysql -u seu_usuario -p nome_do_banco < database/techfix.sql
```

> Requer **MySQL 8.0** (usa `DEFAULT (CURRENT_DATE)` e restrições `CHECK`).
> O script não cria o banco de dados: crie e selecione um antes de executar (`CREATE DATABASE techfix; USE techfix;`).

## O que o script contém

1. **Criação das tabelas** com chaves primárias, estrangeiras, `UNIQUE`, `NOT NULL`, `CHECK` e `DEFAULT`
2. **Massa de dados** fictícia e coerente (clientes, funcionários, OS, orçamentos, compras, vendas, estoque e pagamentos)
3. **Consultas simples** e **JOINs** (`INNER JOIN` e `LEFT JOIN`)
4. **UPDATE e DELETE controlados**, sempre com `SELECT` antes e depois
5. **13 consultas gerenciais** (valor por OS, faturamento por mês, produtividade dos técnicos, saldo de estoque, contas a receber, fluxo de caixa, entre outras)
6. **Consultas de auditoria** das regras de negócio (RN)
7. **Testes de violação** comentados, para conferir cada restrição (descomente um por vez)

### Sobre as irregularidades propositais

Alguns registros foram inseridos **de propósito** com problemas (por exemplo: OS em manutenção sem técnico, orçamento aprovado sem data de decisão, compra recebida sem entrada no estoque, pagamento estornado sem motivo). Eles servem para provar que as consultas de auditoria encontram violações das regras de negócio. Cada caso está identificado no script pelo comentário `irregular de propósito`.

## Documentação

O PDF em [`docs/`](docs/TechFix_Documentacao.pdf) reúne: caracterização da empresa, justificativa, problemas identificados, processos de negócio, requisitos e regras de negócio, DER dividido em quatro módulos, normalização, modelo lógico, dicionário de dados, massa de dados e relatórios.

## Integrantes

- _Adicione aqui o nome dos integrantes da equipe_
