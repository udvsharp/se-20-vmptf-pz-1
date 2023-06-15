#! /bin/bash

# Copyright (C)2023 Ihor Sokorchuk, ihor.sokorchuk@nure.ua

# У цьому прикладі ми загорнемо просту функцію C з допомогою Cython і 
# викличемо її з чистого модуля Python, який не залежатиме від коду виклику C. 
# Для цього виконаємо таке:
#  * Створимо бібліотеки C
#  * Встановимо Cython (при потребі)
#  * Створимо файлу .pyx, у якому функція C буде оголошена та упакована
#  * Створимо файл setup.py, який створить спільний об’єкт, що 
#    функціонуватиме як імпортований модуль Python
#  * Побудуємо модуль
#  * Створимо файл на Python, у якому імпортуємо створений модуль та 
#    викличемо загорнуту функцію

show_info() {
cat <<'EOF'

У цьому прикладі ми загорнемо просту функцію на C з допомогою 
Cython та викличемо її зі звичайного модуля Python, код якого 
не залежить від коду виклику C. 

Для цього виконаємо таке:

1. Створимо бібліотеку з функціями на C
2. Встановимо Cython (при потребі)
3. Створимо файл .pyx, у якому буде оголошена та упакована функція C
4. Створимо файл setup.py, який створюватиме спільний об’єкт, що 
   функціонуватиме як імпортований модуль Python
5. Побудуємо модуль зі спільним обʼєктом
6. Створимо файл на Python, у якому імпортуємо створений модуль та 
   викличемо загорнуту функцію
EOF
next_stage
}

declare -r MY_CYTHON_PROJECT='my_c_wrapper_project'

declare -r RED='\033[1;31m'
declare -r GREN='\033[1;32m'
declare -r YELLOW='\033[1;33m'
declare -r BLUE='\033[1;34m'
declare -r PURPLE='\033[1;35m'
declare -r CYAN='\033[1;36m'
declare -r NC='\033[0m' # No Color

# Очистимо екран
clear

# Допоміжна функція для цього Bash скрипта
#
next_stage() {
  echo
  read -p 'Щоб продовжити натисни [Enter]: '
  echo -ne "${RED}"
  echo -e '\n#########################################################\n'
  echo -ne "${NC}"
}

# Допоміжна функція для цього Bash скрипта
#
show_file() {
  echo
  echo 'Вміст файла:'
  echo
  echo '=== Початок файла ==='
  echo -ne "${YELLOW}"
  cat $1
  echo -ne "${NC}"
  echo '=== Кінець файла ==='
  next_stage
}

show_info

#  Видалимо директорію старого проєкту із усім її вмістом
#
if [ -e ${MY_CYTHON_PROJECT} ]; then
  read -p 'Видалити директорію проєкту '${MY_CYTHON_PROJECT}' [y/N]: '
  if [ "$REPLY" == 'y' ]; then
    rm -rf ${MY_CYTHON_PROJECT} && echo 'Проєкт видалено!'
  else
    echo 'Старий проєкт НЕ видалено!'
    exit
  fi
fi
next_stage

# Створимо директорію для нового проєкту
#
mkdir -p ${MY_CYTHON_PROJECT}/lib || exit

# Перейдемо у створену директорію та запам'ятаємо поточну
#
pushd ${MY_CYTHON_PROJECT} >/dev/null || exit


# Створимо файл example.c на C для бібліотеки
#
FILE='./lib/examples.c'
echo "Створимо файл ${FILE} із кодом бібліотеки на C"

cat >${FILE} <<'EOF'
#include <stdio.h>

#include "examples.h"

void hello(const char *name) {
    printf("Hello %s!\n", name);
}

EOF
#
# Переглянемо створений файл
#
show_file ${FILE}


# Створимо файл example.h
#
FILE='./lib/examples.h'
echo "Створимо файл заголовків ${FILE} для бібліотеки"

cat >${FILE} <<'EOF'
#ifndef EXAMPLES_H
#define EXAMPLES_H

void hello(const char *name);

#endif

EOF
#
# Переглянемо створений файл
#
show_file ${FILE}


# Створимо файл Makefile, який полегшить нам процес створення бібліотеки:
#
FILE='./lib/Makefile'
echo "Створимо файл ${FILE} для роботи з C бібліотекою"

sed 's/\s\s\s\s/\t/g' >${FILE} <<'EOF'
CC = gcc

default: libexamples.a

