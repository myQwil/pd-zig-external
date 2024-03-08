const std = @import("std");

pub fn build(b: *std.Build) !void {
	var buf: [64]u8 = undefined;

	std.debug.print("\n---------- Externals ----------\n", .{});
	{
		const target = b.standardTargetOptions(.{});
		const optimize = b.standardOptimizeOption(.{});

		const sources = [_][]const u8 {"helloworld"};
		for (sources) |source| {
			var s = try std.fmt.bufPrint(&buf, "src/{s}.zig", .{source});
			const artifact = b.addSharedLibrary(.{
				.name = source,
				.root_source_file = .{ .path = s },
				.target = target,
				.optimize = optimize,
				.link_libc = true,
			});
			artifact.force_pic = true;
			artifact.addIncludePath(.{ .cwd_relative = "src" });
			artifact.addSystemIncludePath(.{ .cwd_relative = "/usr/include" });

			s = try std.fmt.bufPrint(&buf, "{s}.pd_linux", .{source});
			std.debug.print("{s}\n", .{s});

			const install = b.addInstallFile(artifact.getOutputSource(), s);
			install.step.dependOn(&artifact.step);
			b.getInstallStep().dependOn(&install.step);
		}
	}

	std.debug.print("\n---------- Help files ----------\n", .{});
	{
		const dir = try std.fs.cwd().openIterableDir("help", .{});
		var iter = dir.iterate();
		while (try iter.next()) |file| {
			if (file.kind != .file) {
				continue;
			}
			std.debug.print("{s}\n", .{file.name});
			const s = try std.fmt.bufPrint(&buf, "help/{s}", .{file.name});
			b.installFile(s, file.name);
		}
	}

	std.debug.print("\n", .{});
}
