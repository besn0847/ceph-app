FROM ubuntu:14.04
MAINTAINER franck@besnard.mobi 

RUN apt-get update \
        && apt-get install -y --force-yes --no-install-recommends \
                supervisor bind9 dnsutils \
        && apt-get autoclean \
        && apt-get autoremove \
        && rm -rf /var/lib/apt/lists/*


ADD int.docker.net /var/lib/bind/
ADD int.docker.net.keys /etc/bind/
ADD named.conf /etc/bind/
ADD bind.conf /etc/supervisor/conf.d/
ADD update-dns.sh /root/
ADD root /var/spool/cron/crontabs/
ADD bootstrap.sh /

RUN chgrp -R bind /var/lib/bind /etc/bind \
		&& chmod -R g+w /var/lib/bind /etc/bind \
		&& chmod +x /root/update-dns.sh \
		&& chmod 600 /var/spool/cron/crontabs/root \
		&& chmod +x /bootstrap.sh
		
WORKDIR /root
ENTRYPOINT ["/bootstrap.sh"]
