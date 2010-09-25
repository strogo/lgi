--[[-- Assorted tests. --]]--

require 'lgi'
local GLib = require 'lgi.GLib'
local Gio = require 'lgi.Gio'
local GObject = require 'lgi.GObject'

-- Make logs verbose (do not mute DEBUG level).
lgi.log.DEBUG = 'verbose'

local tests = {}

-- Fails given tests with error, number indicates how many functions on the
-- stack should be skipped when reporting error location.
local function fail(msg, skip)
   error(msg or 'failure', (skip or 1) + 1)
end
local function check(cond, msg, skip)
   if not cond then fail(msg, (skip or 1) + 1) end
end

-- Helper, checks that given value has requested type and value.
local function checkv(val, exp, exptype)
   check(type(val) == exptype, string.format("got type `%s', expected `%s'",
					     type(val), exptype), 2)
   check(val == exp, string.format("got value `%s', expected `%s'",
				   tostring(val), tostring(exp)), 2)
end

-- gobject-introspection 'Regress' based tests.
function tests.t01_gireg_01_boolean()
   local R = lgi.Regress
   checkv(R.test_boolean(true), true, 'boolean')
   checkv(R.test_boolean(false), false, 'boolean')
end

function tests.t01_gireg_02_int8()
   local R = lgi.Regress
   checkv(R.test_int8(0), 0, 'number')
   checkv(R.test_int8(1), 1, 'number')
   checkv(R.test_int8(-1), -1, 'number')
   checkv(R.test_int8(1.1), 1, 'number')
   checkv(R.test_int8(-1.1), -1, 'number')
   checkv(R.test_int8(128), -128, 'number')
   checkv(R.test_int8(255), -1, 'number')
   checkv(R.test_int8(256), 0, 'number')
end

function tests.t01_gireg_03_uint8()
   local R = lgi.Regress
   checkv(R.test_uint8(0), 0, 'number')
   checkv(R.test_uint8(1), 1, 'number')
   checkv(R.test_uint8(-1), 255, 'number')
   checkv(R.test_uint8(1.1), 1, 'number')
   checkv(R.test_uint8(-1.1), 255, 'number')
   checkv(R.test_uint8(128), 128, 'number')
   checkv(R.test_uint8(255), 255, 'number')
   checkv(R.test_uint8(256), 0, 'number')
end

function tests.t01_gireg_04_int16()
   local R = lgi.Regress
   checkv(R.test_int16(0), 0, 'number')
   checkv(R.test_int16(1), 1, 'number')
   checkv(R.test_int16(-1), -1, 'number')
   checkv(R.test_int16(1.1), 1, 'number')
   checkv(R.test_int16(-1.1), -1, 'number')
   checkv(R.test_int16(32768), -32768, 'number')
   checkv(R.test_int16(65535), -1, 'number')
   checkv(R.test_int16(65536), 0, 'number')
end

function tests.t01_gireg_05_uint16()
   local R = lgi.Regress
   checkv(R.test_uint16(0), 0, 'number')
   checkv(R.test_uint16(1), 1, 'number')
   checkv(R.test_uint16(-1), 65535, 'number')
   checkv(R.test_uint16(1.1), 1, 'number')
   checkv(R.test_uint16(-1.1), 65535, 'number')
   checkv(R.test_uint16(32768), 32768, 'number')
   checkv(R.test_uint16(65535), 65535, 'number')
   checkv(R.test_uint16(65536), 0, 'number')
end

function tests.t01_gireg_06_int32()
   local R = lgi.Regress
   checkv(R.test_int32(0), 0, 'number')
   checkv(R.test_int32(1), 1, 'number')
   checkv(R.test_int32(-1), -1, 'number')
   checkv(R.test_int32(1.1), 1, 'number')
   checkv(R.test_int32(-1.1), -1, 'number')
   checkv(R.test_int32(0x80000000), -0x80000000, 'number')
   checkv(R.test_int32(0xffffffff), -1, 'number')
   checkv(R.test_int32(0x100000000), 0, 'number')
end

function tests.t01_gireg_07_uint32()
   local R = lgi.Regress
   checkv(R.test_uint32(0), 0, 'number')
   checkv(R.test_uint32(1), 1, 'number')
   checkv(R.test_uint32(-1), 0xffffffff, 'number')
   checkv(R.test_uint32(1.1), 1, 'number')
   checkv(R.test_uint32(-1.1), 0xffffffff, 'number')
   checkv(R.test_uint32(0x80000000), 0x80000000, 'number')
   checkv(R.test_uint32(0xffffffff), 0xffffffff, 'number')
   checkv(R.test_uint32(0x100000000), 0, 'number')
