#include <windows.h>
#include <io.h>

#include <sys/types.h>			// Primitive system data types
#include <stdio.h>				// Input/Output
#include <stdlib.h>				// General utilities
#include <string.h>				// String handling
#include <fcntl.h>              // File control (for random numbers)

#include <stdint.h>
#include <sys/stat.h>
#include <string.h>

#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm>
#include <exception>

using namespace  std;


// Compile: cl /EHsc ucLoadWin.cpp 
// call like this:
// ./ucLoadWin -f ../sw/obj/main_simple.bin -s 0x8000 -p com2 -c 1

// serial
#define BAUDRATE B115200
#define _POSIX_SOURCE 1 /* POSIX compliant source */

#define DBG_C
//#define DBG_D

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


void usleep (long usec)
{
	LARGE_INTEGER lFrequency;
	LARGE_INTEGER lEndTime;
	LARGE_INTEGER lCurTime;
	QueryPerformanceFrequency (&lFrequency);
	if (lFrequency.QuadPart) {
		QueryPerformanceCounter (&lEndTime);
		lEndTime.QuadPart += (LONGLONG) usec *
		lFrequency.QuadPart / 1000000;
		do {
			QueryPerformanceCounter (&lCurTime);
			Sleep(0);
		} while (lCurTime.QuadPart < lEndTime.QuadPart);
	}
}

////////////////// serial port //////////////////////


int init_io(const char *dev, HANDLE* pHandle)
{
  //struct termios newtio;
    HANDLE serFd;
	serFd = CreateFile( dev,
						GENERIC_READ | GENERIC_WRITE, 
						0, 
						0, 
						OPEN_EXISTING,
						0,
						0);
	if (serFd == INVALID_HANDLE_VALUE){
    perror(dev); 
    printf("Notty\n");
    return -1;
  }

	DCB dcbSerialParams = {0};
	dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (GetCommState(serFd, &dcbSerialParams) == 0)
    {
        fprintf(stderr, "Error getting device state\n");
        CloseHandle(serFd);
        return -1;
    }
     
    dcbSerialParams.BaudRate = CBR_115200;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity = NOPARITY;
    if(SetCommState(serFd, &dcbSerialParams) == 0)
    {
        fprintf(stderr, "Error setting device parameters\n");
        CloseHandle(serFd);
        return -1;
    }
 
    // Set COM port timeout settings
    COMMTIMEOUTS timeouts = {0};
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;
    if(SetCommTimeouts(serFd, &timeouts) == 0)
    {
        fprintf(stderr, "Error setting timeouts\n");
        CloseHandle(serFd);
        return -1;
    }

  *pHandle = serFd;
  return 0;
  
}


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
    << "[-p <serial port, default: COM1>] " << endl \
    << "[-d <data bytes, default: 1>] "  << endl \
    << "[-g <debug datat>, default: unset] "  << endl \
    << "[-l <lock>, default: re-initialize] "  << endl \
    << "[-o <offset, default 0. skip offset bytes from file>] "  << endl \
    /* << "[-p <serial port, default: /dev/ttyUSB0>] " */ \
    ;
    exit(0);
}


int send(HANDLE fd, vector<uint8_t> cmd, int dbgLen = 0) {
    int i;
	DWORD bytes_written;
    for (i = 0; i < cmd.size(); i++){
        bytes_written = 0;
        do {
            WriteFile(fd, &cmd.data()[i],1, &bytes_written, NULL);
        } while (0 == bytes_written);
        usleep(100);
    }
    FlushFileBuffers(fd);
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
    return cmd.size();
}

const uint8_t magic[] = {0,0,'X','Y','Z'};

////////////////////////////////////////////////

int main(int argc, char **argv){
    
    // command params
    string serDev = "\\\\.\\COM1";
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
    HANDLE serFd;
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
        option = input.getCmdOption("-p");
        if (!option.empty()){
            serDev = option;
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

    // open tty
	if (0 == init_io(serDev.c_str(),&serFd)) {
        cout << "Serial port " << serDev << "initialized" << endl;
	} else {
        cout << serDev << ": Notty" << endl;
        exit(0);
	}

    // serfd is open, bitfile is open => print params
    cout << "Data bytes: " << dec << dataBytes << endl;
    cout << "Serial device: " << serDev << endl;
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
    send(serFd,cmd);
    
    // control on
    cmd.clear();
    cmd.push_back(cmdC << 4);
    cmd.push_back(ctlVal);
    send(serFd,cmd);

    // start address
    cmd.clear();
    for (int i = 0; i < addrBytes; i++){
        cmd.push_back((cmdA << 4) + i);
        cmd.push_back((startAddress >> 8*i) & 0xff);
    }
    send(serFd,cmd);
        
    // data length, value is one less than actual 
    cmd.clear();
    for (int i = 0; i < addrBytes; i++){
        cmd.push_back((cmdD << 4) + i);
        cmd.push_back(((words - 1) >> 8*i) & 0xff);
    }
    send(serFd,cmd);
   
    if (0 == words) {
        cout << "No data. Going to read mode ..." << endl;
        usleep(1000000);
    } else {
        // data
        cmd.clear();
        cmd.push_back(cmdS << 4);
        for (int i = 0; i < fsize - offset; i++) {
            cmd.push_back(dbuf[offset + i]);
        }
        delete[] dbuf;

        int sentBytes;
        sentBytes = send(serFd,cmd,ddbg?cmd.size():1);
        if (sentBytes != fsize - offset + 1) {
            cout << endl << "Error on serial, data bytes sent: " << sentBytes - 1 << endl;
            CloseHandle(serFd);
            exit(0);
        }
        cout << endl << "Data bytes sent OK: " << sentBytes - 1 << endl;
        
        usleep(1000000);
        
        // control off
        cmd.clear();
        cmd.push_back(cmdC << 4);
        cmd.push_back(0);
        send(serFd,cmd);
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
    send(serFd,cmd);
    cout << endl;
    // close
    CloseHandle(serFd);
    
    return 0;
}
    
