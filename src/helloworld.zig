const pd = @import("pd.zig");

const HelloWorld = extern struct {
	const Self = @This();
	var class: *pd.Class = undefined;

	obj: pd.Object,
	out: *pd.Outlet,
	sym: *pd.Symbol,

	fn bang(self: *const Self) void {
		pd.post("Hello %s!", self.sym.name);
	}

	fn float(self: *const Self, f: pd.Float) void {
		self.out.float(f * 2);
	}

	fn symbol(self: *Self, s: *pd.Symbol) void {
		self.sym = s;
	}

	fn new() ?*Self {
		const self: *Self = @ptrCast(class.new() orelse return null);
		self.out = self.obj.outlet(pd.s.float);
		self.sym = pd.symbol("world");
		return self;
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
