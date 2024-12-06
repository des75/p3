.PHONY: all init upgrade compile clean test xref shell dialyzer tags doc

PROJECT ?= $(notdir $(CURDIR))
PROJECT := $(strip $(PROJECT))

REBAR = rebar3

SUITE ?= all

ifeq (${SUITE},all)
	CT_SUITE =
else
	CT_SUITE = --suite ${SUITE}_SUITE
endif

all: xref test dialyzer

compile:
	@${REBAR} compile

clean:
	@${REBAR} clean --all
	@rm -f rebar.lock

test:
	@${REBAR} ct --cover --sys_config=config/sys.config ${CT_SUITE}

xref:
	@${REBAR} xref

run:
	@${REBAR} shell

dialyzer:
	@${REBAR} dialyzer

edoc:
	ERL_FLAGS="-config config/sys.config" $(REBAR) edoc

# Release.

RELEASE_NAME = p3

release:
	@${REBAR} release -n $(RELEASE_NAME)

console: release
	_build/default/rel/${RELEASE_NAME}/bin/${RELEASE_NAME} console

start: release
	_build/default/rel/${RELEASE_NAME}/bin/${RELEASE_NAME} start

stop:
	_build/default/rel/${RELEASE_NAME}/bin/${RELEASE_NAME} stop
