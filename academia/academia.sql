-- Criando banco de dados
CREATE DATABASE academia;
USE academia;

-- Tabelas
CREATE TABLE PLANOS_MENSALIDADE (
    id_plano INT PRIMARY KEY,
    valor_mensal FLOAT,
    nome_plano VARCHAR(50) NOT NULL
);

CREATE TABLE BAIRRO (
    id_bairro INT PRIMARY KEY,
    nm_bairro VARCHAR(50)
);

CREATE TABLE ALUNO (
    matricula INT PRIMARY KEY,
    dt_matricula DATE,
    dt_nasc DATE,
    nome_completo VARCHAR(50) NOT NULL,
    id_bairro INT,
    id_plano INT,
    numero INT,
    complemento Varchar(100),
    rua VARCHAR (50),
    FOREIGN KEY (id_bairro) REFERENCES BAIRRO(id_bairro),
    FOREIGN KEY (id_plano) REFERENCES PLANOS_MENSALIDADE(id_plano)
    );

CREATE TABLE PAGAMENTO (
    matricula INT PRIMARY KEY,
    mes_ano VARCHAR(50),
    dt_pagamento DATE,
    id_plano INT,
    CONSTRAINT matricula FOREIGN KEY(matricula) REFERENCES ALUNO(matricula),
    FOREIGN KEY(id_plano) REFERENCES PLANOS_MENSALIDADE(id_plano)
    );


 -- Inserindo Dados
 INSERT INTO PLANOS_MENSALIDADE VALUES
 (1, 124.0 , 'O basico que faz bem'),
 (2, 60.0 , 'Melhor que nada'),
 (3, 124.0 , 'Hiper Mega Plus');

 INSERT INTO BAIRROS VALUES
 (1, 'Vasconcelos');

 INSERT INTO ALUNO VALUES
 (1, '2026-08-22', '2006-05-12','Rafaella Santos', 1, 732, 'casa','Rua Azevedo');

 INSERT INTO PAGAMENTO VALUES
 (1, 09/2026, '2026-08-22', 1 );


  -- Consultas / Verificando


-- 1 - alunos matriculados em 2026
SELECT
    a.nome_completo AS aluno_matriculado
FROM ALUNO a
JOIN BAIRRO b ON b.id_bairro = a.id_bairro
JOIN PLANOS_MENSALIDADE m ON m.id_plano = a.id_plano
WHERE a.dt_matricula >= '2026-01-01' 
ORDER BY a.dt_matricula;

-- 2 - o plano que mais tem aluno matriculado
SELECT 
    m.nome_plano AS plano,
    COUNT(a.matricula) AS total_alunos
FROM ALUNO a
JOIN PLANOS_MENSALIDADE m ON m.id_plano = a.id_plano
GROUP BY m.id_plano, m.nome_plano
ORDER BY total_alunos DESC,
LIMIT (1);

-- 3 - alunos que ainda nao pagaram a mensalidade do mes de setembro
SELECT 
    a.nome_completo AS aluno
FROM ALUNO a
LEFT JOIN PAGAMENTO p
    ON a.matricula = p.matricula
    AND p.mes_ano = '09/2026'
WHERE p.matricula is NULL;



