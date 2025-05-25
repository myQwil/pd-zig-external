const std = @import("std");
const LinkMode = std.builtin.LinkMode;
const installLink = @import("InstallLink.zig").installLink;

const PatchMode = enum {
	/// Install copies of patches.
	copy,
	/// Install symbolic links to patches.
	/// This makes it easier to track changes made to the patches.
	symbolic,
	/// Don't install any patches.
	skip,
};

const Options = struct {
	float_size: u8 = 32,
	patches: PatchMode = .copy,
	linkage: LinkMode = .dynamic,
};

const Dependency = enum {
	libc,
};

const External = struct {
	name: []const u8,
	deps: []const Dependency = &.{},
};

const externals = [_]External{
	.{ .name = "helloworld" },
};

pub fn build(b: *std.Build) !void {
	const target = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});

	//---------------------------------------------------------------------------
	// Options
	const default: Options = .{};
	const opt: Options = .{
		.float_size = b.option(u8, "float_size",
			"Size of a floating-point number"
		) orelse default.float_size,

		.patches = b.option(PatchMode, "patches",
			"Method for installing Pd patches"
		) orelse default.patches,

		.linkage = b.option(LinkMode, "linkage",
			"Library linking method"
		) orelse default.linkage,
	};

	//---------------------------------------------------------------------------
	// Dependencies and modules
	const pd = b.dependency("pd", .{
		.target = target,
		.optimize = optimize,
		.float_size = opt.float_size,
	}).module("pd");

	//---------------------------------------------------------------------------
	// Install externals
	const extension = blk: {
		const os = target.result.os.tag;
		const arch = target.result.cpu.arch;
		break :blk b.fmt(".{s}_{s}", .{
			if      (os.isDarwin())  "d"
			else if (os == .windows) "m"
			else                     "l"
			,
			if      (arch == .x86_64)  "amd64"
			else if (arch == .x86)     "i386"
			else if (arch.isArm())     "arm"
			else if (arch.isAARCH64()) "arm64"
			else if (arch.isPowerPC()) "ppc"
			else                       @tagName(arch)
		});
	};
	for (externals) |x| {
		const mod = b.createModule(.{
			.target = target,
			.optimize = optimize,
			.root_source_file = b.path(b.fmt("src/{s}.zig", .{ x.name })),
			.imports = &.{.{ .name = "pd", .module = pd }},
		});
		const lib = b.addLibrary(.{
			.name = x.name,
			.linkage = .dynamic,
			.root_module = mod,
		});

		for (x.deps) |dep| switch (dep) {
			.libc => mod.link_libc = true,
		};

		const install = b.addInstallFile(lib.getEmittedBin(),
			b.fmt("{s}{s}", .{ x.name, extension }));
		install.step.dependOn(&lib.step);
		b.getInstallStep().dependOn(&install.step);

		const step_install = b.step(x.name, b.fmt("Build {s}", .{ x.name }));
		step_install.dependOn(&install.step);
	}

	//---------------------------------------------------------------------------
	// Install help patches and abstractions
	const InstallFunc = fn(*std.Build, []const u8, []const u8) void;
	const installFile: *const InstallFunc = switch (opt.patches) {
		.symbolic => &installLink,
		.copy => &std.Build.installFile,
		.skip => return,
	};

	for ([_][]const u8{"help"}) |dir_name| {
		const dir = try std.fs.cwd().openDir(dir_name, .{ .iterate = true });
		var iter = dir.iterate();
		while (try iter.next()) |file| {
			if (file.kind != .file) {
				continue;
			}
			installFile(b, b.fmt("{s}/{s}", .{ dir_name, file.name }), file.name);
		}
	}
}
