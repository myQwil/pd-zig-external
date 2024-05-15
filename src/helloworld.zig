const pd = @import("pd.zig");

const HelloWorld = extern struct {
	const Self = @This();
	var class: *pd.Class = undefined;

	obj: pd.Object,
	sym: *pd.Symbol,

	fn bang(self: *const Self) void {
		pd.post("Hello %s!", self.sym.name);
	}

	fn float(self: *const Self, f: pd.Float) void {
		self.obj.out.float(f * 2);
	}

	fn symbol(self: *Self, s: *pd.Symbol) void {
		self.sym = s;
	}

	inline fn _new() !*Self {
		const self: *Self = @ptrCast(class.new() orelse return error.NoSetup);
		errdefer pd.mem.destroy(self);

		_ = self.obj.outlet(pd.s.float);
		self.sym = pd.symbol("world");
		return self;
	}

	fn new() ?*Self {
		return _new() catch null;
	}

	inline fn setup() void {
		class = pd.class(pd.symbol("helloworld"), @ptrCast(&new), null,
			@sizeOf(Self), pd.Class.DEFAULT, 0);
		class.addBang(@ptrCast(&bang));
		class.addFloat(@ptrCast(&float));
		class.addSymbol(@ptrCast(&symbol));
	}
};

export fn helloworld_setup() void {
	HelloWorld.setup();
}
