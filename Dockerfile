FROM python:latest AS script
ENV SOLVER=https://gist.githubusercontent.com/chamlis/4d7441967787dc862f635a53958cabd6/raw/6062345673fd963d22f1eb0c1a82a5f8d09986f7/solve.py

RUN wget $SOLVER \
 && pwd \
 && ls -lah

FROM python:latest AS dl
ENV APPINDEX=https://dl-cdn.alpinelinux.org/alpine/edge/main/x86_64/APKINDEX.tar.gz
RUN pip install pulp
RUN wget $APPINDEX \
 && tar -xvzf 'APKINDEX.tar.gz' \
 && pwd \
 && ls -lah

FROM python:latest AS grabby
RUN pip install pulp
COPY --from=dl APKINDEX /APKINDEX
COPY --from=script solve.py /solve.py
RUN  pwd \
 && ls -lah \
 && python /solve.py /APKINDEX \
 && pwd \
 && ls -lah

FROM alpine:latest
COPY --from=grabby out packages.txt
RUN while read package; do apk add "$package"; done < packages.txt
