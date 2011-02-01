// for RS
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

// RS configuration
#include "tcp_server.c"
#include "rs.c"

// IO Server
//
// Usage:
// ioserver.bin <port>
//
// transmission parameters are changeable only in config.h


int main(int argc, char** argv) {
    unsigned char c = 'D';
    unsigned char cin = 0;

    // create port using parameter
    int tty_fd = openRS( argv[1] );

    // crate TCP server
    char buffer[MAX_LINE]; /*  character buffer          */
    int conn_s; /*  connection socket         */
    int list_s = createTcpServer();


    /*  Enter an infinite loop to respond
        to client requests and echo input  */

    while (1) {

        /*  Wait for a connection, then accept() it  */

        if ((conn_s = accept(list_s, NULL, NULL)) < 0) {
            fprintf(stderr, "ECHOSERV: Error calling accept()\n");
            exit(EXIT_FAILURE);
        }


        /*  Retrieve an input line from the connected socket
            then simply write it back to the same socket.     */

        Readline(conn_s, buffer, MAX_LINE - 1);

        unsigned char command = buffer[0];
        unsigned int result = 0;

        c = command;
        result = 0;

        write(tty_fd, &c, 1);
        read(tty_fd, &cin, 1);
        buffer[0] = cin;
        result = (unsigned int) cin;
        result *= 256;
        read(tty_fd, &cin, 1);
        buffer[1] = cin;
        result += (unsigned int) cin;

        buffer[2] = 0;
        printf("result %d\n", result);


        Writeline(conn_s, buffer, 2);


        /*  Close the connected socket  */

        if (close(conn_s) < 0) {
            fprintf(stderr, "ECHOSERV: Error calling close()\n");
            exit(EXIT_FAILURE);
        }
    }




    
}