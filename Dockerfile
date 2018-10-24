FROM centos:latest

#Set labels.
LABEL maintainer="Anthony Lubrani"
LABEL maintainer.email="twilightwars2005@gmail.com"

#Set environment values and variables.
ARG version
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

#Update system and install prerequisite packages.
RUN yum -y update
RUN yum -y install git gcc gcc-c++ make bison flex ncurses-devel compat-lua-devel sqlite-devel zlib-devel pkgconfig SDL-devel SDL_image-devel libpng-devel freetype-devel dejavu-sans-fonts dejavu-sans-mono-fonts python-tornado

#Pull latest build from github.
RUN git clone https://github.com/crawl/crawl.git
RUN cd /crawl/ ; git submodule update --init ; git checkout tags/$version

#Compile the webserver with webtiles and dgamelaunch support.
RUN cd /crawl/crawl-ref/source/ ; make WEBTILES=y USE_DGAMELAUNCH=y
RUN mkdir /crawl/crawl-ref/source/rcs

#Create user and set the config to use it.
RUN useradd crawl ; chown -R crawl:crawl /crawl/ ; sed -i -re 's/([g,u]id =)[^=]*$/\1 1000/' /crawl/crawl-ref/source/webserver/config.py

#Replace name values on the launcher with the currently built version.
RUN sed -i -re "s/ (trun)+\w+/ $version/g" /crawl/crawl-ref/source/webserver/config.py

#Expose port 8080.
EXPOSE 8080
EXPOSE 8081

#Run the server.
WORKDIR /crawl/crawl-ref/source
CMD ["/usr/bin/python", "webserver/server.py"]
