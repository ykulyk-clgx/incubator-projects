FROM debian:stable

RUN mkdir /usr/webs
COPY fortune/ /usr/webs/
WORKDIR /usr/webs

EXPOSE 80

RUN apt update
RUN apt install fortune-mod python3 python3-pip -y
RUN pip3 install flask

ENTRYPOINT python3 server.py

#RUN python3 server.py >/dev/null 2>&1 &
#ENTRYPOINT tail -f /dev/null
