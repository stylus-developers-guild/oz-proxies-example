
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
		-o oz-proxies2.wasm
	@wasm2wat oz-proxies2.wasm >oz-proxies.wat
	@wat2wasm oz-proxies.wat >oz-proxies.wasm
	@rm -f oz-proxies2.wasm oz-proxies.wat
