-- ============================================================
-- Projeto Final de Banco de Dados: Montadora Automotiva
-- Aluna: Sophia Byernes Carvalho Duarte
-- Script de criação das tabelas (DDL)
-- ============================================================

CREATE DATABASE montadora_db;
USE montadora_db;

-- ============================================================
-- INSTITUCIONAL
-- ============================================================
CREATE TABLE Montadora (
    id_montadora INT AUTO_INCREMENT PRIMARY KEY,
    razao_social VARCHAR(150) NOT NULL,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    endereco VARCHAR(200)
);

CREATE TABLE Fabrica (
    id_fabrica INT AUTO_INCREMENT PRIMARY KEY,
    id_montadora INT NOT NULL,
    localizacao VARCHAR(150) NOT NULL,
    cap_produtiva INT,
    responsavel VARCHAR(120),
    FOREIGN KEY (id_montadora) REFERENCES Montadora(id_montadora)
);

-- ============================================================
-- RECURSOS HUMANOS
-- ============================================================
CREATE TABLE Setor (
    id_setor INT AUTO_INCREMENT PRIMARY KEY,
    nome_setor VARCHAR(80) NOT NULL
);

CREATE TABLE Cargo (
    id_cargo INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(80) NOT NULL,
    nivel_acesso INT DEFAULT 1
);

CREATE TABLE Funcionario (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    id_fabrica INT NOT NULL,
    id_setor INT NOT NULL,
    id_cargo INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    salario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_fabrica) REFERENCES Fabrica(id_fabrica),
    FOREIGN KEY (id_setor) REFERENCES Setor(id_setor),
    FOREIGN KEY (id_cargo) REFERENCES Cargo(id_cargo)
);

-- ============================================================
-- ENGENHARIA E PRODUTO
-- ============================================================
CREATE TABLE Categoria_Veiculo (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(60) NOT NULL
);

CREATE TABLE Modelo (
    id_modelo INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    nome VARCHAR(80) NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categoria_Veiculo(id_categoria)
);

CREATE TABLE Versao (
    id_versao INT AUTO_INCREMENT PRIMARY KEY,
    id_modelo INT NOT NULL,
    nome_versao VARCHAR(80) NOT NULL,
    FOREIGN KEY (id_modelo) REFERENCES Modelo(id_modelo)
);

CREATE TABLE Cor (
    id_cor INT AUTO_INCREMENT PRIMARY KEY,
    nome_cor VARCHAR(50) NOT NULL,
    tipo_pintura VARCHAR(50)
);

CREATE TABLE Motor (
    id_motor INT AUTO_INCREMENT PRIMARY KEY,
    especificacao VARCHAR(80) NOT NULL,
    combustivel VARCHAR(40) NOT NULL
);

-- ============================================================
-- SUPRIMENTOS
-- ============================================================
CREATE TABLE Fornecedor (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    razao_social VARCHAR(150) NOT NULL,
    cnpj VARCHAR(18) NOT NULL UNIQUE
);

CREATE TABLE Peca (
    codigo_peca VARCHAR(20) PRIMARY KEY,
    id_fornecedor INT NOT NULL,
    nome_peca VARCHAR(120) NOT NULL,
    unidade_medida VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor(id_fornecedor)
);

CREATE TABLE Estoque_Peca (
    id_estoque_peca INT AUTO_INCREMENT PRIMARY KEY,
    id_fabrica INT NOT NULL,
    codigo_peca VARCHAR(20) NOT NULL,
    quantidade DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (id_fabrica) REFERENCES Fabrica(id_fabrica),
    FOREIGN KEY (codigo_peca) REFERENCES Peca(codigo_peca)
);

-- ============================================================
-- PRODUÇÃO
-- ============================================================
CREATE TABLE Linha_Montagem (
    id_linha INT AUTO_INCREMENT PRIMARY KEY,
    id_fabrica INT NOT NULL,
    identificacao VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_fabrica) REFERENCES Fabrica(id_fabrica)
);

CREATE TABLE Lote_Producao (
    id_lote INT AUTO_INCREMENT PRIMARY KEY,
    id_linha INT NOT NULL,
    data_inicio DATE NOT NULL,
    FOREIGN KEY (id_linha) REFERENCES Linha_Montagem(id_linha)
);

CREATE TABLE Veiculo (
    chassi VARCHAR(17) PRIMARY KEY,
    id_lote INT NOT NULL,
    id_versao INT NOT NULL,
    id_cor INT NOT NULL,
    id_motor INT NOT NULL,
    status VARCHAR(30) DEFAULT 'EM_PRODUCAO',
    ano_fabricacao YEAR NOT NULL,
    FOREIGN KEY (id_lote) REFERENCES Lote_Producao(id_lote),
    FOREIGN KEY (id_versao) REFERENCES Versao(id_versao),
    FOREIGN KEY (id_cor) REFERENCES Cor(id_cor),
    FOREIGN KEY (id_motor) REFERENCES Motor(id_motor)
);

CREATE TABLE Veiculo_Peca (
    chassi VARCHAR(17) NOT NULL,
    codigo_peca VARCHAR(20) NOT NULL,
    quantidade_usada INT DEFAULT 1,
    PRIMARY KEY (chassi, codigo_peca),
    FOREIGN KEY (chassi) REFERENCES Veiculo(chassi),
    FOREIGN KEY (codigo_peca) REFERENCES Peca(codigo_peca)
);

