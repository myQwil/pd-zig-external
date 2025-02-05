const pd = @import("pd");

const HelloWorld = extern struct {
	const Self = @This();
	var class: *pd.Class = undefined;

	obj: pd.Object,
	out: *pd.Outlet,
	sym: *pd.Symbol,

	fn bangC(self: *const Self) callconv(.C) void {
		pd.post.do("Hello %s!", .{ self.sym.name });
	}

	fn floatC(self: *const Self, f: pd.Float) callconv(.C) void {
		self.out.float(f * 2);
	}

	fn symbolC(self: *Self, s: *pd.Symbol) callconv(.C) void {
		self.sym = s;
	}

	fn yesNoC(self: *Self, f: pd.Float) callconv(.C) void {
		self.out.symbol(if (f != 0) pd.symbol("yes") else pd.symbol("no"));
	}

	inline fn new() !*Self {
		const self: *Self = @ptrCast(try class.pd());
		errdefer @as(*pd.Pd, @ptrCast(self)).free();

		self.out = try self.obj.outlet(&pd.s_float);
		self.sym = pd.symbol("world");
		return self;
	}

	fn newC() callconv(.C) ?*Self {
		return new() catch |e| {
			pd.post.err(null, "%s", .{ @errorName(e).ptr });
			return null;
		};
	}

	inline fn setup() !void {
		class = try pd.class(pd.symbol("helloworld"), @ptrCast(&newC), null,
			@sizeOf(Self), .{}, &.{});
		class.addBang(@ptrCast(&bangC));
		class.addFloat(@ptrCast(&floatC));
		class.addSymbol(@ptrCast(&symbolC));
		class.addMethod(@ptrCast(&yesNoC), pd.symbol("yesno"), &.{ .float });
	}
};

export fn helloworld_setup() void {
	HelloWorld.setup() catch |e|
		pd.post.err(null, "%s: %s", .{ @src().fn_name.ptr, @errorName(e).ptr });
}
