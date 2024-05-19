pub extern const pd_compatibilitylevel: i32;

pub const Int = isize;
pub const Float = f32;
pub const Sample = f32;
pub const FloatUInt = if (Float == f64) u64 else u32;

pub const Method = ?*const fn () void;
pub const NewMethod = ?*const fn () *anyopaque;

pub const Word = extern union {
	float: Float,
	symbol: *Symbol,
	gpointer: *GPointer,
	array: *Array,
	binbuf: *BinBuf,
	index: i32,
};

// ----------------------------------- Atom ------------------------------------
// -----------------------------------------------------------------------------
pub const Atom = extern struct {
	type: u32,
	w: Word,

	extern fn atom_gensym(*const Atom) *Symbol;
	pub const toSymbol = atom_gensym;
	extern fn atom_string(*const Atom, [*]u8, u32) void;
	pub const bufPrint = atom_string;
	extern fn atom_getint(*const Atom) Int;
	pub const int = atom_getint;
	extern fn atom_getfloat(*const Atom) Float;
	pub const float = atom_getfloat;
	extern fn atom_getsymbol(*const Atom) *Symbol;
	pub const symbol = atom_getsymbol;

	extern fn atom_getintarg(u32, u32, *const Atom) Int;
	pub inline fn intArg(self: *const Atom, which: u32, ac: u32) Int {
		return atom_getintarg(which, ac, self);
	}
	extern fn atom_getfloatarg(u32, u32, *const Atom) Float;
	pub inline fn floatArg(self: *const Atom, which: u32, ac: u32) Float {
		return atom_getfloatarg(which, ac, self);
	}
	extern fn atom_getsymbolarg(u32, u32, *const Atom) *Symbol;
	pub inline fn symbolArg(self: *const Atom, which: u32, ac: u32) *Symbol {
		return atom_getsymbolarg(which, ac, self);
	}
};

// variadic functions can't work with enum literals, even if the enum has
// an explicit tag type, so this enum is really just being used as a namespace.
pub const AtomType = enum {
	pub const NULL: u32 = 0;
	pub const FLOAT: u32 = 1;
	pub const SYMBOL: u32 = 2;
	pub const POINTER: u32 = 3;
	pub const SEMI: u32 = 4;
	pub const COMMA: u32 = 5;
	pub const DEFFLOAT: u32 = 6;
	pub const DEFSYM: u32 = 7;
	pub const DEFSYMBOL: u32 = 7;
	pub const DOLLAR: u32 = 8;
	pub const DOLLSYM: u32 = 9;
	pub const GIMME: u32 = 10;
	pub const CANT: u32 = 11;
};


// ---------------------------------- BinBuf -----------------------------------
// -----------------------------------------------------------------------------
pub const BinBuf = opaque {
	extern fn binbuf_free(*BinBuf) void;
	pub const free = binbuf_free;
	extern fn binbuf_duplicate(*const BinBuf) *BinBuf;
	pub const duplicate = binbuf_duplicate;
	extern fn binbuf_text(*BinBuf, [*]const u8, usize) void;
	pub const fromText = binbuf_text;
	extern fn binbuf_gettext(*const BinBuf, *[*]u8, *u32) void;
	pub const text = binbuf_gettext;
	extern fn binbuf_clear(*BinBuf) void;
	pub const clear = binbuf_clear;
	extern fn binbuf_add(*BinBuf, u32, [*]const Atom) void;
	pub const add = binbuf_add;
	extern fn binbuf_addv(*BinBuf, [*]const u8, ...) void;
	pub const addV = binbuf_addv;
	extern fn binbuf_addbinbuf(*BinBuf, *const BinBuf) void;
	pub const addBinBuf = binbuf_addbinbuf;
	extern fn binbuf_addsemi(*BinBuf) void;
	pub const addSemi = binbuf_addsemi;
	extern fn binbuf_restore(*BinBuf, u32, [*]const Atom) void;
	pub const restore = binbuf_restore;
	extern fn binbuf_print(*const BinBuf) void;
	pub const print = binbuf_print;
	extern fn binbuf_getnatom(*const BinBuf) u32;
	pub const nAtoms = binbuf_getnatom;
	extern fn binbuf_getvec(*const BinBuf) [*]Atom;
	pub const vec = binbuf_getvec;
	extern fn binbuf_resize(*BinBuf, u32) u32;
	pub const resize = binbuf_resize;
	extern fn binbuf_eval(*const BinBuf, *Pd, u32, [*]const Atom) void;
	pub const eval = binbuf_eval;
	extern fn binbuf_read(*BinBuf, [*]const u8, [*]const u8, u32) u32;
	pub const read = binbuf_read;
	extern fn binbuf_read_via_canvas(*BinBuf, [*]const u8, *const GList, u32) u32;
	pub const readViaCanvas = binbuf_read_via_canvas;
	extern fn binbuf_read_via_path(*BinBuf, [*]const u8, [*]const u8, u32) u32;
	pub const readViaPath = binbuf_read_via_path;
	extern fn binbuf_write(*const BinBuf, [*]const u8, [*]const u8, u32) u32;
	pub const write = binbuf_write;
};
extern fn binbuf_new() *BinBuf;
pub const binbuf = binbuf_new;


