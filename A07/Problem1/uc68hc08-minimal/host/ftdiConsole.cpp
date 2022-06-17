// open the ftdi port B as serial port and print incoming characters

#include <stdio.h>				// Input/Output
#include <unistd.h>
#include <string.h>				// String handling
#include <fcntl.h>              // File control (for random numbers)
#include <termios.h>
#include <sys/stat.h>
#include <errno.h>
#include <stdlib.h>
#include <getopt.h>
#include <signal.h>
#include <ftdi.h>

#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm>
#include <exception>

using namespace  std;

// g++ --std=c++11 -o ftdiConsole ftdiConsole.cpp -lftdi1 -I /usr/include/libftdi1
// call like this:
// ./ftdiConsole  

#define BAUDRATE B115200

#define DBG_C
//#define DBG_D

static int exitRequested = 0;
/*
 * sigintHandler --
 *
 *    SIGINT handler, so we can gracefully exit when the user hits ctrl-C.
 */
static void
sigintHandler(int signum)
{
    exitRequested = 1;
}

struct ftdi_context *ftdi = NULL;
unsigned int chunksize = 0;
int baudrate = 115200;

int initFtdi(void);
void closeFdti(int freeOnly = 0);


////////////////////////////////////////////////

int main(int argc, char **argv){
    
    bool ddbg = false;

    // local varaibles
    int serFd;
    struct termios newtio, oldtio;

    if (!initFtdi()){
        cout << endl << "FTDI init failed " << endl;
        exit(0);
    }
    cout << "FTDI device opened OK" << endl;

    // read loop
    signal(SIGINT, sigintHandler);
    uint8_t *buf = new uint8_t [chunksize];
    while (!exitRequested)
    {
        int f = ftdi_read_data(ftdi, buf, sizeof(buf));
        if (f<0)
            usleep(1 * 100000);
        else if(f> 0)
        {
            fwrite(buf, f, 1, stdout);
            fflush(stdout);
        }
    }
    delete [] buf;
    signal(SIGINT, SIG_DFL);

    // close
    closeFdti();
    
    return 0;
}

int initFtdi(void)
{
    unsigned char buf[1024];
    int f = 0, i;
    int vid = 0x403;
    int pid = 0x6010;
    int interface = INTERFACE_B;

    // Init
    if ((ftdi = ftdi_new()) == 0)
    {
        fprintf(stderr, "ftdi_new failed\n");
        return false;
    }

    if (!vid && !pid && (interface == INTERFACE_ANY))
    {
        ftdi_set_interface(ftdi, INTERFACE_ANY);
        struct ftdi_device_list *devlist;
        int res;
        if ((res = ftdi_usb_find_all(ftdi, &devlist, 0, 0)) < 0)
        {
            fprintf(stderr, "No FTDI with default VID/PID found\n");
            closeFdti(1);
            return false;
        }
        if (res == 1)
        {
            f = ftdi_usb_open_dev(ftdi,  devlist[0].dev);
            if (f<0)
            {
                fprintf(stderr, "Unable to open device %d: (%s)",
                        i, ftdi_get_error_string(ftdi));
            }
        }
        ftdi_list_free(&devlist);
        if (res > 1)
        {
            fprintf(stderr, "%d Devices found, please select Device with VID/PID\n", res);
            /* TODO: List Devices*/
            closeFdti(1);
            return false;
        }
        if (res == 0)
        {
            fprintf(stderr, "No Devices found with default VID/PID\n");
            closeFdti(1);
            return false;
        }
    }
    else
    {
        // Select interface
        ftdi_set_interface(ftdi, (ftdi_interface)interface);
        
        // Open device
        f = ftdi_usb_open(ftdi, vid, pid);
    }
    if (f < 0)
    {
        fprintf(stderr, "unable to open ftdi device: %d (%s)\n", f, ftdi_get_error_string(ftdi));
        return false;
    }

    // Set baudrate
    f = ftdi_set_baudrate(ftdi, baudrate);
    if (f < 0)
    {
        fprintf(stderr, "unable to set baudrate: %d (%s)\n", f, ftdi_get_error_string(ftdi));
        return false;
    }
    
    /* Set line parameters
     *
     * TODO: Make these parameters settable from the command line
     *
     * Parameters are choosen that sending a continous stream of 0x55 
     * should give a square wave
     *
     */
    f = ftdi_set_line_property(ftdi, (ftdi_bits_type)8, STOP_BIT_1, NONE);
    if (f < 0)
    {
        fprintf(stderr, "unable to set line parameters: %d (%s)\n", f, ftdi_get_error_string(ftdi));
        return false;
    }
    
    // turn off flow control
    f = ftdi_setflowctrl(ftdi, SIO_DISABLE_FLOW_CTRL);
    if (f < 0)
    {
        fprintf(stderr, "unable to disable flow control: %d (%s)\n", f, ftdi_get_error_string(ftdi));
        return false;
    }

    // get chunk size
    f = ftdi_write_data_get_chunksize(ftdi, &chunksize);
    if (f < 0)
    {
        fprintf(stderr, "unable to get chunk size: %d (%s)\n", f, ftdi_get_error_string(ftdi));
        return false;
    }  else 
        fprintf(stderr, "FTDI chunksize: %d\n", chunksize);
        
    return true;
}

void closeFdti(int freeOnly) {
    if (!freeOnly)
        ftdi_usb_close(ftdi);
    ftdi_free(ftdi);
}    
    
