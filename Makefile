
oz-proxies.wasm: $(shell find src -name '*.rs')
	@cargo build --target wasm32-unknown-unknown --release
	@cp target/wasm32-unknown-unknown/release/oz_proxies.wasm oz-proxies.wasm