// ----------------------------------- Class -----------------------------------
// -----------------------------------------------------------------------------
pub const MethodEntry = extern struct {
	name: *Symbol,
	fun: GotFn,
	arg: [6]u8,
};

pub const BangMethod = ?*const fn (*Pd) void;
pub const PointerMethod = ?*const fn (*Pd, *GPointer) void;
pub const FloatMethod = ?*const fn (*Pd, Float) void;
pub const SymbolMethod = ?*const fn (*Pd, *Symbol) void;
pub const ListMethod = ?*const fn (*Pd, *Symbol, u32, [*]Atom) void;
pub const AnyMethod = ?*const fn (*Pd, *Symbol, u32, [*]Atom) void;

pub const SaveFn = ?*const fn (*GObj, ?*BinBuf) void;
pub const PropertiesFn = ?*const fn (*GObj, *GList) void;
pub const ClassFreeFn = ?*const fn (*Class) void;

pub const Class = extern struct {
	name: *Symbol,
	helpname: *Symbol,
	externdir: *Symbol,
	size: usize,
	methods: [*]MethodEntry,
	nmethod: u32,
	freemethod: Method,
	bangmethod: BangMethod,
	pointermethod: PointerMethod,
	floatmethod: FloatMethod,
	symbolmethod: SymbolMethod,
	listmethod: ListMethod,
	anymethod: AnyMethod,
	wb: ?*const WidgetBehavior,
	pwb: ?*const ParentWidgetBehavior,
	savefn: SaveFn,
	propertiesfn: PropertiesFn,
	next: *Class,
	floatsignalin: i32,
	flags: u8,
	classfreefn: ClassFreeFn,

	extern fn class_free(*Class) void;
	pub const free = class_free;
	extern fn class_addmethod(*Class, Method, *Symbol, u32, ...) void;
	pub const addMethod = class_addmethod;
	extern fn class_addbang(*Class, Method) void;
	pub const addBang = class_addbang;
	extern fn class_addpointer(*Class, Method) void;
	pub const addPointer = class_addpointer;
	extern fn class_doaddfloat(*Class, Method) void;
	pub const addFloat = class_doaddfloat;
	extern fn class_addsymbol(*Class, Method) void;
	pub const addSymbol = class_addsymbol;
	extern fn class_addlist(*Class, Method) void;
	pub const addList = class_addlist;
	extern fn class_addanything(*Class, Method) void;
	pub const addAnything = class_addanything;
	extern fn class_sethelpsymbol(*Class, *Symbol) void;
	pub const setHelpSymbol = class_sethelpsymbol;
	extern fn class_setwidget(*Class, ?*const WidgetBehavior) void;
	pub const setWidget = class_setwidget;
	extern fn class_setparentwidget(*Class, ?*const ParentWidgetBehavior) void;
	pub const setParentWidget = class_setparentwidget;
	extern fn class_getname(*const Class) [*]const u8;
	pub const name = class_getname;
	extern fn class_gethelpname(*const Class) [*]const u8;
	pub const helpName = class_gethelpname;
	extern fn class_gethelpdir(*const Class) [*]const u8;
	pub const helpDir = class_gethelpdir;
	extern fn class_setdrawcommand(*Class) void;
	pub const setDrawCommand = class_setdrawcommand;
	extern fn class_isdrawcommand(*const Class) i32;
	pub const isDrawCommand = class_isdrawcommand;
	extern fn class_domainsignalin(*Class, i32) void;
	pub const doMainSignalIn = class_domainsignalin;
	extern fn class_setsavefn(*Class, SaveFn) void;
	pub const setSaveFn = class_setsavefn;
	extern fn class_getsavefn(*const Class) SaveFn;
	pub const saveFn = class_getsavefn;
	extern fn class_setpropertiesfn(*Class, PropertiesFn) void;
	pub const setPropertiesFn = class_setpropertiesfn;
	extern fn class_getpropertiesfn(*const Class) PropertiesFn;
	pub const propertiesFn = class_getpropertiesfn;
	extern fn class_setfreefn(*Class, ClassFreeFn) void;
	pub const setFreeFn = class_setfreefn;
	extern fn pd_new(*const Class) ?*Pd;
	pub const new = pd_new;

	extern fn pd_findbyclass(*Symbol, *const Class) ?*Pd;
	pub inline fn find(self: *const Class, sym: *Symbol) ?*Pd {
		return pd_findbyclass(sym, self);
	}

	pub const DEFAULT: u32 = 0;     // flags for new classes below
	pub const PD: u32 = 1;          // non-canvasable (bare) pd such as an inlet
	pub const GOBJ: u32 = 2;        // pd that can belong to a canvas
	pub const PATCHABLE: u32 = 3;   // pd that also can have inlets and outlets
	pub const TYPEMASK: u32 = 3;
	pub const NOINLET: u32 = 8;          // suppress left inlet
	pub const MULTICHANNEL: u32 = 0x10;  // can deal with multichannel signals
	pub const NOPROMOTESIG: u32 = 0x20;  // don't promote scalars to signals
	pub const NOPROMOTELEFT: u32 = 0x40; // not even the main (left) inlet
};
extern fn class_new(?*Symbol, NewMethod, Method, usize, u32, u32, ...) *Class;
pub const class = class_new;
extern fn class_new64(?*Symbol, NewMethod, Method, usize, u32, u32, ...) *Class;
pub const class64 = class_new64;

