FROM ubuntu:18.04

RUN apt-get update && apt-get install -y curl
RUN apt-get install build-essential iproute2 iputils-ping net-tools iptables ethtool netcat tcpdump vim -y

RUN mkdir -p /user/rust-tcp/src
WORKDIR /user/rust-tcp/src

COPY setup.sh .

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"

#WORKDIR /user/rust-tcp/src/toytcp
#RUN cargo build --examples