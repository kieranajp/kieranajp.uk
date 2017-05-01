FROM python:2.7-alpine
MAINTAINER me@kieranajp.co.uk

RUN pip install pygments pygments-style-solarized

ADD https://github.com/spf13/hugo/releases/download/v0.20.6/hugo_0.20.6_Linux-64bit.tar.gz /tmp/hugo.tar.gz
RUN tar xzf /tmp/hugo.tar.gz -C /usr/local/bin \
    && chmod +x /usr/local/bin/hugo \
    && rm /tmp/hugo.tar.gz

RUN mkdir /hugo
WORKDIR /hugo
ADD . /hugo

EXPOSE 1313
CMD hugo --theme=kieranajp