pub extern const garray_class: *Class;
pub extern const scalar_class: *Class;
pub extern const glob_pdobject: *Class;


// ----------------------------------- Clock -----------------------------------
// -----------------------------------------------------------------------------
pub const Clock = opaque {
	extern fn clock_set(*Clock, f64) void;
	pub const set = clock_set;
	extern fn clock_delay(*Clock, f64) void;
	pub const delay = clock_delay;
	extern fn clock_unset(*Clock) void;
	pub const unset = clock_unset;
	extern fn clock_setunit(*Clock, f64, u32) void;
	pub const setUnit = clock_setunit;
	extern fn clock_free(*Clock) void;
	pub const free = clock_free;
};
extern fn clock_new(*anyopaque, Method) *Clock;
pub const clock = clock_new;
extern fn clock_getlogicaltime() f64;
pub const logicalTime = clock_getlogicaltime;
extern fn clock_getsystime() f64;
pub const sysTime = clock_getsystime;
extern fn clock_gettimesince(f64) f64;
pub const timeSince = clock_gettimesince;
extern fn clock_gettimesincewithunits(f64, f64, u32) f64;
pub const timeSinceWithUnits = clock_gettimesincewithunits;
extern fn clock_getsystimeafter(f64) f64;
pub const sysTimeAfter = clock_getsystimeafter;


// ------------------------------------ Dsp ------------------------------------
// -----------------------------------------------------------------------------
pub const dsp = struct {
	extern fn dsp_add(PerfRoutine, u32, ...) void;
	pub const add = dsp_add;
	extern fn dsp_addv(PerfRoutine, u32, [*]Int) void;
	pub const addV = dsp_addv;
	extern fn dsp_add_plus([*]Sample, [*]Sample, [*]Sample, u32) void;
	pub const addPlus = dsp_add_plus;
	extern fn dsp_add_copy([*]Sample, [*]Sample, u32) void;
	pub const addCopy = dsp_add_copy;
	extern fn dsp_add_scalarcopy([*]Float, [*]Sample, u32) void;
	pub const addScalarCopy = dsp_add_scalarcopy;
	extern fn dsp_add_zero([*]Sample, u32) void;
	pub const addZero = dsp_add_zero;
};


// ---------------------------------- GArray -----------------------------------
// -----------------------------------------------------------------------------
pub const GArray = opaque {
	extern fn garray_getfloatarray(*GArray, *u32, *[*]Float) u32;
	pub const floatArray = garray_getfloatarray;
	extern fn garray_redraw(*GArray) void;
	pub const redraw = garray_redraw;
	extern fn garray_npoints(*GArray) u32;
	pub const nPoints = garray_npoints;
	extern fn garray_vec(*GArray) [*]u8;
	pub const vec = garray_vec;
	extern fn garray_resize(*GArray, Float) void;
	pub const resize = garray_resize;
	extern fn garray_resize_long(*GArray, i64) void;
	pub const resizeLong = garray_resize_long;
	extern fn garray_usedindsp(*GArray) void;
	pub const useInDsp = garray_usedindsp;
	extern fn garray_setsaveit(*GArray, i32) void;
	pub const setSaveIt = garray_setsaveit;
	extern fn garray_getglist(*GArray) *GList;
	pub const glist = garray_getglist;
	extern fn garray_getarray(*GArray) ?*Array;
	pub const array = garray_getarray;

	extern fn garray_getfloatwords(*GArray, *u32, *[*]Word) u32;
	pub fn floatWords(self: *GArray) ?[]Word {
		var len: u32 = undefined;
		var ptr: [*]Word = undefined;
		return if (garray_getfloatwords(self, &len, &ptr) != 0) ptr[0..len] else null;
	}
};


