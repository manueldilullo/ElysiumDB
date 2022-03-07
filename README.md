<h2 align="center">
  <br>
  <a href="https://web.uniroma2.it/"><img src="logo_torvergata.png" alt="Tor Vergata Logo" width="200"></a>
</h2>
<br>

# ElysiumDB
Project developed for Database and knowledge at University of Rome Tor Vergata in 2020. The project involves the implementation of a database for the management of records of a generic MMORPG video game called **Elysium**. Includes: description, requirements analysis, development with MySQL query examples, user management, store procedures, events, transactions, triggers. Is also present the version in MongoDB with comparison between the two technologies. The content is in **Italian**

## Game description 
The intent is to design a relational database for managing information in a video game MMORPG (Massive(ly) Multiplayer Online Role-Playing Game) that is a role-playing game that takes place exclusively on the Internet in which thousands of real people meet simultaneously in the same virtual environment.     
The video game in question is a fantasy based on adventure, the development of missions and the search for objects within a vast map with fantastic and medieval features.   
Any new user who wants to enter the game world will have to register by entering his name,  surname, username, e-mail, password and date of birth. Once registered, the gamers can access through their username and password chosen.   

Completed  the access, users will enter the game by dressing up as different customizable characters each belonging to a specific race and one of the classes made available.  Each character has statistics that characterize him; they are based on predefined numerical fields such as: level, current health, maximum health, current mana, maximum mana, defense,  strength, dexterity, constitution, intelligence, wisdom, charisma, temper, stealth.   

Each class/race combination corresponds to a dedicated set of abilities and usable items: a Human-Magician pairing will have a large collection of magical abilities available while other pairs, such as an Elf-Warrior, they will have a reduced skill set but a wide range of dedicated items. Each race, however, guarantees an ability, called "innate", always usable by the character. 

Each object belongs to a category that determines its usefulness: armor, weapons, potions, parchments, groceries, clothes, mission, various. They can be earned by completing missions or buying them in special business activities. These activities, visible on a two-dimensional map available to all players, are of different species (taverns, shops, shops, street vendors), each of them has a range of products that can sell whose prices can vary depending on the activity.  

There are different types of missions with different degrees of difficulty, which, once completed, provide various rewards to players, such as items, coins or experience, of value directly proportional to the difficulty of the task. A task, to be started, may have some constraints, such as: minimum and maximum number of participants and missions to be completed necessarily before starting the task in question (if they exist). 

To encourage team play, it was decided to create groups where players can gather and progress in the adventure in the company of other players. Within the game there is the possibility of creating companies called "Guilds" managed by a "Guild Leader", where players become part of it as their digital egos and gather to complete specific missions dedicated only to members of a Guild. This allows users to get rare items and large sums of money as well as making new acquaintances.

## Some snippets of the project
### Physical Entity Relationship Diagram
<p align="center">
    <img width="500" src="Elysium\3_ERFisico.png" alt="Physical Entity Relationship Diagram">
</p>

### Tables Creation
Example of tables creation.
```SQL
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
```

### Triggers
Trigger that doesn't allow a Guild Master to become master of a new guild
```SQL
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
```

### Procedures
Procedure to return the message of a chat that has id = 'ID_chat' and 'utente' as partecipant
```SQL
DROP PROCEDURE IF EXISTS leggi_messaggi //
CREATE PROCEDURE leggi_messaggi ( IN utente varchar(20), IN ID_chat int unsigned )

BEGIN
   SELECT messaggi.* 
   FROM messaggi, partecipare 
   WHERE messaggi.chat = partecipare.id_chat AND utente = partecipare.username AND partecipare.id_chat = ID_chat;
END //

DELIMITER ;
```

### Transactions
When a player will buy something in game, the system will call this transaction.  
```SQL
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
```

### MongoDB queries
```Javascript
/* Informations and pending missions for characters that have completed no quests */
db.personaggi.find( { $where: function(){
    check = true;
    for(i = 0; i < this.missioni.length; i++){
        if(this.missioni[i].stato == "Completata") 
        {   
            check = false; 
            break;
        }
    }
    return check;
} } , {inventario:0, abilita:0, statistiche:0}).pretty()


/* Completed and active missions and difference between them for each character */
db.personaggi.aggregate([
    {$unwind: "$missioni"},
    {
        $group: {
            _id:"$_id",
            N_Completate: {$sum : {$cond: [ { $eq: ["$missioni.stato","Completata"] } , 1, 0]  }},
            N_Attive: {$sum : {$cond: [ { $eq: ["$missioni.stato","Attiva"] } , 1, 0]  }},
        }   
    },
    {
        $addFields: {
            Differenza: {$subtract: ["$N_Completate", "$N_Attive"] }
        }
    }
],
{ allowDiskUse: true}
)
```

# License
GPLv3