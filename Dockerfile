FROM alpine:latest

EXPOSE 53589

ENV TASKDDATA=/var/lib/taskd

RUN apk update
RUN apk add git curl make cmake gcc g++ gnutls-dev util-linux-dev python3 gnutls-utils

RUN ln -sn /usr/bin/python3 /usr/bin/python

WORKDIR /tmp
RUN git clone --recursive https://github.com/GothenburgBitFactory/taskserver.git
WORKDIR /tmp/taskserver

RUN cmake -DCMAKE_BUILD_TYPE=release .
RUN make
RUN make test
RUN make install

RUN mv ./pki /usr/local/share/doc/taskd/

WORKDIR /
RUN rm -rf /tmp/taskserver

RUN apk del make cmake gcc g++ git

COPY ./taskd-* /usr/local/bin

RUN chmod +x /usr/local/bin/taskd-*

CMD ["taskd", "server"]