// ----------------------------------- GList -----------------------------------
// -----------------------------------------------------------------------------
pub const GList = opaque {
	extern fn canvas_makefilename(*const GList, [*]const u8, [*]u8, u32) void;
	pub const makeFilename = canvas_makefilename;
	extern fn canvas_getdir(*const GList) *Symbol;
	pub const dir = canvas_getdir;
	extern fn canvas_dataproperties(*GList, *Scalar, *BinBuf) void;
	pub const dataProperties = canvas_dataproperties;
	extern fn canvas_open(
		*const GList, [*]const u8, [*]const u8, [*]u8, *[*]u8, u32, u32) i32;
	pub const open = canvas_open;
	extern fn canvas_getsr(*GList) Float;
	pub const sampleRate = canvas_getsr;
	extern fn canvas_getsignallength(*GList) u32;
	pub const signalLength = canvas_getsignallength;
	extern fn pd_undo_set_objectstate(
		*GList, *Pd, *Symbol, u32, [*]Atom, u32, [*]Atom) void;
	pub const undoSetState = pd_undo_set_objectstate;
	// static methods
	extern fn canvas_setargs(u32, [*]const Atom) void;
	pub const setArgs = canvas_setargs;
	extern fn canvas_getargs(*u32, *[*]Atom) void;
	pub const args = canvas_getargs;
	extern fn canvas_getcurrent() ?*GList;
	pub const current = canvas_getcurrent;
};


// --------------------------------- GPointer ----------------------------------
// -----------------------------------------------------------------------------
pub const Scalar = extern struct {
	gobj: GObj,
	template: *Symbol,
	vec: [1]Word,
};

pub const GStub = extern struct {
	un: extern union {
		glist: *GList,
		array: *Array,
	},
	which: enum(u32) {
		none,
		glist,
		array,
	},
	refcount: i32,
};

pub const GPointer = extern struct {
	un: extern union {
		scalar: *Scalar,
		w: *Word,
	},
	valid: i32,
	stub: *GStub,

	extern fn gpointer_init(*GPointer) void;
	pub const init = gpointer_init;
	extern fn gpointer_copy(*const GPointer, *GPointer) void;
	pub const copy = gpointer_copy;
	extern fn gpointer_unset(*GPointer) void;
	pub const unset = gpointer_unset;
	extern fn gpointer_check(*const GPointer, u32) u32;
	pub const check = gpointer_check;
};


// ----------------------------------- Inlet -----------------------------------
// -----------------------------------------------------------------------------
pub const Inlet = extern struct {
	pd: Pd,
	next: ?*Inlet,
	owner: *Object,
	dest: ?*Pd,
	symfrom: *Symbol,
	un: extern union {
		symto: *Symbol,
		pointerslot: *GPointer,
		floatslot: *Float,
		symslot: **Symbol,
		floatsignalvalue: Float,
	},

	extern fn inlet_free(*Inlet) void;
	pub const free = inlet_free;
};


// ---------------------------------- Memory -----------------------------------
// -----------------------------------------------------------------------------
const Allocator = @import("std").mem.Allocator;
const assert = @import("std").debug.assert;

extern fn getbytes(usize) ?[*]u8;
fn alloc(_: *anyopaque, len: usize, _: u8, _: usize) ?[*]u8 {
	assert(len > 0);
	return getbytes(len);
}

fn resize(_: *anyopaque, buf: []u8, _: u8, new_len: usize, _: usize) bool {
	return (new_len <= buf.len);
}

extern fn freebytes(*anyopaque, usize) void;
fn free(_: *anyopaque, buf: []u8, _: u8, _: usize) void {
	freebytes(buf.ptr, buf.len);
}

const mem_vtable = Allocator.VTable {
	.alloc = alloc,
	.resize = resize,
	.free = free,
};
pub const mem = Allocator {
	.ptr = undefined,
	.vtable = &mem_vtable,
};


// ---------------------------------- Object -----------------------------------
// -----------------------------------------------------------------------------
pub const GObj = extern struct {
	pd: Pd,
	next: *GObj,
};

