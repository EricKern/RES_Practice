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

// g++ --std=c++11 -o ucLoadFtdi ucLoadFtdi.cpp -lftdi1 -I /usr/include/libftdi1
// call like this:
// ./ucLoadFtdi -f ../sw/main.bin -s 0xc000 -c 1
// ./ucLoadFtdi -f ../sw/obj/main_simple.bin -s 0x8000 -c 1

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

// vhdl commands
// upper nibble
// constant cmdC: integer := 1; -- control
// constant cmdA: integer := 2; -- address
// constant cmdD: integer := 3; -- data length
// constant cmdS: integer := 4; -- data stream
// constant cmdI: integer := 5; -- initialize
// lower nibble is offset for address andlength
const uint8_t cmdL = 0; //-- invalid or lock
const uint8_t cmdC = 1; //-- control
const uint8_t cmdA = 2; //-- address
const uint8_t cmdD = 3; //-- data length
const uint8_t cmdS = 4; //-- data stream
const uint8_t cmdI = 5; //-- initialize

class ucx : public exception {
public:
    ucx(string s) {w = s;};
    const char*what() {return w.c_str();};
protected:
    string w;
};

class InputParser{
public:
    InputParser (int &argc, char **argv){
        for (int i=1; i < argc; ++i)
            this->tokens.push_back(std::string(argv[i]));
    }
    const std::string& getCmdOption(const std::string &option) const{
        std::vector<std::string>::const_iterator itr;
        itr =  std::find(this->tokens.begin(), this->tokens.end(), option);
        if (itr != this->tokens.end() && ++itr != this->tokens.end()){
            return *itr;
        }
        static const std::string empty_string("");
        return empty_string;
    }
    bool cmdOptionExists(const std::string &option) const{
        return std::find(this->tokens.begin(), this->tokens.end(), option)
        != this->tokens.end();
    }
private:
    std::vector <std::string> tokens;
};

void usage(string p) {
    cout << "Usage: " << p << " " << endl \
    << "-c <control value> "  << endl \
    << "-f <data file> "  << endl \
    << "-s <start address> "  << endl \
    << "[-a <address bytes, default: 2>] "  << endl \
    << "[-b <baudrate, default: 115200, option 19200>] "  << endl \
    << "[-d <data bytes, default: 1>] "  << endl \
    << "[-g <debug datat>, default: unset] "  << endl \
    << "[-l <lock>, default: re-initialize] "  << endl \
    << "[-o <offset, default 0. skip offset bytes from file>] "  << endl \
    /* << "[-p <serial port, default: /dev/ttyUSB0>] " */ \
    ;
    exit(0);
}

int send(vector<uint8_t> cmd, int dbgLen = 0) {
#ifdef DBG_C
    {
        int k = dbgLen?dbgLen:cmd.size(); // given len or all
        cout << endl;
        for (int j=0; j < k; j++)
            cout << hex << setfill('0') << setw(2) << (int)cmd.data()[j];
//        for (int j=0; j < k; j++) printf("%2.2x",cmd.data()[j]);
    }
    cout << dec << endl;
#endif
    
    // set signal handöer
    signal(SIGINT, sigintHandler);
    uint8_t *buf = cmd.data();
    int i = cmd.size();
    int f;
    while (i > 0) {
        if (i > chunksize) {
            f = ftdi_write_data(ftdi, buf, chunksize);
            buf += chunksize;
            i -= chunksize;
            cout << "FDTI data chunk sent, size: " << dec << chunksize << endl;
        } else {
            f = ftdi_write_data(ftdi, buf, i);
            cout << "FDTI data chunk sent, size: " << dec << i << endl;
            i = 0;
        }
        if (f < 0)
        {
            fprintf(stderr, "FTDI write error %d (%s)\n", f, ftdi_get_error_string(ftdi));
            break;
        }
    }
    signal(SIGINT, SIG_DFL);
    return cmd.size();
}

const uint8_t magic[] = {0,0,'X','Y','Z'};

////////////////////////////////////////////////

