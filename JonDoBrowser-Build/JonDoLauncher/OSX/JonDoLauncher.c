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
    if(argc == 2){
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
    	if(!isJavaRunning){
    		system(javaExePPath);
    	}
	}
}
	/*
    char cCurrentPath[FILENAME_MAX];
    if (!getcwd(cCurrentPath, sizeof(cCurrentPath)))
    {
        out << errno << endl;
        out.close();
        return errno;
    }
    out << cCurrentPath << endl;
    */
/*
string exec(const char* cmd) {
    array<char, 128> buffer;
    string result;
    shared_ptr<FILE> pipe(popen(cmd, "r"), pclose);
    if (!pipe) {
    	out << "popen() failed" << endl;
    	throw runtime_error("popen() failed!");
    }
    while (!feof(pipe.get())) {
        if (fgets(buffer.data(), 128, pipe.get()) != NULL){
            result += buffer.data();
        	out << buffer.data();
        }
    }
    return result;
}
*/
/*
#include <iostream>  
#include <stdlib.h> 
#include <fstream>
using namespace std;
int main(int argc, char*argv[]) {

  ofstream out("/home/tinker/Downloads/tmp/jondobrowser_en-US/Browser/JonDo/out.txt", ofstream::out);
  cout << argc << endl;
  cout << argv[0] << endl;
  out << argc << "," << argv[0] << endl;
  system("java -jar JAP.jar &");
  out << "java called";
  out.close();
  return 0;
}
*/