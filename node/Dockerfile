FROM ceph-app/base
MAINTAINER franck@besnard.mobi 

RUN apt-get update \
        && apt-get install -y --force-yes --no-install-recommends \
                ceph ceph-mds \
		&& apt-get autoclean \
        && apt-get autoremove \
        && rm -rf /var/lib/apt/lists/*
		
