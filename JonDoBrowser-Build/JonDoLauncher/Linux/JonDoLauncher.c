#include <cstdio>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <cstring>
#include <array>
#include <unistd.h>
//#include <fstream>

using namespace std;

string exec(const char* cmd) {
    array<char, 128> buffer;
    string result = "";
    shared_ptr<FILE> pipe(popen(cmd, "r"), pclose);
    if (!pipe) {
    	throw runtime_error("popen() failed!");
    }
    while (!feof(pipe.get())) {
        if (fgets(buffer.data(), 128, pipe.get()) != NULL){
            result += buffer.data();
        }
    }
    return result;
}

int main(int argc, char*argv[]){
    //ofstream out("./JonDo/out.txt", ofstream::out);
    //out << argc << endl;
    if(argc == 2){
        //out << argv[0] << endl;
        //out << argv[1] << endl;
    	string res = exec("ps aux | grep \"[J]AP.jar\" | wc -l");
        bool isJAPRunning = false;
        for(int i = 0; i < res.length(); i++){
            if(res[i] == (char)'0'){
                break;
            }else if(res[i] > (char)'0' && res[i] <= (char)'9'){
                isJAPRunning = true;
                break;
            }
        }
        //out << isJAPRunning << endl;
        //out << strcmp(argv[1], "on") << endl;
        //out << strcmp(argv[1], "off") << endl;
    	if(!isJAPRunning && strcmp(argv[1], "on") == 0){
    		system("java -jar ./JonDo/JAP.jar --hideUpdate &");
    	}
        if(isJAPRunning && strcmp(argv[1], "off") == 0){
            system("pkill -f 'java.*JAP.jar*' &");
        }
    }
    //out.close();
}
	