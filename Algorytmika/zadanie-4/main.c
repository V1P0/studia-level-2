#include <string.h>
#include <stdio.h>

int check_pattern(const char* pattern, const char* text){
    for(int k = 0; k<=strlen(text)-strlen(pattern); k++){
        if(memcmp(pattern, text+k, strlen(pattern)*sizeof(char))==0)
            return k;
    }
    return -1;
}

int main(){
    printf("%d\n", check_pattern("xd", "xdd"));
    return 0;
}