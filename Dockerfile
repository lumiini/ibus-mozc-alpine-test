FROM alpine:latest

# Install build dependencies
RUN apk add --update alpine-sdk git cmake ninja protobuf-dev protobuf openssl-dev pkgconfig boost-dev abseil-cpp-dev libxml2-dev libxkbcommon-dev libxkbcommon-x11 glib-dev icu-dev gtk+3.0-dev
# Clone the Mozc repository
RUN git clone https://github.com/google/mozc.git /mozc

# List the contents of /mozc
RUN ls -al /mozc

# Create a build directory
WORKDIR /mozc/build

# Configure the build
RUN cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DIM_MODULE=ibus /mozc

# Build Mozc
RUN ninja

# Create a directory to store the output
RUN mkdir /output

# Install Mozc into the output directory (using a custom prefix)
RUN ninja install DESTDIR=/output

# The final image will only contain the built artifacts
FROM scratch
COPY --from=0 /output /usr/local
