FROM ceph-app/base
MAINTAINER franck@besnard.mobi 

RUN apt-get update \
        && apt-get install -y --force-yes --no-install-recommends \
                ceph-deploy ceph-common \
		&& apt-get autoclean \
        && apt-get autoremove \
        && rm -rf /var/lib/apt/lists/*

ADD ceph.conf /home/ceph/ceph.conf
ADD bootstrap.sh /home/ceph/bootstrap.sh
ADD init-mon.sh /home/ceph/init-mon.sh
ADD init-osd.sh /home/ceph/init-osd.sh
ADD init-mds.sh /home/ceph/init-mds.sh
ADD ceph-deploy.conf /etc/supervisor/conf.d/ceph-deploy.conf

RUN chown -R ceph.ceph /home/ceph/ \ 
	&& chmod +x /home/ceph/*.sh
