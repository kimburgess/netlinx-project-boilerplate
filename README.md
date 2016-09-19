# What is this thing?

Base system framework for building out AMX NetLinx control systems. This repository sets up a workspace, standard project directory structure and links commonly useful libraries to aid in rapid development and deployment.

# How do I use it?

Clone this repo

    git clone git@github.com:KimBurgess/netlinx-project-boilerplate.git <your project name>

then

    cd <your project name>

and finally

    ./init.sh

# What you get

A fresh git repo (ready for pushing to your project remote) that contains a base project manageable directory structure for the some lovely OCD project organisation.

    /
    |-- include
    |-- lib
    |-- module
        |-- doc
    |-- ui

## `/`
Root directory should contain the NetLinx Studio workspace and master `*.axs` file only.

## `/include/`
All project specific includes. Where possible functionality should be split into logical `*.axi` components.

As NetLinx does not offer any language syntax for limiting variable or function scope, all entites (variable, functions etc) should be prefixed with the name of their parent include to provide a psuedo encapsulation - e.g. `includNameFunctionName(..)` or `includeNameVariable`.

All non-public entities within include components should be further prefixed with an underscore (`_`) to indicate they should not be utilised outside of the enclosing include.

## `/lib/`
All external libraries and re-usable components.

This comes prefilled with:

- [netlinx-common-libraries](https://github.com/KimBurgess/netlinx-common-libraries)
- [amx-device-library](https://github.com/AMXAUNZ/amx-device-library)

## `/module/`
All device drivers or fully encapsulated system components. Root directory should contain precompiled modules only with any associated API documents placed in the `/module/doc` subdirectory.

Any fully encapsulated system components should be given their own directory containing all source code.

## `/ui/`
Project `*.tp4` and `*.tp5` files.
