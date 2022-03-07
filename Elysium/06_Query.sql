/*#1 STAMPA ESPERIENZA GUADAGNATA DA TUTTI I MEMBRI DELLA GILDA "gilda99"*/
SELECT personaggi.gilda, personaggi.nome, SUM(esperienza) as TOT_Esperienza
FROM (assegnare JOIN missioni ON assegnare.missione = missioni.ID) JOIN personaggi ON personaggi.nome = assegnare.personaggio
WHERE assegnare.stato = "Completata" AND personaggi.gilda = "gilda99"
GROUP BY personaggi.nome;    

/*#2 STAMPA A SCHERMO L'ESPERIENZA GUADAGNATA DA I GIOCATORI MEMBRI DI UNA GILDA ATTRAVERSO MISSIONI DEDICATE A QUESTE ULTIME E ORDINARE IN BASE ALL'ESPERIENZA TOTALE GUADAGNATA DALLA GILDA*/
SELECT personaggi.gilda, SUM(esperienza) as TOT_Esperienza
FROM (assegnare JOIN missioni ON assegnare.missione = missioni.ID) JOIN personaggi ON personaggi.nome = assegnare.personaggio
WHERE assegnare.stato = "Completata" AND missioni.rivolta_a = "gilda" AND NOT ISNULL(personaggi.gilda)
GROUP BY personaggi.gilda
ORDER BY Tot_Esperienza DESC;


/*#3 STAMPA INFORMAZIONI DI TUTTI GLI OGGETTI POSSEDUTI DA UN UTENTE RAGGRUPPATI PER PERSONAGGIO*/
SELECT personaggi.nome AS Personaggio, oggetti.nome as oggetto, oggetti.descrizione, oggetti.bersaglio, oggetti.categoria , oggetti.utilizzabile, oggetti.vendibile, oggetti.valore
FROM (inventario JOIN oggetti ON oggetti.nome = inventario.oggetto) JOIN personaggi ON personaggi.nome = inventario.personaggio
ORDER BY personaggi.nome 
LIMIT 50;

/*#4 STAMPA IL NUMERO DI OGGETTI POSSEDUTI DA OGNI PERSONAGGIO CHE NE POSSIEDE PIU DI 30*/ 
SELECT personaggi.nome AS Personaggio, COUNT(oggetti.nome) as TOT_Oggetti
FROM (inventario JOIN oggetti ON oggetti.nome = inventario.oggetto) JOIN personaggi ON personaggi.nome = inventario.personaggio
GROUP BY personaggi.nome
HAVING TOT_Oggetti > 30;

/*#5 STAMPA CORPO (primi 100 caratteri) DEI MESSAGGI INVIATI DA L'UTENTE "ytDejCla72" E LE CHAT VERSO LE QUALI LI HA INVIATI */
SELECT messaggi.mittente, SUBSTRING(messaggi.Corpo, 1, 100) AS Corpo, chat.nome
FROM chat, messaggi
WHERE messaggi.mittente = "ytDejCla72" AND chat.ID = messaggi.chat;

/*#6 STAMPA NOME DI TUTTI GLI OGGETTI GUADAGNATI COMPLETANDO MISSIONI DA PERSONAGGI DI CLASSE "Guerriero"*/
SELECT personaggi.nome, personaggi.classe, ricompense.oggetto
FROM ( (assegnare JOIN personaggi ON personaggi.nome = assegnare.personaggio) JOIN missioni ON  assegnare.missione = missioni.ID) JOIN ricompense ON ricompense.missione = missioni.ID 
WHERE assegnare.stato = "Completata" AND personaggi.classe = "Guerriero"
ORDER BY personaggi.nome;


/*#7 STAMPA INFORMAZIONI PERSONAGGIO CHE POSSIEDE IL MAGGIOR NUMERO DI OGGETTI (numero oggetti diversi, non interessano le quantità)*/
SELECT personaggi.nome as proprietario, COUNT(oggetti.nome) as TOT_Oggetti
FROM (inventario JOIN oggetti ON oggetti.nome = inventario.oggetto) JOIN personaggi ON personaggi.nome = inventario.personaggio
GROUP BY personaggi.nome
ORDER BY TOT_Oggetti DESC
LIMIT 1;

