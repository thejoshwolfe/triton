
# the default target
.PHONY: all
all:

BINARY_NAME = triton-display
LIBS = glut

# the root of all the source code
SRC = src
# the root of all the output
OUT_ROOT = out

# Give this function a target, and it will make sure its directory exists before its rule is run.
define lazy-create-dir
 $1: | $$(dir $1)
 LAZY_DIRS += $$(dir $1)
endef

# Returns the md5sum of the argument. Note the return value has some whitespace around it.
define hash
 $(shell echo -n $1 | md5sum | cut -d' ' -f1)
endef

# Give this function a string and a variable name, then depend on the variable's value.
# This will cause the dependency to be out of date whenever the string changes.
# parameters:
#  $1: the variable to store the path to the dummy timestamp file. depend on this variables' value.
#  $2: the dummy timestamp file's prefix, typically in an out-of-the-way output directory.
#  $3: the string to hash.
define hash-timestamp
 $1 := $2.$$(strip $$(call hash,$3)).timestamp
 $$(eval $$(call lazy-create-dir,$$($1)))
 $$($1):
	rm -f $2.*.timestamp && touch $$@
endef

# sets up a rule for compiling a C++ file.
# parameters:
#  $1: the output file. should probably end with .o.
#  $2: the source file. should probably end with .cpp.
#  $3: any include directories that should become -I parameters to g++.
define object
 $$(eval $$(call lazy-create-dir,$1))
 # depend on the command string, so that changing parameters causes a rebuild.
 $1.COMMAND = g++ -o $1 -c -g $$(addprefix -I ,$3) $2 -MMD -MP -MF $1.d
 $$(eval $$(call hash-timestamp,$1.COMMAND.HASH,$1.command,$$($1.COMMAND)))
 $1: $2 $$($1.COMMAND.HASH)
	$$($1.COMMAND)
 # depend on proper .h files
 -include $1.d
endef

# give the paths to any stray object files to this function, and they will be cleaned up as part of the 'all' target.
define stray-object
 .PHONY: $1.cleanup
 $1.cleanup:
	rm -f $1 $1.d $1.command.*.timestamp
 all: $1.cleanup
endef

# sets up rules to create the executable

OBJ_DIR = $(OUT_ROOT)/obj

# scan source directory for source files
SOURCES := $(wildcard $(SRC)/*.cpp)
# make rules for all the objects
OBJECTS = $(sort $(foreach i,$(SOURCES),$(OBJ_DIR)/$i.o))
$(foreach i,$(SOURCES),$(eval $(call object,$(OBJ_DIR)/$i.o,$i,$(SRC))))
# detect and delete any stray objects
STRAY_OBJECTS := $(filter-out $(OBJECTS),$(shell find $(OBJ_DIR) -name \*.o 2>/dev/null))
$(foreach i,$(STRAY_OBJECTS),$(eval $(call stray-object,$i)))

# make rules for this executable
BINARY = $(OUT_ROOT)/$(BINARY_NAME)
# depend on the command string so that changing link parameters causes a rebuild.
BINARY.COMMAND = g++ -o $@ $(OBJECTS) $(foreach i,$(LIBS),-l $i)
$(eval $(call hash-timestamp,BINARY.COMMAND.HASH,$(OBJ_DIR)/@.command,$(BINARY.COMMAND)))
$(BINARY): $(OBJECTS) $(BINARY.COMMAND.HASH)
	$(BINARY.COMMAND)
all: $(BINARY)

# now that the above has had a chance to add to the lazy directory list, make the rule that actually creates them.
UNIQUE_LAZY_DIRS = $(sort $(LAZY_DIRS))
$(UNIQUE_LAZY_DIRS):
	mkdir -p $@

clean:
	rm -rf $(OUT_ROOT)
