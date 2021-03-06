# Docker for Linux
Docker is an open source project to pack, ship and run any application as a lightweight container.

Docker containers are both hardware-agnostic and platform-agnostic. This means they can run anywhere, from your laptop to the largest cloud compute instance and everything in between - and they don't require you to use a particular language, framework or packaging system. That makes them great building blocks for deploying and scaling web apps, databases, and backend services without depending on a particular stack or provider.

# Usage
This asset supports configuration via custom deployment properties.
Supported Properties:

| key | values | default | description |
|:-----:|:--------:|:---------:|:-------------:|
|`docker.socket.tcp.enabled.<role>`|`true`,`false`|`false`|Configure docker daemon to listen over tcp in addition to the default unix socket
|`docker.socket.tcp.address.<role>`|any valid `tcp://<host>:<port>`|`tcp://0.0.0.0:2375`|Configure the host and port docker daemon listens on|
|`docker.group.enabled.<role>`|`true`, `false`|`false`|Configure docker daemon to be accessible by the `docker` group (Warning! this is not secure. Make sure to use best practices for production environments)|
|`docker.group.users.<role>`|any comma separated list of users|`cons3rt`|Users to add to the docker group|


# Requirements:
 * Linux Kernel 3.10+
 * Yum
 * [Cons3rt Utils](https://github.com/oconnormi/cons3rt-utils)
