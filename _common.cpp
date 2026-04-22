
#include <string>

int LLAMA_BUILD_NUMBER = 114514;
char const *LLAMA_COMMIT = LLAMA_COMMON_BUILD_COMMIT;
char const *LLAMA_COMPILER = "clang 20.1.5";
char const *LLAMA_BUILD_TARGET = "x86_64-w64-windows-gnu";
char const *LICENSES[] = {"LICENSES"};

int llama_build_number(void) {
    return LLAMA_BUILD_NUMBER;
}

const char * llama_commit(void) {
    return LLAMA_COMMIT;
}

const char * llama_compiler(void) {
    return LLAMA_COMPILER;
}

const char * llama_build_target(void) {
    return LLAMA_BUILD_TARGET;
}

const char * llama_build_info(void) {
    static std::string s = "b" + std::to_string(LLAMA_BUILD_NUMBER) + "-" + LLAMA_COMMIT;
    return s.c_str();
}

void llama_print_build_info(void) {
    fprintf(stderr, "%s: build = %d (%s)\n",      __func__, llama_build_number(), llama_commit());
    fprintf(stderr, "%s: built with %s for %s\n", __func__, llama_compiler(), llama_build_target());
}

#include "jinja/lexer.cpp"
#include "jinja/parser.cpp"
#include "jinja/runtime.cpp"
#include "jinja/string.cpp"
#include "jinja/value.cpp"
#include "jinja/caps.cpp"

#include "arg.cpp"
#include "chat.cpp"
#include "chat-auto-parser-generator.cpp"
#include "chat-auto-parser-helpers.cpp"
#include "chat-diff-analyzer.cpp"
#include "chat-peg-parser.cpp"
#include "common.cpp"
#include "console.cpp"
#include "debug.cpp"
#include "download.cpp"
#include "fit.cpp"
#include "hf-cache.cpp"
#include "json-partial.cpp"
#include "json-schema-to-grammar.cpp"
#include "llguidance.cpp"
#include "log.cpp"
#include "ngram-cache.cpp"
#include "ngram-map.cpp"
#include "ngram-mod.cpp"
#include "peg-parser.cpp"
#include "preset.cpp"
#include "reasoning-budget.cpp"
#include "regex-partial.cpp"
#include "sampling.cpp"
#include "speculative.cpp"
#include "unicode.cpp"


#include "../vendor/cpp-httplib/httplib.cpp"