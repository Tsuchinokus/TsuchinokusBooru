Needs to be done in the end. For now: 

# Tsuchinokus


## Original guide from Philomena:

### Getting started with dev env:

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

### Troubleshooting

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

### Deployment guide from original devs, to me.

Furbooru uses the following providers for the following purposes:

OVH - main server (a simple $25 VPS)

Cloudflare - anti-ddos + proxy + DNS

Cloudflare R2 - primary image storage and CDN

Backblaze B2 - backups storage

Vultr - auxiliary servers for Discord bots, proxy and camo


**So, in short, all that right now cost 60 or 80$ month.**
In this moment, furbooru have near 210.000 images, 18,900 users, and 25,000 comments. 

Now, to Deployment:
Prod deploy is essentially easy for a programmer. 

Get a debian server. I use last ubuntu-server version mostly.

Install openresty, postgresql, elasticsearch and redis. 

With that 4 installed, import openresty (nginx) configs from development, adjust all the paths, and make ssl certificate. You can use Let's encrypt ones, they are free.

Make a user account for your booru and install elixir **on it via kiex**. Trust me, use Kiex. Truly.

Clone repo into ~/tsuchinokus folder, make a shell script that would set all environment variables (you can see which ones in docker-compose.yml file)


Now, in that user account:

```
mix local.rebar --force && mix local.hex --force
```

Then, install all Tsuchinokus dependencies like ffmpeg and whatnot. They recommend me use **fiberglass** (docker-based media processing tools container) and create shortcuts to it in /usr/local/bin. I need to take a close look at this myself.
```
- mix deps.get
```
```
- mix release --overwrite
```
```
- mix db:seed
```
Finally, create systemd user service that starts Tsuchinokus, and mostly, you will had your app running
