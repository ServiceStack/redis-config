# Configure Redis Sentinel

This repository contains the necessary configuration and redis binaries to quickly setup the [Basic Sentinel configuration](http://redis.io/topics/sentinel#example-2-basic-setup-with-three-boxes) on either Linux, OSX or Windows servers. The default configuration supports spawning multiple redis processes which can conveniently all be run on a single server using the included start-all/stop-all scripts (ideal for development environments mimicking their production Sentinel environments). 

The configurations are split into separate `server-{port}` directories which are easily customizable to run on different servers using the included per-server start/stop scripts.

## Usage 

To run the included Sentinel configuration just clone this repository on the server you want to run it on:

    git clone https://github.com/ServiceStack/redis-config.git
    
Then run the scripts for the target Operating System. This repository includes the [latest stable](http://redis.io/download) pre-built binaries for OSX and [MSOpen Tech's latest builds](https://github.com/ServiceStack/redis-windows#running-microsofts-native-port-of-redis) for Windows. As Linux binaries are less portable, the Linux bash scripts assumes an existing install of redis is available in your $PATH.

### Windows

Start 1x Master, 2x Slaves and 3x Sentinel redis-servers:

    cd redis-config\sentinel3\windows
    start-all.cmd

Shutdown started instances:

    stop-all.cmd

### OSX

Start 1x Master, 2x Slaves and 3x Sentinel redis-servers:

    cd redis-config\sentinel3\osx
    ./start-all.sh

Shutdown started instances:

    ./stop-all.sh

### Linux

Start 1x Master, 2x Slaves and 3x Sentinel redis-servers:

    cd redis-config\sentinel3\linux
    ./start-all.sh

Shutdown started instances:

    ./stop-all.sh

Note: The bash scripts for OSX and Linux require execute permission which can be enabled with:

    chmod a=rx start-all.sh

### Notes

After spawning the different redis-server instances the `start-all` script will pause. Wait a few seconds until you see **+slave** and **+sentinel** log entries in the sentinel servers console which shows the sentinels successfully auto-detecting and registering the different slave and sentinel instances. Hitting return will ping the first 2 Sentinel servers for info on the current master and slaves, showing everything is working and configured correctly.


## [Basic Sentinel Setup monitoring 1x Master and 2x Slaves](http://redis.io/topics/sentinel#example-2-basic-setup-with-three-boxes)

With the efficiency and headroom provided from a single redis-server instance, we expect this minimal Sentinel configuration required to achieve high-availability will be the most popular configuration used for Sentinel, which this repository focuses on.

From the [redis Sentinel docs](http://redis.io/topics/sentinel#example-2-basic-setup-with-three-boxes) this setup consists of 1x redis master and 2x redis slaves instances with a Redis Sentinel monitoring each redis instance:

```
            +----------+
            | M1:6380  |
            | S1:26380 |
            +----------+
                 |
 +----------+    |    +----------+
 | R2:6381  |----+----| R3:6382  |
 | S2:26381 |         | S3:26382 |
 +----------+         +----------+
 Configuration: quorum = 2
```

> The above diagram also shows the ports for each of the master, slave and sentinel instances.

This setup enables a "highly-available" configuration which can survive a single **redis-server** or **redis-sentinel** instance or entire server failing. 

### Redis Slave Server failing

If any of the slave servers fail it's business as usual but, just one less replicated slave. This would still cause temporary disruption for any read-only clients that were connected to the failed slave, but if your Redis client library [follows the recommended client strategy](http://redis.io/topics/sentinel-clients), the next time it tries to re-connect it will ask the Sentinel for the next address and connect to one of the other available instances, automatically recovering.

### Redis Master Server failing

It's more disruptive when the master server fails since that's where most of the clients are going to be connected to, who'll only be able to resume until the remaining 2 Sentinels both agree (quorum = 2) the master is **objectively down** and begins the process of failing over promoting one of the replicated slaves to master. Since replication to slaves is asynchronous there's a small window for loss of writes to master that weren't replicated in time before it failed. 

There's a greater potential for loss if there's instead a network split, cutting off the master server from the remaining sentinel servers, i.e:

```
         +----+
         | M1 |
         | S1 | <- C1 (writes will be lost)
         +----+
            |
            /
            /
+------+    |    +----+
| [M2] |----+----| R3 |
| S2   |         | S3 |
+------+         +----+
```

In this case the master continues to process redis commands but won't be able to successfully replicate them to any of its slaves. If the network split was long enough to cause the other 2 Sentinels to presume the master had failed and promoted one of the slaves to master, by the time the master rejoins the network it assumes the role as slave and ends up losing all the writes it processed before the network split. 

This loss can be mitigated by configuring the master to stop accepting writes unless it has successfully replicated to a minimum number of slaves specified in the **min-slaves-to-write** and **min-slaves-max-lag** tolerance options. Consult the [Redis Sentinel docs](http://redis.io/topics/sentinel#example-2-basic-setup-with-three-boxes) for more info.

### Google Cloud - Click to Deploy Redis
