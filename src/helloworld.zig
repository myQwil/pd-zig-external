const pd = @import("pd");

const HelloWorld = extern struct {
	const name = "helloworld";
	var class: *pd.Class = undefined;

	obj: pd.Object,
	out: *pd.Outlet,
	sym: *pd.Symbol,

	fn bangC(self: *const HelloWorld) callconv(.C) void {
		pd.post.do("Hello {s}!", .{ self.sym.name });
	}

	fn floatC(self: *const HelloWorld, f: pd.Float) callconv(.C) void {
		self.out.float(f * 2);
	}

	fn symbolC(self: *HelloWorld, s: *pd.Symbol) callconv(.C) void {
		self.sym = s;
	}

	fn yesNoC(self: *HelloWorld, f: pd.Float) callconv(.C) void {
		self.out.symbol(.gen(if (f != 0) "yes" else "no"));
	}

	inline fn new() !*HelloWorld {
		const self: *HelloWorld = @ptrCast(try class.pd());
		const obj: *pd.Object = &self.obj;
		errdefer obj.g.pd.free();

		self.out = try obj.outlet(&pd.s_float);
		self.sym = .gen("world");
		return self;
	}

	fn newC() callconv(.C) ?*HelloWorld {
		return new() catch |e| {
			pd.post.err(null, name ++ ": {s}", .{ @errorName(e) });
			return null;
		};
	}

	inline fn setup() !void {
		class = try .new(HelloWorld, name, &.{}, &newC, null, .{});
		class.addBang(@ptrCast(&bangC));
		class.addFloat(@ptrCast(&floatC));
		class.addSymbol(@ptrCast(&symbolC));
		class.addMethod(@ptrCast(&yesNoC), .gen("yesno"), &.{ .float });
	}
};

export fn helloworld_setup() void {
	HelloWorld.setup() catch |e|
		pd.post.err(null, "{s}: {s}", .{ @src().fn_name, @errorName(e) });
}
