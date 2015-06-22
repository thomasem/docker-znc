# Dockerized ZNC server

## Requirements

* Install [Docker](https://docs.docker.com/).
* If on Mac OS X, or any other platform which tends to only have a Docker client, you'll also need a Docker daemon running remotely, [exposing the API](https://docs.docker.com/reference/api/docker_remote_api_v1.19/).
* This can also easily be run on a [Docker Swarm](https://docs.docker.com/swarm/) cluster.

## From scratch setup
First you'll want to generate your configuration. This image will mount a volume, `/var/lib/znc`, where it will place all of your ZNC configuration files. If you're interested in the why, [here](https://docs.docker.com/userguide/dockervolumes/) is a quick read for you.

```
$ docker run -it --name znc-conf tmaddox/znc:1.0 --makeconf
```

This will pull down the image if it doesn't exist locally and invoke the interactive configuration creator from ZNC.

```
[ .. ] Checking for list of available modules...
[ >> ] ok
[ ** ]
[ ** ] -- Global settings --
[ ** ]
[ ?? ] Listen on port (1025 to 65534): 6697
[ ?? ] Listen using SSL (yes/no) [no]: yes
[ ?? ] Listen using both IPv4 and IPv6 (yes/no) [yes]: no
[ .. ] Verifying the listener...
[ >> ] ok
[ ** ] Unable to locate pem file: [/var/lib/znc/znc.pem], creating it
[ .. ] Writing Pem file [/var/lib/znc/znc.pem]...
[ >> ] ok
[ ** ] Enabled global modules [webadmin]
[ ** ]
[ ** ] -- Admin user settings --
[ ** ]
[ ?? ] Username (alphanumeric): user
[ ?? ] Enter password:
[ ?? ] Confirm password:
[ ?? ] Nick [user]:
[ ?? ] Alternate nick [user_]:
[ ?? ] Ident [user]:
[ ?? ] Real name [Got ZNC?]: First Last
[ ?? ] Bind host (optional):
[ ** ] Enabled user modules [chansaver, controlpanel]
[ ** ]
[ ?? ] Set up a network? (yes/no) [yes]: yes
[ ** ]
[ ** ] -- Network settings --
[ ** ]
[ ?? ] Name [freenode]:
[ ?? ] Server host [chat.freenode.net]:
[ ?? ] Server uses SSL? (yes/no) [yes]:
[ ?? ] Server port (1 to 65535) [6697]:
[ ?? ] Server password (probably empty):
[ ?? ] Initial channels:
[ ** ] Enabled network modules [simple_away]
[ ** ]
[ .. ] Writing config [/var/lib/znc/configs/znc.conf]...
[ >> ] ok
[ ** ]
[ ** ] To connect to this ZNC you need to connect to it as your IRC server
[ ** ] using the port that you supplied.  You have to supply your login info
[ ** ] as the IRC server password like this: user/network:pass.
[ ** ]
[ ** ] Try something like this in your IRC client...
[ ** ] /server <znc_server_ip> +6697 user:<pass>
[ ** ]
[ ** ] To manage settings, users and networks, point your web browser to
[ ** ] https://<znc_server_ip>:6697/
[ ** ]
[ ?? ] Launch ZNC now? (yes/no) [yes]: no
```

As you can see, the initial configuration is pretty straightforward. I would recommend just answering 'no' to the question, "Launch ZNC now?" We'll start the ZNC server soon enough. Just a quick tip: the username/password you set up will be the username/password to log in from your IRC client to the ZNC server. Credentials to your various IRC servers will be handled separately when you go to add networks to connect to via your ZNC console commands.

As promised, now you'll want to start up a server using the configuration you just generated.

```
$ docker run -d --name znc-server --volumes-from=znc-conf -p 6697:6697 tmaddox/znc:1.0
```

Now you can go fill out your host, port, username, and password details in your favorite IRC client and connect directly to your ZNC server. Upon doing so, go ahead and issue a `/znc help` to your ZNC bouncer, through your IRC client, to get a list of possible commands you can issue.

ZNC documentation can be found here: http://wiki.znc.in/ZNC.

## Editing the configuration

When you want to edit your configuration after-the-fact you can do the following:

```
$ docker exec -it znc-server /bin/bash
root@1e57434b8081:/var/lib/znc# vim.tiny configs/znc.conf
root@1e57434b8081:/var/lib/znc# exit
```

Then, you may do `/znc rehash` from your IRC client in order to reload your configuration file. :)

## Migrating existing ZNC bouncer

The main thing to make an easy migration is to essentially mount your existing znc data directory inside your znc-conf container, instead of generating a new configuration. To do this, you can simply create a new container and mount your existing directory at the expected datadir for this Docker image (/var/lib/znc)
```
$ docker run --name znc-conf -v /path/to/znc:/var/lib/znc busybox
```

In this case, you don't necessarily need the `tmaddox/znc` image, since you're not invoking `znc --make-conf` to generate a new configuration. :)

After you've created your `znc-conf` container, you can create your server container, like described in the [from scratch setup](#from-scratch-setup):

```
$ docker run -d --name znc-server --volumes-from=znc-conf -p 6697:6697 tmaddox/znc:1.0
```

After creating the `znc-conf` container, in order to reduce downtime in the migration, it might be best to `docker pull` the image first, so you could do something like:

```
$ docker pull tmaddox/znc:1.0
```

Once, Docker is done pulling the image, just stop your existing service and run the container; it should be very quick. This will allow us to use the same port as before, without Docker erroring out trying to use a port that's already in-use.

```
$ service znc stop && docker run -d --name znc-server --volumes-from=znc-conf -p 6697:6697 tmaddox/znc:1.0
```

Et voilà!
