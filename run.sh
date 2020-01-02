#!/bin/bash

echo "Type root path for the rustlang followed by [ENTER]:"
read root_path

echo "Type the project path followed by [ENTER]:"
read -e project

if [ "$root_path" == "" ]; then
    echo "Bad root path: " $root_path
    exit 1
else
    if [ "$project" == "" ]; then
        echo "Bad project path: " $project
        exit 1
    else
        docker run --rm -it -e DISPLAY=$DISPLAY \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -v ~/$root_path/rustlang/.vscode/:/home/andrei/.vscode/ \
            -v $project:/home/andrei/project/ \
            -v /media/andrei/6e5f0878-8312-4de4-b648-d84d12f21529/PyOutput/:/home/andrei/datasource/ \
            --network=host \
            rustlang:latest
        exit 0
    fi
fi
