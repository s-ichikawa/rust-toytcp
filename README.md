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

## File Server/Client

```shell
# client
# ip netns exec host1 ./target/debug/examples/fileclient 10.0.1.1 40000 sea.jpg

# server
# ip netns exec host2 ./target/debug/examples/fileserver 10.0.1.1 40000 saved.jpg

```

# Memo

## 3.5.9 動作確認のncコマンドのオプションが違う

```shell
# 本に書かれてるコマンド
$ sudo ip netns exec host2 nc -l 10.0.1.1.40000

# こうすると動いた
$ ip netns exec host2 nc -l -p 40000
```

## File Serverは不安定

こんな感じのエラーが出てしばしば落ちるけど、何度か試すと時々成功する。謎。。
```shell
# ip netns exec host2 ./target/debug/examples/fileserver 10.0.1.1 40000 saved.jpg
...
thread '<unnamed>' panicked at 'attempt to subtract with overflow', src/tcp.rs:520:58
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: PoisonError { .. }', src/tcp.rs:191:42
```
時々成功する