/*#8 STAMPA NOME, COORDINATE E PREZZO DEI LUOGHI CHE VENDONO "Wisdom Jar" ORDINATI IN ORDINE DI PREZZO CRESCENTE*/
SELECT luoghi.nome, luoghi.latitudine, luoghi.longitudine, vendere.prezzo
FROM (luoghi JOIN attività_commerciali ON luoghi.nome = attività_commerciali.luogo) JOIN vendere ON attività_commerciali.ID = vendere.attività
WHERE vendere.oggetto = "Wisdom Jar"
ORDER BY vendere.prezzo ASC;

/*#9 STAMPA IL NUMERO DI PERSONAGGI DELLO STESSO LIVELLO CHE HANNO COMPLETATO LA MISSIONE "400" E POI STAMPARNE IL TOTALE*/
SELECT assegnare.missione, COALESCE(personaggi.livello, "TOTALE ->") AS Livello, COUNT(personaggi.nome) AS N_personaggi
FROM assegnare JOIN personaggi ON personaggi.nome = assegnare.personaggio
WHERE assegnare.missione = 400 AND assegnare.stato = "Completata"
GROUP BY personaggi.livello WITH ROLLUP;

/*#10 STAMPA ID, MONETE, ESPERIENZA DELLE MISSIONI CHE FORNISCONO OGGETTI CHE HANNO EFFETTO SULLA SALUTE*/
SELECT missioni.ID, missioni.monete, missioni.esperienza
FROM ( (ricompense JOIN missioni ON missioni.ID = ricompense.missione) JOIN oggetti ON ricompense.oggetto = oggetti.nome) JOIN influenzare ON influenzare.oggetto = oggetti.nome
WHERE influenzare.statistica IN ("salute_attuale", "salute_massima")
GROUP BY missioni.ID;

/*#11 STAMPA NOME E LIVELLO DI TUTTI I PERSONAGGI CHE HANNO COMPLETATO UNA MISSIONE DI GRADO >= 125*/
SELECT personaggi.nome, personaggi.livello
FROM (assegnare JOIN personaggi ON personaggi.nome = assegnare.personaggio) JOIN missioni ON missioni.ID = assegnare.missione
WHERE missioni.grado >= 125;

/*#12 STAMPA OGGETTI UTILIZZABILI DALLA RAZZA "Dragonide"*/
SELECT utilizzare_razza.razza, oggetti.*
FROM utilizzare_razza JOIN oggetti ON oggetti.nome = utilizzare_razza.oggetto
WHERE utilizzare_razza.razza = "Dragonide";

/*#13 STAMPA NOME, RAZZA, CLASSE, LIVELLO E GILDA DEI PERSONAGGI POSSEDUTI DA UTENTI CHE HANNO ESEGUITO L'ACCESSO TRA IL "2019-02-25 21:40:24" E IL "2019-10-31 17:50:21"*/
SELECT personaggi.utente, orario, personaggi.nome, personaggi.razza, personaggi.classe, personaggi.livello, personaggi.gilda
FROM utenti JOIN accessi ON utenti.username = accessi.username JOIN personaggi ON personaggi.utente = utenti.username
WHERE orario BETWEEN "2019-02-25 21:40:24" AND "2019-10-31 17:50:21" 
ORDER BY orario;

/*#14 STAMPA NOME RAZZA, NOME ABILITA, EFFETTI E DURATA DELLE ABILITA INNATE DELLE RAZZE CHE POSSONO USARE L'OGGETTO "Sanctifying Sta"*/
SELECT razze.nome, avere_effetto.* 
FROM ((avere_effetto JOIN abilita ON abilita.nome = avere_effetto.abilita) JOIN razze ON razze.abilita = abilita.nome) JOIN utilizzare_razza ON utilizzare_razza.razza = razze.nome
WHERE utilizzare_razza.oggetto = "Sanctifying Sta";

/*#15 STAMPA INFORMAZIONI SUGLI OGGETTI UTILIZZABILI SULLA STATISTICA COL VALORE MASSIMO TRA TUTTE LE STATISTICHE DI TUTTI I PERSONAGGI */
SELECT influenzare.statistica, oggetti.*
FROM (SELECT MAX(caratterizzare.valore) as massimo, statistica from caratterizzare) max_stat,
      oggetti JOIN influenzare ON influenzare.oggetto = oggetti.nome
