# LEMP + phpMyAdmin + MailCatcher for Google Cloud Shell
Rapidly iterate on your LEMP projects on Google's Cloud Shell.

## What is this?

Google offers a free VM called 'Google Cloud Shell' aimed at managing cloud infrastructure via the included `gcloud` utility, and also for testing and running various scripts. The terms of usage however don't prohibit usage outside of this scenario.

The `.customize_environment` file is the centerpiece here, and it's essentially a script that runs at instance creation, or whenever it 'wakes up' from hibernation. Only the user home directory contents persist, as such this moves the `www` root into the user's home directory, as well as the `mysql` data directory. It installs the LEMP stack: `nginx`, `mysql` and `php8`.

## Usage

You can just copy paste the following one-liner commands to install it:
```
cd `mktemp -d`; git clone https://github.com/oktvn/lemp-cloudshell.git .; bash .customize_environment
```

(Optional) Run the installation script on demand from your home directory:
```
bash .customize_environment
```

## Notes

* As long as you don't delete the `.customize_environment` file in your home directory, you don't have to re-run the first initialization script yourself on the next boot of the Cloud Shell instance.
* Recommended for development work only. Please don't use the conf files on any live environment of any kind. 