pub const Object = extern struct {
	g: GObj,
	binbuf: *BinBuf,
	out: ?*Outlet,
	in: ?*Inlet,
	xpix: i16,
	ypix: i16,
	width: i16,
	type: enum(u8) {
		text = 0,
		object = 1,
		message = 2,
		atom = 3,
	},

	extern fn obj_list(*Object, *Symbol, u32, [*]Atom) void;
	pub const list = obj_list;
	extern fn obj_saveformat(*const Object, ?*BinBuf) void;
	pub const saveFormat = obj_saveformat;
	extern fn outlet_new(*Object, *Symbol) *Outlet;
	pub const outlet = outlet_new;
	extern fn inlet_new(*Object, *Pd, ?*Symbol, ?*Symbol) *Inlet;
	pub const inlet = inlet_new;
	extern fn pointerinlet_new(*Object, *GPointer) *Inlet;
	pub const inletPointer = pointerinlet_new;
	extern fn floatinlet_new(*Object, *Float) *Inlet;
	pub const inletFloat = floatinlet_new;
	extern fn symbolinlet_new(*Object, **Symbol) *Inlet;
	pub const inletSymbol = symbolinlet_new;
	extern fn signalinlet_new(*Object, Float) *Inlet;
	pub const inletSignal = signalinlet_new;

	pub inline fn inletFloatArg(obj: *Object, fp: *Float, av: []const Atom, i: usize)
	*Inlet {
		fp.* = (&av[0]).floatArg(@intCast(i), @intCast(av.len));
		return obj.inletFloat(fp);
	}

	pub inline fn inletSymbolArg(obj: *Object, sp: **Symbol, av: []const Atom, i: usize)
	*Inlet {
		sp.* = (&av[0]).symbolArg(@intCast(i), @intCast(av.len));
		return obj.inletSymbol(sp);
	}

};


// ---------------------------------- Outlet -----------------------------------
// -----------------------------------------------------------------------------
pub const Outlet = opaque {
	extern fn outlet_bang(*Outlet) void;
	pub const bang = outlet_bang;
	extern fn outlet_pointer(*Outlet, *GPointer) void;
	pub const pointer = outlet_pointer;
	extern fn outlet_float(*Outlet, Float) void;
	pub const float = outlet_float;
	extern fn outlet_symbol(*Outlet, *Symbol) void;
	pub const symbol = outlet_symbol;
	extern fn outlet_list(*Outlet, ?*Symbol, u32, [*]Atom) void;
	pub const list = outlet_list;
	extern fn outlet_anything(*Outlet, *Symbol, u32, [*]Atom) void;
	pub const anything = outlet_anything;
	extern fn outlet_getsymbol(*Outlet) *Symbol;
	pub const toSymbol = outlet_getsymbol;
	extern fn outlet_free(*Outlet) void;
	pub const free = outlet_free;
};


// ------------------------------------ Pd -------------------------------------
// -----------------------------------------------------------------------------
pub const Pd = extern struct {
	_: *const Class,

	extern fn pd_free(*Pd) void;
	pub const free = pd_free;
	extern fn pd_bind(*Pd, *Symbol) void;
	pub const bind = pd_bind;
	extern fn pd_unbind(*Pd, *Symbol) void;
	pub const unbind = pd_unbind;
	extern fn pd_pushsym(*Pd) void;
	pub const pushSymbol = pd_pushsym;
	extern fn pd_popsym(*Pd) void;
	pub const popSymbol = pd_popsym;
	extern fn pd_bang(*Pd) void;
	pub const bang = pd_bang;
	extern fn pd_pointer(*Pd, *GPointer) void;
	pub const pointer = pd_pointer;
	extern fn pd_float(*Pd, Float) void;
	pub const float = pd_float;
	extern fn pd_symbol(*Pd, *Symbol) void;
	pub const symbol = pd_symbol;
	extern fn pd_list(*Pd, *Symbol, u32, [*]Atom) void;
	pub const list = pd_list;
	extern fn pd_anything(*Pd, *Symbol, u32, [*]Atom) void;
	pub const anything = pd_anything;
	extern fn pd_vmess(*Pd, *Symbol, [*]const u8, ...) void;
	pub const vMess = pd_vmess;
	extern fn pd_typedmess(*Pd, *Symbol, u32, [*]Atom) void;
	pub const typedMess = pd_typedmess;
	extern fn pd_forwardmess(*Pd, u32, [*]Atom) void;
	pub const forwardMess = pd_forwardmess;
	extern fn pd_checkobject(*Pd) ?*Object;
	pub const checkObject = pd_checkobject;
	extern fn pd_getparentwidget(*Pd) ?*const ParentWidgetBehavior;
	pub const parentWidget = pd_getparentwidget;
	extern fn gfxstub_new(*Pd, ?*anyopaque, [*]const u8) void;
	pub const gfxStub = gfxstub_new;
	extern fn pdgui_stub_vnew(*Pd, [*]const u8, ?*anyopaque, [*]const u8, ...) void;
	pub const guiStub = pdgui_stub_vnew;
	extern fn getfn(*const Pd, *Symbol) GotFn;
	pub const func = getfn;
	extern fn zgetfn(*const Pd, *Symbol) GotFn;
	pub const zFunc = zgetfn;
	extern fn pd_newest() *Pd;
	pub const newest = pd_newest; // static
};


