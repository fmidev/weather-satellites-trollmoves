# Container recipe for Trollmoves

This recipe is automatically built on new version tags, and the image
is available from
https://quay.io/repository/fmi/weather-satellites-trollmoves

Trollmoves is a Pytroll library for transferring files using a
Server/Client architecture. This recipe can be used to build a
container image for use in OpenShift, Kubernetes, Docker, Podman etc.

## Building from the recipe

If the pre-built image isn't usable, the container image can be build
for example by using Podman:

```bash
podman build -t trollmoves .
```

## Configuration

All configuration files are places within `/config/` directory inside
the container.  The injection of the configuration files is
demonstrated below.

### `/config/env-variables`

The entrypoint will start by setting environment variables placed in
`/config/env-variables` file. There are two variables that have an effect
on Trollmoves Server only.  If not given the options are not set

```bash
# Disable handling of existing files
export DISABLE_BACKLOG="--disable-backlog"
# Use watchdog watcher instead of inotify
export USE_WATCHDOG="-w"
```

Trollmoves Client needs an empty `env-variables` file to be present.

### Trollmoves configuration

The process that is run is decided based on the available file names.
If both `trollmoves_server.ini` and `trollmoves_client.ini` are
available, Trollmoves Server is started.

Refer to https://github.com/pytroll/trollmoves on defining the
configuration files.

#### Trollmoves Server

Two configuration files are required for the Trollmoves Server process:
* `/config/trollmoves_log_config.yaml`
* `/config/trollmoves_server.ini`

#### Trollmoves Client

Two configuration files are required for the Trollmoves Client process:
* `/config/trollmoves_log_config.yaml`
* `/config/trollmoves_client.ini`

## Running

The below shows how the processes are run using Podman.

### Networking

As the containers need to communicate between each other, they need to
be placed within the same network and the network should have DNS
enabled.

Lets create a dedicated network and check that DNS is enabled:

```bash
$ podman network create trollmoves
$ podman network inspect trollmoves | grep dns
          "dns_enabled": true,
```

Name the network in a way that makes sense.

### Trollmoves Server

Here's a simple config `trollmoves_server.ini`, make sure the paths
match within the container

```
[example]
origin = /incoming/{filename}.txt
topic = /foo
# ALWAYS use port 40001
request_port = 40001
# No use for nameserver
nameserver = False
```

Make sure to save the config to `trollmoves_server.ini` and match the
directory path mounted to the container.

Similarly save the logging config to `trollmoves_log_config.ini` and
`env-variables` within the same directory.

```bash
podman run --rm \
    --name test_trollmoves_server \
    --network trollmoves \
    -v /host/path/to/server/config_dir:/config:Z \
    -v /data/incoming:/incoming:Z \
    -v /data/target:/target:Z \
    trollmoves
```

### Trollmoves Client

Simple config matching the Server config above:

```
[test]
topic = /foo
# Use the name of the Server container and ALWAYS port number 40000
providers = test_trollmoves_server:40000
destination = file:///target
# ALWAYS use port 40000
publish_port = 40000
heartbeat_alarm_scale = 1
# No use for nameservers
nameservers = False
```

Save the config to `trollmoves_client.ini` along with an empty
`env-variables` file to the config directory of your choice.

We'll also map the host port `9013` to the port `40000` inside the
container so that the messages are reachable also outside the
dedicated Podman network.  This is not necessary if everything works
within the `trollmoves` network.

```bash
podman run --rm \
    --name test_trollmoves_client \
    --network trollmoves \
    -p 40000:9013 \
    -v /host/path/to/client/config_dir:/config:Z \
    trollmoves
```
