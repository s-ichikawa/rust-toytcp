# 環境構築

```shell
$ docker run -it --privileged -v $PWD/toytcp:/user/rust-tcp/src/toytcp rust-tcp:1.0 /bin/bash

root@8e840c8a655d:/user/rust-tcp/src# ./setup.sh
+ ip netns add host1
...
	tx-tcp-ecn-segmentation: off [requested on]
	tx-tcp-mangleid-segmentation: off [requested on]
	tx-tcp6-segmentation: off [requested on]
	

root@8e840c8a655d:/user/rust-tcp/src# cd toytcp/
root@8e840c8a655d:/user/rust-tcp/src/toytcp# cargo build --examples
    Updating crates.io index
  Downloaded anyhow v1.0.52

... #色々 warning でるけど気にしなくてOK

  |
  = note: `#[warn(unused_imports)]` on by default

warning: `toytcp` (example "echoclient") generated 1 warning
    Finished dev [unoptimized + debuginfo] target(s) in 29.94s
```

# 実行方法

```shell
# セッション1: ToyTCPを受け入れるServer
root@8e840c8a655d:/user/rust-tcp/src/toytcp# ip netns exec host2 nc -l 10.0.1.1 40000

# セッション2: パケットキャプチャ用
$ docker ps
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS         PORTS     NAMES
8e840c8a655d   rust-tcp:1.0   "/bin/bash"   6 minutes ago   Up 6 minutes             elegant_jang

$ docker exec -it 8e840c8a655d ip netns exec host1 tcpdump -l
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on host1-veth1, link-type EN10MB (Ethernet), capture size 262144 bytes

# セッション3: パケット送信
$ docker exec -it 8e840c8a655d ip netns exec host1 /user/rust-tcp/src/toytcp/target/debug/examples/echoclient 10.0.1.1 40000

```
