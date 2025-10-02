
oz-proxies.wasm: $(shell find src -name '*.rs')
	@rm -f oz-proxies.wasm
	@cargo build --target wasm32-unknown-unknown --release
	@wasm-opt \
		--dce \
		--rse \
		--signature-pruning \
		--enable-bulk-memory \
		--strip-debug \
		--strip-producers \
		-Oz target/wasm32-unknown-unknown/release/oz_proxies.wasm \
		-o oz-proxies.wasm