int main(int argc, char **argv){
    
    // command params
    string bitName;
    int addrBytes = 2;
    int dataBytes = 1;
    int ctlVal;
    int words;
    uint32_t startAddress;
    uint32_t offset = 0;
    bool reinit = true;
    string dName;
    bool ddbg = false;

    // local varaibles
    int serFd;
    struct termios newtio, oldtio;
    ifstream bitFile;
    int fsize;
    uint8_t *dbuf;
    vector<uint8_t> cmd;
    InputParser input(argc, argv);
    string option;

    // code
    // get options
    try {
        option = input.getCmdOption("-f");
        // mandatory
        if (option.empty()){
            usage(argv[0]);
        } else {
            bitName = option;
            cout << "Bitfile: " << option << endl;
        }
        option = input.getCmdOption("-c");
        if (option.empty()){
            usage(argv[0]);
        } else {
            sscanf(option.c_str(),"%i",&ctlVal);
        }
        option = input.getCmdOption("-s");
        if (option.empty()){
            usage(argv[0]);
        } else {
            sscanf(option.c_str(),"%i",&startAddress);
        }
        
        // optional
        option = input.getCmdOption("-a");
        if (!option.empty()){
            addrBytes = stoi(option);
        }
        option = input.getCmdOption("-d");
        if (!option.empty()){
            dataBytes = stoi(option);
        }
        option = input.getCmdOption("-b");
        if (!option.empty()){
            baudrate = stoi(option);
        }
        if (input.cmdOptionExists("-l")){
            reinit = false;
        }
        if (input.cmdOptionExists("-g")){
            ddbg = true;
        }
        option = input.getCmdOption("-o");
        if (!option.empty()){
            sscanf(option.c_str(),"%i",&offset);
        }
    } catch(ucx e) {
        cout << "Error: " << e.what() << endl;
        usage(argv[0]);
    } catch(exception e) {
        cout << "Error: " << e.what() << endl;
        usage(argv[0]);
    }
    
    // check file
    try {
        bitFile.open(bitName,std::ifstream::binary);
        if (!bitFile.good()){
            ucx e(string("File error on ") + bitName);
            throw(e);
        } else {
            bitFile.seekg (0, bitFile.end);
            fsize = bitFile.tellg();
            cout << "File size (bytes): " << dec << fsize << endl;
            bitFile.seekg (0, bitFile.beg);
            dbuf = new uint8_t[fsize];
            bitFile.read((char*)dbuf,fsize);
            bitFile.close();
            if (!bitFile) {
                ucx e("Read error");
                throw(e);
            }
        }
    } catch(ucx e) {
        cout << endl << "Error: " << e.what() << endl;
        exit(0);
    } catch(exception e) {
        cout << endl << "Error: " << e.what() << endl;
        exit(0);
    }

    if (!initFtdi()){
        cout << endl << "FTDI init failed " << endl;
        exit(0);
    }
    cout << "FTDI device opened OK" << endl;

    // serfd is open, bitfile is open => print params
    cout << "Data bytes: " << dec << dataBytes << endl;
    cout << "Baudrate: " << baudrate << endl;
    cout << "Reinit ON"  << endl;
    cout << "Address bytes: " << dec << addrBytes << endl;
    cout << "Start: 0x" << hex << startAddress << dec << endl;
    cout << "Offset 0x:" << hex << offset << dec << endl;
    cout << "Control val: 0x" << hex << ctlVal << dec << endl;
    if (0 < offset) {
        cout << "Will skip offset: " << dec << offset << " bytes" << endl;
    }
    words = (fsize - offset) / dataBytes;
    cout << "Words: " << dec << words << endl;

    // send commands
    // magic
    cmd.clear();
    for (int i = 0; i < sizeof(magic); i++){
        cmd.push_back(magic[i]);
    }
    send(cmd);
    
    // control on
    cmd.clear();
    cmd.push_back(cmdC << 4);
    cmd.push_back(ctlVal);
    send(cmd);

    // start address
    cmd.clear();
    for (int i = 0; i < addrBytes; i++){
        cmd.push_back((cmdA << 4) + i);
        cmd.push_back((startAddress >> 8*i) & 0xff);
    }
    send(cmd);
        
    // data length, value is one less than actual 
    cmd.clear();
    for (int i = 0; i < addrBytes; i++){
        cmd.push_back((cmdD << 4) + i);
        cmd.push_back(((words - 1) >> 8*i) & 0xff);
    }
    send(cmd);
   
    if (0 == words) {
        cout << "No data. Going to read mode ..." << endl;
        sleep(1);
    } else {
        // data
        cmd.clear();
        cmd.push_back(cmdS << 4);
        for (int i = 0; i < fsize - offset; i++) {
            cmd.push_back(dbuf[offset + i]);
        }
        delete[] dbuf;

        int sentBytes;
        sentBytes = send(cmd,ddbg?cmd.size():1);
        if (sentBytes != fsize - offset + 1) {
            cout << endl << "Error on serial, data bytes sent: " << sentBytes - 1 << endl;
            close(serFd);
            exit(0);
        }
        cout << endl << "Data bytes sent OK: " << sentBytes - 1 << endl;
        
        sleep(1);
        
        // control off
        cmd.clear();
        cmd.push_back(cmdC << 4);
        cmd.push_back(0);
        send(cmd);
    }
        
    // control is now off (unless we had 0 data)
    // exit handling ...
    cmd.clear();
    if (reinit){
        cout << "Reinitialization" << endl;
        cmd.push_back(cmdI << 4);
        cmd.push_back(cmdI << 4);
    } else {
        cout << "Locking" << endl;
        for (int i = 0; i < 10; i++)
            cmd.push_back(cmdL << 4);
    }
    send(cmd);

    cout << endl;

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
    
