#!/bin/bash
if ! pgrep -x mariadbd >/dev/null 2>&1 && ! pgrep -x mysqld >/dev/null 2>&1; then echo "Starting mariadb..."; mkdir -p /var/run/mysqld; chown mysql:mysql /var/run/mysqld 2>/dev/null || true; mysqld_safe --datadir=/var/lib/mysql & sleep 5; fi
for i in 1 2 3 4 5 6 7 8 9 10; do if mysqladmin ping -u root --silent 2>/dev/null; then break; fi; sleep 1; done
if ! mysqladmin ping -u root --silent 2>/dev/null; then echo "FAIL: MariaDB not running"; exit 1; fi
if ! mysql -u root -e "SHOW DATABASES LIKE 'appdb';" 2>/dev/null | grep -q appdb; then echo "FAIL: database appdb does not exist"; exit 1; fi
if ! mysql -u root -e "SELECT User,Host FROM mysql.user WHERE User='appuser' AND Host='localhost';" 2>/dev/null | grep -q appuser; then echo "FAIL: user appuser@localhost does not exist"; mysql -u root -e "SELECT User,Host FROM mysql.user;" 2>/dev/null; exit 1; fi
grants="$(mysql -u root -e "SHOW GRANTS FOR 'appuser'@'localhost';" 2>/dev/null)"
echo "Grants: $grants"
if echo "$grants" | grep -qi "SELECT" && echo "$grants" | grep -qi "INSERT" && echo "$grants" | grep -qi "appdb"; then if echo "$grants" | grep -qi "ALL PRIVILEGES"; then echo "FAIL: user has ALL PRIVILEGES, expected only SELECT, INSERT"; exit 1; fi; echo "PASS: appuser@localhost has SELECT, INSERT on appdb"; exit 0; else echo "FAIL: Grants do not contain SELECT and INSERT on appdb"; echo "$grants"; exit 1; fi
