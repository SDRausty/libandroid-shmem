//
// A dummy program to test support of shm*() system calls.
//

#include <linux/ipc.h>
#include <stdio.h>
#include <syscall.h>
#include <unistd.h>

// Note: it seems that __NR_shmget and other __NR_shm* calls
// are not defined for x86 (32bit).

#ifndef __i386__
static int shmget(key_t key, size_t size, int shmflg) {
    return syscall(__NR_shmget, key, size, shmflg);
}
#endif

int main() {
#ifdef __i386__
    return 1;
#else
    int shmid;

    if ((shmid = shmget(IPC_PRIVATE, 30, IPC_CREAT | 0666)) < 0)
        return 1;

    return 0;
#endif
}
