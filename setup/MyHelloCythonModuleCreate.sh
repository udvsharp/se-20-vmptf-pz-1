#! /bin/bash

# Copyright (C)2023 Ihor Sokorchuk, ihor.sokorchuk@nure.ua

declare -r MY_CYTHON_PROJECT='my_hello_project'

# Очистимо екран
#
clear

# Допоміжна функція для цього скрипта на Bash
#
continue_running() {
  echo
  read -p 'Щоб продовжити натисни [Enter]: '
  echo -e "\n\n"
}

# Допоміжна функція для цього скрипта на Bash
#
show_file() {
  echo
  echo 'Вміст файла:'
  echo
  echo '=== Початок файла ==='
  cat $1
  echo '=== Кінець файла ==='
  continue_running
}


#  Видалимо директорію старого проєкту із усім її вмістом
#
rm -rf ${MY_CYTHON_PROJECT}

# Створимо директорію для нового проєкту
#
mkdir ${MY_CYTHON_PROJECT} || exit

# Перейдемо у створену директорію та запам'ятаємо поточну
#
pushd ${MY_CYTHON_PROJECT} >/dev/null || exit

# Створимо файл, який містить код на Cython (розширення .pyx)
# нашого модуля hello
#
echo 'Створимо файл hello.pyx з кодом на Cython нашого модуля hello'

cat >hello.pyx <<'EOF'
from libc.math cimport pow

cdef double square_and_add (double x):
    """Compute x^2 + x as double.

    This is a cdef function that can be called from within
    a Cython program, but not from Python.
    """
    return pow(x, 2.0) + x

cpdef print_result (double x):
    """This is a cpdef function that can be called from Python."""
    print("({} ^ 2) + {} = {}".format(x, x, square_and_add(x)))

EOF


# Переглянемо створений файл hello.pyx
#
show_file hello.pyx

# Створимо файл, який містить код на Python (розширення .py)
# для перевірки роботи нашого модуля hello
#
echo 'Створимо файл test.py з кодом на Python для перевірки нашого модуля hello'

cat >test.py <<'EOF'
#! /usr/bin/python3

# Import the extension module hello.
import hello


# Call the print_result method
hello.print_result(23.0)

EOF

# Зробимо файл test.py виконуваним
#
chmod +x test.py


# Переглянемо створений файл test.py
#
show_file test.py


# Приклади компіляції Cython файла з командного рядка
#
cat <<'EOF'
Файл можна скомпілювати з допомогою утиліт.
Існує два способи компіляції з командного рядка:
* Команда cython бере файл .py або .pyx та компілює його у файл C/C++
  Потім компілятор gcc компілює файл C/C++ у бінарну бібліотеку
  ( ключ -fPIC та ключ -shared вказують, що потрібно створити
    позиційно-незалежний код та бібліотеку )
  Приклад: cython -3 hello.pyx && \
           gcc -fPIC -shared -o hello2.so hello.c -I /usr/include/python3.7m/
* Команда cythonize бере файл .py або .pyx та компілює його у файл C/C++
  Далі вона компілює файл C/C++ у модуль розширення, який можна
  безпосередньо імпортувати з Python.
EOF
continue_running


# Створимо файл, який містить код на Python
# для збирання нашого проєкту
#
echo 'Файл також можна скомпілювати з допомогою програми на Python.'
echo 'Створимо файл setup.py з кодом на Python для збирання нашого модуля hello'

cat >setup.py <<'EOF'
#! /usr/bin/python3

from distutils.core import Extension, setup
from Cython.Build import cythonize


# define an extension that will be cythonized and compiled
ext = Extension(name="hello", sources=["hello.pyx"])
setup(ext_modules=cythonize(ext))

EOF


# Зробимо файл setup.py виконуваним
#
chmod +x setup.py

# Переглянемо створений файл setup.py
#
show_file setup.py


# Зберемо наш проєкт скриптом setup.py
#
echo 'Зберемо наш проєкт скриптом setup.py'
echo
echo '=== Початок роботи скрипта setup.py ==='
./setup.py build_ext --inplace || exit
echo
echo '=== Кінець роботи скрипта setup.py ==='
continue_running


# Переглянемо вміст поточної директорії
#
echo 'Вміст кореневої директорії проєкту:'
echo
ls -F
echo -e "\n\n"
echo 'Дерево проєкту:'
echo
tree ./
continue_running


# Перевіримо роботу нашого модуля
#
echo 'Виконаємо скрипт test.py'
echo
./test.py
echo ' === Кінець роботи скрипта test.py ==='
continue_running

# Повернемось у попередню директорію і завершимо роботу
#
popd >/dev/null

# EOF

