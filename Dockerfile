FROM jekyll/builder:latest
# This image is cached on the Github Actions VM, so it drastically reduces build time

USER root
# Github actions must be run as root: https://docs.github.com/en/actions/creating-actions/dockerfile-support-for-github-actions#user

RUN apk --no-cache add curl jq

COPY ./jekyll_diff.sh /

CMD /jekyll_diff.sh
