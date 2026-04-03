const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const fluxsort_mod = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "fluxsort",
        .root_module = fluxsort_mod,
    });
    b.installArtifact(lib);

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("fluxsort", fluxsort_mod);

    const exe = b.addExecutable(.{
        .name = "fluxsort-demo",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the demo executable");
    run_step.dependOn(&run_cmd.step);

    const example_mod = b.createModule(.{
        .root_source_file = b.path("examples/basic_sort.zig"),
        .target = target,
        .optimize = optimize,
    });
    example_mod.addImport("fluxsort", fluxsort_mod);

    const example_exe = b.addExecutable(.{
        .name = "basic_sort",
        .root_module = example_mod,
    });

    const run_example = b.addRunArtifact(example_exe);
    const example_step = b.step("example", "Run the basic sort example");
    example_step.dependOn(&run_example.step);

    const tests_mod = b.createModule(.{
        .root_source_file = b.path("test/tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    tests_mod.addImport("fluxsort", fluxsort_mod);

    const tests = b.addTest(.{
        .root_module = tests_mod,
    });
    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run FluxSort tests");
    test_step.dependOn(&run_tests.step);

    const bench_mod = b.createModule(.{
        .root_source_file = b.path("bench/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    bench_mod.addImport("fluxsort", fluxsort_mod);

    const bench_exe = b.addExecutable(.{
        .name = "fluxsort-bench",
        .root_module = bench_mod,
    });

    const run_bench = b.addRunArtifact(bench_exe);
    if (b.args) |args| run_bench.addArgs(args);

    const bench_step = b.step("bench", "Run local benchmark harness");
    bench_step.dependOn(&run_bench.step);
}
