.PHONY: test

test:
	rm -f luacov.* && luacheck . && busted && luacov-console && luacov-console -s
