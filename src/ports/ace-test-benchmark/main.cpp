#include "benchmark/benchmark.h"
#include <chrono>
#include <format>

static void random(benchmark::State& state)
{
  for (auto _ : state) {
    const auto tp = std::chrono::system_clock::now();
    auto str = std::format("{}", tp.time_since_epoch().count());
    benchmark::DoNotOptimize(str);
  }
}

BENCHMARK(random);

int main(int argc, char** argv)
{
  benchmark::Initialize(&argc, argv);
  if (benchmark::ReportUnrecognizedArguments(argc, argv)) {
    return EXIT_FAILURE;
  }
  benchmark::RunSpecifiedBenchmarks();
}
