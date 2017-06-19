let perl_carton_path = system('carton exec perl -e "print join(q/,/,@INC)"')
let perl_lib_path = fnamemodify(finddir("lib", ";"), ":p")
let perl_libs_path = join([perl_carton_path, perl_lib_path], ',')
execute('set path='.perl_libs_path)

let g:ale_perl_perl_options = '-c -Mwarnings -Ilib,'.perl_libs_path
