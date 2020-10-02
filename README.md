C/C++ to assembly visualizer
===============

C/C++ to assembly visualizer calls the command `gcc -c -Wa,-ahldn -g file.cpp`, then visualizes the interleaved C/C++ and assembly code on a fancy HTML web interface.

**See Demo [assembly.ynh.io](http://assembly.ynh.io/)**

Quick start
-----------

1. Clone the repo, `git clone https://github.com/ynh/cpp-to-assembly.git`, or [download as ZIP](https://github.com/ynh/cpp-to-assembly/zipball/master).

2. Install the application
```sh
$ git clone https://github.com/ynh/cpp-to-assembly.git
$ cd cpp-to-assembly
$ npm install -d
$ npm install coffee-script
```

3. Start the server
```sh
$ npm start
```

4. Visit [localhost:8080](http://localhost:8080)

Licence
-------
GPL 3 or later

http://gplv3.fsf.org/ 

5.Hope you learn something new
