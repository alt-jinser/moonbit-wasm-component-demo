MOON = moon
WAC = wac
WASM-TOOLS = wasm-tools
WIT-BINDGEN = wit-bindgen
CARGO = cargo

.PHONY: all clean test

all: goal

.PHONY: goal
goal: prebuild build/final.wasm

prebuild:
	mkdir build -p

build/adder.wasm: adder/
	cd adder/ && \
	$(MOON) build --target wasm --release && \
	$(WASM-TOOLS) component embed ../wit/adder/ target/wasm/release/build/gen/gen.wasm -o target/wasm/release/build/gen/gen.wasm --world adder --encoding utf16 && \
	$(WASM-TOOLS) component new target/wasm/release/build/gen/gen.wasm -o ../build/adder.wasm && \
	cd -

build/calculator.wasm: calculator/
	mkdir wit/calculator/deps -p && \
	cp wit/adder wit/calculator/deps -r && \
	cd calculator/ && \
	$(MOON) build --target wasm --release && \
	$(WASM-TOOLS) component embed ../wit/calculator target/wasm/release/build/gen/gen.wasm -o target/wasm/release/build/gen/gen.wasm --world calculator --encoding utf16 && \
	$(WASM-TOOLS) component new target/wasm/release/build/gen/gen.wasm -o ../build/calculator.wasm && \
	cd - && rm wit/calculator/deps -r

build/command.wasm: command/
	cd command && \
	$(CARGO) component build --release && \
	cp target/wasm32-wasip1/release/command.wasm ../build/command.wasm && \
	cd -

build/composed.wasm: build/adder.wasm build/calculator.wasm
	$(WAC) plug build/calculator.wasm --plug build/adder.wasm -o build/composed.wasm

build/final.wasm: build/command.wasm build/composed.wasm
	$(WAC) plug build/command.wasm --plug build/composed.wasm -o build/final.wasm

adder/gen:
	$(WIT-BINDGEN) moonbit wit/adder --world adder --derive-show --derive-eq --out-dir adder && \
	$(MOON) fmt -C adder

calculator/gen:
	mkdir wit/calculator/deps -p && \
	cp wit/adder wit/calculator/deps -r && \
	$(WIT-BINDGEN) moonbit wit/calculator --world calculator --derive-show --derive-eq --out-dir calculator && \
	$(MOON) fmt -C calculator && \
	rm wit/calculator/deps -r

clean:
	rm build/ -rf
