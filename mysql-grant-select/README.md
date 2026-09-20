# Database User Privileges

## Objective
Create a database and a restricted user with specific grants.

## Task
Using MariaDB:

1. Ensure the database server is running and create a database named `appdb` if it does not exist.
2. Create a user `appuser@localhost` identified by `SecurePass123!` if it does not exist.
3. Grant only `SELECT` and `INSERT` privileges on `appdb.*` to that user.

Do not grant additional privileges.

## Hints
- The server can be started directly without the system service manager.
- Grants can be inspected to confirm only the intended privileges were given.
- The user and database creation should be idempotent.

## Expected Outcome
- Database `appdb` exists.
- User `appuser@localhost` exists with password `SecurePass123!`.
- `SHOW GRANTS` for the user includes `SELECT` and `INSERT` on `appdb` and does not include `ALL PRIVILEGES`.
