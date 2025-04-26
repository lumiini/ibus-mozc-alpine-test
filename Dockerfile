FROM alpine/20250108

# Add the testing repository to the list of repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update

# Install necessary build dependencies (including JDK for Bazel)
RUN apk add --update alpine-sdk git bash unzip curl openjdk11 bazel8

# Install Bazelisk (recommended way to use Bazel)
RUN curl -Lo /usr/local/bin/bazelisk https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64 && \
    chmod +x /usr/local/bin/bazelisk

# Clone the Mozc repository
RUN git clone https://github.com/google/mozc.git /mozc

# Change to the Mozc source directory
WORKDIR /mozc

# Attempt to build the IBus module using Bazelisk
RUN bazelisk build -c opt //src/ibus:mozc

# Create an output directory
RUN mkdir /output

# Copy the built IBus module (adjust path if necessary)
RUN cp /mozc/bazel-bin/src/ibus/mozc.so /output/ibus-mozc

# Copy necessary data files (adjust path if necessary)
RUN cp -r /mozc/src/data /output/mozc-data

# Minimal final image
FROM scratch
COPY --from=0 /output /usr/local
