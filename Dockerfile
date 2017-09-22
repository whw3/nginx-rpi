### BUILD ###
FROM whw3/buildpack-deps:rpi-s6 as nginx-builder

COPY nginx.list /etc/apt/sources.list.d/
RUN curl https://nginx.org/keys/nginx_signing.key | apt-key add -

WORKDIR /usr/src/
RUN cd /usr/src/ &&\
	apt-get update && apt-get upgrade &&\
	rm -rf /usr/src/nginx* &&\
	apt-get build-dep nginx  &&\
	apt-get source -b  nginx

### FINAL STAGE ###

FROM whw3/rpi-s6
WORKDIR /usr/src/
COPY --from=nginx-builder /usr/src/nginx_*deb /usr/src/
RUN cd /usr/src/ && dpkg -i nginx_*deb

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

STOPSIGNAL SIGTERM

ENTRYPOINT ["/init"]

CMD ["nginx", "-g", "daemon off;"]
