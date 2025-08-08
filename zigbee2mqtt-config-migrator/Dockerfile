# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
ARG BUILD_FROM
FROM $BUILD_FROM AS base

ENV LANG=C.UTF-8

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]