/* Makes gethostname()/uname() report the simulated server's hostname (/etc/hostname, or the
 * transient name set with `hostname NAME`). A container cannot change its kernel hostname, so
 * without this a shell prompt would keep showing the container id. Loaded via /etc/ld.so.preload. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/utsname.h>

static int sim_name(char *buf, size_t len) {
    FILE *f = fopen("/run/ksim/transient-hostname", "r");
    if (!f || !fgets(buf, (int)len, f)) {
        if (f) fclose(f);
        f = fopen("/etc/hostname", "r");
        if (!f) return -1;
        if (!fgets(buf, (int)len, f)) { fclose(f); return -1; }
    }
    fclose(f);
    buf[strcspn(buf, "\r\n")] = 0;
    return buf[0] ? 0 : -1;
}

int gethostname(char *name, size_t len) {
    char b[256];
    if (sim_name(b, sizeof b) == 0) {
        if (strlen(b) + 1 > len) { errno = ENAMETOOLONG; return -1; }
        strcpy(name, b);
        return 0;
    }
    int (*real)(char *, size_t) = dlsym(RTLD_NEXT, "gethostname");
    return real ? real(name, len) : -1;
}

int uname(struct utsname *u) {
    int (*real)(struct utsname *) = dlsym(RTLD_NEXT, "uname");
    int rc = real ? real(u) : -1;
    char b[256];
    if (rc == 0 && sim_name(b, sizeof b) == 0) {
        strncpy(u->nodename, b, sizeof u->nodename - 1);
        u->nodename[sizeof u->nodename - 1] = 0;
    }
    return rc;
}
