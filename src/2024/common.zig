const std = @import("std");

pub fn toNumber(field: []const u8) !i64 {
    return std.fmt.parseInt(i64, field, 10);
}

pub fn charTou4(char: u8) u4 {
    return @intCast(char - '0');
}

var splitBuffer: [1024]i64 = undefined;

pub fn split(line: []const u8, delimiter: u8) ![]i64 {
    var columit = std.mem.splitScalar(u8, line, delimiter);
    var i: usize = 0;
    while (columit.next()) |column| {
        splitBuffer[i] = try toNumber(column);
        i += 1;
    }
    return splitBuffer[0..i];
}

pub fn instr(str: []const u8, start: usize, char: u8) ?usize {
    var pos = start;
    while (pos < str.len) {
        if (str[pos] == char) {
            return pos;
        }
        pos += 1;
    }
    return null;
}

pub fn Grid(comptime T: type) type {
    return struct {
        const Self = @This();
        allocator: std.mem.Allocator,
        width: usize,
        height: usize,
        data: []T,

        pub fn init(width: usize, height: usize, allocator: std.mem.Allocator) !Self {
            return .{
                .allocator = allocator,
                .width = width,
                .height = height,
                .data = try allocator.alloc(T, width * height),
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.data);
        }

        pub fn get(self: *Self, x: usize, y: usize) T {
            return self.data[y * self.width + x];
        }

        pub fn set(self: *Self, x: usize, y: usize, value: T) void {
            self.data[y * self.width + x] = value;
        }

        pub fn reset(self: *Self, value: T) void {
            @memset(self.data, value);
        }
    };
}

pub fn readGrid(input: []const u8, allocator: std.mem.Allocator) !Grid(u8) {
    var pos: usize = 0;
    while (input[pos] != '\n') {
        pos += 1;
    }

    const width = pos;
    var height: usize = 0;
    while (pos < input.len) {
        if (input[pos] == '\n') {
            height += 1;
        }
        pos += 1;
    }

    var grid = try Grid(u8).init(width, height, allocator);

    for (0..height) |y| {
        for (0..width) |x| {
            grid.set(x, y, input[y * (width + 1) + x]);
        }
    }

    return grid;
}

pub fn readAndMapGrid(comptime T: type, comptime convert: fn (char: u8) T, input: []const u8, allocator: std.mem.Allocator) !Grid(T) {
    var pos: usize = 0;
    while (input[pos] != '\n') {
        pos += 1;
    }

    const width = pos;
    var height: usize = 0;
    while (pos < input.len) {
        if (input[pos] == '\n') {
            height += 1;
        }
        pos += 1;
    }

    var grid = try Grid(T).init(width, height, allocator);

    for (0..height) |y| {
        for (0..width) |x| {
            grid.set(x, y, convert(input[y * (width + 1) + x]));
        }
    }

    return grid;
}

test "readGrid" {
    const input =
        \\0123456789
        \\ABCDEFGHIJ
        \\abcdefghij
        \\
    ;
    const allocator = std.testing.allocator;

    var grid = try readGrid(input, allocator);
    defer grid.deinit();

    try std.testing.expectEqual(10, grid.width);
    try std.testing.expectEqual(3, grid.height);

    try std.testing.expectEqual('0', grid.get(0, 0));
    try std.testing.expectEqual('9', grid.get(9, 0));
    try std.testing.expectEqual('A', grid.get(0, 1));
    try std.testing.expectEqual('a', grid.get(0, 2));
    try std.testing.expectEqual('j', grid.get(9, 2));
}

test "readAndMapGrid" {
    const input =
        \\0123456789
        \\9876543210
        \\4242424242
        \\
    ;
    const allocator = std.testing.allocator;

    var grid = try readAndMapGrid(u4, charTou4, input, allocator);
    defer grid.deinit();

    try std.testing.expectEqual(10, grid.width);
    try std.testing.expectEqual(3, grid.height);

    try std.testing.expectEqual(0, grid.get(0, 0));
    try std.testing.expectEqual(9, grid.get(9, 0));
    try std.testing.expectEqual(9, grid.get(0, 1));
    try std.testing.expectEqual(4, grid.get(0, 2));
    try std.testing.expectEqual(2, grid.get(9, 2));
}

test "instr" {
    try std.testing.expectEqual(0, instr(":123", 0, ':').?);
    try std.testing.expectEqual(1, instr("1:23", 0, ':').?);
    try std.testing.expectEqual(2, instr("12:3", 0, ':').?);
    try std.testing.expectEqual(3, instr("123:", 0, ':').?);
    try std.testing.expectEqual(null, instr("123", 0, ':'));

    try std.testing.expectEqual(1, instr("1:23", 1, ':').?);
    try std.testing.expectEqual(2, instr("12:3", 2, ':').?);
    try std.testing.expectEqual(3, instr("123:", 2, ':').?);
}
