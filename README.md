Needs to be done in the end. For now: 




Original guide from Philomena:

## Getting started with dev env:

On systems with `docker` and `docker-compose` installed, the process should be as simple as:

```
docker-compose build
docker-compose up
```

You have to install docker, then docker-compose, clone this repo, and use docker to build the app. May take some time. For me, mostly 15 minutes or less. 

If you use `podman` and `podman-compose` instead, the process for constructing a rootless container is nearly identical:

```
podman-compose build
podman-compose up
```

Once the application has started, navigate to http://localhost:8080 and login with admin@example.com / Tsuchinokus123456789

## Troubleshooting

If you are running Docker on Windows and the application crashes immediately upon startup, please ensure that `autocrlf` is set to `false` in your Git config, and then re-clone the repository. Additionally, it is recommended that you allocate at least 4GB of RAM to your Docker VM.

If you run into an Elasticsearch bootstrap error, it´s important to increase your `max_map_count` on the host as follows:

```
sudo sysctl -w vm.max_map_count=262144
```

If you have SELinux enforcing (Fedora, Arch, others) and manifests as a `Could not find a Mix.Project` error, you should run the following in the application directory on the host before proceeding:

```
chcon -Rt svirt_sandbox_file_t .
```

This allows Docker or Podman to bind mount the application directory into the containers.

If you are using a platform which uses cgroups v2 by default (Fedora 31+), use `podman` and `podman-compose`. Docker will not work correctly.
