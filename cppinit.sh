#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <project_name> <class_names> <other_cpp_files> <other_inc_files>"
    exit 1
fi

create_makefile()
{
    local name="$1"
    local src="$2"
    local inc="$3"

    cat > Makefile << EOF
CC=c++
CFLAGS=-Wall -Wextra -Werror -std=c++98
NAME=$name
SRC=$src
INC=$inc
OBJ=\$(SRC:.cpp=.o)

all: \$(NAME)

\$(NAME): \$(OBJ)
	\$(CC) \$(CFLAGS) \$^ -o \$@

%.o: %.cpp \$(INC)
	\$(CC) \$(CFLAGS) -c \$< -o \$@

clean:
	rm -f \$(OBJ)

fclean: clean
	rm -f \$(NAME)

re: fclean all

.PHONY: clean
EOF

    echo "Created Makefile with NAME=$name and INC=$inc"
}


create_class_hpp()
{
    local name="$1"
    local up_name=$(echo "$name" | awk '{print toupper($0)}')

    cat >$name.hpp << EOF
#ifndef ${up_name}_HPP
# define ${up_name}_HPP

#include <iostream>
#include <string>

class $name
{

public:
    $name();
    $name(const $name& src);
    ~$name();
    $name& operator=(const $name src);

private:
    // members here
};

#endif
EOF

    echo "Created $name class header file"
}



create_class_cpp()
{
    local name="$1"
    
    cat >$name.cpp << EOF
#include "$name.hpp"

$name::$name() // init members here
{
    // default constructor
}

$name::$name(const $name& src)
{
    // (copy constructor) init or assign members here
}

$name& $name::operator=(const $name& src)
{
    // (assign operator overload) init or assign members here
}

$name::~$name()
{
    // default destructor
}

EOF

    echo "Created $name class source file"
}


cpp_template()
{
    local name="$1"
    local classes="$2"
    local other_cpp="$3"
    local other_inc="$4"

    local hpp_files=""
    local cpp_files=""

    IFS=' '
    read -ra newarr <<< "$classes"
    for class_name in "${newarr[@]}"; do
        create_class_hpp "$class_name"
        create_class_cpp "$class_name"
        hpp_files+="${class_name}.hpp"
        cpp_files+="${class_name}.cpp"
    done

    read -ra o_cpp <<< "$other_cpp"
    for c in "${o_cpp[@]}"; do
	touch $c
    done

    create_makefile "$name" "$cpp_files $other_cpp" "$hpp_files $other_inc"
}

cpp_template "$1" "$2" "$3" "$4"



