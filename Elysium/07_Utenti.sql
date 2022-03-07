DROP USER IF EXISTS 'dilullo'@'localhost'; 
CREATE USER 'dilullo'@'localhost' IDENTIFIED WITH mysql_native_password;
SET old_passwords = 0;
ALTER USER 'dilullo'@'localhost' IDENTIFIED BY 'password'; 
ALTER USER 'dilullo'@'localhost' WITH MAX_USER_CONNECTIONS 5;
GRANT ALL PRIVILEGES ON Elysium.* TO 'dilullo'@'localhost';
FLUSH PRIVILEGES;


DROP USER IF EXISTS 'player'@'127.0.0.1'; 
CREATE USER 'player'@'127.0.0.1' IDENTIFIED WITH mysql_native_password;
SET old_passwords = 0;
ALTER USER 'player'@'127.0.0.1' IDENTIFIED BY 'player_password'; 
GRANT SELECT ON Elysium.* TO 'player'@'127.0.0.1';
GRANT SELECT ON Elysium.Accessi TO 'player'@'127.0.0.1'; REVOKE SELECT ON Elysium.Accessi FROM 'player'@'127.0.0.1';
GRANT SELECT ON Elysium.Messaggi TO 'player'@'127.0.0.1'; REVOKE SELECT ON Elysium.Messaggi FROM 'player'@'127.0.0.1';
GRANT SELECT ON Elysium.Utenti TO 'player'@'127.0.0.1'; REVOKE SELECT ON Elysium.Utenti FROM 'player'@'127.0.0.1';
GRANT SELECT ON Elysium.Statistiche TO 'player'@'127.0.0.1'; REVOKE SELECT ON Elysium.Statistiche FROM 'player'@'127.0.0.1';
GRANT INSERT ON Elysium.gilde TO 'player'@'127.0.0.1';
GRANT INSERT, DELETE ON Elysium.equipaggiare TO 'player'@'127.0.0.1';
GRANT INSERT ON Elysium.messaggi TO 'player'@'127.0.0.1';
FLUSH PRIVILEGES;