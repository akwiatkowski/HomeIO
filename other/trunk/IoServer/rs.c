#include "rs.h"

// Open RS port and set all parameters
// Parameters are stored in config.h
int openRS(char* portDevice) {
    // initialize RS232
    struct termios tio;

    //memset(&tio, 0, sizeof (tio));
    tio.c_iflag = 0;
    tio.c_oflag = 0;
    // set in config.h
    tio.c_cflag = RS_FLAGS;
    tio.c_lflag = 0;
    tio.c_cc[VMIN] = 1;
    tio.c_cc[VTIME] = 5;

    // open port
    int tty_fd;
    //tty_fd = open(argv[1], O_RDWR | O_NONBLOCK);
    tty_fd = open(portDevice, O_RDWR);

    cfsetospeed(&tio, RS_SPEED); // 115200 baud
    cfsetispeed(&tio, RS_SPEED); // 115200 baud

    tcsetattr(tty_fd, TCSANOW, &tio);

    return tty_fd;
}

// Close RS port
void closeRS( int tty_fd ) {
    close(tty_fd);
}

