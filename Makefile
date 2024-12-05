# ==================================================
# KOBIL ecosystem
# ==================================================

.PHONY: all init upgrade compile clean test xref shell dialyzer tags elvis doc

PROJECT ?= $(notdir $(CURDIR))
PROJECT := $(strip $(PROJECT))

REBAR = ${PWD}/scripts/rebar3

SUITE ?= all

ifeq (${SUITE},all)
	CT_SUITE =
else
	CT_SUITE = --suite ${SUITE}_SUITE
endif

ifneq ($(and $(BRANCH),$(BUILD_NUMBER)),)
	NODE_NAME_OVERRIDE = --name="$(subst /,_,${BRANCH})@TC-${BUILD_NUMBER}"
else
	NODE_NAME_OVERRIDE =
endif

all: xref test dialyzer

init: $(REBAR) update_index

compile: init
	@${REBAR} compile

clean: init
	@${REBAR} clean --all
	@rm -f rebar.cover.spec
	@rm -f rebar.lock

test: init rebar.cover.spec elvis
	./adapt_sys_config.sh
	@${REBAR} ct --sys_config=config/test.config ${NODE_NAME_OVERRIDE} ${CT_SUITE} $(CT_OPTS)

xref: init
	@${REBAR} xref

elvis:
	@${REBAR} as test elvis

shell: init rebar.cover.spec
	@${REBAR} shell

dialyzer: init
	@${REBAR} dialyzer

edoc: init
	ERL_FLAGS="-config config/sys.config" $(REBAR) edoc

tags:
	@ctags --excmd=number --tag-relative=no --fields=+i+a+m+n+S --languages=erlang --exclude=_build -R 2> /dev/null

scripts:
	mkdir $@

update_index:
	@${REBAR} update

$(REBAR): | scripts
	curl -L -o $@ https://s3.amazonaws.com/rebar3/rebar3
	chmod +x $@

rebar.cover.spec: $(ERL_SOURCES)
	@echo '{incl_dirs, [' >>$@
	echo '"_build/test/lib/$(PROJECT)/ebin"' >>$@
	@echo ']}.' >>$@

doc: error_codes_doc

error_codes_doc:
	@ERL_FLAGS="-config config/sys.config" rebar3 as error_code_docs edoc

# Release.

RELEASE_NAME = presence

release:
	@${REBAR} release -n $(RELEASE_NAME)

console: release
	_build/default/rel/${RELEASE_NAME}/bin/${RELEASE_NAME} console

start: release
	_build/default/rel/${RELEASE_NAME}/bin/${RELEASE_NAME} start

stop:
	_build/default/rel/${RELEASE_NAME}/bin/${RELEASE_NAME} stop
