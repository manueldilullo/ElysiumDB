DROP DATABASE IF EXISTS Elysium;
CREATE DATABASE Elysium;
USE Elysium;

CREATE TABLE Utenti(
    username varchar(20) not NULL,
    nome  varchar(20) not NULL,
    cognome varchar(25) not NULL,
    email varchar(255) not NULL unique,
    pass char(40) not NULL,
    data_di_nascita DATE not NULL,

    PRIMARY KEY(username)
) ENGINE=INNODB;


CREATE TABLE Accessi
(
    ip char(15) not NULL,
    orario TIMESTAMP not NULL DEFAULT CURRENT_TIMESTAMP,
    username varchar(20) not NULL,

    PRIMARY KEY (ip, orario),
    FOREIGN KEY(username) REFERENCES Utenti(username)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);


CREATE TABLE Amici
(
    utente1 varchar(20) not NULL,
    utente2 varchar(20) not NULL,  
    stato_richiesta boolean not NULL DEFAULT 0,

    CONSTRAINT chk_utenti CHECK(utente1 <> utente2),

    PRIMARY KEY(utente1, utente2),
    FOREIGN KEY(utente1) REFERENCES Utenti(username)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY(utente2) REFERENCES Utenti(username)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=INNODB;


CREATE TABLE Chat
(
    ID int unsigned AUTO_INCREMENT not NULL,
    nome varchar(20) not NULL,
    data_creazione TIMESTAMP not NULL,

    PRIMARY KEY(ID)
) ENGINE=INNODB;



CREATE TABLE Messaggi
(   
    mittente varchar(20) not NULL,
    chat int unsigned not NULL,
    corpo varchar(1024) not NULL,
    orario TIMESTAMP not NULL DEFAULT NOW(),

    PRIMARY KEY(mittente, chat, orario),
    FOREIGN KEY(mittente) REFERENCES Utenti(username) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY(chat) REFERENCES Chat(ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=INNODB;



CREATE TABLE Partecipare
(
    username varchar(20) not NULL,
    id_chat int unsigned not NULL,

    PRIMARY KEY(username, id_chat),
    FOREIGN KEY(username) REFERENCES Utenti(username)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(id_chat) REFERENCES Chat(ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=INNODB;


CREATE TABLE Livelli
(
    livello tinyint unsigned not NULL,
    esperienza int unsigned not NULL,

    PRIMARY KEY(livello)
) ENGINE=INNODB;


CREATE TABLE Abilita
(
    nome varchar(30) not NULL,
    descrizione varchar(512) not NULL,
    livello tinyint unsigned not NULL DEFAULT 1,

    PRIMARY KEY(nome),
    FOREIGN KEY(livello) REFERENCES Livelli(livello) 
        ON UPDATE CASCADE
) ENGINE=INNODB;


CREATE TABLE Razze
(
    nome varchar(15) not NULL,
    descrizione varchar(512) not NULL,
    abilita varchar(30) not NULL UNIQUE,

    PRIMARY KEY(nome),
    FOREIGN KEY(abilita) REFERENCES Abilita(nome)
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
) ENGINE=INNODB;


CREATE TABLE Classi
(
    nome varchar(15) not NULL,
    descrizione varchar(512) not NULL,

    PRIMARY KEY(nome)
) ENGINE=INNODB;


CREATE TABLE Disporre
(
    classe varchar(15) not NULL,
    abilita varchar(30) not NULL,
    
    PRIMARY KEY(classe, abilita),
    FOREIGN KEY(classe) REFERENCES Classi(nome)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY(abilita) REFERENCES Abilita(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=INNODB;



CREATE TABLE Statistiche
(
    nome varchar(15) not NULL,

    PRIMARY KEY(nome)
) ENGINE=INNODB;


CREATE TABLE Avere_effetto
(
    abilita varchar(30) not NULL,
    statistica varchar(15) not NULL,
    durata int unsigned not NULL,
    valore smallint not NULL,

    PRIMARY KEY(abilita, statistica),
    FOREIGN KEY(abilita) REFERENCES Abilita(nome)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY(statistica) REFERENCES Statistiche(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=INNODB;


CREATE TABLE Personaggi
(
    nome varchar(20) not NULL,
    monete float unsigned not NULL,
    utente varchar(20) not NULL,
    razza varchar(15) not NULL,
    classe varchar(15) not NULL,
    livello tinyint unsigned not NULL,
    gilda varchar(20) DEFAULT NULL,
    
    PRIMARY KEY(nome),
    FOREIGN KEY(utente) REFERENCES Utenti(username)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(razza) REFERENCES Razze(nome)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY(classe) REFERENCES Classi(nome)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY(livello) REFERENCES Livelli(livello)
        ON DELETE RESTRICT
        ON UPDATE CASCADE

) ENGINE=INNODB;

CREATE TABLE Gilde(
    nome varchar(20) not NULL,
    descrizione varchar(512) DEFAULT " ",
    capo varchar(20) not NULL UNIQUE,

    PRIMARY KEY(nome),
    FOREIGN KEY(capo) REFERENCES Personaggi(nome) 
        ON DELETE CASCADE
        ON UPDATE CASCADE
)ENGINE=INNODB;

ALTER TABLE Personaggi 
    ADD CONSTRAINT FOREIGN KEY(gilda) REFERENCES Gilde(nome)
        ON DELETE SET NULL
        ON UPDATE CASCADE;



CREATE TABLE Equipaggiare
(   
    personaggio varchar(20) not NULL,
    abilita varchar(30) not NULL,

    PRIMARY KEY(personaggio, abilita),
    FOREIGN KEY(personaggio) REFERENCES Personaggi(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(abilita) REFERENCES abilita(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=INNODB;



CREATE TABLE Caratterizzare
(   
    personaggio varchar(20) not NULL,
    statistica varchar(15) not NULL,
    valore smallint unsigned not NULL DEFAULT 1,

    PRIMARY KEY(personaggio, statistica),
    FOREIGN KEY(personaggio) REFERENCES Personaggi(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(statistica) REFERENCES Statistiche(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=INNODB;



CREATE TABLE Oggetti
(
    nome varchar(30) not NULL,
    descrizione varchar(512) not NULL,
    bersaglio varchar(20) not NULL DEFAULT 'sè',
    categoria varchar(20) not NULL,
    utilizzabile boolean not NULL DEFAULT 1,
    vendibile boolean not NULL DEFAULT 1,
    valore float not NULL DEFAULT 0,

    CONSTRAINT chk_bersaglio CHECK (bersaglio IN ('sè', 'alleato singolo', 
                                    'alleato gruppo(5m)', 'alleato gruppo(10m)', 
                                    'nemico singolo', 'nemico gruppo(5m)', 
                                    'nemico gruppo(10m)')),
    CONSTRAINT chk_categoria CHECK (categoria IN ('armatura', 'arma', 'pozione', 
                                    'pergamena', 'genere alimentare', 'abito', 
                                    'missione', 'varie')),

    PRIMARY KEY(nome)
) ENGINE=INNODB;



CREATE TABLE Influenzare
(
    oggetto varchar(30) not NULL,
    statistica varchar(15) not NULL,
    durata int unsigned not NULL,
    valore smallint not NULL DEFAULT 0,

    PRIMARY KEY(oggetto, statistica),
    FOREIGN KEY(oggetto) REFERENCES Oggetti(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(statistica) REFERENCES Statistiche(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=INNODB;



CREATE TABLE Utilizzare_Classe
(
    classe varchar(15) not NULL,
    oggetto varchar(30) not NULL,

    PRIMARY KEY(oggetto, classe),
    FOREIGN KEY(oggetto) REFERENCES Oggetti(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(classe) REFERENCES Classi(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=INNODB;



CREATE TABLE Utilizzare_Razza
(   
    razza varchar(15) not NULL,
    oggetto varchar(15) not NULL, 

    PRIMARY KEY(oggetto, razza),
    FOREIGN KEY(oggetto) REFERENCES Oggetti(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(razza) REFERENCES Razze(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=INNODB;



CREATE TABLE Inventario
(   
    personaggio varchar(20) not NULL,
    oggetto varchar(30) not NULL, 
    quantità smallint unsigned not NULL DEFAULT 1,

    CONSTRAINT chk_quantita CHECK (quantità > 0),

    PRIMARY KEY(personaggio, oggetto),
    FOREIGN KEY(personaggio) REFERENCES Personaggi(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE,    
    FOREIGN KEY(oggetto) REFERENCES Oggetti(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=INNODB;



CREATE TABLE Luoghi
(
    nome varchar(20) not NULL,
    latitudine float not NULL UNIQUE,
    longitudine float not NULL UNIQUE,

    PRIMARY KEY(nome)
) ENGINE=INNODB;



CREATE TABLE Missioni
(
    ID smallint unsigned not NULL AUTO_INCREMENT,
    min_partecipanti smallint not NULL DEFAULT 1,
    max_partecipanti smallint not NULL DEFAULT 1,
    grado tinyint unsigned not NULL DEFAULT 1,
    esperienza int unsigned not NULL,
    monete int unsigned not NULL DEFAULT 0,
    rivolta_a varchar(10) not NULL DEFAULT 'pubblica',
    luogo varchar(20) not NULL,

    CONSTRAINT chk_partecipanti CHECK(min_partecipanti <= max_partecipanti),
    CONSTRAINT chk_rivolto CHECK (rivolta_a IN ('pubblica', 'gilda')),

    PRIMARY KEY(id),
    FOREIGN KEY(luogo) REFERENCES Luoghi(nome) 
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=INNODB;



CREATE TABLE Assegnare
(
    personaggio varchar(20) not NULL,
    missione smallint unsigned not NULL,
    stato varchar(10) not NULL,

    CONSTRAINT chk_stato CHECK(stato IN ('Attiva', 'Completata') ),

    PRIMARY KEY(personaggio, missione),
    FOREIGN KEY(personaggio) REFERENCES Personaggi(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(missione) REFERENCES Missioni(ID)
        ON UPDATE CASCADE
) ENGINE=INNODB;



CREATE TABLE Ricompense
(
    missione smallint unsigned not NULL,
    oggetto varchar(30) not NULL, 
    quantità smallint unsigned not NULL DEFAULT 1,

    PRIMARY KEY(missione, oggetto),
    FOREIGN KEY(missione) REFERENCES Missioni(ID)
        ON UPDATE CASCADE,
    FOREIGN KEY(oggetto) REFERENCES Oggetti(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=INNODB;



CREATE TABLE Attività_commerciali
(
    ID smallint unsigned not NULL AUTO_INCREMENT,
    tipologia varchar(15) not NULL,
    luogo varchar(20) not NULL,

    CONSTRAINT chk_tipologia CHECK (tipologia IN ('taverne', 'negozi', 
                                    'botteghe', 'venditori', 'ambulanti')),

    PRIMARY KEY(ID),
    FOREIGN KEY(luogo) REFERENCES Luoghi(nome)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=INNODB;



CREATE TABLE Vendere
(
    oggetto varchar(30) not NULL,
    attività smallint unsigned not NULL,
    prezzo float not NULL,
    disponibile int unsigned NOT NULL DEFAULT 0,
    disponibile_max int unsigned NOT NULL,

    CONSTRAINT check_disponibilita CHECK (disponibile_max >= disponibile),

    PRIMARY KEY(oggetto, attività),
    FOREIGN KEY(oggetto) REFERENCES Oggetti(nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(attività) REFERENCES Attività_commerciali(ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=INNODB;