#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

int main(int argc, char *argv[]) {
    struct timespec sleep_time;
    int milliseconds;

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <milliseconds>\n", argv[0]);
        return 1;
    }

    // Convert the command line argument to an integer
    milliseconds = atoi(argv[1]);
    if (milliseconds < 0) {
        fprintf(stderr, "Invalid input: milliseconds must be a non-negative integer\n");
        return 1;
    }

    // Convert milliseconds to seconds and nanoseconds
    sleep_time.tv_sec = milliseconds / 1000;                 // Seconds
    sleep_time.tv_nsec = (milliseconds % 1000) * 1000000L;   // Nanoseconds

    // Sleep for the specified duration
    if (nanosleep(&sleep_time, NULL) == -1) {
        fprintf(stderr, "nanosleep() failed: %s\n", strerror(errno));
        return 1;
    }

    return 0;
}

