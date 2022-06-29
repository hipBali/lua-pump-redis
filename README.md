


# lua-pump-redis

Lua tools to pump data into redis storage


# Table of Contents
[Requirements](#req)

[Directory structure](#dir_struct)

[Usage](#usage)


## Requirements  <a name="req"></a>

>**Redis**
>[redis.io](https://redis.io)

for use as rest service
>**OpenResty**
>[openresty.org](https://openresty.org/)

for use from command line
>**redis-lua**
>[nrk/redis-lua](https://github.com/nrk/redis-lua)
>

## Directory structure <a name="dir_struct"></a>
~~~
lua-pump-redis
├── src
│   ├── dtcoll.lua
│   ├── dtcommon.lua
│   ├── dtree_redis.lua
│   ├── dtutil_redis.lua
│   ├── hlpfunc.lua
│   ├── json.lua
│   ├── redis_client.lua
│   └── redis_client_cli.lua
└── examples
    ├── bikestore_data
    │   └── # bikestore example files (json)
    ├── bikestore_loader.lua
    └── toredis.lua
~~~

## Usage <a name="usage"></a>
### using rest service
1. *install openresty*
2. *create your own workspace and install lua-datatree-redis*
~~~
   mkdir ~/work 
   cd ~/work 
   git clone https://github.com/hipBali/lua-datatree-redis.git
   cd dtree-redis
   cp src/* resty/api/core
~~~
 3. *run Nginx rest service*
~~~
   nginx -p `pwd`/ -c conf/nginx.conf
~~~

***simple curl request***

## License


BSD 2-Clause License
Copyright (c) 2022, hipBali
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
