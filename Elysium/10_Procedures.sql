DELIMITER //
DROP PROCEDURE IF EXISTS leggi_messaggi //
CREATE PROCEDURE leggi_messaggi ( IN utente varchar(20), IN ID_chat int unsigned )

BEGIN
   SELECT messaggi.* 
   FROM messaggi, partecipare 
   WHERE messaggi.chat = partecipare.id_chat AND utente = partecipare.username AND partecipare.id_chat = ID_chat;
END //

DELIMITER ;


call leggi_messaggi("aColIrm54", 125);