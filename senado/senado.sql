/*****************************/
/* CRIANDO DO BANCO DE DADOS */
/*****************************/
CREATE DATABASE senado

USE congresso_c;

/*********************/
/*CRIANDO DAS TABELAS*/
/*********************/
CREATE TABLE PARTIDO (
    cd_partido INT PRIMARY KEY,
    nome_partido VARCHAR(100) NOT NULL);

CREATE TABLE CATEGORIA (
    cd_categ INT PRIMARY KEY,
    nm_categ VARCHAR(100) NOT NULL,
	desc_categ text);

CREATE TABLE VOTO (
    tp_voto INT PRIMARY KEY,
    ds_tp_voto VARCHAR(20) NOT NULL);

CREATE TABLE CONGRESSISTA (
    cd_congr INT PRIMARY KEY,
    nm_congr VARCHAR(100) NOT NULL,
    cd_partido INT,
    dt_inicio DATE,
    constraint fk_partido FOREIGN KEY (cd_partido) REFERENCES PARTIDO(cd_partido));

CREATE TABLE PROJETO_LEI (
    cd_pl INT PRIMARY KEY,
    nm_projeto VARCHAR(150) NOT NULL,
    dt_proposta DATE,
    situacao BIT,
    cd_congr INT,
    cd_categ INT,
    FOREIGN KEY (cd_categ) REFERENCES CATEGORIA(cd_categ),
    FOREIGN KEY (cd_congr) REFERENCES CONGRESSISTA(cd_congr));

CREATE TABLE VOTACAO (
    id_voto INT IDENTITY (1,1) PRIMARY KEY,
    dt_voto date,
	tp_voto INT,
	cd_congr INT,
    cd_pl INT,
    FOREIGN KEY (cd_congr) REFERENCES CONGRESSISTA(cd_congr),
    FOREIGN KEY (cd_pl) REFERENCES PROJETO_LEI(cd_pl),
    FOREIGN KEY (tp_voto) REFERENCES VOTO(tp_voto));

/*************************/
/* INCLUSAO DE REGISTROS */
/*************************/
INSERT INTO PARTIDO VALUES
(1, 'Partido A'),
(2, 'Partido B'),
(3, 'Partido C'),
(4, 'Partido D'),
(5, 'Partido E');

INSERT INTO CATEGORIA VALUES
(1, 'Educa��o', 'Projetos de Lei que impactam pol�ticas p�blicas em educa��o'),
(2, 'Sa�de', 'Projetos de Lei que impactam pol�ticas p�blicas em sa�de');

INSERT INTO VOTO VALUES
(1, 'SIM'),
(2, 'N�O'),
(3, 'ABSTEN��O');

INSERT INTO CONGRESSISTA VALUES
(1, 'Jo�o Silva', 1, '2020-01-01'),
(2, 'Maria Souza', 2, '2019-03-15'),
(3, 'Carlos Lima', 3, '2018-07-10'),
(4, 'Ana Costa', 2, '2021-06-01'),
(5, 'Pedro Alves', 3, '2022-02-20');


INSERT INTO PROJETO_LEI VALUES
(1, 'Projeto Educa��o', '2024-01-10', null, 3, 1),
(2, 'Projeto Sa�de', '2024-02-15', null, 3, 2),
(3, 'Projeto BNCC', '2024-03-20', null, 2, 1),
(4, 'Projeto Exames Obrigat�rios', '2024-04-05', null, 2, 2),
(5, 'Projeto Educa��o B�sica', '2024-05-12', null, 4, 1);


INSERT INTO VOTACAO (dt_voto, tp_voto, cd_congr, cd_pl) VALUES
-- Projeto 1 (MAIORIA SIM)
(GETDATE(),1,1,1),
(GETDATE(),1,2,1),
(GETDATE(),2,3,1),
(GETDATE(),1,4,1),
(GETDATE(),3,5,1);


