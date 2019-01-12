CFLAGS += -fpic -std=c11 -Wall -Wextra

all: libandroid-shmem.so shm_test

libandroid-shmem.so: shmem.c shm.h
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -Wl,--version-script=exports.txt -DTERMUX_PREFIX=\"$(PREFIX)\" shmem.c -llog -o $@

shm_test: shm_test.c
	$(CC) $(CFLAGS) $(LDFLAGS) shm_test.c -o $@

install: libandroid-shmem.so shm.h
	install -D libandroid-shmem.so $(PREFIX)/lib/libandroid-shmem.so
	install -D shm.h $(PREFIX)/include/sys/shm.h
	install -D shm_test $(PREFIX)/libexec/shm_test

clean:
	rm -f libandroid-shmem.so shm_test

.PHONY: install
