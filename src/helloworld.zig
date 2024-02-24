const c = @cImport({
	@cInclude("m_pd.h");
});

// -------------------------------- hello world --------------------------------
var helloworld_class: ?*c.t_class = null;

const t_helloworld = struct {
	x_obj: c.t_object,
	x_s: *c.t_symbol,
};

fn helloworld_bang(x: *t_helloworld) void {
	c.post("Hello %s!", x.x_s.s_name);
}

fn helloworld_float(x: *t_helloworld, f: c.t_float) void {
	c.outlet_float(x.x_obj.te_outlet, f * 2);
}

fn helloworld_symbol(x: *t_helloworld, s: *c.t_symbol) void {
	x.x_s = s;
}

fn helloworld_new() ?*anyopaque {
	const x: *t_helloworld = @ptrCast(c.pd_new(helloworld_class));
	_ = c.outlet_new(&x.x_obj, &c.s_float);
	x.x_s = c.gensym("world");
	return x;
}

export fn helloworld_setup() void {
	helloworld_class = c.class_new(c.gensym("helloworld"),
		@as(c.t_newmethod, @ptrCast(&helloworld_new)), null,
		@sizeOf(t_helloworld), c.CLASS_DEFAULT, 0);

	c.class_addbang(helloworld_class, @as(c.t_method, @ptrCast(&helloworld_bang)));
	c.class_addfloat(helloworld_class, @as(c.t_method, @ptrCast(&helloworld_float)));
	c.class_addsymbol(helloworld_class, @as(c.t_method, @ptrCast(&helloworld_symbol)));
}