WHERE influenzare.statistica = max_stat.statistica;

/*#16 STAMPA INFORMAZIONI DI TUTTI I LUOGHI E, SE ESISTONO, MISSIONI E ATTIVITA SITUATE IN QUEL LUOGO */
SELECT luoghi.*, missioni.ID, attività_commerciali.ID
FROM (luoghi LEFT JOIN missioni ON luoghi.nome = missioni.luogo) LEFT JOIN attività_commerciali ON attività_commerciali.luogo = luoghi.nome;

/*#17 STAMPA IL NUMERO DI MESSAGGI INVIATI DAGLI UTENTE IL CUI NOME INIZIA PER UNA VOCALE*/
SELECT utenti.username, COUNT(messaggi.mittente) as TOT_Messaggi
FROM  messaggi JOIN utenti ON messaggi.mittente = utenti.username 
WHERE utenti.username LIKE "a%" OR utenti.username LIKE "e%" OR utenti.username LIKE "i%" OR utenti.username LIKE "o%" OR utenti.username LIKE "u%"
GROUP BY utenti.username;

/*#18 STAMPA LA MEDIA E LA SOMMA DELLE MISSIONI COMPLETATE DAI MEMBRI DI UNA GILDA E IL NUMERO DI MEBRI DI ESSA*/
SELECT completate.gilde, COUNT(completate.pers), SUM(completate.Totale) as Totale_Gilde, AVG(completate.Totale) AS Media_Gilde
FROM  (
            SELECT personaggi.nome as pers, personaggi.gilda as gilde,  COUNT(assegnare.missione) as Totale
            FROM personaggi JOIN assegnare ON personaggi.nome = assegnare.personaggio
            WHERE assegnare.stato = "Completata"
            GROUP BY personaggi.nome
      ) completate
GROUP BY completate.gilde;

/*#19 STAMPA IL NUMERO DI OGGETTI POSSEDUTI DAI CAPI DELLE GILDE (dove il numero oggetti è inteso somma quantità per ogni oggetto) E ORDINALI IN MANIERA DESCRESCENTE*/
SELECT personaggi.nome, COUNT(inventario.oggetto) as Tipi_Oggetti, SUM(quantità) as Totale_Oggetti
FROM (gilde JOIN personaggi ON personaggi.nome = gilde.capo) JOIN inventario ON inventario.personaggio = personaggi.nome
GROUP BY personaggi.nome
ORDER BY Totale_Oggetti DESC;

/*#20 STAMPA, PER OGNI PERSONAGGIO, LA QUANTITA DI ESPERIENZA GUADAGNATA COMPLETANDO LE MISSIONI, QUELLA GUADAGNABILE TRAMITE MISSIONI ATTIVE E LA DIFFERENZA TRA LE DUE ORDINATI PER QUEST ULTIMO VALORE*/
SELECT Nome, Completate, Attive, (Completate - Attive) AS Differenza
FROM ( SELECT personaggio as Nome,
              SUM(case when stato = 'Completata' then missioni.esperienza else 0 end) AS Completate,
              SUM(case when stato = 'Attiva' then missioni.esperienza else 0 end) AS Attive
        FROM missioni JOIN assegnare ON missioni.ID = assegnare.missione
        GROUP BY personaggio
    ) as Conteggio
ORDER BY Differenza LIMIT 10;

/*#21 STAMPA LE MISSIONI COMPLETATE E ATTIVE DEI MEMBRI DELLA GILDA DEL PERSONAGGIO "FrigidYetis" CHE SIANO STATE COMPLETATE O ATTIVATE DA QUEST'ULTIMO */
SELECT PM.gilda, PM.nome, AF.missione
FROM assegnare AF JOIN personaggi PF ON AF.personaggio = PF.nome, 
     assegnare AM JOIN personaggi PM ON AM.personaggio = PM.nome
WHERE AF.missione = AM.missione AND
      PF.gilda = PM.gilda AND
      PF.nome = "FrigidYetis" AND PM.nome <> "FrigidYetis";