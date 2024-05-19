const std = @import("std");

const externals = [_][]const u8 {
	"helloworld"
};

pub fn build(b: *std.Build) void {
	const target = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});

	for (externals) |e| {
		const artifact = b.addSharedLibrary(.{
			.name = e,
			.root_source_file = .{ .path = b.fmt("src/{s}.zig", .{e}) },
			.target = target,
			.optimize = optimize,
			.link_libc = true,
			.pic = true,
		});
		artifact.addIncludePath(.{ .cwd_relative = "src" });
		artifact.addSystemIncludePath(.{ .cwd_relative = "/usr/include" });

		const install = b.addInstallFile(artifact.getEmittedBin(),
			b.fmt("{s}.pd_linux", .{e}));
		install.step.dependOn(&artifact.step);
		b.getInstallStep().dependOn(&install.step);
	}
	installHelpFiles(b) catch {};
}

fn installHelpFiles(b: *std.Build) !void {
	const dir = try std.fs.cwd().openDir("help", .{ .iterate = true });
	var iter = dir.iterate();
	while (try iter.next()) |file| {
		if (file.kind != .file) {
			continue;
		}
		b.installFile(b.fmt("help/{s}", .{file.name}), file.name);
	}
}
