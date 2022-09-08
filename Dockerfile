FROM grafana/grafana:9.0.4-ubuntu
USER root
RUN [ -z "$(apt-get indextargets)" ]
RUN set -xe   && echo '#!/bin/sh' > /usr/sbin/policy-rc.d  && echo 'exit 101' >> /usr/sbin/policy-rc.d  && chmod +x /usr/sbin/policy-rc.d   && dpkg-divert --local --rename --add /sbin/initctl  && cp -a /usr/sbin/policy-rc.d /sbin/initctl  && sed -i 's/^exit.*/exit 0/' /sbin/initctl   && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup   && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean  && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean  && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean   && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages   && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes   && echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests
RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container
CMD ["/bin/bash"]
ARG GF_UID=472
ARG GF_GID=472
ARG DEBIAN_FRONTEND=noninteractive
ENV PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin GF_PATHS_CONFIG=/etc/grafana/grafana.ini GF_PATHS_DATA=/var/lib/grafana GF_PATHS_HOME=/usr/share/grafana GF_PATHS_LOGS=/var/log/grafana GF_PATHS_PLUGINS=/var/lib/grafana/plugins GF_PATHS_PROVISIONING=/etc/grafana/provisioning
WORKDIR /usr/share/grafana
RUN DEBIAN_FRONTEND=noninteractive GF_GID=472 GF_UID=472  apt-get update && apt-get -y upgrade &&     apt-get install -qq -y libfontconfig1 ca-certificates curl &&     apt-get autoremove -y &&     rm -rf /var/lib/apt/lists/*
# RUN DEBIAN_FRONTEND=noninteractive GF_GID=472 GF_UID=472  mkdir -p "$GF_PATHS_HOME/.aws" &&     groupadd -r -g $GF_GID grafana &&     useradd -r -u $GF_UID -g grafana grafana &&     mkdir -p "$GF_PATHS_PROVISIONING/datasources"              "$GF_PATHS_PROVISIONING/dashboards"              "$GF_PATHS_PROVISIONING/notifiers"              "$GF_PATHS_LOGS"              "$GF_PATHS_PLUGINS"              "$GF_PATHS_DATA" &&     cp "$GF_PATHS_HOME/conf/sample.ini" "$GF_PATHS_CONFIG" &&     cp "$GF_PATHS_HOME/conf/ldap.toml" /etc/grafana/ldap.toml &&     chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING" &&     chmod -R 777 "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING"
EXPOSE 3000
# USER grafana
ENTRYPOINT ["/run.sh"]
USER root

# ENV http_proxy=http://proxy-chain.intel.com:911
# ENV https_proxy=http://proxy-chain.intel.com:912
RUN apt-get autoclean && apt-get autoremove -y
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update --allow-releaseinfo-change
RUN grafana-cli plugins install ryantxu-ajax-panel
RUN apt-get update && apt-get -y install curl gettext-base vim
ENV GF_SECURITY_ADMIN_USER=admin
ENV GF_SECURITY_ADMIN_PASSWORD=admin
WORKDIR /app
COPY entrypoint.sh entrypoint.sh
RUN chmod 777 entrypoint.sh
USER uucp
ENTRYPOINT ["/app/entrypoint.sh"]
ENV http_proxy=
ENV https_proxy=
