# Web Service on 8080

## Objective
Serve a static page on port `8080` using Nginx.

## Task
1. Create the document root and content:
   - Directory: `/data/www`
   - File: `index.html` containing exactly `hello, clice` (lowercase, with a comma and space)

2. Configure Nginx to serve `/data/www` on port `8080` and start the service. The default configuration should be adapted or supplemented so that a request to `http://localhost:8080/` returns your file.

## Hints
- On this system Nginx configuration can be added under `/etc/nginx/conf.d/` or `/etc/nginx/sites-available/`.
- After changing configuration, verify syntax and (re)start Nginx.
- `curl` can be used to test the local endpoint.

## Expected Outcome
`curl -s http://localhost:8080/` returns `hello, clice` and `/data/www/index.html` contains the same.