end

function tests.t01_gireg_08_int64()
   local R = lgi.Regress
   checkv(R.test_int64(0), 0, 'number')
   checkv(R.test_int64(1), 1, 'number')
   checkv(R.test_int64(-1), -1, 'number')
   checkv(R.test_int64(1.1), 1, 'number')
   checkv(R.test_int64(-1.1), -1, 'number')

   checkv(R.test_int64(0x80000000), 0x80000000, 'number')
   checkv(R.test_int64(0xffffffff), 0xffffffff, 'number')
   checkv(R.test_int64(0x100000000), 0x100000000, 'number')

-- Following tests fail because Lua's internal number representation
-- is always 'double', and conversion between double and int64 big
-- constants is always lossy.  Not sure if it can be solved somehow.

-- checkv(R.test_int64(0x8000000000000000), -0x8000000000000000, 'number')
-- checkv(R.test_int64(0xffffffffffffffff), -1, 'number')
-- checkv(R.test_int64(0x10000000000000000), 0, 'number')
end

function tests.t01_gireg_09_uint64()
   local R = lgi.Regress
   checkv(R.test_uint64(0), 0, 'number')
   checkv(R.test_uint64(1), 1, 'number')
   checkv(R.test_uint64(1.1), 1, 'number')

   checkv(R.test_uint64(0x80000000), 0x80000000, 'number')
   checkv(R.test_uint64(0xffffffff), 0xffffffff, 'number')
   checkv(R.test_uint64(0x100000000), 0x100000000, 'number')

-- See comment above about lossy conversions.
-- checkv(R.test_uint64(0xffffffffffffffff), 0xffffffffffffffff, 'number')
-- checkv(R.test_uint64(-1), 0xffffffffffffffff, 'number')
-- checkv(R.test_uint64(-1.1), 0xffffffffffffffff, 'number')
-- checkv(R.test_uint64(0x8000000000000000), 0x8000000000000000, 'number')
-- checkv(R.test_uint64(0x10000000000000000), 0, 'number')
end

function tests.t01_gireg_10_short()
   local R = lgi.Regress
   checkv(R.test_short(0), 0, 'number')
   checkv(R.test_short(1), 1, 'number')
   checkv(R.test_short(-1), -1, 'number')
   checkv(R.test_short(1.1), 1, 'number')
   checkv(R.test_short(-1.1), -1, 'number')
end

function tests.t01_gireg_11_ushort()
   local R = lgi.Regress
   checkv(R.test_ushort(0), 0, 'number')
   checkv(R.test_ushort(1), 1, 'number')
   checkv(R.test_ushort(1.1), 1, 'number')
   checkv(R.test_ushort(32768), 32768, 'number')
   checkv(R.test_ushort(65535), 65535, 'number')
end

function tests.t01_gireg_12_int()
   local R = lgi.Regress
   checkv(R.test_int(0), 0, 'number')
   checkv(R.test_int(1), 1, 'number')
   checkv(R.test_int(-1), -1, 'number')
   checkv(R.test_int(1.1), 1, 'number')
   checkv(R.test_int(-1.1), -1, 'number')
end

function tests.t01_gireg_13_uint()
   local R = lgi.Regress
   checkv(R.test_uint(0), 0, 'number')
   checkv(R.test_uint(1), 1, 'number')
   checkv(R.test_uint(1.1), 1, 'number')
   checkv(R.test_uint(0x80000000), 0x80000000, 'number')
   checkv(R.test_uint(0xffffffff), 0xffffffff, 'number')
end

function tests.t01_gireg_14_ssize()
   local R = lgi.Regress
   checkv(R.test_ssize(0), 0, 'number')
   checkv(R.test_ssize(1), 1, 'number')
   checkv(R.test_ssize(-1), -1, 'number')
   checkv(R.test_ssize(1.1), 1, 'number')
   checkv(R.test_ssize(-1.1), -1, 'number')
end

function tests.t01_gireg_15_size()
   local R = lgi.Regress
   checkv(R.test_size(0), 0, 'number')
   checkv(R.test_size(1), 1, 'number')
   checkv(R.test_size(1.1), 1, 'number')
   checkv(R.test_size(0x80000000), 0x80000000, 'number')
   checkv(R.test_size(0xffffffff), 0xffffffff, 'number')
end

