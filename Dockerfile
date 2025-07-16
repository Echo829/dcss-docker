FROM ubuntu:latest

#Set labels.
LABEL maintainer="Anthony Lubrani"
LABEL maintainer.email="twilightwars2005@gmail.com"

#Set environment values and variables.
ARG version

#Update system and install prerequisite packages.
RUN apt -y update
RUN apt-get -y upgrade
RUN apt-get -y install make build-essential libsdl2-image-dev libsdl2-mixer-dev libsdl2-dev libfreetype6-dev libpng-dev fonts-dejavu-core advancecomp pngcrush git python3 python3-tornado yamllint

#Pull latest build from github.
RUN git clone https://github.com/crawl/crawl.git
RUN cd /crawl/ ; git submodule update --init ; git checkout tags/$version

#Compile the webserver with webtiles and dgamelaunch support.
RUN cd /crawl/crawl-ref/source/ ; make WEBTILES=y USE_DGAMELAUNCH=y
RUN mkdir /crawl/crawl-ref/source/rcs

#Create user and set the config to use it.
RUN groupadd -g 1001 crawl && useradd -m -u 1001 -g crawl crawl
RUN chown -R 1001:1001 /crawl/ ; sed -i -re 's/([g,u]id =)[^=]*$/\1 1001/' /crawl/crawl-ref/source/webserver/config.py

#Replace name values on the launcher with the currently built version.
RUN sed -i -re "s/ (trun)+\w+/ $version/g" /crawl/crawl-ref/source/webserver/config.py

#Expose port 8080.
EXPOSE 8080
EXPOSE 8081

#Create user db.
RUN touch /crawl/crawl-ref/source/webserver/passwd.db3 ; chown 1001:1001 /crawl/crawl-ref/source/webserver/passwd.db3 ; chmod 755 /crawl/crawl-ref/source/webserver/passwd.db3

#Run the server.
USER 1001:1001
WORKDIR /crawl/crawl-ref/source
CMD ["/usr/bin/python3", "webserver/server.py"]