// --------------------------------- Resample ----------------------------------
// -----------------------------------------------------------------------------
pub const Resample = extern struct {
	method: i32,
	downsample: i32,
	upsample: i32,
	vec: [*]Sample,
	n: u32,
	coeffs: [*]Sample,
	coefsize: u32,
	buffer: [*]Sample,
	bufsize: u32,

	extern fn resample_init(*Resample) void;
	pub const init = resample_init;
	extern fn resample_free(*Resample) void;
	pub const free = resample_free;
	extern fn resample_dsp(*Resample, [*]Sample, u32, [*]Sample, u32, u32) void;
	pub const dsp = resample_dsp;
	extern fn resamplefrom_dsp(*Resample, [*]Sample, u32, u32, u32) void;
	pub const fromDsp = resamplefrom_dsp;
	extern fn resampleto_dsp(*Resample, [*]Sample, u32, u32, u32) void;
	pub const toDsp = resampleto_dsp;
};


// ---------------------------------- Signal -----------------------------------
// -----------------------------------------------------------------------------
pub const Signal = extern struct {
	len: u32,
	vec: [*]Sample,
	srate: Float,
	nchans: u32,
	overlap: i32,
	refcount: i32,
	isborrowed: i32,
	isscalar: i32,
	borrowedfrom: *Signal,
	nextfree: *Signal,
	nextused: *Signal,
	nalloc: i32,
};
extern fn signal_new(u32, u32, Float, [*]Sample) *Signal;
pub const signal = signal_new;
extern fn signal_setmultiout(*[*]Signal, u32) void;
pub const setMultiOut = signal_setmultiout;


// ---------------------------------- Symbol -----------------------------------
// -----------------------------------------------------------------------------
pub const Symbol = extern struct {
	name: [*:0]const u8,
	thing: ?*Pd,
	next: ?*Symbol,

	extern fn class_set_extern_dir(*Symbol) void;
	pub const setExternDir = class_set_extern_dir;
	extern fn text_getbufbyname(*Symbol) ?*BinBuf;
	pub const buf = text_getbufbyname;
	extern fn text_notifybyname(*Symbol) void;
	pub const notify = text_notifybyname;
	extern fn value_get(*Symbol) *Float;
	pub const val = value_get;
	extern fn value_release(*Symbol) void;
	pub const releaseVal = value_release;
	extern fn value_getfloat(*Symbol, *Float) u32;
	pub const float = value_getfloat;
	extern fn value_setfloat(*Symbol, Float) u32;
	pub const setFloat = value_setfloat;
};
extern fn gensym([*]const u8) *Symbol;
pub const symbol = gensym;

pub const s = struct {
	extern var s_pointer: Symbol;
	pub const pointer = &s_pointer;
	extern var s_float: Symbol;
	pub const float = &s_float;
	extern var s_symbol: Symbol;
	pub const symbol = &s_symbol;
	extern var s_bang: Symbol;
	pub const bang = &s_bang;
	extern var s_list: Symbol;
	pub const list = &s_list;
	extern var s_anything: Symbol;
	pub const anything = &s_anything;
	extern var s_signal: Symbol;
	pub const signal = &s_signal;
	extern var s__N: Symbol;
	pub const _N = &s__N;
	extern var s__X: Symbol;
	pub const _X = &s__X;
	extern var s_x: Symbol;
	pub const x = &s_x;
	extern var s_y: Symbol;
	pub const y = &s_y;
	extern var s_: Symbol;
	pub const _ = &s_;
};


