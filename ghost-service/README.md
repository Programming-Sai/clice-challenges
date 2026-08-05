# Ghost Service

## Objective

Get a small HTTP service running inside this container that:

1. Runs as a **non-root** system user named `svc-runner` (not root, not
   your default user).
2. Listens on **TCP port 9000**.
3. Responds to `GET /health` with a JSON body containing
   `"status": "ok"` and `"service": "clice"` (formatting/whitespace
   doesn't matter, the fields just need to be present with those values).
4. **Keeps running after your shell session ends.** Verification happens
   once you submit, not while you're still connected — if your service
   dies the moment your interactive shell exits, it won't be running by
   the time it's checked.

There is no file to write anywhere for this one. Everything is checked
by inspecting live process, user, and network state.

## Tools available in this image

`python3`, `curl`, `netcat-openbsd`, `socat`, `sudo`, `iproute2`,
`procps` — pick whatever combination gets you there. There is more than
one valid way to build the service itself and more than one valid way
to keep it alive after your shell exits.

## Notes

- Think about what actually happens to a background process when the
  shell that launched it terminates.
- Running the service as root is the easy way and will fail the check —
  the whole point is doing it as an unprivileged user.
