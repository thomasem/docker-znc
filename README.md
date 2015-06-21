# docker-znc
Dockerized ZNC server

First you'll want to generate your configuration. This image will mount a volume, `/var/lib/znc`, where it will place all of your ZNC configuration files. If you're interested in the why, [here](https://docs.docker.com/userguide/dockervolumes/) is a quick read for you.

```
$ docker run -it --name znc-conf tmaddox/znc --makeconf
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
$ docker run -d --name znc-server --volumes-from=znc-conf -p 6697:6697 tmaddox/znc
```

Now you can go fill out your host, port, username, and password details in your favorite IRC client and connect directly to your ZNC server. Upon doing so, go ahead and issue a `/znc help` to your ZNC bouncer, through your IRC client, to get a list of possible commands you can issue.

ZNC documentation can be found here: http://wiki.znc.in/ZNC.

When you want to edit your configuration after-the-fact you can do the following:

```
$ docker run -it --entrypoint /bin/bash --volumes-from=znc-conf tmaddox/znc
znc@b33b2673ba76:~$ vim.tiny /var/lib/znc/configs/znc.conf # Edit all the things!
znc@b33b2673ba76:~$ exit
```

Then, you may do `/znc rehash` in your IRC client when on a network through your ZNC bouncer in order to reload your configuration file. :)

Et voilà!
