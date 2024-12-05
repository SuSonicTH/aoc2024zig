const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Direction = struct {
    x: i2,
    y: i2,
};

const right: Direction = .{ .x = 1, .y = 0 };
const left: Direction = .{ .x = -1, .y = 0 };
const up: Direction = .{ .x = 0, .y = -1 };
const down: Direction = .{ .x = 0, .y = 1 };
const rightUp: Direction = .{ .x = 1, .y = -1 };
const rightDown: Direction = .{ .x = 1, .y = 1 };
const leftUp: Direction = .{ .x = -1, .y = -1 };
const leftDown: Direction = .{ .x = -1, .y = 1 };

const Directions: [8]Direction = .{ right, left, up, down, rightUp, rightDown, leftUp, leftDown };

pub fn part1(this: *const @This()) !?i64 {
    const mtx: Matrix = Matrix.init(this.input);
    var count: i64 = 0;

    for (0..mtx.yMax + 1) |y| {
        for (0..mtx.xMax + 1) |x| {
            if (mtx.get(x, y) == 'X') {
                inline for (Directions) |direction| {
                    count += mtx.matches(x, y, direction, "XMAS");
                }
            }
        }
    }
    return count;
}

pub fn part2(this: *const @This()) !?i64 {
    const mtx: Matrix = Matrix.init(this.input);
    var count: i64 = 0;

    for (1..mtx.yMax) |y| {
        for (1..mtx.xMax) |x| {
            if (mtx.get(x, y) == 'A') {
                if (mtx.get(x - 1, y - 1) == 'M' and mtx.get(x + 1, y + 1) == 'S') {
                    if (mtx.get(x + 1, y - 1) == 'M' and mtx.get(x - 1, y + 1) == 'S') {
                        count += 1;
                    } else if (mtx.get(x + 1, y - 1) == 'S' and mtx.get(x - 1, y + 1) == 'M') {
                        count += 1;
                    }
                } else if (mtx.get(x - 1, y - 1) == 'S' and mtx.get(x + 1, y + 1) == 'M') {
                    if (mtx.get(x + 1, y - 1) == 'M' and mtx.get(x - 1, y + 1) == 'S') {
                        count += 1;
                    } else if (mtx.get(x + 1, y - 1) == 'S' and mtx.get(x - 1, y + 1) == 'M') {
                        count += 1;
                    }
                }
            }
        }
    }
    return count;
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

    inline fn get(self: Matrix, x: usize, y: usize) u8 {
        const pos = y * (self.xMax + 2) + x;
        return self.data[pos];
    }

    inline fn matches(self: Matrix, x: usize, y: usize, direction: Direction, word: []const u8) i64 {
        const ix: i64 = @intCast(x);
        const iy: i64 = @intCast(y);
        const len: i64 = @intCast(word.len - 1);
        const xMax = ix + direction.x * len;
        const yMax = iy + direction.y * len;
        if (xMax < 0 or xMax > self.xMax or yMax < 0 or yMax > self.yMax) return 0;
        for (word[1..], 1..) |c, i| {
            const cx: usize = @intCast(ix + direction.x * @as(i64, @intCast(i)));
            const cy: usize = @intCast(iy + direction.y * @as(i64, @intCast(i)));
            if (self.get(cx, cy) != c) {
                return 0;
            }
        }
        return 1;
    }
};

test "it should do nothing" {
    const allocator = std.heap.page_allocator;
    const input =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
        \\
    ;

    const problem: @This() = .{
        .input = input,
        .allocator = allocator,
    };

    try std.testing.expectEqual(18, try problem.part1());
    try std.testing.expectEqual(9, try problem.part2());
}

test "matrix" {
    const input =
        \\0123456789
        \\ABCDEFGHIJ
        \\abcdefghij
        \\0123456789
        \\
    ;

    const mtx: Matrix = Matrix.init(input);
    try std.testing.expectEqual(9, mtx.xMax);
    try std.testing.expectEqual(3, mtx.yMax);

    try std.testing.expectEqual('0', mtx.get(0, 0));
    try std.testing.expectEqual('9', mtx.get(9, 0));
    try std.testing.expectEqual('A', mtx.get(0, 1));
    try std.testing.expectEqual('a', mtx.get(0, 2));
    try std.testing.expectEqual('j', mtx.get(9, 2));
    try std.testing.expectEqual('9', mtx.get(9, 3));
}
