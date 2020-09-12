# ================================
# Build image
# ================================
FROM vapor/swift:5.2 as build
WORKDIR /build
COPY . .
RUN swift package clean
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y libssl-dev zlib1g-dev
RUN swift build --enable-test-discovery -c release -Xswiftc -g

# ================================
# Run image
# ================================
FROM vapor/ubuntu:18.04
WORKDIR /run

# Copy build artifacts
COPY --from=build /build/.build/release /run
# Copy Swift runtime libraries
COPY --from=build /usr/lib/swift/ /usr/lib/swift/
# Uncomment the next line if you need to load resources from the `Public` directory
#COPY --from=build /build/Public /run/Public
EXPOSE 8801
ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0"]
