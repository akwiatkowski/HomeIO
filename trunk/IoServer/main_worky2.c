#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

int main(int argc, char** argv) {
    struct termios tio;
    struct termios stdio;

    fd_set rdset;

    unsigned char c = 'D';
    unsigned char cin = 0;
    char rs[] = "/dev/ttyS0";

    /*
    printf("Please start with %s /dev/ttyS1 (for example)\n", argv[0]);
    //memset(&stdio, 0, sizeof (stdio));
    stdio.c_iflag = 0;
    stdio.c_oflag = 0;
    stdio.c_cflag = 0;
    stdio.c_lflag = 0;
    stdio.c_cc[VMIN] = 1;
    stdio.c_cc[VTIME] = 0;
    tcsetattr(STDOUT_FILENO, TCSANOW, &stdio);
    tcsetattr(STDOUT_FILENO, TCSAFLUSH, &stdio);
    fcntl(STDIN_FILENO, F_SETFL, O_NONBLOCK); // make the reads non-blocking
     */

    //memset(&tio, 0, sizeof (tio));
    tio.c_iflag = 0;
    tio.c_oflag = 0;
    tio.c_cflag = CS8 | CREAD | CLOCAL; // 8n1, see termios.h for more information
    tio.c_lflag = 0;
    tio.c_cc[VMIN] = 1;
    tio.c_cc[VTIME] = 5;

    int tty_fd;
    //tty_fd = open(argv[1], O_RDWR | O_NONBLOCK);
    //tty_fd = open(rs, O_RDWR | O_NONBLOCK);
    tty_fd = open(rs, O_RDWR);
    cfsetospeed(&tio, B38400); // 115200 baud
    cfsetispeed(&tio, B38400); // 115200 baud

    tcsetattr(tty_fd, TCSANOW, &tio);

    unsigned int tmp = 0;

    c = 's';
    write(tty_fd, &c, 1);
    read(tty_fd, &cin, 1);
    tmp = (unsigned int) cin;
    printf("OUT s = %d\n", tmp);


    c = 't';
    write(tty_fd, &c, 1);
    read(tty_fd, &cin, 1);
    tmp = (unsigned int) cin;
    printf("OUT test = %d\n", tmp);

    read(tty_fd, &cin, 1);
    tmp = (unsigned int) cin;
    printf("OUT test = %d\n", tmp);

    int i;
    for (i = 0; i < 8; i++) {
        c = '0';
        c += i;

        write(tty_fd, &c, 1);
        read(tty_fd, &cin, 1);
        tmp = (unsigned int) cin;
        tmp *= 256;
        read(tty_fd, &cin, 1);
        tmp += (unsigned int) cin;

        printf("OUT %d = %d\n", i, tmp);
    }

    close(tty_fd);
}