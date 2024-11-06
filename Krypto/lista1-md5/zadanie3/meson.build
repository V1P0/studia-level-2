cmake = import('cmake')
sub_proj = cmake.subproject('mbedtls')
cm_lib = sub_proj.dependency('mbedcrypto')
cm_lib2 = sub_proj.dependency('mbedx509')
cm_lib3 = sub_proj.dependency('mbedtls')

message('CMake targets:\n - ' + '\n - '.join(sub_proj.target_list()))

exec = executable('zadanie3', ['src/main.c'], dependencies:[cm_lib, cm_lib2, cm_lib3])