libexamples.a: examples.o
    ar rcs $@ $^

examples.o: examples.c examples.h
    $(CC) -c $<

clean:
    rm *.o *.a

EOF
#
# Переглянемо створений файл
#
show_file ${FILE}

# Скомпілюємо нашу бібліотеку example.c
#
echo 'Створимо обʼєктний файл і статичну (для простоти) бібліотеку:'
# gcc -c examples.c
# ar rcs libexamples.a examples.o
pushd ./lib/
echo -ne "${PURPLE}"
make
echo -ne "${NC}"
popd
echo
echo 'Дерево проєкту:'
tree ./
next_stage


# Створимо файл Makefile
# Він полегшить нам процес створення модуля Cython:
FILE='Makefile'
echo "Створимо файл ${FILE} для створення модуля Cython"

sed 's/\s\s\s\s/\t/g' >${FILE} <<'EOF'
LIB_DIR = lib

default: pyexamples

pyexamples: setup.py pyexamples.pyx $(LIB_DIR)/libexamples.a
    python3 setup.py build_ext --inplace && rm -f pyexamples.c && rm -Rf build

$(LIB_DIR)/libexamples.a:
    make -C $(LIB_DIR) libexamples.a

clean:
    rm *.so

EOF
#
# Переглянемо створений файл
#
show_file ${FILE}


# При потребі встановимо cython
#
# pip3 install cython


# Створимо файл pyexamples.pyx
# Цей файл Cython скомпілює в спільний об’єкт
# Він написаний на мові Cython, надмножині Python і поєднує чистий Python
# із C-подібними оголошеннями
# У нашому коді ми включаємо оголошення функції hello та
# обгортаємо її функцією, яку можна викликати на Python:
#
FILE='pyexamples.pyx'
echo "Створимо файл ${FILE}, який оголошує та загортає функцію hello"

sed 's/\t/\s\s\s\s/g' >${FILE} <<'EOF'
cdef extern from "examples.h":
    void hello(const char *name)

def py_hello(name: bytes) -> None:
    hello(name)

EOF
#
# chmod +x ${FILE}
#
# Переглянемо створений файл
#
show_file ${FILE}


# Створимо файл setup.py
# Cython інтегрується з distutils, що
# полегшує створення спільного об’єкта.
# Зверніть увагу на бібліотеки:
# Параметри library_dir і include_dir - імʼя бібліотеки —
# це ім’я файла без префікса lib і суфікса .a,
# а шляхи до каталогів мають відповідати структурі проєкту.
# У разі, якщо всі файли знаходяться в одному каталозі,
# параметри dir можуть бути пропущені.
#
FILE='setup.py'
echo "Створимо файл ${FILE} для створення спільного обʼєкта"

sed 's/\t/\s\s\s\s/g' >${FILE} <<'EOF'
#! /usr/bin/python3

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

examples_extension = Extension(
    name="pyexamples",
    sources=["pyexamples.pyx"],
    libraries=["examples"],
    library_dirs=["lib"],
    include_dirs=["lib"]
)

setup(
    name="pyexamples",
    ext_modules=cythonize([examples_extension])
)

EOF
#
chmod +x ${FILE}
#
# Переглянемо створений файл
#
show_file ${FILE}

# Створимо модуль.
# Буде створено каталог «build», файл «pyexamples.c» та 
# спільний об’єкт із дещо складною назвою.
# Нам потрібен лише спільний об’єкт, тому ми можемо 
# видалити файл C і каталог збірки «build»
#
echo 'Створимо модуль'
echo -ne "${PURPLE}"
./setup.py build_ext --inplace
echo -ne "${NC}"
echo
echo 'Дерево проєкту:'
tree
next_stage


# Створимо простий Python файл із викликом загорнутої функції:
#
FILE='main.py'
echo "Створимо файл ${FILE} із викликом загорнутої функції"

sed 's/\t/\s\s\s\s/g' >${FILE} <<'EOF'
#! /usr/bin/env python3

import pyexamples

pyexamples.py_hello(b"world")

EOF
#
chmod +x ${FILE}
#
# Переглянемо створений файл
#
show_file ${FILE}


# Перевіримо роботу Python скрипта main.py
#
echo 'Вміст файла main.py'
show_file ./main.py
echo 'Виконаємо створений файл main.py'
echo
echo -ne "${PURPLE}"
./main.py
echo -ne "${NC}"
next_stage


# Вийдемо із програми
#
popd

# EOF
