/*PROCEDURA PER INSERIMENTO DI RECORD NELLA TABELLA CHAT*/

DROP PROCEDURE IF EXISTS inserisci_chat;
DELIMITER //
CREATE PROCEDURE inserisci_chat(IN loops int)
BEGIN
    DECLARE v1 int;  
    
    SET @v1 = 0;

    WHILE @v1 < loops DO 
        INSERT IGNORE INTO chat(nome, data_creazione) VALUES (CONCAT("nome_chat",@v1), NOW());
        SET @v1 = @v1 + 1;
    
    END WHILE;
END; //
DELIMITER ;
    
CALL inserisci_chat(1000);



/*PROCEDURA PER INSERIMENTO DI RECORD NELLA TABELLA AMICI*/

DROP PROCEDURE IF EXISTS inserisci_amici;
DELIMITER //
CREATE PROCEDURE inserisci_amici (IN loops int)
BEGIN
	DECLARE utente1 VARCHAR(20);
	DECLARE utente2 varchar(20);
    DECLARE v1 int;
    DECLARE stato tinyint(1);

    SET @v1 = 0;

    WHILE @v1 < loops DO 

        SET @utente1 = (SELECT username FROM Utenti ORDER BY RAND() LIMIT 1);
        SET @utente2 = (SELECT username FROM Utenti ORDER BY RAND() LIMIT 1);

        IF @stato = 1 THEN
            SET @stato = 0;
        ELSE
            SET @stato = 1;
        END IF;

        IF @utente1 <> @utente2 THEN
            INSERT IGNORE INTO Amici VALUES (@utente1, @utente2, @stato);
            INSERT IGNORE INTO Amici VALUES (@utente2, @utente1, @stato);
        END IF;

        SET @v1 = @v1 + 1;
    END WHILE;
	
END //
DELIMITER ;
    
CALL inserisci_amici(1000);
