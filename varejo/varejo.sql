-- Criando banco de dados
CREATE DATABASE varejo;
USE varejo;

-- Tabelas
CREATE TABLE UN_MEDIDA (
    id_un_med INT PRIMARY KEY,
    des_unidade_medida VARCHAR(100) NOT NULL
);

CREATE TABLE CATEGORIA (
    id_categ INT PRIMARY KEY,
    nome_categoria VARCHAR(100) NOT NULL
);

CREATE TABLE PRODUTO(
    id_produto INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    peso DECIMAL(10,3),
    preco DECIMAL(10,2),
    id_un_med INT,
    id_categ INT,
    FOREIGN KEY (id_un_med) REFERENCES UN_MEDIDA(id_un_med),
    FOREIGN KEY (id_categ) REFERENCES CATEGORIA(id_categ)
);

CREATE TABLE UF (
    id_uf INT PRIMARY KEY,
    estado VARCHAR(2) NOT NULL
);

CREATE TABLE BAIRRO (
    id_bairro INT PRIMARY KEY,
    nome_bairro VARCHAR(100),
    cidade VARCHAR(100),
    id_uf INT,
    FOREIGN KEY (id_uf) REFERENCES UF(id_uf)
);

CREATE TABLE CEP (
    id_cep INT PRIMARY KEY,
    logradouro VARCHAR(100) NOT NULL,
    id_bairro INT,
    FOREIGN KEY (id_bairro) REFERENCES BAIRRO(id_bairro)
);

CREATE TABLE GENERO (
    id_genero INT PRIMARY KEY,
    desc_genero VARCHAR(100) NOT NULL
);

CREATE TABLE CLIENTE (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    dt_nasc DATE,
    id_genero INT, 
    id_cep INT,
    numero INT,
    complemento VARCHAR(100),
    FOREIGN KEY (id_genero) REFERENCES GENERO(id_genero),
    FOREIGN KEY (id_cep) REFERENCES CEP(id_cep)
);

CREATE TABLE LOJA (
    id_loja INT PRIMARY KEY,
    nome_loja VARCHAR(100) NOT NULL,
    id_cep INT,
    FOREIGN KEY (id_cep) REFERENCES CEP(id_cep)
);

CREATE TABLE VENDEDOR (
    id_vendedor INT PRIMARY KEY,
    nome_vendedor VARCHAR(100) NOT NULL,
    id_loja INT,
    perc_comiss DECIMAL(5,2),
    FOREIGN KEY (id_loja) REFERENCES LOJA(id_loja)
);

CREATE TABLE OPER_FISCAL (
    id_oper_fiscal INT PRIMARY KEY,
    nome_operacao VARCHAR(100) NOT NULL,
    icms INT,
    ipi INT, 
    pis INT,
    cofins INT,
    iss INT,
    ir INT   
);

CREATE TABLE NOTA_FISCAL (
    num_nf INT PRIMARY KEY,
    id_cliente INT,
    data_nf DATE,
    id_oper_fiscal INT,
    vl_frete DECIMAL(10,2),
    vl_comissao DECIMAL(10,2),
    id_vendedor INT,
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente),
    FOREIGN KEY (id_oper_fiscal) REFERENCES OPER_FISCAL(id_oper_fiscal),
    FOREIGN KEY (id_vendedor) REFERENCES VENDEDOR(id_vendedor)
);

CREATE TABLE ITEM_NF (
    num_nf INT,
    id_produto INT,
    quant INT,
    vl_unitario DECIMAL(10,2),
    vl_total DECIMAL(10,2),
    tt_impostos DECIMAL(10,2),
    PRIMARY KEY (num_nf, id_produto),
    FOREIGN KEY (num_nf) REFERENCES NOTA_FISCAL(num_nf),
    FOREIGN KEY (id_produto) REFERENCES PRODUTO(id_produto)
);

-- Inserções

-- 1 - Cliente
INSERT INTO GENERO VALUES
(1, 'Feminino'),
(2, 'Masculino');

INSERT INTO UF VALUES
(1,'SP');

INSERT INTO BAIRRO VALUES
(1,'Jd Santo Ângelo', NULL, 1);

INSERT INTO CEP VALUES
(1, 'Rua Jaboticabal',1 );