CREATE TABLE Etapa_Producao (
    id_etapa INT AUTO_INCREMENT PRIMARY KEY,
    nome_etapa VARCHAR(80) NOT NULL
);

CREATE TABLE Producao_Veiculo (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    chassi VARCHAR(17) NOT NULL,
    id_etapa INT NOT NULL,
    id_funcionario INT NOT NULL,
    data_hora DATETIME NOT NULL,
    status_etapa VARCHAR(30) DEFAULT 'CONCLUIDA',
    FOREIGN KEY (chassi) REFERENCES Veiculo(chassi),
    FOREIGN KEY (id_etapa) REFERENCES Etapa_Producao(id_etapa),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario)
);

-- ============================================================
-- QUALIDADE
-- ============================================================
CREATE TABLE Tipo_Teste (
    id_tipo_teste INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(80) NOT NULL
);

CREATE TABLE Teste_Qualidade (
    id_teste INT AUTO_INCREMENT PRIMARY KEY,
    chassi VARCHAR(17) NOT NULL,
    id_tipo_teste INT NOT NULL,
    aprovado BOOLEAN DEFAULT FALSE,
    data_teste DATETIME NOT NULL,
    FOREIGN KEY (chassi) REFERENCES Veiculo(chassi),
    FOREIGN KEY (id_tipo_teste) REFERENCES Tipo_Teste(id_tipo_teste)
);

CREATE TABLE Defeito (
    id_defeito INT AUTO_INCREMENT PRIMARY KEY,
    descricao_falha VARCHAR(150) NOT NULL
);

CREATE TABLE Veiculo_Defeito (
    id_registro_def INT AUTO_INCREMENT PRIMARY KEY,
    chassi VARCHAR(17) NOT NULL,
    id_defeito INT NOT NULL,
    resolvido BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (chassi) REFERENCES Veiculo(chassi),
    FOREIGN KEY (id_defeito) REFERENCES Defeito(id_defeito)
);

CREATE TABLE Manutencao_Corretiva (
    id_manutencao INT AUTO_INCREMENT PRIMARY KEY,
    id_registro_def INT NOT NULL,
    id_funcionario INT NOT NULL,
    solucao TEXT NOT NULL,
    data_manutencao DATE NOT NULL,
    FOREIGN KEY (id_registro_def) REFERENCES Veiculo_Defeito(id_registro_def),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario)
);

-- ============================================================
-- COMERCIAL E PÓS-VENDA
-- ============================================================
CREATE TABLE Estoque_Veiculo (
    id_estoque_veic INT AUTO_INCREMENT PRIMARY KEY,
    chassi VARCHAR(17) NOT NULL UNIQUE,
    data_entrada DATE NOT NULL,
    FOREIGN KEY (chassi) REFERENCES Veiculo(chassi)
);

CREATE TABLE Concessionaria (
    id_concessionaria INT AUTO_INCREMENT PRIMARY KEY,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    nome_loja VARCHAR(120) NOT NULL,
    cidade VARCHAR(80) NOT NULL
);

CREATE TABLE Faturamento (
    id_faturamento INT AUTO_INCREMENT PRIMARY KEY,
    chassi VARCHAR(17) NOT NULL UNIQUE,
    id_concessionaria INT NOT NULL,
    data_envio DATE NOT NULL,
    FOREIGN KEY (chassi) REFERENCES Veiculo(chassi),
    FOREIGN KEY (id_concessionaria) REFERENCES Concessionaria(id_concessionaria)
);

CREATE TABLE Cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cpf_cnpj VARCHAR(18) NOT NULL UNIQUE
);

CREATE TABLE Venda_Final (
    id_venda INT AUTO_INCREMENT PRIMARY KEY,
    chassi VARCHAR(17) NOT NULL UNIQUE,
    id_concessionaria INT NOT NULL,
    id_cliente INT NOT NULL,
    data_venda DATE NOT NULL,
    FOREIGN KEY (chassi) REFERENCES Veiculo(chassi),
    FOREIGN KEY (id_concessionaria) REFERENCES Concessionaria(id_concessionaria),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

CREATE TABLE Garantia (
    id_garantia INT AUTO_INCREMENT PRIMARY KEY,
    id_venda INT NOT NULL UNIQUE,
    data_vencimento DATE NOT NULL,
    FOREIGN KEY (id_venda) REFERENCES Venda_Final(id_venda)
);

CREATE TABLE Assistencia_Tecnica (
    id_assistencia INT AUTO_INCREMENT PRIMARY KEY,
    razao_social VARCHAR(150) NOT NULL,
    credenciada BOOLEAN DEFAULT TRUE
);

CREATE TABLE Revisao (
    id_revisao INT AUTO_INCREMENT PRIMARY KEY,
    chassi VARCHAR(17) NOT NULL,
    id_assistencia INT NOT NULL,
    quilometragem INT NOT NULL,
    data_revisao DATE NOT NULL,
    FOREIGN KEY (chassi) REFERENCES Veiculo(chassi),
    FOREIGN KEY (id_assistencia) REFERENCES Assistencia_Tecnica(id_assistencia)
);

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX idx_status ON Veiculo(status);
CREATE INDEX idx_prod_chassi ON Producao_Veiculo(chassi);
