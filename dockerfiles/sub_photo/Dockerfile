#
FROM ros:melodic-ros-base
ARG PICAM_GIT_BRANCH=master

#
ENV DEBIAN_FRONTEND noninteractive
ENV PICAM_GIT_BRANCH ${PICAM_GIT_BRANCH}
COPY ./build.sh /tmp
RUN cd /tmp \
 && ./build.sh

#
COPY ./startup.sh /tmp

#
COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
