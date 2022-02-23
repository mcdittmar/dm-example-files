WORK_ROOT   = ./temp
TARGET_ROOT = ./install

TARGET_BIN  = $(TARGET_ROOT)/bin
TARGET_TEST = $(TARGET_ROOT)/test
TARGET_TESTBIN  = $(TARGET_TEST)/bin
TARGET_TESTDATA = $(TARGET_TEST)/data
TARGET_TESTBASE = $(TARGET_TEST)/base
TARGET_TESTRES  = $(TARGET_TEST)/res

TESTIN  = $(TARGET_TESTDATA)
TESTOUT = $(WORK_ROOT)/test/out
TESTSAV = $(TARGET_TESTBASE)
TESTRES = $(TARGET_TESTRES)

NEWPATH	 = "$(TARGET_BIN):$(TARGET_TESTBIN):${PATH}"

build:
	@mkdir -p $(TARGET_BIN) $(TARGET_TESTBIN)
	@mkdir -p $(TARGET_TESTDATA)
	@mkdir -p $(TARGET_TESTRES)
	@mkdir -p $(TARGET_TESTBASE)

	@echo "Build utility - voefg"
	cp ./tools/voefg/src/voefg.py $(TARGET_BIN)/voefg
	chmod u+x $(TARGET_BIN)/voefg

	@echo "Build test utility - voefg"
	cp ./tools/voefg/tests/test_voefg.sh $(TARGET_TESTBIN)/test_voefg
	chmod u+x $(TARGET_TESTBIN)/test_voefg

	cp ./tools/voefg/tests/data/* $(TARGET_TESTDATA)/.
	cp ./tools/voefg/tests/res/*  $(TARGET_TESTRES)/.
	cp ./tools/voefg/tests/base/*  $(TARGET_TESTBASE)/.

	@echo "Build pyvodm example file generation script"
	cp ./tools/generate_pyvodm_examples.pl $(TARGET_BIN)/.
	chmod u+x $(TARGET_BIN)/generate_pyvodm_examples.pl

clean:
	@echo "Remove working spaces"
	rm -rf $(TARGET_ROOT)
	rm -rf $(WORK_ROOT)

install:
	@echo "Nothing to install"

uninstall:
	@echo "Nothing to uninstall"

test:
	@echo "Run voefg utility tests" 
	@export PATH=$(NEWPATH) TESTIN=$(TESTIN) TESTOUT=$(TESTOUT) TESTSAV=$(TESTSAV) TESTRES=$(TESTRES) ; test_voefg 

examples:
	@echo "Generate example files"
	@rm -f ${WORK_ROOT}/*
	@export PATH=$(NEWPATH); generate_pyvodm_examples.pl


all: build test install
