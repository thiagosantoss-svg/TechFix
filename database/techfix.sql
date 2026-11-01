-- Usa o banco de dados já selecionado pelo editor (sem permissão para criar bancos)

-- Tabelas principais
CREATE TABLE cliente (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  cpf CHAR(11) NOT NULL UNIQUE,
  telefone VARCHAR(20), email VARCHAR(100) UNIQUE,
  logradouro VARCHAR(120), numero VARCHAR(15), complemento VARCHAR(80), bairro VARCHAR(60), cidade VARCHAR(60), estado CHAR(2), cep CHAR(8),
  data_cadastro DATE NOT NULL DEFAULT (CURRENT_DATE),
  situacao VARCHAR(10) NOT NULL DEFAULT 'ATIVO' CHECK (situacao IN ('ATIVO','INATIVO'))
) ENGINE=InnoDB;

CREATE TABLE funcionario (
  id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  cpf CHAR(11) NOT NULL UNIQUE,
  telefone VARCHAR(20),
  cargo VARCHAR(12) NOT NULL CHECK (cargo IN ('ATENDENTE','TECNICO','GERENTE')),
  situacao VARCHAR(10) NOT NULL DEFAULT 'ATIVO' CHECK (situacao IN ('ATIVO','INATIVO'))
) ENGINE=InnoDB;

