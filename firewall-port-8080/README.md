# Open Port 8080

## Objective
Allow TCP traffic on port `8080` in the `public` firewall zone.

## Task
Open port `8080/tcp` permanently in the `public` zone. The change should persist and be visible in the permanent configuration.

If the firewall service is not actively running, the offline configuration is sufficient.

## Hints
- `firewalld` provides both a running and an offline/permanent mode — the permanent zone files are stored under `/etc/firewalld/zones/`.
- You can query whether a port is considered open in the permanent configuration.

## Expected Outcome
Port `8080/tcp` is listed as open for the `public` zone in the permanent configuration.
