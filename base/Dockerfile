FROM ubuntu:14.04
MAINTAINER franck@besnard.mobi 

RUN apt-get update \
        && apt-get install -y --force-yes --no-install-recommends \
                supervisor openssh-server dnsutils wget \
		  && wget -q --no-check-certificate -O- 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | sudo apt-key add - \
		  && echo deb http://ceph.com/debian-firefly/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list \
		  && apt-get update \
        && apt-get install -y --force-yes --no-install-recommends ca-certificates \
        && apt-get autoclean \
        && apt-get autoremove \
        && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/bind/

ADD int.docker.net.keys /etc/bind/
ADD sshd.conf /etc/supervisor/conf.d/
ADD update-dns.sh /root/
ADD root /var/spool/cron/crontabs/
ADD bootstrap.sh / 
ADD supervisord.conf /etc/supervisor/

RUN mkdir -p /var/run/sshd \
	&& sed -i -e 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config \
	&& sed -i -e 's/^session    required     pam_loginuid.so$/session    optional     pam_loginuid.so/g' /etc/pam.d/sshd \
	&& echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
	&& echo 'root:passw0rd' | chpasswd \
	&& useradd -d /home/ceph -m ceph \
	&& echo 'ceph:passw0rd' | chpasswd \
	&& echo "ceph ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ceph \
	&& mkdir -p /home/ceph/.ssh/ \
	&& mkdir -p /root/.ssh \
	&& chmod 0440 /etc/sudoers.d/ceph \
	&& chmod -R g+w /etc/bind \
	&& chmod +x /root/update-dns.sh \
	&& chmod 600 /var/spool/cron/crontabs/root \
	&& chmod +x /bootstrap.sh

ADD authorized_keys /home/ceph/.ssh/authorized_keys
ADD id_rsa /root/.ssh/id_rsa
ADD id_rsa.pub /root/.ssh/id_rsa.pub
ADD config /root/.ssh/config
ADD id_rsa /home/ceph/.ssh/id_rsa
ADD id_rsa.pub /home/ceph/.ssh/id_rsa.pub
ADD config /home/ceph/.ssh/config
ADD authorized_keys /home/ceph/.ssh/authorized_keys

RUN chown -R ceph.ceph /home/ceph/ \
	&& chmod 400 /root/.ssh/id_rsa /home/ceph/.ssh/id_rsa
	
EXPOSE 22

WORKDIR /root
ENTRYPOINT ["/bootstrap.sh"]
