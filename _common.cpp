
int LLAMA_BUILD_NUMBER = 8772;
char const *LLAMA_COMMIT = LLAMA_COMMON_BUILD_COMMIT;
char const *LLAMA_COMPILER = "clang 20.1.5";
char const *LLAMA_BUILD_TARGET = "x86_64-w64-windows-gnu";
char const *LICENSES[] = {"LICENSES"};

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