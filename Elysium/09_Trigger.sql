/*
    NEL FRAMMENTO DI CODICE CHE SEGUE VENGONO CREATI DUE TRIGGER
       CHE IMPEDISCONO DI ELIMINARE RECORD DALLE TABELLE  livelli, abilita e missioni
*/
DELIMITER //

DROP TRIGGER IF EXISTS blocca_delete_livello//
CREATE DEFINER=`dilullo`@`localhost` TRIGGER blocca_delete_livello
    BEFORE DELETE ON livelli
    FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Impossibile Eliminare Livelli';
END//

DROP TRIGGER IF EXISTS blocca_delete_abilita//
CREATE DEFINER=`dilullo`@`localhost` TRIGGER blocca_delete_abilita
    BEFORE DELETE ON ABILITA
    FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Impossibile Eliminare abilita';
END //

DROP TRIGGER IF EXISTS blocca_delete_missioni//
CREATE DEFINER=`dilullo`@`localhost` TRIGGER blocca_delete_missioni
    BEFORE DELETE ON ABILITA
    FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Impossibile Eliminare missioni';
END //

DELIMITER ;

        /*PER TESTARE*/
        DELETE FROM livelli;
        DELETE FROM abilita;
        DELETE FROM missioni;



/*
    CON IL SEGUENTE TRIGGER SI VERIFICA CHE IL NUMERO DI ABILITA' EQUIPAGGIATE
        DA UN DETERMINATO PERSONAGGIO SIANO AL MASSIMO 20
*/
DELIMITER //
DROP TRIGGER IF EXISTS check_equipaggiare//
CREATE DEFINER=`dilullo`@`localhost` TRIGGER check_equipaggiare
    BEFORE INSERT ON equipaggiare
    FOR EACH ROW
BEGIN
    
    DECLARE x int;

    SET @x = (SELECT COUNT(*) FROM equipaggiare WHERE personaggio = NEW.personaggio GROUP BY personaggio);

    IF @x >= 20 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Impossibile aggiungere una nuova abilità per 
                                                    il personaggio selezionato! out of limit";
    END IF;
    
END//

DELIMITER ;

        /*PER TESTARE*/
        SELECT COUNT(*) FROM equipaggiare WHERE personaggio = "MaroonMelusines" GROUP BY personaggio;
        insert into equipaggiare values ("MaroonMelusines", "Absolve");



/*   
    CON IL SEGUENTE TRIGGER SI VERIFICA CHE UN PERSONAGGIO, PRIMA DI ENTRARE
      IN UNA GILDA NON SIA GIA' A CAPO DI UN'ALTRA
*/

DELIMITER //
DROP TRIGGER IF EXISTS controlla_appartenenza//


CREATE DEFINER=`dilullo`@`localhost` TRIGGER controlla_appartenenza
    BEFORE UPDATE ON personaggi
    FOR EACH ROW
BEGIN
    DECLARE x int;
    IF NEW.gilda <> OLD.gilda THEN
        SET @x = (SELECT COUNT(*) FROM gilde WHERE capo = OLD.nome);

        IF @x > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Impossibile aggiornare gilda! 
                                                        Personaggio già a capo di un'altra gilda";
        END IF;
    END IF;
END//

DELIMITER ;
        /*PER TESTARE*/
        SELECT capo, nome from gilde;
        UPDATE personaggi SET gilda = "gilda36" WHERE nome = "WhistlingIncubi";



/*   
    CON IL SEGUENTE TRIGGER SI VERIFICA CHE UN MESSAGGIO VENGA INSERITO IN UNA CHAT SOLO SE 
       IL MITTENTE FA PARTE DI QUEST ULTIMA O SE IL MESSAGGIO NON FA GIA' PARTE DI UN'ALTRA CHAT
*/

DELIMITER //
DROP TRIGGER IF EXISTS controlla_destinatario//

CREATE DEFINER=`dilullo`@`localhost` TRIGGER controlla_destinatario
    BEFORE INSERT ON messaggi
    FOR EACH ROW
BEGIN
    
    DECLARE condizione int;
    DECLARE destinatario int;

    SET @destinatario = NEW.chat;
    SET @condizione = (SELECT COUNT(*) FROM partecipare WHERE username = NEW.mittente AND id_chat = NEW.chat );

    IF @condizione = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Impossibile inviare messaggio! Il mittente non fa parte della chat";
    END IF;
END//

