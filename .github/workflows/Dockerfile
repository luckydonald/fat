FROM python:latest AS script
ENV SOLVER https://gist.githubusercontent.com/chamlis/4d7441967787dc862f635a53958cabd6/raw/6062345673fd963d22f1eb0c1a82a5f8d09986f7/solve.py

RUN pip install pulp requests \
 && python -c "import requests; r = requests.get('$SOLVER') ; open('solver.py' , 'wb').write(r.content)" \
 && pwd \
 && ls -lah

FROM python:latest AS dl
ENV APPINDEX https://dl-cdn.alpinelinux.org/alpine/edge/main/x86_64/APKINDEX.tar.gz
RUN python -c "import requests; r = requests.get('$APPINDEX') ; open('APKINDEX.tar.gz' , 'wb').write(r.content)" \
 && tar -xvzf 'APKINDEX.tar.gz' \
 && pwd \
 && ls -lah

FROM python:latest as grabby
COPY --from=dl APKINDEX APKINDEX
COPY --from=script APKINDEX APKINDEX
RUN python ./solver.py ./APKINDEX

FROM alpine:latest
COPY --from=grabby out packages.txt
RUN while read package; do apk add "$package"; done < packages.txt

