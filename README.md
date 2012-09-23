C/C++ to assembly visualizer
===============

C/C++ to assembly visualizer calls the command `gcc -c -Wa,-ahldn -g file.cpp`, then visualizes the interleaved C/C++ and assembly code on a fancy HTML web interface.

**See Demo [assembly.ynh.io](http://assembly.ynh.io/)**

Quick start
-----------

Clone the repo, `git clone https://github.com/ynh/cpp-to-assembly.git`, or [download as ZIP](https://github.com/ynh/cpp-to-assembly/zipball/master).

Install the application

***
```
$ git checkout git clone https://github.com/ynh/cpp-to-assembly.git
$ cd cpp-to-assembly
$ npm install -d
$ npm install coffee-script
```
***

Start the server

***
```
$ npm start
```
***

Vist [http://localhost:8080](http://localhost:8080)

Licence
-------
http://creativecommons.org/licenses/by/3.0/