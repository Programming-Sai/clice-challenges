# DNS Forward Zone

## Objective
Configure a local BIND resolver to answer for `app.local`.

## Task
Configure BIND to resolve `www.app.local` to `192.168.1.100`.

Your zone should include:
- A SOA record
- An NS record for `ns1.app.local`
- An A record for `ns1` (`192.168.1.10`)
- An A record for `www` (`192.168.1.100`)

Add the zone to the BIND configuration, verify the configuration and zone file are valid, start the name server, and ensure it answers queries.

## Hints
- Zone files and BIND configuration live under `/etc/bind` on Ubuntu and `/etc` / `/var/named` on openEuler — check where your system expects them.
- Two tools can validate your work before you start the server: one for the main config and one for the zone file.
- Test with a direct query to `127.0.0.1` to avoid relying on external resolvers.

## Expected Outcome
`dig @127.0.0.1 www.app.local +short` returns `192.168.1.100` and both configuration checks pass.
