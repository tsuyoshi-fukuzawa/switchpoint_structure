-- for rails user
CREATE USER 'switchpoint'@'localhost' IDENTIFIED BY 'switchpoint';
grant ALL PRIVILEGES on switchpoint.* TO 'switchpoint'@'localhost';
grant ALL PRIVILEGES on switchpoint_test.* TO 'switchpoint'@'localhost';
FLUSH PRIVILEGES;

-- for read only
CREATE USER 'switchpoint_read'@'localhost' IDENTIFIED BY 'switchpoint';
grant SELECT on switchpoint.* TO 'switchpoint_read'@'localhost';
FLUSH PRIVILEGES;



-- for rails user
-- CREATE USER 'switchpoint'@'%' IDENTIFIED BY 'switchpoint';
-- grant ALL PRIVILEGES on switchpoint.* TO 'switchpoint'@'%';
-- grant ALL PRIVILEGES on switchpoint_test.* TO 'switchpoint'@'%';
-- FLUSH PRIVILEGES;
-- 
-- for read only
-- CREATE USER 'switchpoint_read'@'%' IDENTIFIED BY 'switchpoint';
-- grant SELECT on switchpoint.* TO 'switchpoint_read'@'%';
-- FLUSH PRIVILEGES;