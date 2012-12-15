/* 
 * File:   rs.h
 * Author: olek
 *
 * Created on 1 luty 2011, 19:11
 */

#ifndef RS_H
#define	RS_H

#ifdef	__cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>


#include <termios.h>
#include "config.h"

    // Open RS port and set all parameters
    // Parameters are stored in config.h
    int openRS(char* portDevice);

    // Close RS port
    void closeRS(int tty_fd);



#ifdef	__cplusplus
}
#endif

#endif	/* RS_H */

