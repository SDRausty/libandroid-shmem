CFLAGS += -fpic -shared -std=c11 -Wall -Wextra -Wl,--version-script=exports.txt

libandroid-shmem.so: shmem.c shm.h
	$(CC) $(CFLAGS) $(LDFLAGS) shmem.c -llog -o $@

gnulinux: shmem.c shm.h ashmem.h
	$(CC) $(CFLAGS) -D_GNU_SOURCE -pthread $(LDFLAGS) shmem.c -o libandroid-shmem.so

install: libandroid-shmem.so shm.h
	install -D libandroid-shmem.so $(PREFIX)/lib/libandroid-shmem.so
	install -D shm.h $(PREFIX)/include/sys/shm.h

clean:
	rm -f libandroid-shmem.so

.PHONY: install
