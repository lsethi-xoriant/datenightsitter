/* *********************************
      Configure RDS
 ********************************* */
 
/*
DB Engine:  MySQL
DB Version:  5.6.17
DB Instance Class:  db.t1.micro
Multi-AZ Deployment:  No
name: db01
username: scdba
password: sittercity

VPC:  Default

Publicly Accessible:  No

Availability Zone:  us-west-2b

Security Group:  MySQL

Database Name:  <empty>   #### No initial MySQL DB will be created

Backup Retention Period:   5 Days

*/

/* *********************************
      Configure production and staging databases
 ********************************* */

/*delete test data */
DROP DATABASE test;
DELETE FROM mysql.user WHERE user = '';


/* create base database */
CREATE DATABASE marketplace CHARACTER SET utf8;
CREATE DATABASE marketplace_staging CHARACTER SET utf8;

/* create user */
CREATE USER 'sittercity'@'localhost';

UPDATE mysql.user SET password=password('sitter123') WHERE user like ('sittercit%') and host = 'localhost';

GRANT ALL PRIVILEGES ON marketplace.* to 'sittercity'@'localhost';
GRANT ALL PRIVILEGES ON *.* to 'root';

FLUSH PRIVILEGES;

/* *********************************
      Configure dev and test databases
 ********************************* */

/*delete test data */
DROP DATABASE test;
DELETE FROM mysql.user WHERE user = '';


/* create base database */
CREATE DATABASE marketplace_dev CHARACTER SET utf8;
CREATE DATABASE marketplace_test CHARACTER SET utf8;


/* create dev and test users */
CREATE USER 'sittercity_dev'@'localhost';
CREATE USER 'sittercity_test'@'localhost';

UPDATE mysql.user SET password=password('sitter123') WHERE user like ('sittercit%') and host = 'localhost';

GRANT ALL PRIVILEGES ON marketplace_dev.* to 'sittercity_dev'@'localhost';
GRANT ALL PRIVILEGES ON marketplace_test.* to 'sittercity_test'@'localhost';
GRANT ALL PRIVILEGES ON *.* to 'root';

FLUSH PRIVILEGES;

