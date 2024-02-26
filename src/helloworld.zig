const c = @cImport({
	@cInclude("m_pd.h");
});

// -------------------------------- hello world --------------------------------
const t_helloworld = extern struct {
	const Self = @This();
	var class: ?*c.t_class = undefined;

	base: c.t_object,
	sym: *c.t_symbol,

	fn bang(self: *Self) void {
		c.post("Hello %s!", self.sym.s_name);
	}

	fn float(self: *Self, f: c.t_float) void {
		c.outlet_float(self.base.te_outlet, f * 2);
	}

	fn symbol(self: *Self, s: *c.t_symbol) void {
		self.sym = s;
	}

	fn new() *Self {
		const self: *Self = @ptrCast(c.pd_new(class));
		_ = c.outlet_new(&self.base, &c.s_float);
		self.sym = c.gensym("world");
		return self;
	}

	fn setup() void {
		class = c.class_new(c.gensym("helloworld"),
			@as(c.t_newmethod, @ptrCast(&Self.new)), null,
			@sizeOf(Self), c.CLASS_DEFAULT, 0);

		c.class_addbang(class, @as(c.t_method, @ptrCast(&Self.bang)));
		c.class_addfloat(class, @as(c.t_method, @ptrCast(&Self.float)));
		c.class_addsymbol(class, @as(c.t_method, @ptrCast(&Self.symbol)));
	}
};

export fn helloworld_setup() void {
	t_helloworld.setup();
}