-- Helper, checks that given value has requested type and value.
local function checkvf(val, exp, tolerance)
   check(type(val) == 'number', string.format(
	     "got type `%s', expected `number'", type(val)), 2)
   check(math.abs(val - exp) <= tolerance,
	  string.format("got value `%s', expected `%s'",
			tostring(val), tostring(exp)), 2)
end

function tests.t01_gireg_16_float()
   local R = lgi.Regress
   local t = 0.0000001
   checkvf(R.test_float(0), 0, t)
   checkvf(R.test_float(1), 1, t)
   checkvf(R.test_float(1.1), 1.1, t)
   checkvf(R.test_float(-1), -1, t)
   checkvf(R.test_float(-1.1), -1.1, t)
   checkvf(R.test_float(0x8000), 0x8000, t)
   checkvf(R.test_float(0xffff), 0xffff, t)
   checkvf(R.test_float(-0x8000), -0x8000, t)
   checkvf(R.test_float(-0xffff), -0xffff, t)
end

function tests.t01_gireg_17_double()
   local R = lgi.Regress
   checkv(R.test_double(0), 0, 'number')
   checkv(R.test_double(1), 1, 'number')
   checkv(R.test_double(1.1), 1.1, 'number')
   checkv(R.test_double(-1), -1, 'number')
   checkv(R.test_double(-1.1), -1.1, 'number')
   checkv(R.test_double(0x80000000), 0x80000000, 'number')
   checkv(R.test_double(0xffffffff), 0xffffffff, 'number')
   checkv(R.test_double(-0x80000000), -0x80000000, 'number')
   checkv(R.test_double(-0xffffffff), -0xffffffff, 'number')
end

function tests.t01_gireg_18_timet()
   local R = lgi.Regress
   checkv(R.test_timet(0), 0, 'number')
   checkv(R.test_timet(1), 1, 'number')
   checkv(R.test_timet(10000), 10000, 'number')
end

function tests.t01_gireg_19_gtype()
   local R = lgi.Regress
   checkv(R.test_gtype(0), 0, 'number')
   checkv(R.test_gtype(1), 1, 'number')
   checkv(R.test_gtype(10000), 10000, 'number')
end

function tests.t01_gireg_20_closure()
   local R = lgi.Regress
   checkv(R.test_closure(function() return 42 end), 42, 'number')
end

function tests.t01_gireg_21_closure_arg()
   local R = lgi.Regress
   checkv(R.test_closure_one_arg(function(int) return int end, 43), 43,
	  'number')
end

function tests.t01_gireg_22_gvalue_arg()
   local R = lgi.Regress
   checkv(R.test_int_value_arg(42), 42, 'number')
end

function tests.t01_gireg_23_gvalue_return()
   local R = lgi.Regress
   local v = R.test_value_return(43)
   checkv(v.value, 43, 'number')
   check(v.type == 'gint', 'incorrect value type')
end

function tests.t01_gireg_24_utf8_const_return()
   local R = lgi.Regress
   local utf8_const = 'const \226\153\165 utf8'
   check(R.test_utf8_const_return() == utf8_const)
end

function tests.t01_gireg_25_utf8_nonconst_return()
   local R = lgi.Regress
   local utf8_nonconst = 'nonconst \226\153\165 utf8'
   check(R.test_utf8_nonconst_return() == utf8_nonconst)
end

function tests.t01_gireg_26_utf8_nonconst_in()
   local R = lgi.Regress
   local utf8_nonconst = 'nonconst \226\153\165 utf8'
   R.test_utf8_nonconst_in(utf8_nonconst)
end

function tests.t01_gireg_27_utf8_const_in()
   local R = lgi.Regress
   local utf8_const = 'const \226\153\165 utf8'
   R.test_utf8_const_in(utf8_const)
end

function tests.t01_gireg_28_utf8_out()
   local R = lgi.Regress
   local utf8_nonconst = 'nonconst \226\153\165 utf8'
   check(R.test_utf8_out() == utf8_nonconst)
end

function tests.t01_gireg_29_utf8_inout()
   local R = lgi.Regress
   local utf8_const = 'const \226\153\165 utf8'
   local utf8_nonconst = 'nonconst \226\153\165 utf8'
   check(R.test_utf8_inout(utf8_const) == utf8_nonconst)
end

