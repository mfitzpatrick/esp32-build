FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    apt-utils \
    bison \
    ca-certificates \
    ccache \
    check \
    cmake \
    curl \
    flex \
    git \
    gperf \
    lcov \
    libncurses-dev \
    libusb-1.0-0-dev \
    libffi-dev \
    libssl-dev \
    make \
    ninja-build \
    python3 \
    python3-pip \
    python3-setuptools \
    unzip \
    wget \
    xz-utils \
    zip \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /opt/rustup.sh

# Virtualenv <20.x is required for ESP-IDFv4.0. Should be fixed in next release.
# Rustc is required by python's cryptography package.
RUN python -m pip install --upgrade pip virtualenv==16.7.9 \
    && sh /opt/rustup.sh -y
ENV PATH="/root/.cargo/bin:${PATH}"

# To build the image for a branch or a tag of IDF, pass --build-arg IDF_CLONE_BRANCH_OR_TAG=name.
# To build the image with a specific commit ID of IDF, pass --build-arg IDF_CHECKOUT_REF=commit-id.
# It is possibe to combine both, e.g.:
#   IDF_CLONE_BRANCH_OR_TAG=release/vX.Y
#   IDF_CHECKOUT_REF=<some commit on release/vX.Y branch>.

ARG IDF_CLONE_URL=https://github.com/espressif/esp-idf.git
ARG IDF_CLONE_BRANCH_OR_TAG=v4.2
ARG IDF_CHECKOUT_REF=

ENV IDF_PATH=/opt/esp/idf

RUN echo IDF_CHECKOUT_REF=$IDF_CHECKOUT_REF IDF_CLONE_BRANCH_OR_TAG=$IDF_CLONE_BRANCH_OR_TAG && \
    git clone --recursive \
      ${IDF_CLONE_BRANCH_OR_TAG:+-b $IDF_CLONE_BRANCH_OR_TAG} \
      $IDF_CLONE_URL $IDF_PATH && \
    if [ -n "$IDF_CHECKOUT_REF" ]; then \
      cd $IDF_PATH && \
      git checkout $IDF_CHECKOUT_REF && \
      git submodule update --init --recursive; \
    fi

RUN cd ${IDF_PATH} && ./install.sh

# Create an entrypoint that sources the export.sh script first, then runs the CMD parameters
RUN echo '#!/bin/bash\n. ${IDF_PATH}/export.sh\nexec "$@"' >/entrypoint.sh \
    && chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]

