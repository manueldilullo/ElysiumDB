
/*EVENTO CHE RIFORNISCE I NEGOZI OGNI 24 ORE*/
SET GLOBAL event_scheduler = ON;
DROP EVENT IF EXISTS rifornimento;
CREATE EVENT rifornimento
ON SCHEDULE EVERY 1 DAY STARTS '2020-06-24 00:00:00'
DO 
UPDATE elysium.vendere SET disponibile = disponibile_max;



/*ESEMPIO DI TRANSAZIONE*/
DELIMITER //
DROP PROCEDURE IF EXISTS acquisto //
CREATE PROCEDURE acquisto(IN attivita smallint(5), 
                          IN personaggio varchar(20), 
                          IN oggetto varchar(30), 
                          IN quantita smallint(5))
BEGIN
    DECLARE prezzo float;
    DECLARE condizione int;

    START TRANSACTION;
        SET @prezzo = (SELECT prezzo 
                       FROM vendere 
                       WHERE vendere.attività = attivita AND 
                             vendere.oggetto = oggetto);
        UPDATE vendere SET disponibile = disponibile - quantita 
                       WHERE vendere.attività = attivita AND 
                             vendere.oggetto = oggetto;
        UPDATE personaggi SET monete = monete - (@prezzo * quantità)
                          WHERE nome = personaggio;

        SET @condizione = (SELECT COUNT(*) 
                            FROM inventario 
                            WHERE inventario.personaggio = personaggio AND 
                                  inventario.oggetto = oggetto);
        IF @condizione > 0 THEN
            UPDATE inventario SET inventario.quantità = inventario.quantità + quantita 
                              WHERE inventario.personaggio = personaggio AND 
                                    inventario.oggetto = oggetto;
        ELSE
            INSERT INTO inventario VALUES (personaggio, oggetto, quantita);
        END IF;
    COMMIT;
END //
DELIMITER ;

            /*PER TESTARE*/
            UPDATE vendere SET disponibile = disponibile_max WHERE attività = 502;
            UPDATE personaggi SET monete = 1000 WHERE  nome = "WildAnubis";

            CALL acquisto(502, "WildAnubis", "All-Seeing Lett", 10);

            SELECT monete FROM personaggi WHERE nome = "WildAnubis";
            SELECT prezzo FROM vendere WHERE vendere.attività = 502 AND vendere.oggetto = "All-Seeing Lett";
            SELECT * FROM inventario WHERE personaggio = "WildAnubis" AND oggetto = "All-Seeing Lett"; 

