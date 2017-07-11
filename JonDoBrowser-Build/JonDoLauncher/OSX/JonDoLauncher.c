#include <cstdio>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <array>
#include <fstream>
#include <unistd.h>

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
    if(argc == 3){
        char* javaExeRPath = "/JAP.app/Contents/MacOS/JavaAppLauncher --hideUpdate &";
        char* javaExePPath = new char [strlen(argv[1]) + strlen(javaExeRPath) + 1];
        strcpy(javaExePPath, argv[1]);
        strcat(javaExePPath, javaExeRPath);

    	string res = exec("ps aux | grep \"[J]AP.app\" | wc -l");

        bool isJavaRunning = false;
        for(int i = 0; i < res.length(); i++){
            if(res[i] == (char)'0'){
                break;
            }else if(res[i] > (char)'0' && res[i] <= (char)'9'){
                isJavaRunning = true;
                break;
            }
        }
    	if(!isJavaRunning && strcmp(argv[2], "on") == 0){
    		system(javaExePPath);
    	}
        if(isJavaRunning && strcmp(argv[2], "off") == 0){
            system("pkill -f 'JAP.app' &");
        }
	}
}