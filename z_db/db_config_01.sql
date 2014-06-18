# *********************************
#      Configure databases
# *********************************

#delete test data
DROP DATABASE test;
DELETE FROM mysql.user WHERE user = '';




#create base database
CREATE DATABASE sit_mkt CHARACTER SET utf8;
CREATE DATABASE sit_mkt_dev CHARACTER SET utf8;
CREATE DATABASE sit_mkt_test CHARACTER SET utf8;


CREATE USER 'sittercity'@'localhost';
CREATE USER 'sittercity_dev'@'localhost';
CREATE USER 'sittercity_test'@'localhost';

UPDATE mysql.user SET password=password('sitter123') WHERE user like ('sittercit%') and host = 'localhost';

GRANT ALL PRIVILEGES ON sit_mkt.* to 'sittercity'@'localhost';
GRANT ALL PRIVILEGES ON sit_mkt_dev.* to 'sittercity_dev'@'localhost';
GRANT ALL PRIVILEGES ON sit_mkt_test.* to 'sittercity_test'@'localhost';
GRANT ALL PRIVILEGES ON *.* to 'root';
FLUSH PRIVILEGES;

