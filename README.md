# OpenTAKServer Installation Guideline

## 1. Create AWS EC2 Instance

## 1.1. Create an Instance
Instance Minimum Requirements for <= 10 users\
- Instance type: t3.medium
- CPU core count: 2
- Memory (GB): 4
- Storage (GB): 10 (4.5GB OS + OTS)

Below snippet shows an example of storage spaces of an AWS instance with Ubuntu 24 that has OTS installed successfully.
```
Filesystem       Size  Used Avail Use% Mounted on
/dev/root         30G  4.5G   26G  15% /
tmpfs            1.9G  1.1M  1.9G   1% /dev/shm
tmpfs            768M  892K  767M   1% /run
tmpfs            5.0M     0  5.0M   0% /run/lock
efivarfs         128K  3.8K  120K   4% /sys/firmware/efi/efivars
/dev/nvme0n1p16  881M   89M  730M  11% /boot
/dev/nvme0n1p15  105M  6.2M   99M   6% /boot/efi
tmpfs            384M   16K  384M   1% /run/user/1000
```

## 1.2. Configure Security Group
Inbound Rules:
- Port 8089 (TCP) from 0.0.0.0/0 - ATAK SSL streaming
- Port 8446 (TCP) from 0.0.0.0/0 - Certificate enrollment
- Port 443 (TCP) from your IP/admin IPs - Web UI (restrict to admin access)
- Port 8889 (TCP) from 0.0.0.0/0 - WebRTC video (if needed)
- Port 8189 (UDP) from 0.0.0.0/0 - WebRTC data (if needed)
- Port 22 (TCP) from your IP - SSH (restrict to admin access)


## 2. HTTPS SSL Certificate from Let's Encrypt (Optional)
This steps is not required if you can obtain SSL certificate for HTTPS from other vendors.
For example, you can obtain a certificate from AWS ACM if you have a static public IP and a domain hosted in AWS Route53.
```
We use certbot to obtain and renew the certificate and recommend to follow the page below since we use `nginx` as the proxy server for OTS and `pip` for most of the installation.

https://certbot.eff.org/instructions?ws=nginx&os=pip
```
### 2.1. Obtain the Certificate and Install in `nginx`
We recommend to use the command `sudo certbot --nginx` to (1) obtain the SSL certificate, and (2) modify nginx configuration to install the certificate. Below snippet shows an example of output from the command once the certificate is obtained and installed successfully.
```
$ sudo certbot --nginx
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Enter email address or hit Enter to skip.
 (Enter 'c' to cancel): tajui.s@gmail.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at:
https://letsencrypt.org/documents/LE-SA-v1.6-August-18-2025.pdf
You must agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y
Account registered.
Please enter the domain name(s) you would like on your certificate (comma and/or
space separated) (Enter 'c' to cancel): tttest-tak.duckdns.org
Requesting a certificate for tttest-tak.duckdns.org

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/tttest-tak.duckdns.org/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/tttest-tak.duckdns.org/privkey.pem
This certificate expires on 2026-05-17.
These files will be updated when the certificate renews.

Deploying certificate
Successfully deployed certificate for tttest-tak.duckdns.org to /etc/nginx/sites-enabled/ots_http
Congratulations! You have successfully enabled HTTPS on https://tttest-tak.duckdns.org

NEXT STEPS:
- The certificate will need to be renewed before it expires. Certbot can automatically renew the certificate in the background, but you may need to take steps to enable that functionality. See https://certbot.org/renewal-setup for instructions.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

### 2.2. Check the Certificate Expiration
Run the command `sudo certbot renew` to check the expiration date of the certificate.

```
$ sudo certbot renew
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/tttest-tak.duckdns.org.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Certificate not yet due for renewal

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
The following certificates are not due for renewal yet:
  /etc/letsencrypt/live/tttest-tak.duckdns.org/fullchain.pem expires on 2026-05-17 (skipped)
No renewals were attempted.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

### 2.3. Configure `certbot` to Run Periodically to Renew the Certificate
Run the command
```
$ echo "0 0,12 * * * root /opt/certbot/bin/python -c 'import random; import time; time.sleep(random.random() * 3600)' && sudo certbot renew -q" | sudo tee -a /etc/crontab > /dev/null
```
This adds an entry to run `certbot` in `/etc/crontab`
```
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
# You can also override PATH, but by default, newer versions inherit it from the environment
#PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || { cd / && run-parts --report /etc/cron.daily; }
47 6    * * 7   root    test -x /usr/sbin/anacron || { cd / && run-parts --report /etc/cron.weekly; }
52 6    1 * *   root    test -x /usr/sbin/anacron || { cd / && run-parts --report /etc/cron.monthly; }
#
0 0,12 * * * root /opt/certbot/bin/python -c 'import random; import time; time.sleep(random.random() * 3600)' && sudo certbot renew -q
```


## 3. Dynamic DNS from Duck DNS (Optional)
1. Docker and Docker Compose to run dynamic DNS client (DuckDNS)
```
Follow the below page for Docker installation
[Docker Installation] - https://docs.docker.com/engine/install/ubuntu/
```
2. Duck DNS compose file
```
Follow the instructions in the below page to create a container for dynamic DNS client
[DuckDNS Image] - https://hub.docker.com/r/linuxserver/duckdns
```

## References
- Installing OTS - https://www.youtube.com/watch?v=_7MWZwzWEeo

## Further Reads
- OTS Docker (not ready yet) - https://github.com/brian7704/OpenTAKServer-Docker
- CloudTAK - https://github.com/dfpc-coe/CloudTAK