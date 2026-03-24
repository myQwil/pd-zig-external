const std = @import("std");
const pd = @import("pd");
const LinkMode = std.builtin.LinkMode;
const Build = std.Build;

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

	fn init(b: *Build) Options {
		const default: Options = .{};
		return .{
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
	}
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

pub fn build(b: *Build) !void {
	const target = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});
	const opt: Options = .init(b);

	//---------------------------------------------------------------------------
	// Dependencies and modules
	const pd_mod = b.dependency("pd", .{ .float_size = opt.float_size }).module("pd");

	//---------------------------------------------------------------------------
	// Install externals
	const extension = pd.extension(b, target, opt.float_size);
	for (externals) |x| {
		const mod = b.createModule(.{
			.target = target,
			.optimize = optimize,
			.root_source_file = b.path(b.fmt("src/{s}.zig", .{ x.name })),
			.imports = &.{.{ .name = "pd", .module = pd_mod }},
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
	const io = b.graph.io;
	const InstallFunc = fn(*Build, []const u8, []const u8) void;
	const installFile: *const InstallFunc = switch (opt.patches) {
		.symbolic => &pd.InstallLink.install,
		.copy => &Build.installFile,
		.skip => return,
	};

	for ([_][]const u8{ "help" }) |dir_name| {
		const dir = try std.Io.Dir.cwd().openDir(io, dir_name, .{ .iterate = true });
		var iter = dir.iterate();
		while (try iter.next(io)) |file| {
			if (file.kind != .file) {
				continue;
			}
			installFile(b, b.fmt("{s}/{s}", .{ dir_name, file.name }), file.name);
		}
	}
}
