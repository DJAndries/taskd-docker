# Builder Image
FROM alpine:latest as builder

RUN apk update && \
    apk add git \ 
    curl \
    make \
    cmake \
    gcc \
    g++ \
    gnutls-dev \
    util-linux-dev \
    python3 \
    gnutls-utils

WORKDIR /tmp
RUN git clone --recursive https://github.com/GothenburgBitFactory/taskserver.git
WORKDIR /tmp/taskserver

RUN cmake -DCMAKE_BUILD_TYPE=release .
RUN make
RUN make test
RUN make install

# Final image
FROM alpine:latest

EXPOSE 53589
ENV TASKDDATA=/home/taskd/data

# These are runtime dependencies for taskd
RUN apk update && \
    apk add gnutls-dev \
    util-linux-dev \
    gnutls-utils && \
    adduser taskd --disabled-password --uid 65532

COPY --from=builder /tmp/taskserver/pki /usr/local/share/doc/taskd/pki/
COPY --from=builder /usr/local/bin/taskd /usr/local/bin/
COPY --from=builder /usr/local/bin/taskdctl /usr/local/bin/
COPY taskd-add-user /usr/local/bin/
COPY taskd-generate-client-key /usr/local/bin/
COPY taskd-generate-server-key /usr/local/bin/
COPY taskd-init /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /usr/local/bin/taskd* && \
    chmod +x /entrypoint.sh && \
    mkdir -p /home/taskd/data && \
    chown taskd /home/taskd/data && \
    chown taskd /usr/local/share/doc/taskd/pki -R

WORKDIR /home/taskd

# Drop privileges and run as a low privileged user
USER taskd

CMD ["/entrypoint.sh"]