function tests.t01_gireg_30_filename_return()
   local R = lgi.Regress
   local fns = R.test_filename_return()
   check(type(fns) == 'table')
   check(#fns == 2)
   check(fns[1] == 'åäö')
   check(fns[2] == '/etc/fstab')
end

function tests.t01_gireg_31_int_out_utf8()
   local R = lgi.Regress
   check(R.test_int_out_utf8('') == 0)
   check(R.test_int_out_utf8('abc') == 3)
   local utf8_const = 'const \226\153\165 utf8'
   check(R.test_int_out_utf8(utf8_const) == 12)
end

function tests.t01_gireg_32_multi_double_args()
   local R = lgi.Regress
   local o1, o2 = R.test_multi_double_args(1)
   check(o1 == 2 and o2 == 3)
   check(#{R.test_multi_double_args(1)} == 2)
end

function tests.t01_gireg_33_utf8_out_out()
   local R = lgi.Regress
   local o1, o2 = R.test_utf8_out_out()
   check(o1 == 'first' and o2 == 'second')
   check(#{R.test_utf8_out_out()} == 2)
end

function tests.t01_gireg_34_utf8_out_nonconst_return()
   local R = lgi.Regress
   local o1, o2 = R.test_utf8_out_nonconst_return()
   check(o1 == 'first' and o2 == 'second')
   check(#{R.test_utf8_out_nonconst_return()} == 2)
end

function tests.t01_gireg_35_utf8_null_in()
   local R = lgi.Regress
   R.test_utf8_null_in(nil)
   R.test_utf8_null_in()
end

function tests.t01_gireg_36_utf8_null_out()
   local R = lgi.Regress
   check(R.test_utf8_null_out() == nil)
end

function tests.t01_gireg_37_array_int_in()
   local R = lgi.Regress
   check(R.test_array_int_in{1,2,3} == 6)
   check(R.test_array_int_in{1.1,2,3} == 6)
   check(R.test_array_int_in{} == 0)
   check(not pcall(R.test_array_int_in, nil))
   check(not pcall(R.test_array_int_in, 'help'))
   check(not pcall(R.test_array_int_in, {'help'}))
end

function tests.t01_gireg_38_array_int_out()
   local R = lgi.Regress
   local a = R.test_array_int_out()
   check(#a == 5)
   check(a[1] == 0 and a[2] == 1 and a[3] == 2 and a[4] == 3 and a[5] == 4)
   check(#{R.test_array_int_out()} == 1)
end

function tests.t01_gireg_39_array_int_inout()
   local R = lgi.Regress
   local a = R.test_array_int_inout({1, 2, 3, 4, 5})
   check(#a == 4)
   check(a[1] == 3 and a[2] == 4 and a[3] == 5 and a[4] == 6)
   check(#{R.test_array_int_inout({1, 2, 3, 4, 5})} == 1)
   check(not pcall(R.test_array_int_inout, nil))
   check(not pcall(R.test_array_int_inout, 'help'))
   check(not pcall(R.test_array_int_inout, {'help'}))
end

function tests.t01_gireg_40_array_gint8_in()
   local R = lgi.Regress
   check(R.test_array_gint8_in{1,2,3} == 6)
   check(R.test_array_gint8_in{1.1,2,3} == 6)
   check(R.test_array_gint8_in{} == 0)
   check(not pcall(R.test_array_gint8_in, nil))
   check(not pcall(R.test_array_gint8_in, 'help'))
   check(not pcall(R.test_array_gint8_in, {'help'}))
end

function tests.t01_gireg_41_array_gint16_in()
   local R = lgi.Regress
   check(R.test_array_gint16_in{1,2,3} == 6)
   check(R.test_array_gint16_in{1.1,2,3} == 6)
   check(R.test_array_gint16_in{} == 0)
   check(not pcall(R.test_array_gint16_in, nil))
   check(not pcall(R.test_array_gint16_in, 'help'))
   check(not pcall(R.test_array_gint16_in, {'help'}))
end

function tests.t01_gireg_42_array_gint32_in()
   local R = lgi.Regress
   check(R.test_array_gint32_in{1,2,3} == 6)
   check(R.test_array_gint32_in{1.1,2,3} == 6)
   check(R.test_array_gint32_in{} == 0)
   check(not pcall(R.test_array_gint32_in, nil))
   check(not pcall(R.test_array_gint32_in, 'help'))
   check(not pcall(R.test_array_gint32_in, {'help'}))
end

function tests.t01_gireg_43_array_gint64_in()
   local R = lgi.Regress
   check(R.test_array_gint64_in{1,2,3} == 6)
   check(R.test_array_gint64_in{1.1,2,3} == 6)
   check(R.test_array_gint64_in{} == 0)
   check(not pcall(R.test_array_gint64_in, nil))
   check(not pcall(R.test_array_gint64_in, 'help'))
   check(not pcall(R.test_array_gint64_in, {'help'}))
end

function tests.t01_gireg_44_strv_in()
   local R = lgi.Regress
   check(R.test_strv_in{'1', '2', '3'})
   check(not pcall(R.test_strv_in))
   check(not pcall(R.test_strv_in, '1'))
   check(not pcall(R.test_strv_in, 1))
   check(not R.test_strv_in{'3', '2', '1'})
   check(not R.test_strv_in{'1', '2', '3', '4'})
end

function tests.t01_gireg_45_strv_in_container()
   local R = lgi.Regress
   check(R.test_strv_in_container{'1', '2', '3'})
   check(not pcall(R.test_strv_in_container))
   check(not pcall(R.test_strv_in_container, '1'))
   check(not pcall(R.test_strv_in_container, 1))
   check(not R.test_strv_in_container{'3', '2', '1'})
   check(not R.test_strv_in_container{'1', '2', '3', '4'})
end

function tests.t02_gvalue_simple()
   local V = GObject.Value
   local function checkv(gval, tp, val)
      check(type(gval.type) == 'string', "GValue.type is not `string'")
      check(gval.type == tp, ("GValue type: expected `%s', got `%s'"):format(
	       tp, gval.type), 2)
      check(gval.value == val, ("GValue value: exp `%s', got `%s'"):format(
	       tostring(val), tostring(gval.value), 2))
   end
   checkv(V(), '', nil)
   checkv(V(0), 'gint', 0)
   checkv(V(1.1), 'gdouble', 1.1)
   checkv(V('str'), 'gchararray', 'str')
   local gcl = GObject.Closure(function() end)
   checkv(V(gcl), 'GClosure', gcl)
   local v = V(42)
   checkv(V(v).value, 'gint', 42)

-- For non-refcounted boxeds, the returned Value.value is always new
-- copy of the instance, so the following test fails:
--
-- checkv(V(v), 'GValue', v)

   check(V(v).type == 'GValue')
end

--[[--
function tests.t02_gio_01_loadfile_sync()
   local file = Gio.file_new_for_path('test.lua')
   local ok, contents, length, etag = file:load_contents()
   assert(ok and type(contents) == 'string' and type(length) == 'number' and
    type(etag) == 'string')
end

function tests.t02_gio_02_loadfile_async()
   local file = Gio.file_new_for_path('test.lua')
   local ok, contents, length, etag
   local main = GLib.MainLoop.new()
   file:load_contents_async(nil, function(_, result)
				    ok, contents, length, etag =
				       file:load_contents_finish(result)
				    main:quit()
				 end)
   main:run()
   assert(ok and type(contents) == 'string' and type(length) == 'number' and
    type(etag) == 'string')
end

function tests.t02_gio_03_loadfile_coro()
   local ok, contents, length, etag
   local main = GLib.MainLoop.new()
   coroutine.wrap(
      function()
	 local running = coroutine.running()
	 local file = Gio.file_new_for_path('test.lua')
	 file:load_contents_async(
	    nil, function(f, result)
		    coroutine.resume(running, file:load_contents_finish(result))
		 end)
	 ok, contents, length, etag = coroutine.yield()
	 main:quit()
      end)()
   main:run()
   assert(ok and type(contents) == 'string' and type(length) == 'number' and
    type(etag) == 'string')
end
--]]--

local tests_passed = 0
local tests_failed = 0

-- Runs specified test from tests table.
local function runtest(name)
   local func = tests[name]
   if type(func) ~= 'function' then
      print(string.format('ERRR: %s is not known test', name))
   else
      local ok, msg
      if not tests_debug then
	 ok, msg = pcall(tests[name])
      else
	 tests[name]()
	 ok = true
      end
      if ok then
	 print(string.format('PASS: %s', name))
	 tests_passed = tests_passed + 1
      else
	 print(string.format('FAIL: %s: %s', name, tostring(msg)))
	 tests_failed = tests_failed + 1
      end
   end
end

-- Create sorted index of tests.
do
   local names = {}
   for name in pairs(tests) do names[#names + 1] = name end
   table.sort(names)
   for i, name in ipairs(names) do tests[i] = name end
end

-- Run all tests from commandline, or all tests sequentially, if not
-- commandline is given.
if tests_run then
   tests[tests_run]()
else
   local args = {...}
   for _, name in ipairs(#args > 0 and args or tests) do runtest(name) end
   local tests_total = tests_failed + tests_passed
   if tests_failed == 0 then
      print(string.format('All %d tests passed.', tests_total))
   else
      print(string.format('%d of %d tests FAILED!', tests_failed, tests_total))
   end
end
