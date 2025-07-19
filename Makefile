PLENARY_INIT=tests/init.lua
TESTS_DIR=tests

.PHONY: test clean

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${PLENARY_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${PLENARY_INIT}' }"

clean:
	@rm -rf /tmp/plenary.nvim
