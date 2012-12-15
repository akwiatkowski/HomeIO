/* 
 * File:   tcp_server.h
 * Author: olek
 *
 * Created on 1 luty 2011, 19:20
 */

#ifndef TCP_SERVER_H
#define	TCP_SERVER_H

#ifdef	__cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>


#include <sys/socket.h> // socket definitions
#include <sys/types.h> // socket types
#include <arpa/inet.h> // inet (3) funtions
#include <unistd.h> // misc. UNIX functions
#include <sys/socket.h>
#include <unistd.h>
#include <errno.h>

#include "config.h"

#define LISTENQ (1024) // Backlog for listen()
#define MAX_LINE (1000)

    // Read line from socket
    ssize_t readLine(int sockd, void *vptr, size_t maxlen);
    // Write line to socket
    ssize_t writeLine(int sockd, const void *vptr, size_t n);
    // Create TCP listening socket
    int createTcpServer();

#ifdef	__cplusplus
}
#endif

#endif	/* TCP_SERVER_H */

