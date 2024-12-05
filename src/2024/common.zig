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

const Matrix = struct {
    data: []const u8 = undefined,
    xMax: usize = undefined,
    yMax: usize = undefined,

    pub fn init(input: []const u8) Matrix {
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
            .data = input,
            .xMax = xMax,
            .yMax = yMax,
        };
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
};

test "matrix" {
    const input =
        \\0123456789
        \\ABCDEFGHIJ
        \\abcdefghij
        \\
    ;

    const mtx: Matrix = Matrix.init(input);
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
