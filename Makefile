.PHONY: all build clean store find-floating-points

all: build

build:
	RUSTFLAGS='-C link-arg=-s' cargo build --release --target wasm32-unknown-unknown --locked
	wasm-opt -Os ./target/wasm32-unknown-unknown/release/*.wasm -o ./contract.wasm
	cat ./contract.wasm | gzip -9 > ./contract.wasm.gz 

find-floating-points:
	cargo build --release --target wasm32-unknown-unknown --locked
	twiggy paths ./target/wasm32-unknown-unknown/release/*.wasm > find_floats_twiggy.txt
	wasm2wat ./target/wasm32-unknown-unknown/release/*.wasm | grep -B 20 -P 'f(64|32)' > find_floats_grep.txt

clean:
	cargo clean
	-rm -f ./contract.wasm ./contract.wasm.gz

store: build
	secretcli tx compute store contract.wasm.gz --from 1 -y --gas 10000000 --source "https://github.com/enigmampc/RandomOracle/blob/$(shell git show --oneline -s | cut -f 1 -d ' ')/contract/src/contract.rs" -b block

