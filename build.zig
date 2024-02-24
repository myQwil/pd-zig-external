const std = @import("std");

pub fn build(b: *std.Build) void {
	const target = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});

	const hello = b.addSharedLibrary(.{
		.name = "helloworld",
		.root_source_file = .{ .path = "src/helloworld.zig" },
		.target = target,
		.optimize = optimize,
	});
	hello.addIncludePath(.{ .cwd_relative = "src" });
	hello.addSystemIncludePath(.{ .cwd_relative = "/usr/include" });

	const install = b.addInstallFile(hello.getOutputSource(), "helloworld.pd_linux");
	const paste = b.addInstallFile(hello.getOutputSource(), "../pd/helloworld.pd_linux");
	install.step.dependOn(&hello.step);
	paste.step.dependOn(&install.step);

	b.getInstallStep().dependOn(&paste.step);
}
