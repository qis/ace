
#include <benchmark/benchmark.h>
#include <string>

static void BM_StringCreation(benchmark::State& state) {
  for (auto _ : state) {
    std::string empty;
  }
}
BENCHMARK(BM_StringCreation);

static void BM_StringCopy(benchmark::State& state) {
  std::string test = "test";
  for (auto _ : state) {
    std::string copy{ test };
  }
}
BENCHMARK(BM_StringCopy);

#include <cstdlib>

int main(int argc, char* argv[]) {
  benchmark::Initialize(&argc, argv);
  if (benchmark::ReportUnrecognizedArguments(argc, argv)) {
    return EXIT_FAILURE;
  }
  benchmark::RunSpecifiedBenchmarks();
  benchmark::Shutdown();
  return EXIT_SUCCESS;
}