CREATE TABLE funcionario_especialidade (
  id_funcionario INT NOT NULL,
  especialidade VARCHAR(50) NOT NULL,
  PRIMARY KEY (id_funcionario, especialidade),
  FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE usuario (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  id_funcionario INT NOT NULL UNIQUE,
  login VARCHAR(50) NOT NULL UNIQUE,
  senha_protegida VARCHAR(255) NOT NULL,
  perfil_acesso VARCHAR(12) NOT NULL CHECK (perfil_acesso IN ('ATENDENTE','TECNICO','GERENTE')),
  situacao VARCHAR(10) NOT NULL DEFAULT 'ATIVO' CHECK (situacao IN ('ATIVO','BLOQUEADO')),
  FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE servico (
  id_servico INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL UNIQUE,
  descricao TEXT,
  valor_base_mao_obra DECIMAL(10,2) NOT NULL CHECK (valor_base_mao_obra > 0),
  tempo_medio_horas DECIMAL(5,1) NOT NULL CHECK (tempo_medio_horas > 0),
  prazo_garantia_padrao_dias INT NOT NULL DEFAULT 0 CHECK (prazo_garantia_padrao_dias >= 0),
  situacao VARCHAR(10) NOT NULL DEFAULT 'ATIVO' CHECK (situacao IN ('ATIVO','INATIVO'))
) ENGINE=InnoDB;

CREATE TABLE produto (
  id_produto INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(30) NOT NULL UNIQUE,
  nome VARCHAR(100) NOT NULL,
  descricao TEXT,
  tipo VARCHAR(15) NOT NULL CHECK (tipo IN ('PECA','PRODUTO_VENDA')),
  preco_venda DECIMAL(10,2) NOT NULL CHECK (preco_venda > 0),
  quantidade_minima INT NOT NULL DEFAULT 0 CHECK (quantidade_minima >= 0),
  situacao VARCHAR(10) NOT NULL DEFAULT 'ATIVO' CHECK (situacao IN ('ATIVO','INATIVO'))
) ENGINE=InnoDB;

CREATE TABLE fornecedor (
  id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
  razao_social VARCHAR(120) NOT NULL,
  cnpj CHAR(14) NOT NULL UNIQUE,
  telefone VARCHAR(20), email VARCHAR(100),
  logradouro VARCHAR(120), numero VARCHAR(15), complemento VARCHAR(80), bairro VARCHAR(60), cidade VARCHAR(60), estado CHAR(2), cep CHAR(8),
  aprovado VARCHAR(3) NOT NULL DEFAULT 'NAO' CHECK (aprovado IN ('SIM','NAO')),
  situacao VARCHAR(10) NOT NULL DEFAULT 'ATIVO' CHECK (situacao IN ('ATIVO','INATIVO'))
) ENGINE=InnoDB;

CREATE TABLE aparelho (
  id_aparelho INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  tipo VARCHAR(50) NOT NULL,
  marca VARCHAR(50) NOT NULL,
  modelo VARCHAR(80) NOT NULL,
  numero_serie_imei VARCHAR(80) NOT NULL UNIQUE,
  FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabelas operacionais e financeiras
CREATE TABLE ordem_servico (
  id_os INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  id_aparelho INT NOT NULL,
  id_funcionario_abertura INT NOT NULL,
  id_funcionario_aut_entrega INT,
  data_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  defeito_relatado TEXT NOT NULL,
  estado_fisico_entrada TEXT NOT NULL,
  senha_acesso_informada VARCHAR(100),
  status VARCHAR(30) NOT NULL DEFAULT 'RECEBIDO' CHECK (status IN ('RECEBIDO','EM_ANALISE','AGUARDANDO_APROVACAO','EM_MANUTENCAO','PRONTO_PARA_RETIRADA','ENTREGUE','CANCELADO')),
  data_previsao_entrega DATE,
  data_conclusao DATE,
  data_entrega DATE,
  entrega_com_pendencia VARCHAR(3) NOT NULL DEFAULT 'NAO' CHECK (entrega_com_pendencia IN ('SIM','NAO')),
  FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT,
  FOREIGN KEY (id_aparelho) REFERENCES aparelho(id_aparelho) ON DELETE RESTRICT,
  FOREIGN KEY (id_funcionario_abertura) REFERENCES funcionario(id_funcionario) ON DELETE RESTRICT,
  FOREIGN KEY (id_funcionario_aut_entrega) REFERENCES funcionario(id_funcionario) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE diagnostico (
  id_diagnostico INT AUTO_INCREMENT PRIMARY KEY,
  id_os INT NOT NULL,
  id_funcionario INT NOT NULL,
  descricao TEXT NOT NULL,
  data_diagnostico DATE NOT NULL,
  observacoes TEXT,
  FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os) ON DELETE RESTRICT,
  FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE alocacao_tecnico (
  id_os INT NOT NULL,
  id_funcionario INT NOT NULL,
  funcao VARCHAR(10) NOT NULL CHECK (funcao IN ('PRINCIPAL','AUXILIAR')),
  data_atribuicao DATE NOT NULL,
  horas_trabalhadas DECIMAL(5,1) NOT NULL DEFAULT 0 CHECK (horas_trabalhadas >= 0),
  PRIMARY KEY (id_os, id_funcionario),
  FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os) ON DELETE RESTRICT,
  FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE orcamento (
  id_orcamento INT AUTO_INCREMENT PRIMARY KEY,
  id_os INT NOT NULL,
  tipo VARCHAR(12) NOT NULL CHECK (tipo IN ('INICIAL','ADICIONAL')),
  versao INT NOT NULL DEFAULT 1 CHECK (versao >= 1),
  data_emissao DATE NOT NULL,
  status VARCHAR(12) NOT NULL DEFAULT 'PENDENTE' CHECK (status IN ('PENDENTE','APROVADO','RECUSADO','SUBSTITUIDO')),
  data_decisao DATE,
  forma_confirmacao VARCHAR(12) CHECK (forma_confirmacao IN ('PRESENCIAL','TELEFONE','WHATSAPP','EMAIL')),
  motivo_recusa TEXT,
  observacoes TEXT,
  FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE orcamento_servico (
  id_orcamento INT NOT NULL,
  id_servico INT NOT NULL,
  quantidade INT NOT NULL CHECK (quantidade > 0),
  valor_unitario DECIMAL(10,2) NOT NULL CHECK (valor_unitario > 0),
  PRIMARY KEY (id_orcamento, id_servico),
  FOREIGN KEY (id_orcamento) REFERENCES orcamento(id_orcamento) ON DELETE RESTRICT,
  FOREIGN KEY (id_servico) REFERENCES servico(id_servico) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE orcamento_peca (
  id_orcamento INT NOT NULL,
  id_produto INT NOT NULL,
  quantidade INT NOT NULL CHECK (quantidade > 0),
  valor_unitario DECIMAL(10,2) NOT NULL CHECK (valor_unitario > 0),
  PRIMARY KEY (id_orcamento, id_produto),
  FOREIGN KEY (id_orcamento) REFERENCES orcamento(id_orcamento) ON DELETE RESTRICT,
  FOREIGN KEY (id_produto) REFERENCES produto(id_produto) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE os_servico (
  id_os INT NOT NULL,
  id_servico INT NOT NULL,
  quantidade INT NOT NULL CHECK (quantidade > 0),
  valor_cobrado DECIMAL(10,2) NOT NULL CHECK (valor_cobrado > 0),
  prazo_garantia_dias INT NOT NULL DEFAULT 0 CHECK (prazo_garantia_dias >= 0),
  data_execucao DATE NOT NULL,
  PRIMARY KEY (id_os, id_servico),
  FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os) ON DELETE RESTRICT,
  FOREIGN KEY (id_servico) REFERENCES servico(id_servico) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE os_peca (
  id_os INT NOT NULL,
  id_produto INT NOT NULL,
  quantidade INT NOT NULL CHECK (quantidade > 0),
  valor_unitario DECIMAL(10,2) NOT NULL CHECK (valor_unitario > 0),
  data_utilizacao DATE NOT NULL,
  PRIMARY KEY (id_os, id_produto),
  FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os) ON DELETE RESTRICT,
  FOREIGN KEY (id_produto) REFERENCES produto(id_produto) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE compra (
  id_compra INT AUTO_INCREMENT PRIMARY KEY,
  id_fornecedor INT NOT NULL,
  id_funcionario INT NOT NULL,
  data_compra DATE NOT NULL,
  numero_documento VARCHAR(50),
  condicao_pagamento VARCHAR(10) NOT NULL CHECK (condicao_pagamento IN ('A_VISTA','A_PRAZO')),
  status VARCHAR(12) NOT NULL DEFAULT 'REGISTRADA' CHECK (status IN ('REGISTRADA','RECEBIDA','CANCELADA')),
  data_recebimento DATE,
  FOREIGN KEY (id_fornecedor) REFERENCES fornecedor(id_fornecedor) ON DELETE RESTRICT,
  FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE item_compra (
  id_compra INT NOT NULL,
  id_produto INT NOT NULL,
  quantidade INT NOT NULL CHECK (quantidade > 0),
  custo_unitario DECIMAL(10,2) NOT NULL CHECK (custo_unitario > 0),
  PRIMARY KEY (id_compra, id_produto),
  FOREIGN KEY (id_compra) REFERENCES compra(id_compra) ON DELETE RESTRICT,
  FOREIGN KEY (id_produto) REFERENCES produto(id_produto) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE parcela_pagar (
  id_compra INT NOT NULL,
  numero_parcela INT NOT NULL,
  valor_parcela DECIMAL(10,2) NOT NULL CHECK (valor_parcela > 0),
  data_vencimento DATE NOT NULL,
  situacao VARCHAR(10) NOT NULL DEFAULT 'ABERTA' CHECK (situacao IN ('ABERTA','PAGA','CANCELADA')),
  data_pagamento DATE,
  valor_pago DECIMAL(10,2),
  forma_pagamento VARCHAR(15) CHECK (forma_pagamento IN ('DINHEIRO','PIX','CARTAO_DEBITO','CARTAO_CREDITO','BOLETO')),
  PRIMARY KEY (id_compra, numero_parcela),
  FOREIGN KEY (id_compra) REFERENCES compra(id_compra) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE venda (
  id_venda INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  id_funcionario INT NOT NULL,
  data_venda DATE NOT NULL,
  status VARCHAR(10) NOT NULL DEFAULT 'CONCLUIDA' CHECK (status IN ('CONCLUIDA','CANCELADA')),
  FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT,
  FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE item_venda (
  id_venda INT NOT NULL,
  id_produto INT NOT NULL,
  quantidade INT NOT NULL CHECK (quantidade > 0),
  preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario > 0),
  PRIMARY KEY (id_venda, id_produto),
  FOREIGN KEY (id_venda) REFERENCES venda(id_venda) ON DELETE RESTRICT,
  FOREIGN KEY (id_produto) REFERENCES produto(id_produto) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE movimentacao_estoque (
  id_movimentacao INT AUTO_INCREMENT PRIMARY KEY,
  id_produto INT NOT NULL,
  id_funcionario INT NOT NULL,
  id_funcionario_autorizador INT,
  id_os INT,
  id_compra INT,
  id_venda INT,
  tipo VARCHAR(12) NOT NULL CHECK (tipo IN ('ENTRADA','SAIDA_OS','SAIDA_VENDA','DESCARTE','AJUSTE')),
  quantidade INT NOT NULL CHECK (quantidade > 0),
  data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  motivo TEXT,
  saida_sem_saldo VARCHAR(3) NOT NULL DEFAULT 'NAO' CHECK (saida_sem_saldo IN ('SIM','NAO')),
  CHECK (tipo <> 'ENTRADA' OR id_compra IS NOT NULL),
  CHECK (tipo <> 'SAIDA_OS' OR id_os IS NOT NULL),
  CHECK (tipo <> 'SAIDA_VENDA' OR id_venda IS NOT NULL),
  CHECK (tipo NOT IN ('DESCARTE','AJUSTE') OR motivo IS NOT NULL),
  CHECK (saida_sem_saldo <> 'SIM' OR id_funcionario_autorizador IS NOT NULL),
  FOREIGN KEY (id_produto) REFERENCES produto(id_produto) ON DELETE RESTRICT,
  FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario) ON DELETE RESTRICT,
  FOREIGN KEY (id_funcionario_autorizador) REFERENCES funcionario(id_funcionario) ON DELETE RESTRICT,
  FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os) ON DELETE RESTRICT,
  FOREIGN KEY (id_compra) REFERENCES compra(id_compra) ON DELETE RESTRICT,
  FOREIGN KEY (id_venda) REFERENCES venda(id_venda) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE conta_receber (
  id_conta_receber INT AUTO_INCREMENT PRIMARY KEY,
  id_os INT UNIQUE,
  id_venda INT UNIQUE,
  data_emissao DATE NOT NULL,
  valor_total DECIMAL(10,2) NOT NULL CHECK (valor_total > 0),
  situacao VARCHAR(20) NOT NULL DEFAULT 'EM_ABERTO' CHECK (situacao IN ('EM_ABERTO','PARCIALMENTE_PAGA','QUITADA','CANCELADA')),
  CHECK ((id_os IS NOT NULL AND id_venda IS NULL) OR (id_os IS NULL AND id_venda IS NOT NULL)),
  FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os) ON DELETE RESTRICT,
  FOREIGN KEY (id_venda) REFERENCES venda(id_venda) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE parcela_receber (
  id_conta_receber INT NOT NULL,
  numero_parcela INT NOT NULL,
  valor_parcela DECIMAL(10,2) NOT NULL CHECK (valor_parcela > 0),
  data_vencimento DATE NOT NULL,
  situacao VARCHAR(20) NOT NULL DEFAULT 'ABERTA' CHECK (situacao IN ('ABERTA','PARCIALMENTE_PAGA','PAGA','CANCELADA')),
  PRIMARY KEY (id_conta_receber, numero_parcela),
  FOREIGN KEY (id_conta_receber) REFERENCES conta_receber(id_conta_receber) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE pagamento (
  id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
  id_conta_receber INT NOT NULL,
  numero_parcela INT NOT NULL,
  id_funcionario INT NOT NULL,
  id_funcionario_estorno INT,
  data_pagamento DATE NOT NULL,
  valor_pago DECIMAL(10,2) NOT NULL CHECK (valor_pago > 0),
  forma_pagamento VARCHAR(15) NOT NULL CHECK (forma_pagamento IN ('DINHEIRO','PIX','CARTAO_DEBITO','CARTAO_CREDITO')),
  status VARCHAR(10) NOT NULL DEFAULT 'EFETIVADO' CHECK (status IN ('EFETIVADO','ESTORNADO')),
  data_estorno DATE,
  motivo_estorno TEXT,
  FOREIGN KEY (id_conta_receber, numero_parcela) REFERENCES parcela_receber(id_conta_receber, numero_parcela) ON DELETE RESTRICT,
  FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario) ON DELETE RESTRICT,
  FOREIGN KEY (id_funcionario_estorno) REFERENCES funcionario(id_funcionario) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Dados-base: clientes, funcionários, usuários, catálogo e fornecedores
INSERT INTO cliente (id_cliente,nome,cpf,telefone,email,cidade,estado,data_cadastro,situacao) VALUES
(1,'Ana Ribeiro','10000000001','11990000001','ana@email.com','Sao Paulo','SP','2026-01-02','ATIVO'),
(2,'Bruno Lima','10000000002','11990000002','bruno@email.com','Sao Paulo','SP','2026-01-03','ATIVO'),
(3,'Carla Souza','10000000003','11990000003','carla@email.com','Campinas','SP','2026-01-04','ATIVO'),
(4,'Diego Alves','10000000004','11990000004','diego@email.com','Santos','SP','2026-01-05','ATIVO'),
(5,'Eva Martins','10000000005','11990000005','eva@email.com','Sao Paulo','SP','2026-01-06','INATIVO'),
(6,'Fabio Costa','10000000006','11990000006','fabio@email.com','Jundiai','SP','2026-01-07','ATIVO');

INSERT INTO funcionario (id_funcionario,nome,cpf,telefone,cargo,situacao) VALUES
(1,'Marina Gerente','20000000001','11330000001','GERENTE','ATIVO'),
(2,'Paulo Atendente','20000000002','11330000002','ATENDENTE','ATIVO'),
(3,'Rita Tecnica','20000000003','11330000003','TECNICO','ATIVO'),
(4,'Sergio Tecnico','20000000004','11330000004','TECNICO','ATIVO'),
(5,'Tiago Tecnico','20000000005','11330000005','TECNICO','ATIVO');

INSERT INTO funcionario_especialidade (id_funcionario,especialidade) VALUES
(3,'Smartphones'),(3,'Tablets'),(4,'Notebooks'),(5,'Audio e video');

INSERT INTO usuario (id_usuario,id_funcionario,login,senha_protegida,perfil_acesso,situacao) VALUES
(1,1,'marina.g','$2y$10$hashficticio01','GERENTE','ATIVO'),
(2,2,'paulo.a','$2y$10$hashficticio02','ATENDENTE','ATIVO'),
(3,3,'rita.t','$2y$10$hashficticio03','TECNICO','ATIVO'),
(4,4,'sergio.t','$2y$10$hashficticio04','TECNICO','ATIVO'),
(5,5,'tiago.t','$2y$10$hashficticio05','TECNICO','ATIVO');

INSERT INTO servico (id_servico,nome,descricao,valor_base_mao_obra,tempo_medio_horas,prazo_garantia_padrao_dias) VALUES
(1,'Troca de tela','Substituicao do conjunto de tela',150.00,2.0,90),
(2,'Diagnostico eletronico','Testes de placa e componentes',80.00,1.0,30),
(3,'Troca de bateria','Substituicao de bateria',95.00,1.0,90),
(4,'Reparo de conector','Reparo de conector de carga',120.00,1.5,60),
(5,'Limpeza interna','Limpeza e revisao interna',70.00,1.0,30),
(6,'Instalacao de software','Instalacao e configuracao',60.00,1.0,15);

INSERT INTO produto (id_produto,codigo,nome,descricao,tipo,preco_venda,quantidade_minima,situacao) VALUES
(1,'P-TELA-01','Tela smartphone A','Tela de reposicao','PECA',250.00,2,'ATIVO'),
(2,'P-BAT-01','Bateria smartphone A','Bateria de reposicao','PECA',120.00,2,'ATIVO'),
(3,'P-CABO-01','Cabo flexivel','Cabo interno de reposicao','PECA',20.00,3,'ATIVO'),
(4,'P-CONEC-01','Conector de carga','Conector de reposicao','PECA',10.00,3,'ATIVO'),
(5,'P-SSD-01','SSD 480GB','Unidade para reparo','PECA',220.00,1,'ATIVO'),
(6,'V-FONE-01','Fone bluetooth','Acessorio para venda','PRODUTO_VENDA',80.00,2,'ATIVO'),
(7,'V-CAPA-01','Capa protetora','Acessorio para venda','PRODUTO_VENDA',35.00,2,'ATIVO'),
(8,'V-CARREG-01','Carregador USB','Acessorio para venda','PRODUTO_VENDA',45.00,2,'ATIVO');

INSERT INTO fornecedor (id_fornecedor,razao_social,cnpj,telefone,email,cidade,estado,aprovado,situacao) VALUES
(1,'Pecas Brasil Ltda','30000000000001','11334400001','vendas@pecasbrasil.com','Sao Paulo','SP','SIM','ATIVO'),
(2,'Eletronica Central SA','30000000000002','11334400002','contato@central.com','Campinas','SP','SIM','ATIVO'),
(3,'Distribuidora Nova','30000000000003','11334400003','vendas@nova.com','Santos','SP','NAO','ATIVO');

-- Aparelhos: o cliente 6 fica sem aparelho
INSERT INTO aparelho (id_aparelho,id_cliente,tipo,marca,modelo,numero_serie_imei) VALUES
(1,1,'Smartphone','Marca A','A1','IMEI000000000001'),
(2,2,'Notebook','Marca B','B2','IMEI000000000002'),
(3,3,'Smartphone','Marca C','C3','IMEI000000000003'),
(4,4,'Tablet','Marca D','D4','IMEI000000000004'),
(5,5,'Smartphone','Marca E','E5','IMEI000000000005'),
(6,1,'Smartphone','Marca A','A2','IMEI000000000006'),
(7,2,'Notebook','Marca B','B3','IMEI000000000007');

-- irregular de propósito: OS 4 em manutencao sem tecnico nem orcamento aprovado; auditorias 1 e 13.
-- irregular de propósito: OS 6 entregue com pendencia, sem autorizador e conta nao quitada; auditorias 2 e 3.
-- irregular de propósito: OS 7 aponta cliente diferente do dono do aparelho; auditoria 8.
-- Ordens: OS 4, 6, 7 e 8 concentram irregularidades intencionais
INSERT INTO ordem_servico (id_os,id_cliente,id_aparelho,id_funcionario_abertura,id_funcionario_aut_entrega,data_abertura,defeito_relatado,estado_fisico_entrada,status,data_previsao_entrega,data_conclusao,data_entrega,entrega_com_pendencia) VALUES
(1,1,1,2,1,'2026-01-05 09:00:00','Tela quebrada','Riscos leves','ENTREGUE','2026-01-10','2026-01-09','2026-01-10','NAO'),
(2,2,2,2,1,'2026-01-08 10:00:00','Notebook lento','Bom estado','PRONTO_PARA_RETIRADA','2026-01-20',NULL,NULL,'NAO'),
(3,3,3,2,NULL,'2026-02-01 11:00:00','Nao liga','Sem danos aparentes','RECEBIDO','2026-02-15',NULL,NULL,'NAO'),
(4,4,4,2,NULL,'2026-02-02 12:00:00','Falha intermitente','Trinca na carcaça','EM_MANUTENCAO','2026-02-20',NULL,NULL,'NAO'),
(5,5,5,2,NULL,'2026-02-03 13:00:00','Bateria descarrega','Bom estado','EM_ANALISE','2026-02-18',NULL,NULL,'NAO'),
(6,1,6,2,NULL,'2026-02-04 14:00:00','Falha apos reparo','Marcas de uso','ENTREGUE','2026-02-12','2026-02-11','2026-02-12','SIM'),
(7,3,7,2,NULL,'2026-02-05 15:00:00','Ruido no equipamento','Bom estado','RECEBIDO','2026-02-25',NULL,NULL,'NAO'),
(8,2,2,2,NULL,'2026-02-06 16:00:00','Acessorio com defeito','Embalagem avariada','CANCELADO',NULL,NULL,NULL,'NAO');

INSERT INTO diagnostico (id_diagnostico,id_os,id_funcionario,descricao,data_diagnostico,observacoes) VALUES
(1,1,3,'Tela danificada e demais funcoes operacionais','2026-01-06','Substituir modulo'),
(2,2,4,'SSD com desempenho reduzido','2026-01-09','Recomendada troca'),
(3,5,5,'Bateria com capacidade reduzida','2026-02-04','Aguardar testes adicionais');

-- irregular de propósito: funcionario ATENDENTE alocado na OS 8; auditoria 9.
INSERT INTO alocacao_tecnico (id_os,id_funcionario,funcao,data_atribuicao,horas_trabalhadas) VALUES
(1,3,'PRINCIPAL','2026-01-06',2.5),
(1,4,'AUXILIAR','2026-01-06',1.0),
(2,4,'PRINCIPAL','2026-01-09',3.0),
(5,3,'PRINCIPAL','2026-02-04',1.5),
(5,5,'AUXILIAR','2026-02-04',1.0),
(6,5,'PRINCIPAL','2026-02-05',2.0),
(7,4,'PRINCIPAL','2026-02-06',0.5),
(8,2,'PRINCIPAL','2026-02-06',0.5);

-- irregular de propósito: orcamento 6 aprovado sem decisao nem forma de confirmacao; auditoria 12.
INSERT INTO orcamento (id_orcamento,id_os,tipo,versao,data_emissao,status,data_decisao,forma_confirmacao,motivo_recusa,observacoes) VALUES
(1,1,'INICIAL',1,'2026-01-06','APROVADO','2026-01-06','WHATSAPP',NULL,'Orcamento aprovado'),
(2,2,'INICIAL',1,'2026-01-10','SUBSTITUIDO','2026-01-11','TELEFONE','Cliente pediu ajuste','Versao anterior'),
(3,2,'INICIAL',2,'2026-01-12','APROVADO','2026-01-13','WHATSAPP',NULL,'Nova versao aprovada'),
(4,1,'ADICIONAL',1,'2026-01-08','APROVADO','2026-01-08','PRESENCIAL',NULL,'Servico adicional'),
(5,5,'INICIAL',1,'2026-02-05','PENDENTE',NULL,NULL,NULL,'Aguardando aprovacao'),
(6,6,'INICIAL',1,'2026-02-06','APROVADO',NULL,NULL,NULL,'-- irregular de propósito: auditoria 12 (orcamentos aprovados sem data_decisao ou forma_confirmacao)'),
(7,7,'INICIAL',1,'2026-02-07','RECUSADO','2026-02-08','EMAIL','Cliente nao autorizou','Orcamento recusado');

INSERT INTO orcamento_servico (id_orcamento,id_servico,quantidade,valor_unitario) VALUES
(1,1,1,150.00),(1,2,1,80.00),(2,5,1,70.00),(3,5,1,70.00),(4,6,1,60.00),(5,3,1,95.00),(6,4,1,120.00),(7,2,1,80.00);
INSERT INTO orcamento_peca (id_orcamento,id_produto,quantidade,valor_unitario) VALUES
(1,1,1,250.00),(1,3,1,20.00),(1,4,1,10.00),(2,5,1,220.00),(3,5,1,220.00),(5,2,1,120.00),(6,4,1,10.00),(7,3,1,20.00);

-- Itens efetivamente executados e utilizados
INSERT INTO os_servico (id_os,id_servico,quantidade,valor_cobrado,prazo_garantia_dias,data_execucao) VALUES
(1,1,1,150.00,90,'2026-01-09'),(1,2,1,80.00,30,'2026-01-09'),(2,5,1,70.00,30,'2026-01-15'),(5,3,1,95.00,90,'2026-02-07');
-- irregular de propósito: produto PRODUTO_VENDA utilizado como peca na OS 8; auditoria 10.
INSERT INTO os_peca (id_os,id_produto,quantidade,valor_unitario,data_utilizacao) VALUES
(1,1,1,250.00,'2026-01-09'),(1,3,1,20.00,'2026-01-09'),(1,4,1,10.00,'2026-01-09'),(2,5,1,220.00,'2026-01-15'),(8,6,1,80.00,'2026-02-07');

-- irregular de propósito: compra 2 recebida sem movimentacao de entrada (auditoria 14) e com parcelas divergentes dos itens (auditoria 15).
-- Compras e itens: compra 2 irregular de propósito (sem entrada e valores de parcelas divergentes)
INSERT INTO compra (id_compra,id_fornecedor,id_funcionario,data_compra,numero_documento,condicao_pagamento,status,data_recebimento) VALUES
(1,1,2,'2026-01-04','NF-100','A_VISTA','RECEBIDA','2026-01-05'),
(2,2,2,'2026-02-01','NF-200','A_PRAZO','RECEBIDA','2026-02-03'),
(3,3,2,'2026-02-10','PED-300','A_PRAZO','REGISTRADA',NULL);
INSERT INTO item_compra (id_compra,id_produto,quantidade,custo_unitario) VALUES
(1,1,4,150.00),(1,3,10,8.00),(1,4,8,4.00),(1,6,1,40.00),
(2,2,5,70.00),(2,5,2,150.00),
(3,6,5,40.00);
INSERT INTO parcela_pagar (id_compra,numero_parcela,valor_parcela,data_vencimento,situacao,data_pagamento,valor_pago,forma_pagamento) VALUES
(1,1,752.00,'2026-01-05','PAGA','2026-01-05',752.00,'PIX'),
(2,1,500.00,'2026-02-10','ABERTA',NULL,NULL,NULL),
(2,2,500.00,'2026-04-10','ABERTA',NULL,NULL,NULL),
(3,1,100.00,'2026-03-10','ABERTA',NULL,NULL,NULL),
(3,2,100.00,'2026-04-10','ABERTA',NULL,NULL,NULL);

-- Vendas e contas a receber
INSERT INTO venda (id_venda,id_cliente,id_funcionario,data_venda,status) VALUES
(1,2,2,'2026-01-12','CONCLUIDA'),(2,4,2,'2026-02-08','CONCLUIDA'),(3,5,2,'2026-02-12','CONCLUIDA');
INSERT INTO item_venda (id_venda,id_produto,quantidade,preco_unitario) VALUES
(1,6,1,80.00),(1,1,1,250.00),(2,7,2,35.00),(3,8,1,45.00);

-- irregular de propósito: conta 3 da OS 6 tem parcela total menor que valor_total; auditoria 7.
-- Contas e parcelas de recebimento
INSERT INTO conta_receber (id_conta_receber,id_os,id_venda,data_emissao,valor_total,situacao) VALUES
(1,1,NULL,'2026-01-10',510.00,'QUITADA'),
(2,2,NULL,'2026-01-20',800.00,'EM_ABERTO'),
(3,6,NULL,'2026-02-12',200.00,'EM_ABERTO'),
(4,NULL,1,'2026-01-12',330.00,'QUITADA'),
(5,NULL,2,'2026-02-08',70.00,'EM_ABERTO'),
(6,NULL,3,'2026-02-12',45.00,'EM_ABERTO');
-- irregular de propósito: parcelas 2 e 3 da conta 2 vencem sem pagamento no conjunto de teste; auditoria 6.
INSERT INTO parcela_receber (id_conta_receber,numero_parcela,valor_parcela,data_vencimento,situacao) VALUES
(1,1,510.00,'2026-01-10','PAGA'),
(2,1,200.00,'2026-01-20','ABERTA'),(2,2,200.00,'2026-02-20','ABERTA'),(2,3,200.00,'2026-03-20','ABERTA'),(2,4,200.00,'2026-04-20','ABERTA'),
(3,1,100.00,'2026-02-12','ABERTA'),
(4,1,330.00,'2026-01-12','PAGA'),(5,1,70.00,'2026-03-08','ABERTA'),(6,1,45.00,'2026-03-12','ABERTA');

-- irregular de propósito: saida sem saldo autorizada gera saldo negativo do produto 8; auditorias 4 e 5.
-- Movimentacoes: compra 2 sem entrada e uma saida sem saldo para gerar saldo negativo
INSERT INTO movimentacao_estoque (id_movimentacao,id_produto,id_funcionario,id_funcionario_autorizador,id_os,id_compra,id_venda,tipo,quantidade,data_hora,motivo,saida_sem_saldo) VALUES
(1,1,2,NULL,NULL,1,NULL,'ENTRADA',4,'2026-01-05 09:00:00',NULL,'NAO'),
(2,3,2,NULL,NULL,1,NULL,'ENTRADA',10,'2026-01-05 09:05:00',NULL,'NAO'),
(3,4,2,NULL,NULL,1,NULL,'ENTRADA',8,'2026-01-05 09:10:00',NULL,'NAO'),
(16,6,2,NULL,NULL,1,NULL,'ENTRADA',1,'2026-01-05 09:15:00',NULL,'NAO'),
(4,1,3,NULL,1,NULL,NULL,'SAIDA_OS',1,'2026-01-09 12:00:00',NULL,'NAO'),
(5,3,3,NULL,1,NULL,NULL,'SAIDA_OS',1,'2026-01-09 12:05:00',NULL,'NAO'),
(6,4,3,NULL,1,NULL,NULL,'SAIDA_OS',1,'2026-01-09 12:10:00',NULL,'NAO'),
(7,6,2,NULL,NULL,NULL,1,'SAIDA_VENDA',1,'2026-01-12 10:00:00',NULL,'NAO'),
(8,1,2,NULL,NULL,NULL,1,'SAIDA_VENDA',1,'2026-01-12 10:01:00',NULL,'NAO'),
(9,7,2,NULL,NULL,NULL,2,'SAIDA_VENDA',2,'2026-02-08 11:00:00',NULL,'NAO'),
(10,8,2,NULL,NULL,NULL,3,'SAIDA_VENDA',1,'2026-02-12 11:00:00',NULL,'NAO'),
(12,8,3,1,4,NULL,NULL,'SAIDA_OS',3,'2026-02-07 14:00:00','-- irregular de propósito: auditoria 4 e 5 (saida autorizada sem saldo; saldo negativo)','SIM'),
(13,1,2,NULL,NULL,1,NULL,'DESCARTE',1,'2026-02-10 09:00:00','Peca danificada','NAO'),
(14,1,2,NULL,NULL,NULL,NULL,'AJUSTE',1,'2026-02-11 09:00:00','Ajuste de inventario de teste','NAO'),
(15,7,2,NULL,NULL,NULL,NULL,'AJUSTE',1,'2026-02-12 09:00:00','Movimentacao de teste a remover','NAO');

-- irregular de propósito: pagamento 4 estornado sem motivo; auditoria 11.
-- Pagamentos: os dois efetivos da OS 1 somam R$ 510,00; ha estorno sem motivo intencional
INSERT INTO pagamento (id_pagamento,id_conta_receber,numero_parcela,id_funcionario,id_funcionario_estorno,data_pagamento,valor_pago,forma_pagamento,status,data_estorno,motivo_estorno) VALUES
(1,1,1,2,NULL,'2026-01-10',300.00,'PIX','EFETIVADO',NULL,NULL),
(2,1,1,2,NULL,'2026-01-10',210.00,'DINHEIRO','EFETIVADO',NULL,NULL),
(3,2,1,2,NULL,'2026-01-20',200.00,'PIX','EFETIVADO',NULL,NULL),
(4,3,1,2,1,'2026-02-13',50.00,'DINHEIRO','ESTORNADO','2026-02-14',NULL),
(5,4,1,2,NULL,'2026-01-12',330.00,'PIX','EFETIVADO',NULL,NULL);

-- Consultas simples: clientes ativos
SELECT id_cliente,nome,telefone FROM cliente WHERE situacao='ATIVO' ORDER BY nome;
-- Consultas simples: servicos com maior valor de mao de obra
SELECT id_servico,nome,valor_base_mao_obra FROM servico WHERE situacao='ATIVO' ORDER BY valor_base_mao_obra DESC;
-- Consultas simples: produtos abaixo do preco informado
SELECT id_produto,nome,tipo,preco_venda FROM produto WHERE preco_venda < 100 ORDER BY preco_venda;
-- Consultas simples: ordens abertas em ordem cronologica
SELECT id_os,id_cliente,status,data_abertura FROM ordem_servico WHERE status IN ('RECEBIDO','EM_ANALISE','AGUARDANDO_APROVACAO','EM_MANUTENCAO') ORDER BY data_abertura;

-- JOIN de quatro tabelas: cliente, aparelho, ordem e funcionario de abertura
SELECT c.nome AS cliente,a.modelo,o.id_os,o.status,f.nome AS atendente
FROM cliente c INNER JOIN aparelho a ON a.id_cliente=c.id_cliente
INNER JOIN ordem_servico o ON o.id_aparelho=a.id_aparelho
INNER JOIN funcionario f ON f.id_funcionario=o.id_funcionario_abertura
ORDER BY o.id_os;
-- LEFT JOIN: clientes que ainda nao possuem aparelho
SELECT c.id_cliente,c.nome FROM cliente c LEFT JOIN aparelho a ON a.id_cliente=c.id_cliente WHERE a.id_aparelho IS NULL;
-- LEFT JOIN: aparelhos que ainda nao possuem ordem de servico
SELECT a.id_aparelho,a.modelo FROM aparelho a LEFT JOIN ordem_servico o ON o.id_aparelho=a.id_aparelho WHERE o.id_os IS NULL;
-- LEFT JOIN: produtos que ainda nao possuem movimentacao registrada
SELECT p.id_produto,p.nome FROM produto p LEFT JOIN movimentacao_estoque m ON m.id_produto=p.id_produto WHERE m.id_movimentacao IS NULL;

-- UPDATE: antes e depois da mudanca de status da OS 5
SELECT id_os,status FROM ordem_servico WHERE id_os=5;
UPDATE ordem_servico SET status='PRONTO_PARA_RETIRADA',data_conclusao='2026-02-15' WHERE id_os=5;
SELECT id_os,status,data_conclusao FROM ordem_servico WHERE id_os=5;
-- UPDATE: antes e depois de marcar a parcela 1 da conta 2 como paga
SELECT id_conta_receber,numero_parcela,situacao FROM parcela_receber WHERE id_conta_receber=2 AND numero_parcela=1;
UPDATE parcela_receber SET situacao='PAGA' WHERE id_conta_receber=2 AND numero_parcela=1;
SELECT id_conta_receber,numero_parcela,situacao FROM parcela_receber WHERE id_conta_receber=2 AND numero_parcela=1;
-- UPDATE: antes e depois de atualizar a conta 2 para parcialmente paga
SELECT id_conta_receber,situacao FROM conta_receber WHERE id_conta_receber=2;
UPDATE conta_receber SET situacao='PARCIALMENTE_PAGA' WHERE id_conta_receber=2;
SELECT id_conta_receber,situacao FROM conta_receber WHERE id_conta_receber=2;
-- UPDATE: antes e depois da aprovacao do orcamento pendente da OS 5
SELECT id_orcamento,status,data_decisao,forma_confirmacao FROM orcamento WHERE id_orcamento=5;
UPDATE orcamento SET status='APROVADO',data_decisao='2026-02-08',forma_confirmacao='WHATSAPP' WHERE id_orcamento=5;
SELECT id_orcamento,status,data_decisao,forma_confirmacao FROM orcamento WHERE id_orcamento=5;
-- UPDATE: antes e depois de reajustar o preco de venda do produto 7
SELECT id_produto,nome,preco_venda FROM produto WHERE id_produto=7;
UPDATE produto SET preco_venda=37.00 WHERE id_produto=7;
SELECT id_produto,nome,preco_venda FROM produto WHERE id_produto=7;

-- DELETE controlado: remover alocacao auxiliar de teste sem apagar a alocacao principal
SELECT id_os,id_funcionario,funcao FROM alocacao_tecnico WHERE id_os=1 AND id_funcionario=4;
DELETE FROM alocacao_tecnico WHERE id_os=1 AND id_funcionario=4;
-- DELETE controlado: remover ajuste de estoque de teste do produto 7
SELECT id_movimentacao,id_produto,tipo,motivo FROM movimentacao_estoque WHERE id_movimentacao=15;
DELETE FROM movimentacao_estoque WHERE id_movimentacao=15;

-- Consultas gerenciais
-- 1. Valor total por OS: servicos executados mais pecas utilizadas
SELECT o.id_os,COALESCE(s.total_servicos,0)+COALESCE(p.total_pecas,0) AS valor_total_os
FROM ordem_servico o
LEFT JOIN (SELECT id_os,SUM(quantidade*valor_cobrado) AS total_servicos FROM os_servico GROUP BY id_os) s ON s.id_os=o.id_os
LEFT JOIN (SELECT id_os,SUM(quantidade*valor_unitario) AS total_pecas FROM os_peca GROUP BY id_os) p ON p.id_os=o.id_os
ORDER BY o.id_os;
-- 2. Faturamento por mes e forma de pagamento, considerando apenas pagamentos efetivados
SELECT DATE_FORMAT(data_pagamento,'%Y-%m') AS mes,forma_pagamento,SUM(valor_pago) AS faturamento,COUNT(*) AS quantidade_pagamentos
FROM pagamento WHERE status='EFETIVADO' GROUP BY DATE_FORMAT(data_pagamento,'%Y-%m'),forma_pagamento ORDER BY mes,forma_pagamento;
-- 3. Produtividade dos tecnicos: OS distintas, horas somadas e media de horas por OS
SELECT f.id_funcionario,f.nome,COUNT(DISTINCT a.id_os) AS quantidade_os,SUM(a.horas_trabalhadas) AS total_horas,AVG(a.horas_trabalhadas) AS media_horas
FROM funcionario f JOIN alocacao_tecnico a ON a.id_funcionario=f.id_funcionario
WHERE f.cargo='TECNICO' GROUP BY f.id_funcionario,f.nome HAVING COUNT(DISTINCT a.id_os)>0 ORDER BY total_horas DESC;
-- 4. Servicos mais realizados
SELECT s.id_servico,s.nome,SUM(os.quantidade) AS quantidade_realizada,COUNT(DISTINCT os.id_os) AS ordens
FROM servico s JOIN os_servico os ON os.id_servico=s.id_servico GROUP BY s.id_servico,s.nome HAVING SUM(os.quantidade)>0 ORDER BY quantidade_realizada DESC;
-- 5. Pecas mais usadas em ordens
SELECT p.id_produto,p.nome,SUM(op.quantidade) AS quantidade_usada,COUNT(DISTINCT op.id_os) AS ordens
FROM produto p JOIN os_peca op ON op.id_produto=p.id_produto GROUP BY p.id_produto,p.nome HAVING SUM(op.quantidade)>0 ORDER BY quantidade_usada DESC;
-- 6. Quantidade de OS por status
SELECT status,COUNT(*) AS quantidade_os FROM ordem_servico GROUP BY status ORDER BY quantidade_os DESC,status;
-- 7. Saldo do estoque por produto e indicacao dos itens abaixo do minimo
SELECT p.id_produto,p.nome,p.quantidade_minima,COALESCE(SUM(CASE WHEN m.tipo='ENTRADA' THEN m.quantidade ELSE -m.quantidade END),0) AS saldo,
CASE WHEN COALESCE(SUM(CASE WHEN m.tipo='ENTRADA' THEN m.quantidade ELSE -m.quantidade END),0)<p.quantidade_minima THEN 'SIM' ELSE 'NAO' END AS abaixo_minimo
FROM produto p LEFT JOIN movimentacao_estoque m ON m.id_produto=p.id_produto GROUP BY p.id_produto,p.nome,p.quantidade_minima ORDER BY saldo,p.nome;
-- 8. Contas a receber: total, recebido efetivamente e saldo
SELECT cr.id_conta_receber,cr.id_os,cr.id_venda,cr.valor_total,COALESCE(SUM(CASE WHEN pg.status='EFETIVADO' THEN pg.valor_pago ELSE 0 END),0) AS valor_recebido,
cr.valor_total-COALESCE(SUM(CASE WHEN pg.status='EFETIVADO' THEN pg.valor_pago ELSE 0 END),0) AS saldo_a_receber,cr.situacao
FROM conta_receber cr LEFT JOIN pagamento pg ON pg.id_conta_receber=cr.id_conta_receber GROUP BY cr.id_conta_receber,cr.id_os,cr.id_venda,cr.valor_total,cr.situacao ORDER BY cr.id_conta_receber;
-- 9. Clientes com mais ordens de servico
SELECT c.id_cliente,c.nome,COUNT(o.id_os) AS quantidade_os FROM cliente c JOIN ordem_servico o ON o.id_cliente=c.id_cliente
GROUP BY c.id_cliente,c.nome HAVING COUNT(o.id_os)>0 ORDER BY quantidade_os DESC,c.nome;
-- 10. Parcelas a pagar em aberto por fornecedor e vencimento
SELECT f.razao_social,pp.data_vencimento,COUNT(*) AS parcelas_abertas,SUM(pp.valor_parcela) AS valor_total_em_aberto
FROM fornecedor f JOIN compra co ON co.id_fornecedor=f.id_fornecedor JOIN parcela_pagar pp ON pp.id_compra=co.id_compra
WHERE pp.situacao='ABERTA' GROUP BY f.razao_social,pp.data_vencimento ORDER BY f.razao_social,pp.data_vencimento;
-- 11. Fluxo mensal com entradas/saidas efetivas e previstas
SELECT mes,SUM(entradas_efetivas) AS entradas_efetivas,SUM(saidas_efetivas) AS saidas_efetivas,SUM(entradas_previstas) AS entradas_previstas,SUM(saidas_previstas) AS saidas_previstas,
SUM(entradas_efetivas+entradas_previstas-saidas_efetivas-saidas_previstas) AS saldo_periodo
FROM (
 SELECT DATE_FORMAT(pg.data_pagamento,'%Y-%m') mes,pg.valor_pago entradas_efetivas,0 saidas_efetivas,0 entradas_previstas,0 saidas_previstas FROM pagamento pg WHERE pg.status='EFETIVADO'
 UNION ALL SELECT DATE_FORMAT(pp.data_pagamento,'%Y-%m'),0,pp.valor_pago,0,0 FROM parcela_pagar pp WHERE pp.situacao='PAGA' AND pp.data_pagamento IS NOT NULL
 UNION ALL SELECT DATE_FORMAT(pr.data_vencimento,'%Y-%m'),0,0,pr.valor_parcela,0 FROM parcela_receber pr WHERE pr.situacao IN ('ABERTA','PARCIALMENTE_PAGA')
 UNION ALL SELECT DATE_FORMAT(pp.data_vencimento,'%Y-%m'),0,0,0,pp.valor_parcela FROM parcela_pagar pp WHERE pp.situacao='ABERTA'
) fluxo GROUP BY mes ORDER BY mes;
-- 12. Quantidade de orcamentos por resultado e percentual de aprovacao
SELECT COUNT(*) AS total_orcamentos,SUM(status='APROVADO') AS aprovados,SUM(status='RECUSADO') AS recusados,SUM(status='SUBSTITUIDO') AS substituidos,
ROUND(100.0*SUM(status='APROVADO')/NULLIF(COUNT(*),0),2) AS percentual_aprovacao FROM orcamento;
-- 13. Receita de vendas por produto
SELECT p.id_produto,p.nome,SUM(iv.quantidade) AS unidades_vendidas,SUM(iv.quantidade*iv.preco_unitario) AS receita
FROM produto p JOIN item_venda iv ON iv.id_produto=p.id_produto JOIN venda v ON v.id_venda=iv.id_venda
WHERE v.status='CONCLUIDA' GROUP BY p.id_produto,p.nome HAVING SUM(iv.quantidade)>0 ORDER BY receita DESC;

-- Auditorias: regra RN10, OS em etapas de trabalho sem tecnico alocado
SELECT o.id_os,o.status FROM ordem_servico o LEFT JOIN alocacao_tecnico a ON a.id_os=o.id_os
WHERE o.status IN ('EM_ANALISE','AGUARDANDO_APROVACAO','EM_MANUTENCAO','PRONTO_PARA_RETIRADA') AND a.id_funcionario IS NULL;
-- Auditoria RN47: OS entregue, conta nao quitada e sem autorizacao de gerente na entrega
SELECT o.id_os,o.id_funcionario_aut_entrega,cr.id_conta_receber,cr.situacao FROM ordem_servico o JOIN conta_receber cr ON cr.id_os=o.id_os
WHERE o.status='ENTREGUE' AND cr.situacao<>'QUITADA' AND (o.id_funcionario_aut_entrega IS NULL OR NOT EXISTS (SELECT 1 FROM funcionario f WHERE f.id_funcionario=o.id_funcionario_aut_entrega AND f.cargo='GERENTE'));
-- Auditoria RN48: entrega com pendencia sem funcionario autorizador
SELECT id_os,status,entrega_com_pendencia,id_funcionario_aut_entrega FROM ordem_servico WHERE entrega_com_pendencia='SIM' AND id_funcionario_aut_entrega IS NULL;
-- Auditoria RN28: saidas sem saldo, exibindo registrador e autorizador
SELECT m.id_movimentacao,m.id_produto,m.tipo,m.quantidade,fr.nome AS funcionario_registrador,fa.nome AS funcionario_autorizador,m.saida_sem_saldo
FROM movimentacao_estoque m JOIN funcionario fr ON fr.id_funcionario=m.id_funcionario LEFT JOIN funcionario fa ON fa.id_funcionario=m.id_funcionario_autorizador
WHERE m.saida_sem_saldo='SIM';
-- Auditoria: produtos cujo saldo calculado ficou negativo
SELECT p.id_produto,p.nome,SUM(CASE WHEN m.tipo='ENTRADA' THEN m.quantidade ELSE -m.quantidade END) AS saldo
FROM produto p JOIN movimentacao_estoque m ON m.id_produto=p.id_produto GROUP BY p.id_produto,p.nome HAVING SUM(CASE WHEN m.tipo='ENTRADA' THEN m.quantidade ELSE -m.quantidade END)<0;
-- Auditoria: parcelas a receber vencidas e nao pagas
SELECT pr.id_conta_receber,pr.numero_parcela,pr.valor_parcela,pr.data_vencimento,pr.situacao FROM parcela_receber pr
WHERE pr.data_vencimento<CURDATE() AND pr.situacao<>'PAGA';
-- Auditoria RN41: total das parcelas diferente do total da conta
SELECT cr.id_conta_receber,cr.valor_total,COALESCE(SUM(pr.valor_parcela),0) AS total_parcelas
FROM conta_receber cr LEFT JOIN parcela_receber pr ON pr.id_conta_receber=cr.id_conta_receber
GROUP BY cr.id_conta_receber,cr.valor_total HAVING COALESCE(SUM(pr.valor_parcela),0)<>cr.valor_total;
-- Auditoria RN08: cliente da OS diferente do proprietario cadastrado do aparelho
SELECT o.id_os,o.id_cliente AS cliente_os,a.id_cliente AS cliente_aparelho FROM ordem_servico o JOIN aparelho a ON a.id_aparelho=o.id_aparelho WHERE o.id_cliente<>a.id_cliente;
-- Auditoria: funcionarios que nao sao tecnicos alocados em OS
SELECT a.id_os,f.id_funcionario,f.nome,f.cargo FROM alocacao_tecnico a JOIN funcionario f ON f.id_funcionario=a.id_funcionario WHERE f.cargo<>'TECNICO';
-- Auditoria RN23 e RN38: produto de venda usado como peca ou peca vendida como produto
SELECT 'PRODUTO_VENDA_EM_OS_PECA' AS irregularidade,op.id_os AS documento,p.id_produto,p.nome,p.tipo FROM os_peca op JOIN produto p ON p.id_produto=op.id_produto WHERE p.tipo='PRODUTO_VENDA'
UNION ALL
SELECT 'PECA_EM_ITEM_VENDA',iv.id_venda,p.id_produto,p.nome,p.tipo FROM item_venda iv JOIN produto p ON p.id_produto=iv.id_produto WHERE p.tipo='PECA';
-- Auditoria RN44: pagamento estornado sem motivo registrado
SELECT id_pagamento,id_conta_receber,numero_parcela,status,data_estorno,motivo_estorno FROM pagamento WHERE status='ESTORNADO' AND motivo_estorno IS NULL;
-- Auditoria RN17: orcamento aprovado sem data de decisao ou forma de confirmacao
SELECT id_orcamento,id_os,status,data_decisao,forma_confirmacao FROM orcamento WHERE status='APROVADO' AND (data_decisao IS NULL OR forma_confirmacao IS NULL);
-- Auditoria RN16: manutencao ou etapa posterior sem orcamento aprovado
SELECT o.id_os,o.status FROM ordem_servico o WHERE o.status IN ('EM_MANUTENCAO','PRONTO_PARA_RETIRADA','ENTREGUE') AND NOT EXISTS (SELECT 1 FROM orcamento orc WHERE orc.id_os=o.id_os AND orc.status='APROVADO');
-- Auditoria RN35: compra recebida sem movimentacao de entrada
SELECT co.id_compra,co.data_recebimento,co.status FROM compra co WHERE co.status='RECEBIDA' AND NOT EXISTS (SELECT 1 FROM movimentacao_estoque m WHERE m.id_compra=co.id_compra AND m.tipo='ENTRADA');
-- Auditoria RN34: total das parcelas a pagar diferente do total dos itens da compra
SELECT co.id_compra,COALESCE(it.total_itens,0) AS total_itens,COALESCE(pp.total_parcelas,0) AS total_parcelas
FROM compra co LEFT JOIN (SELECT id_compra,SUM(quantidade*custo_unitario) total_itens FROM item_compra GROUP BY id_compra) it ON it.id_compra=co.id_compra
LEFT JOIN (SELECT id_compra,SUM(valor_parcela) total_parcelas FROM parcela_pagar GROUP BY id_compra) pp ON pp.id_compra=co.id_compra
WHERE COALESCE(it.total_itens,0)<>COALESCE(pp.total_parcelas,0);
-- Auditoria: conta quitada cujo total de pagamentos efetivados diverge do valor total
SELECT cr.id_conta_receber,cr.valor_total,COALESCE(SUM(CASE WHEN pg.status='EFETIVADO' THEN pg.valor_pago ELSE 0 END),0) AS total_efetivado
FROM conta_receber cr LEFT JOIN pagamento pg ON pg.id_conta_receber=cr.id_conta_receber WHERE cr.situacao='QUITADA'
GROUP BY cr.id_conta_receber,cr.valor_total HAVING COALESCE(SUM(CASE WHEN pg.status='EFETIVADO' THEN pg.valor_pago ELSE 0 END),0)<>cr.valor_total;
-- Auditoria: parcelas a pagar vencidas e ainda nao pagas
SELECT id_compra,numero_parcela,valor_parcela,data_vencimento,situacao FROM parcela_pagar WHERE data_vencimento<CURDATE() AND situacao<>'PAGA';

-- Testes de violacao comentados: descomentar um por vez para conferir o erro esperado
-- Regra PRIMARY KEY simples: erro esperado por chave primaria duplicada
-- INSERT INTO cliente (id_cliente,nome,cpf) VALUES (1,'Duplicado','19999999991');
-- Regra PRIMARY KEY composta de os_peca: erro esperado por chave composta duplicada
-- INSERT INTO os_peca (id_os,id_produto,quantidade,valor_unitario,data_utilizacao) VALUES (1,1,1,250.00,'2026-02-20');
-- Regra FOREIGN KEY: erro esperado por cliente inexistente
-- INSERT INTO aparelho (id_aparelho,id_cliente,tipo,marca,modelo,numero_serie_imei) VALUES (99,999,'Tablet','Marca X','X1','IMEI999999999999');
-- Regra FOREIGN KEY composta: erro esperado por parcela inexistente
-- INSERT INTO pagamento (id_pagamento,id_conta_receber,numero_parcela,id_funcionario,data_pagamento,valor_pago,forma_pagamento) VALUES (99,1,99,2,'2026-02-20',10.00,'PIX');
-- Regra UNIQUE: erro esperado por CPF repetido
-- INSERT INTO cliente (id_cliente,nome,cpf) VALUES (98,'CPF repetido','10000000001');
-- Regra CHECK: erro esperado por quantidade negativa
-- INSERT INTO item_venda (id_venda,id_produto,quantidade,preco_unitario) VALUES (1,8,-1,45.00);
-- Regra NOT NULL: erro esperado por nome nulo
-- INSERT INTO cliente (id_cliente,nome,cpf) VALUES (97,NULL,'19999999997');
-- Regra CHECK de status: erro esperado por status de OS fora da lista
-- UPDATE ordem_servico SET status='EM_ESPERA' WHERE id_os=3;
-- Regra CHECK de origem exclusiva: erro esperado por conta sem origem ou com ambas as origens
-- INSERT INTO conta_receber (id_conta_receber,data_emissao,valor_total) VALUES (99,'2026-02-20',10.00);
-- INSERT INTO conta_receber (id_conta_receber,id_os,id_venda,data_emissao,valor_total) VALUES (98,1,1,'2026-02-20',10.00);
-- Regra CHECK de movimentacao: erro esperado por entrada sem compra vinculada
-- INSERT INTO movimentacao_estoque (id_movimentacao,id_produto,id_funcionario,tipo,quantidade) VALUES (99,1,2,'ENTRADA',1);
