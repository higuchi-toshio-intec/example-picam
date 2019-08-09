#
FROM raspbian/stretch

#
COPY ./build.sh /tmp
RUN /tmp/build.sh

#
COPY ./ros_entrypoint.sh /
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

