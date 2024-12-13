const std = @import("std");

pub fn toNumber(field: []const u8) !i64 {
    return std.fmt.parseInt(i64, field, 10);
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

pub const Matrix = struct {
    allocator: std.mem.Allocator,
    data: []u8,
    xMax: usize,
    yMax: usize,

    pub fn init(input: []const u8, allocator: std.mem.Allocator) !Matrix {
        var pos: usize = 0;
        while (input[pos] != '\n') {
            pos += 1;
        }
        const xMax = pos - 1;
        var yMax: usize = 0;
        pos += 1;
        while (pos < input.len) {
            if (input[pos] == '\n') {
                yMax += 1;
            }
            pos += 1;
        }
        return .{
            .allocator = allocator,
            .data = try allocator.dupe(u8, input),
            .xMax = xMax,
            .yMax = yMax,
        };
    }

    pub fn deinit(self: Matrix) void {
        self.allocator.free(self.data);
    }

    pub fn get(self: Matrix, x: i64, y: i64) u8 {
        var rx = x;
        while (rx > self.xMax) {
            rx -= @as(i64, @intCast(self.xMax)) + 1;
        }
        while (rx < 0) {
            rx += @as(i64, @intCast(self.xMax)) + 1;
        }

        var ry = y;
        while (ry > self.yMax) {
            ry -= @as(i64, @intCast(self.yMax)) + 1;
        }
        while (ry < 0) {
            ry += @as(i64, @intCast(self.yMax)) + 1;
        }

        const pos = @as(usize, @intCast(ry)) * (self.xMax + 2) + @as(usize, @intCast(rx));
        return self.data[pos];
    }

    pub fn uget(self: Matrix, x: usize, y: usize) u8 {
        const pos = y * (self.xMax + 2) + x;
        return self.data[pos];
    }

    pub fn set(self: *Matrix, x: usize, y: usize, value: u8) void {
        const pos = y * (self.xMax + 2) + x;
        self.data[pos] = value;
    }
};

test "matrix" {
    const input =
        \\0123456789
        \\ABCDEFGHIJ
        \\abcdefghij
        \\
    ;
    const allocator = std.heap.page_allocator;

    const mtx: Matrix = try Matrix.init(input, allocator);
    try std.testing.expectEqual(9, mtx.xMax);
    try std.testing.expectEqual(2, mtx.yMax);

    try std.testing.expectEqual('0', mtx.get(0, 0));
    try std.testing.expectEqual('9', mtx.get(9, 0));
    try std.testing.expectEqual('A', mtx.get(0, 1));
    try std.testing.expectEqual('a', mtx.get(0, 2));
    try std.testing.expectEqual('j', mtx.get(9, 2));

    try std.testing.expectEqual('9', mtx.get(-1, 0));
    try std.testing.expectEqual('0', mtx.get(10, 0));
    try std.testing.expectEqual('J', mtx.get(-1, 1));
    try std.testing.expectEqual('j', mtx.get(-1, -1));
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
