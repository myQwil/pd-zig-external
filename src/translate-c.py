#!/usr/bin/env python3

import re
import subprocess

cwd = '' # 'src/'
include = '/usr/include/'
lines: list[str]

# Zig's C-translator does not like bit fields (for now)
with open(include + 'm_pd.h', 'r') as f:
	lines = f.read().splitlines()
	for i in range(len(lines)):
		if (lines[i].startswith('    unsigned int te_type:2;')):
			lines[i] = '    unsigned char te_type;'

with open(cwd + 'm_pd.h', 'w') as f:
	f.write('\n'.join(lines))

# translate to zig
out = subprocess.check_output([
	'zig', 'translate-c',
	'-isystem', include,
	cwd + 'm_pd.h'
], encoding='utf-8')


types = {
	'atomtype': 't_atomtype',
	'binbuf': 'pd.BinBuf',
	'floatarg': 'pd.Float',
	'garray': 'pd.GArray',
	'glist': 'pd.GList',
	'gobj': 'pd.GObj',
	'gpointer': 'pd.GPointer',
	'newmethod': 'pd.NewMethod',
	'perfroutine': 'pd.PerfRoutine',
}

vec_names = ['argv', 'av', 'vec']

r_type = r'([^\w])(?:struct__|t_|union_)(\w+)'
def re_type(m):
	# types should be TitleCase
	name = m.group(2)
	name = types[name] if name in types else ('pd.' + name.capitalize())
	return m.group(1) + name

r_param = r'(\w+): (?:\[\*c\]|\?\*)(const )?([\w\.]+)'
def re_param(m):
	name = m.group(1)
	p = '[*]' if name in vec_names else '[*:0]' if m.group(3) == 'u8' else '*'
	return m.group(1) + ': ' + p + (m.group(2) or '') + m.group(3)

r_dblptr = r'\[\*c\]\[\*c\](const )?([\w\.]+)'
def re_dblptr(m):
	ptr = '**' if m.group(2) == 'pd.Symbol' else '*[*]'
	return ptr + (m.group(1) or '') + m.group(2)

lines = out.splitlines()
for i in range(len(lines)):
	if re.match(r'(pub extern fn|pub const \w+ = \?\*const fn)', lines[i]):
		m = re.match(r'(.*)\((?!\.)(.*)\)(.*)', lines[i])
		if m:
			args = m.group(2)
			args = re.sub(r_type, re_type, args)
			args = re.sub(r_param, re_param, args)
			args = re.sub(r_dblptr, re_dblptr, args)
			ret = re.sub(r_type, re_type, m.group(3))
			lines[i] = m.group(1) + '(' + args + ')' + ret
	elif re.match(r'pub const t_(\w+) = struct__(\w+)', lines[i]):
		lines[i] = re.sub(r'([^\w])(?:struct__|union_)(\w+)', re_type, lines[i])

with open(cwd + 'm_pd.zig', 'w') as f:
	f.write('const pd = @import("pd.zig");\n' + '\n'.join(lines))
