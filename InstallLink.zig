const std = @import("std");
const Build = std.Build;
const Step = Build.Step;
const LazyPath = Build.LazyPath;
const InstallDir = Build.InstallDir;
const InstallLink = @This();
const assert = std.debug.assert;

step: Step,
source: LazyPath,
dir: InstallDir,
dest_rel_path: []const u8,

pub fn create(
	owner: *Build, source: LazyPath, dir: InstallDir, dest_rel_path: []const u8
) *InstallLink {
	assert(dest_rel_path.len != 0);
	const link = owner.allocator.create(InstallLink) catch @panic("OOM");
	link.* = .{
		.step = .init(.{
			.id = .custom,
			.name = owner.fmt("install symlink of {s} to {s}",
				.{ source.getDisplayName(), dest_rel_path }),
			.owner = owner,
			.makeFn = make,
		}),
		.source = source.dupe(owner),
		.dir = dir.dupe(owner),
		.dest_rel_path = owner.dupePath(dest_rel_path),
	};
	source.addStepDependencies(&link.step);
	return link;
}

fn make(step: *Step, _: Step.MakeOptions) !void {
	const b = step.owner;
	const link: *InstallLink = @fieldParentPtr("step", step);
	const install_path = b.getInstallPath(link.dir, "");
	const full_dest_path = b.fmt("{s}/{s}", .{install_path, link.dest_rel_path});
	const target_path = blk: {
		const p = link.source.getPath3(b, step);
		const full_src_path = b.pathResolve(&.{ p.root_dir.path orelse ".", p.sub_path });
		break :blk std.fs.path.relative(b.allocator, install_path, full_src_path)
			catch full_src_path;
	};
	const cwd = std.fs.cwd();

	// install folder must already exist before attempting to put symlinks in it
	cwd.access(install_path, .{}) catch cwd.makePath(install_path) catch {};

	cwd.symLink(target_path, full_dest_path, .{}) catch |err| switch (err) {
		error.PathAlreadyExists => {},
		else => return step.fail("unable to install symlink '{s}' -> '{s}': {s}",
			.{ full_dest_path, target_path, @errorName(err) }),
	};
}

pub fn installLink(b: *Build, src_path: []const u8, dest_rel_path: []const u8) void {
	b.getInstallStep().dependOn(
		&create(b, b.path(src_path), .prefix, dest_rel_path).step);
}
