// for RS
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>

// RS configuration
#include "tcp_server.c"
#include "rs.c"

// IO Server
//
// Usage:
// ioserver.bin <port>
//
// transmission parameters are changeable only in config.h

/*
 * Protocol:
 * Send to server array of chars:
 * <count of command bytes> <count of response bytes> <command bytes>
 *
 * After retrieving uC response it reply
 * <response bytes>
 *
 * And close connection
 */



int main(int argc, char** argv) {
    // create port using parameter

    // temporary char used for sending command (loop)
    unsigned char tmp_char = 0;
    // temporary char used for sending command (loop)
    unsigned char i = 0;
    // count of command bytes
    unsigned char count_command = 0;
    // count of response bytes
    unsigned char count_response = 0;

    // file descriptor to RS
    if ( ! argv[1] ) {
        printf("Error: no serial port specified\n");
        exit(1);
    }
    int tty_fd = openRS(argv[1]);


    // crate TCP server
    char buffer[MAX_LINE]; // character buffer
    int conn_s; // connection socket
    int list_s = createTcpServer();

    
    // infinite server loop
    while (1) {
        // Wait for a connection, then accept() it
        if ((conn_s = accept(list_s, NULL, NULL)) < 0) {
            fprintf(stderr, "ECHOSERV: Error calling accept()\n");
            exit(EXIT_FAILURE);
        }

        // Retrieve command
        readLine(conn_s, buffer, MAX_LINE - 1);

	time_t t = time(0);
        printf("Time %srcv %s", ctime(&t), buffer);

        // command and response char count
        count_command = buffer[0];
        count_response = buffer[1];
        
        // send to uC
        for (i=0; i<count_command; i++) {
            tmp_char = buffer[2 + i];
            write(tty_fd, &tmp_char, 1);
        }
        // receive from uC
        unsigned long int tmp = 0;
        for (i=0; i<count_response; i++) {
            // next byte, *256 current value
            tmp *= 256;

            read(tty_fd, &tmp_char, 1);
            buffer[i] = tmp_char;
            // sum for displaying result
            tmp += (unsigned long int) tmp_char;
        }
        buffer[count_response] = 0;
        printf("res raw %d\n", tmp);

        /*
         * // OLD CODE
        read(tty_fd, &i, 1);
        buffer[0] = i;
        tmp = (unsigned int) i;
        tmp *= 256;
        
        buffer[1] = i;
        tmp += (unsigned int) i;
        printf("%d\n", tmp);
        buffer[2] = 0;
         */

        // send uC reply via socket
        // count_response + 1 to add \0
        writeLine(conn_s, buffer, count_response);

        // Close the connected socket
        if (close(conn_s) < 0) {
            fprintf(stderr, "ECHOSERV: Error calling close()\n");
            exit(EXIT_FAILURE);
        }
    }





}
