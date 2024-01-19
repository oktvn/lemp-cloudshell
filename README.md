# LEMP + Opencart + phpMyAdmin for Google Cloud Shell
Create a new OpenCart instance on Google Cloud Shell from scratch.

## What is this?

Google offers a free VM called 'Google Cloud Shell' aimed at managing cloud infrastructure via the included `gcloud` utility, and also for testing and running various scripts. The terms of usage however don't prohibit usage outside of this scenario.

The `.customize_environment` file is the centerpiece here, and it's essentially a script that runs at instance creation, or whenever it 'wakes up' from hibernation. Only the user home directory contents persist, as such this moves the `www` root into the user's home directory, as well as the `mysql` data directory. It installs the LEMP stack: `nginx`, `mysql` and `php8`, and additionally, the phpMyAdmin and OpenCart PHP applications.

## Usage

You can just copy paste the following one-liner commands to either:

* Install a clean LEMP stack without any applications in the `www` root:

```
cd `mktemp -d`; git clone https://github.com/oktvn/lemp-opencart-cloudshell.git .; bash .customize_environment
```
* Install a clean LEMP stack + Opencart + phpMyAdmin
```
cd `mktemp -d`; git clone https://github.com/oktvn/lemp-opencart-cloudshell.git .; bash .customize_environment; bash install-oc.sh
```

## Notes

* As long as you don't delete the `.customize_environment` file in your home directory, you don't have to re-run the first initialization script yourself again.
* Works very well with my other project, if you're an extension developer or want to rapidly iterate on your existing projects on Opencart: [Extension Directory for Opencart 3.x](https://github.com/oktvn/opencart3-extension-directory)
* Recommended for development work only. Please don't use this on any live environment of any kind. 
