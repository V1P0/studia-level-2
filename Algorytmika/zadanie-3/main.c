#include <stdio.h>
#include <string.h>

int biggest_k(const char* string1, const char* string2){
    int len_x = strlen(string1);
    int len_y = strlen(string2);
    int len = len_x > len_y ? len_y : len_x;

    for (int k = len; k > 0; k--) {
        int match = 1;
        int i;
        for (i = 0; i < k; i++) {
            if (string1[i] != string2[len_y - k + i]) {
                match = 0;
                break;
            }
        }
        if (match) {
            return k;
        }
    }
    return 0;
}

int main(){
    printf("%d\n", biggest_k( "psikacz","mopsik"));
}