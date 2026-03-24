const pd = @import("pd");

const HelloWorld = extern struct {
	const name = "helloworld";
	var class: *pd.Class = undefined;

	obj: pd.Object = undefined,
	out: *pd.Outlet,
	sym: *pd.Symbol,

	fn bangC(self: *const HelloWorld) callconv(.c) void {
		pd.post.do("Hello %s!", .{ self.sym.name });
	}

	fn floatC(self: *const HelloWorld, f: pd.Float) callconv(.c) void {
		self.out.float(f * 2);
	}

	fn symbolC(self: *HelloWorld, s: *pd.Symbol) callconv(.c) void {
		self.sym = s;
	}

	fn yesNoC(self: *HelloWorld, f: pd.Float) callconv(.c) void {
		self.out.symbol(.gen(if (f != 0) "yes" else "no"));
	}

	fn initC() callconv(.c) ?*HelloWorld {
		return pd.wrap(*HelloWorld, init(), name);
	}
	inline fn init() !*HelloWorld {
		const self: *HelloWorld = @ptrCast(try class.pd());
		const obj: *pd.Object = &self.obj;
		errdefer obj.g.pd.deinit();

		self.* = .{
			.out = try .init(obj, &pd.s_float),
			.sym = .gen("world"),
		};
		return self;
	}

	inline fn setup() !void {
		class = try .init(HelloWorld, name, &.{}, &initC, null, .{});
		class.addBang(@ptrCast(&bangC));
		class.addFloat(@ptrCast(&floatC));
		class.addSymbol(@ptrCast(&symbolC));
		class.addMethod(@ptrCast(&yesNoC), .gen("yesno"), &.{ .float });
	}
};

export fn helloworld_setup() void {
	_ = pd.wrap(void, HelloWorld.setup(), @src().fn_name);
}