INSERT INTO CLIENTE VALUES
(1,'Francisco Souza Cruz', '2003-05-01', 2 , 1, 345, '11111222');

-- 2 - Produto
INSERT INTO CATEGORIA VALUES
(1, 'matinais'),
(2, 'bebidas');

INSERT INTO UN_MEDIDA VALUES
(1, 'gramas'),
(2, 'mililitros');

INSERT INTO PRODUTO VALUES
(1, 'Caixa de cereal', 0.250, 8.78, 1, 1);

-- 3 - Venda
INSERT INTO OPER_FISCAL VALUES
(10, 'venda',1,2,3,4,5,6);

INSERT INTO LOJA VALUES
(100, 'lojaCem', 1);

INSERT INTO VENDEDOR VALUES
(1,'Fernanda', 100, NULL );

INSERT INTO NOTA_FISCAL VALUES
(1, 1, CURDATE(), 10, 0.00 , 0.05, 1);

INSERT INTO PRODUTO VALUES
(2, 'pão/pães', 0.100, 0.50, 1, 1),
(3, 'refrigerante', 0.500, 7.00, 2, 2);

INSERT INTO ITEM_NF VALUES
(1, 1, 1, 8.78, 8.78, NULL ),
(1, 2, 2, 0.50, 1.00, NULL ),
(1, 3, 3, 7.00, 21.00, NULL);

-- Consultas

-- 1 - Produtos vendidos em fevereiro de 2026
SELECT
    p.nome AS produto,
    SUM(i.quant) AS quantidade_total,
    SUM(i.vl_total) AS valor_total
FROM ITEM_NF i
JOIN NOTA_FISCAL nf ON nf.num_nf = i.num_nf
JOIN PRODUTO p ON p.id_produto = i.id_produto
WHERE nf.data_nf >= '2026-02-01' AND nf.data_nf < '2026-03-01'
GROUP BY p.id_produto, p.nome
ORDER BY p.nome;

-- 2 - Valor total de venda e comissão por vendedor
SELECT
    v.nome_vendedor AS vendedor,
    SUM(t.vl_venda) AS total_vendas,
    SUM(nf.vl_comissao) AS total_comissao
FROM VENDEDOR v
JOIN NOTA_FISCAL nf ON nf.id_vendedor = v.id_vendedor
JOIN (
    SELECT num_nf, SUM(vl_total) AS vl_venda
    FROM ITEM_NF
    GROUP BY num_nf
) t ON t.num_nf = nf.num_nf
GROUP BY v.id_vendedor, v.nome_vendedor
ORDER BY v.nome_vendedor;

-- 3 - Clientes que compraram em janeiro mas não em fevereiro
SELECT
    c.nome,
    g.desc_genero AS genero,
    TIMESTAMPDIFF(YEAR, c.dt_nasc, CURDATE()) AS idade
FROM CLIENTE c
LEFT JOIN GENERO g ON g.id_genero = c.id_genero
WHERE EXISTS (
        SELECT 1 FROM NOTA_FISCAL nf
        WHERE nf.id_cliente = c.id_cliente
          AND nf.data_nf >= '2026-01-01' AND nf.data_nf < '2026-02-01')
  AND NOT EXISTS (
        SELECT 1 FROM NOTA_FISCAL nf
        WHERE nf.id_cliente = c.id_cliente
          AND nf.data_nf >= '2026-02-01' AND nf.data_nf < '2026-03-01')
ORDER BY c.nome;

-- 4 - Produtos por categoria
SELECT
    c.nome_categoria AS categoria,
    p.nome AS produto
FROM PRODUTO p
JOIN CATEGORIA c ON c.id_categ = p.id_categ
ORDER BY c.nome_categoria, p.nome;

-- 5 - Clientes do sexo feminino que fazem aniversário em fevereiro
SELECT
    c.nome,
    YEAR(CURDATE()) - YEAR(c.dt_nasc) AS idade,
    b.nome_bairro AS bairro
FROM CLIENTE c
JOIN GENERO g ON g.id_genero = c.id_genero
LEFT JOIN CEP ce ON ce.id_cep = c.id_cep
LEFT JOIN BAIRRO b ON b.id_bairro = ce.id_bairro
WHERE g.desc_genero = 'Feminino'
  AND MONTH(c.dt_nasc) = 2
ORDER BY c.nome;
