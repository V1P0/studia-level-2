#include <stdio.h>
#include <string.h>
#include <stdbool.h>

bool is_prefix(const char *prefix, const char *str) {
    return strncmp(prefix, str, strlen(prefix)) == 0;
}

bool is_suffix(const char *suffix, const char *str) {
    size_t len_suffix = strlen(suffix);
    size_t len_str = strlen(str);
    return len_suffix <= len_str && strcmp(suffix, str + len_str - len_suffix) == 0;
}

int main(){
    printf("%d\n", is_prefix("hmm", "hmm123"));
    printf("%d\n", is_prefix("123", "hmm123"));
    printf("%d\n", is_suffix("hmm", "hmm123"));
    printf("%d\n", is_suffix("123", "hmm123"));
    return 0;
}