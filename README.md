# Knobby Docker Postfix

## What?

Fork of [docker-postfix-relay](https://github.com/Tecnativa/docker-postfix-relay), with a lot more knobs. [docker-smtp](https://github.com/namshi/docker-smtp) is also out there, but it works a bit differently.

## Why?

I wanted to try out [Bitwarden](https://github.com/bitwarden/), and figured out that it wanted to send out verification emails. It runs on Docker; so I figured an SMTP instance in Docker would be the best way to handle that email traffic. ``docker-smtp`` didn't seem to meet my needs. I kinda went overboard on trying to reconfigure ``docker-postfix-relay``.

## How?

1. [Install Docker Compose](https://docs.docker.com/compose/install/)
1. ``git clone (this repo) && cd knobby-docker-postfix && cp example.env config.env``
1. Edit ``config.env`` to your esired values. The [Postfix documentation](http://www.postfix.org/BASIC_CONFIGURATION_README.html) has some guidance. Also may be wise to delete unused values; they can be re-copied from ``example.env`` as needed.
1. ``docker-compose up -d``

## Gotchas

1. You may need to [validate the networking](https://docs.docker.com/compose/networking/#configure-the-default-network) in the Docker Compose file.
1. If you're using [Gmail Relay](https://support.google.com/a/answer/2956491?hl=en), pay close attention to the output from ``docker logs`` for errors.
1. Postfix gets really wonky if you try to use it with a "slim" container. Fortunately, the base Debian Stable image isn't much bigger.
1. This container, and ``docker-postfix-relay``, rely on [dumb-init](https://github.com/Yelp/dumb-init) for core functionality. If the container isn't building correctly, make sure a copy of ``dumb-init`` is available for use. Adjust the docker-compose / Dockerfile, as needed.