INSERT INTO VOTACAO (dt_voto, tp_voto, cd_congr, cd_pl) VALUES
-- Projeto 3 (MAIORIA SIM)
(GETDATE(),2,1,3),
(GETDATE(),1,2,3),
(GETDATE(),1,3,3),
(GETDATE(),1,4,3),
(GETDATE(),3,5,3);



INSERT INTO VOTACAO (dt_voto, tp_voto, cd_congr, cd_pl) VALUES
-- Projeto 5 (MAIORIA N�O)
(GETDATE(),2,1,5),
(GETDATE(),2,2,5),
(GETDATE(),2,3,5),
(GETDATE(),2,4,5),
(GETDATE(),3,5,5);


/*******************************************/
/* ATUALIZA��O DO STATUS DO PROJETO DE LEI */
/*******************************************/

UPDATE PROJETO_LEI
SET situacao = (
    SELECT 
        CASE 
            WHEN SUM(CASE WHEN v.tp_voto = 1 THEN 1 ELSE 0 END) >
                 SUM(CASE WHEN v.tp_voto = 2 THEN 1 ELSE 0 END)
            THEN 1  -- APROVADO
            ELSE 0  -- REJEITADO
        END
    FROM VOTACAO v
    WHERE v.cd_pl = projeto_lei.cd_pl
)
	WHERE projeto_lei.cd_pl in (select distinct cd_pl from VOTACAO);

select * from PROJETO_LEI

/**********************/
/* queries � exemplos */
/**********************/
--Congressistas de um partido espec�fico (operador =)
SELECT *
FROM CONGRESSISTA
WHERE cd_partido = 1;

--Projetos propostos ap�s determinada data (operador >)
SELECT *
FROM PROJETO_LEI
WHERE dt_proposta > '2024-02-01';

--Congressistas com nome contendo �Silva� (LIKE)
SELECT *
FROM CONGRESSISTA
WHERE nm_congr LIKE '%Silva%';

--Projetos com situa��o APROVADO ou REJEITADO (IN)
SELECT *
FROM PROJETO_LEI
WHERE situacao IN (0,1);

SELECT *
FROM PROJETO_LEI
WHERE situacao is not null;

--Congressistas que N�O pertencem ao partido 1 (<>)
SELECT *
FROM CONGRESSISTA
WHERE cd_partido <> 1;

SELECT *
FROM CONGRESSISTA
WHERE cd_partido != 1;
/*CONSULTAS COM JOIN */
--Nome do congressista + partido (JOIN)
SELECT c.nm_congr, p.nome_partido
FROM CONGRESSISTA c
JOIN PARTIDO p ON c.cd_partido = p.cd_partido;

--Projetos com nome do autor (JOIN)
SELECT pl.nm_projeto AS projeto, c.nm_congr AS autor
FROM PROJETO_LEI pl
JOIN CONGRESSISTA c ON pl.cd_congr = c.cd_congr;

--Votos dos congressistas em cada projeto (JOIN m�ltiplo)
SELECT c.nm_congr, pl.nm_projeto AS projeto, v.ds_tp_voto AS voto
FROM VOTACAO vt
JOIN CONGRESSISTA c ON vt.cd_congr = c.cd_congr
JOIN PROJETO_LEI pl ON vt.cd_pl = pl.cd_pl
JOIN VOTO v ON vt.tp_voto = v.tp_voto;

--Projetos e suas situa��es (uso do CASE)
SELECT pl.nm_projeto, (case situacao when 0 then 'reprovado' when 1 then 'aprovado' else 'sem vota��o' end) as 'situa��o'
FROM PROJETO_LEI pl;


SELECT pl.nm_projeto, SITUACAO
FROM PROJETO_LEI pl;

--Congressistas e seus votos
SELECT *
FROM CONGRESSISTA c
JOIN VOTACAO vt ON c.cd_congr = vt.cd_congr
JOIN PROJETO_LEI pl ON c.cd_congr = pl.cd_congr
order by c.nm_congr