DELIMITER ;


        /*PER TESTARE*/
        select id_chat from partecipare where username = "ytDejCla72";
        INSERT INTO messaggi(corpo, orario, mittente) values ("ciao, questo è un messaggio di prova", NOW(), "ytDejCla72");
        select id from messaggi where mittente = "ytDejCla72";
        INSERT INTO `messaggi`(`mittente`, `chat`, orario, corpo) VALUES ("ytDejCla72", 116, NOW(), "ciao, questo è un messaggio di prova"); /*chat a cui non appartiene*/
        INSERT INTO `messaggi`(`mittente`, `chat`, orario, corpo) VALUES ("ytDejCla72", 115, NOW(), "ciao, questo è un messaggio di prova");  /*Inserimento corretto*/



/* 
    CON IL FRAMMENTO DI CODICE CHE SEGUE SI VUOLE RICALCOLARE IL VALORE DELL'ESPERIENZA GUADAGNATA DA '
        UN PERSONAGGIO QUANDO VIENE COMPLETATA UNA MISSIONE O MODIFICATA UNA PRECEDENTEMENTE COMPLETATA
        E IN CASO INCREMENTARE IL SUO LIVELLO
*/

DELIMITER //
DROP TRIGGER IF EXISTS controlla_livello_insert//

CREATE DEFINER=`dilullo`@`localhost` TRIGGER controlla_livello_insert
    AFTER INSERT ON assegnare
    FOR EACH ROW
BEGIN
    DECLARE x int;
    DECLARE liv int;
    
    IF NEW.stato = "Completata" THEN 
        SET @x = (SELECT COALESCE(SUM(missioni.esperienza),0) 
                FROM missioni, assegnare 
                WHERE assegnare.personaggio = NEW.personaggio AND 
                        assegnare.missione = missioni.ID 
                        AND assegnare.stato = 'Completata');
        SET @liv = (SELECT COUNT(*) FROM livelli WHERE esperienza <= @x);
            
        IF @liv > 0 THEN
            UPDATE personaggi SET livello = @liv WHERE personaggi.nome = NEW.personaggio;
        END IF;
    END IF;
END//


DROP TRIGGER IF EXISTS controlla_livello_update//

CREATE DEFINER=`dilullo`@`localhost` TRIGGER controlla_livello_update
    AFTER UPDATE ON assegnare
    FOR EACH ROW
BEGIN
    DECLARE x int;
    DECLARE liv int;
    
    IF NEW.stato = "Completata" THEN 
        SET @x = (SELECT COALESCE(SUM(missioni.esperienza),0) 
                FROM missioni, assegnare 
                WHERE assegnare.personaggio = NEW.personaggio AND 
                        assegnare.missione = missioni.ID 
                        AND assegnare.stato = 'Completata');
        SET @liv = (SELECT COUNT(*) FROM livelli WHERE esperienza <= @x);
            
        IF @liv > 0 THEN
            UPDATE personaggi SET livello = @liv WHERE personaggi.nome = NEW.personaggio;
        END IF;
    END IF;
END//

DELIMITER ;
        /*PER TESTARE*/
        UPDATE assegnare SET stato = "Attiva" WHERE personaggio = "GhostCentaurs";
        SELECT livello FROM personaggi WHERE personaggi.nome = "GhostCentaurs"; 
        UPDATE assegnare SET stato = "Completata" WHERE personaggio = "GhostCentaurs";
        SELECT livello FROM personaggi WHERE personaggi.nome = "GhostCentaurs"; 




/* 
        IL FRAMMENTO DI CODICE SEGUENTE SERVE AD IMPEDIRE CHE VENGA EQUIPAGGIATA UN'ABILITA'
            CHE E' GIA' UN'ABILITA' INNATA PER IL PERSONAGGIO IN QUESTIONE
*/
DELIMITER //
DROP TRIGGER IF EXISTS controlla_abilitaInnata//

CREATE DEFINER=`dilullo`@`localhost` TRIGGER controlla_abilitaInnata
    BEFORE INSERT ON equipaggiare
    FOR EACH ROW
BEGIN
    DECLARE razza varchar(15);
    DECLARE x int;
    
    SET @razza = (SELECT razza FROM personaggi WHERE personaggi.nome = NEW.personaggio);
    SET @x = (SELECT COUNT(*) FROM razze WHERE nome = @razza AND abilita = NEW.abilita);
        
    IF @x > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Impossibile equipaggiare! 
                                                    E' un'abilità innata del personaggio!";
    END IF;
    
END//
DELIMITER ;
        /*PER TESTARE*/
        DELETE FROM equipaggiare WHERE personaggio = "AlpineAtranochs" AND abilita = "Exorcism";
        SELECT abilita FROM razze WHERE razze.nome = "Umano";
        SELECT personaggi.nome FROM personaggi WHERE razza = "Umano" LIMIT 1;
        INSERT INTO equipaggiare VALUES ("AlpineAtranochs", "Exorcism"); 