// ---------------------------------- System -----------------------------------
// -----------------------------------------------------------------------------
extern fn sys_getblksize() u32;
pub const blockSize = sys_getblksize;
extern fn sys_getsr() Float;
pub const sampleRate = sys_getsr;
extern fn sys_get_inchannels() u32;
pub const inChannels = sys_get_inchannels;
extern fn sys_get_outchannels() u32;
pub const outChannels = sys_get_outchannels;
extern fn sys_vgui([*]const u8, ...) void;
pub const vgui = sys_vgui;
extern fn sys_gui([*]const u8) void;
pub const gui = sys_gui;
extern fn sys_pretendguibytes(i32) void;
pub const pretendGuiBytes = sys_pretendguibytes;
extern fn sys_queuegui(?*anyopaque, ?*GList, GuiCallbackFn) void;
pub const queueGui = sys_queuegui;
extern fn sys_unqueuegui(?*anyopaque) void;
pub const unqueueGui = sys_unqueuegui;
extern fn sys_getversion(*i32, *i32, *i32) void;
pub const version = sys_getversion;
extern fn sys_getfloatsize() u32;
pub const floatSize = sys_getfloatsize;
extern fn sys_getrealtime() f64;
pub const realTime = sys_getrealtime;
extern fn sys_open([*]const u8, i32, ...) i32;
pub const open = sys_open;
extern fn sys_close(i32) i32;
pub const close = sys_close;
// extern fn sys_fopen([*]const u8, [*]const u8) *FILE;
// pub const fopen = sys_fopen;
// extern fn sys_fclose(*FILE) i32;
// pub const fclose = sys_fclose;
extern fn sys_lock() void;
pub const lock = sys_lock;
extern fn sys_unlock() void;
pub const unlock = sys_unlock;
extern fn sys_trylock() i32;
pub const tryLock = sys_trylock;
extern fn sys_isabsolutepath([*]const u8) i32;
pub const isAbsolutePath = sys_isabsolutepath;
extern fn sys_bashfilename([*]const u8, [*]u8) void;
pub const bashFilename = sys_bashfilename;
extern fn sys_unbashfilename([*]const u8, [*]u8) void;
pub const unbashFilename = sys_unbashfilename;
extern fn sys_hostfontsize(i32, i32) i32;
pub const hostFontSize = sys_hostfontsize;
extern fn sys_zoomfontwidth(i32, i32, i32) i32;
pub const zoomFontWidth = sys_zoomfontwidth;
extern fn sys_zoomfontheight(i32, i32, i32) i32;
pub const zoomFontHeight = sys_zoomfontheight;
extern fn sys_fontwidth(i32) i32;
pub const fontWidth = sys_fontwidth;
extern fn sys_fontheight(i32) i32;
pub const fontHeight = sys_fontheight;

extern fn class_addcreator(NewMethod, *Symbol, u32, ...) void;
pub const addCreator = class_addcreator;

extern fn binbuf_evalfile(*Symbol, *Symbol) void;
pub const evalFile = binbuf_evalfile;
extern fn binbuf_realizedollsym(*Symbol, u32, [*]const Atom, u32) *Symbol;
pub const realizeDollSym = binbuf_realizedollsym;

extern fn canvas_getcurrentdir() *Symbol;
pub const currentDir = canvas_getcurrentdir;
extern fn canvas_suspend_dsp() i32;
pub const suspendDsp = canvas_suspend_dsp;
extern fn canvas_resume_dsp(i32) void;
pub const resumeDsp = canvas_resume_dsp;
extern fn canvas_update_dsp() void;
pub const updateDsp = canvas_update_dsp;

extern fn pd_getcanvaslist() ?*GList;
pub const canvasList = pd_getcanvaslist;
extern fn pd_getdspstate() i32;
pub const dspState = pd_getdspstate;

extern fn pd_error(?*const anyopaque, [*]const u8, ...) void;
pub const err = pd_error;

extern fn glob_setfilename(?*anyopaque, *Symbol, *Symbol) void;
pub const setFileName = glob_setfilename;

// ----------------------------------- Misc. -----------------------------------
// -----------------------------------------------------------------------------
pub const OutConnect = opaque {};
pub const Template = opaque {};
pub const Array = opaque {};

pub extern var pd_objectmaker: Pd;
pub extern var pd_canvasmaker: Pd;

pub const GotFn = ?*const fn (*anyopaque, ...) callconv(.C) void;
pub const GotFn1 = ?*const fn (*anyopaque, *anyopaque) void;
pub const GotFn2 = ?*const fn (*anyopaque, *anyopaque, *anyopaque) void;
pub const GotFn3 = ?*const fn (*anyopaque, *anyopaque, *anyopaque, *anyopaque) void;
pub const GotFn4 = ?*const fn (
	*anyopaque, *anyopaque, *anyopaque, *anyopaque, *anyopaque) void;
pub const GotFn5 = ?*const fn (
	*anyopaque, *anyopaque, *anyopaque, *anyopaque, *anyopaque, *anyopaque) void;

extern fn nullfn() void;
pub const nullFn = nullfn;

pub const sys_font: [*]u8 = @extern([*]u8, .{
	.name = "sys_font",
});
pub const sys_fontweight: [*]u8 = @extern([*]u8, .{
	.name = "sys_fontweight",
});

pub const WidgetBehavior = opaque {};
pub const ParentWidgetBehavior = opaque {};

pub extern fn post([*]const u8, ...) void;
pub extern fn startpost([*]const u8, ...) void;
pub extern fn poststring([*]const u8) void;
pub extern fn postfloat(Float) void;
pub extern fn postatom(u32, [*]const Atom) void;
pub extern fn endpost() void;

pub extern fn bug([*]const u8, ...) void;
pub extern fn logpost(?*const anyopaque, LogLevel, [*]const u8, ...) void;
pub extern fn verbose(u32, [*]const u8, ...) void;
pub const LogLevel = enum(u32) {
	critical,
	err,
	normal,
	debug,
	verbose,
};

