
oz-proxies.wasm: $(shell find src -name '*.rs')
	@rm -f oz-proxies.wasm
	@cargo build --target wasm32-unknown-unknown --release
	@cp target/wasm32-unknown-unknown/release/oz_proxies.wasm oz-proxies.wasm
