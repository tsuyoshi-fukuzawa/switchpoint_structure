-- for rails user
CREATE USER 'switchpoint'@'localhost' IDENTIFIED BY 'switchpoint';
grant ALL PRIVILEGES on switchpoint.* TO 'switchpoint'@'localhost';
grant ALL PRIVILEGES on switchpoint_test.* TO 'switchpoint'@'localhost';
FLUSH PRIVILEGES;