pub extern fn open_via_path([*]const u8, [*]const u8, [*]const u8, [*]u8, *[*]u8, u32, u32) i32;
pub extern fn sched_geteventno() i32;
pub extern var sys_idlehook: ?*const fn () i32;

pub const PerfRoutine = ?*const fn ([*]usize) *usize;
pub extern fn plus_perform([*]usize) *usize;
pub extern fn plus_perf8([*]usize) *usize;
pub extern fn zero_perform([*]usize) *usize;
pub extern fn zero_perf8([*]usize) *usize;
pub extern fn copy_perform([*]usize) *usize;
pub extern fn copy_perf8([*]usize) *usize;
pub extern fn scalarcopy_perform([*]usize) *usize;
pub extern fn scalarcopy_perf8([*]usize) *usize;


pub const mayer = struct {
	extern fn mayer_fht([*]Sample, u32) void;
	pub const fht = mayer_fht;
	extern fn mayer_fft(u32, [*]Sample, [*]Sample) void;
	pub const fft = mayer_fft;
	extern fn mayer_ifft(u32, [*]Sample, [*]Sample) void;
	pub const ifft = mayer_ifft;
	extern fn mayer_realfft(u32, [*]Sample) void;
	pub const realfft = mayer_realfft;
	extern fn mayer_realifft(u32, [*]Sample) void;
	pub const realifft = mayer_realifft;
};
pub extern fn pd_fft([*]Float, u32, u32) void;


pub extern var cos_table: [*]f32;

pub fn ulog2(n: u64) u6 {
	var i = n;
	var r: u6 = 0;
	while (i > 1) : ({ r += 1; i >>= 1; }) {}
	return r;
}

pub inline fn floatPassive(fp: *Float, av: []const Atom, i: usize) void {
	if (i < av.len and av[i].type == AtomType.FLOAT) {
		fp.* = av[i].w.float;
	}
}

pub extern fn mtof(Float) Float;
pub extern fn ftom(Float) Float;
pub extern fn rmstodb(Float) Float;
pub extern fn powtodb(Float) Float;
pub extern fn dbtorms(Float) Float;
pub extern fn dbtopow(Float) Float;
pub extern fn q8_sqrt(Float) Float;
pub extern fn q8_rsqrt(Float) Float;
pub extern fn qsqrt(Float) Float;
pub extern fn qrsqrt(Float) Float;

pub const GuiCallbackFn = ?*const fn (*GObj, ?*GList) void;
pub extern fn gfxstub_deleteforkey(?*anyopaque) void;
pub extern fn pdgui_vmess([*]const u8, [*]const u8, ...) void;
pub extern fn pdgui_stub_deleteforkey(?*anyopaque) void;
pub extern fn c_extern(*Pd, NewMethod, Method, *Symbol, usize, i32, u32, ...) void;
pub extern fn c_addmess(Method, *Symbol, u32, ...) void;


pub const BigOrSmall32 = extern union {
	f: Float,
	ui: u32,
};
pub inline fn badFloat(f: Float) bool {
	var pun = BigOrSmall32 { .f = f };
	pun.ui &= 0x7f800000;
	return pun.ui == 0 or pun.ui == 0x7f800000;
}
pub inline fn bigOrSmall(f: Float) bool {
	const pun = BigOrSmall32 { .f = f };
	return pun.ui & 0x20000000 == (pun.ui >> 1) & 0x20000000;
}

pub const MidiInstance = opaque {};
pub const InterfaceInstance = opaque {};
pub const CanvasInstance = opaque {};
pub const UgenInstance = opaque {};
pub const StuffInstance = opaque {};
pub const PdInstance = extern struct {
	systime: f64,
	clock_setlist: *Clock,
	canvaslist: *GList,
	templatelist: *Template,
	instanceno: u32,
	symhash: **Symbol,
	midi: *MidiInstance,
	inter: *InterfaceInstance,
	ugen: *UgenInstance,
	gui: *CanvasInstance,
	stuff: *StuffInstance,
	newest: *Pd,
	islocked: u32,
};
pub extern var pd_maininstance: PdInstance;
pub const this = &pd_maininstance;

pub const MAXPDSTRING: u32 = 1000;
pub const MAXPDARG: u32 = 5;
pub const MAXLOGSIG: u32 = 32;
pub const MAXSIGSIZE: u32 = 1 << MAXLOGSIG;

pub const LOGCOSTABSIZE: u32 = 9;
pub const COSTABSIZE: u32 = 1 << LOGCOSTABSIZE;

pub const PD_USE_TE_XPIX = "";
pub const PDTHREADS: u32 = 1;
pub const PERTHREAD = "";
