const std = @import("std");
const mem = std.mem;
const common = @import("common.zig");
const Map = common.Matrix;

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?usize {
    var map = try Map.init(this.input, this.allocator);
    const heads: []Position = try getHeads(map, this.allocator);
    var score: usize = 0;
    var track = try Track.init(map.xMax + 1, map.yMax + 1, this.allocator);
    for (heads) |head| {
        const s = getScore(&map, &track, head.x, head.y);
        track.reset();
        score += s;
    }
    return score;
}

const Position = struct {
    x: usize,
    y: usize,
};

const Track = struct {
    allocator: mem.Allocator,
    width: usize,
    height: usize,
    data: []bool,

    fn init(width: usize, height: usize, allocator: mem.Allocator) !Track {
        return .{
            .allocator = allocator,
            .width = width,
            .height = height,
            .data = try allocator.alloc(bool, width * height),
        };
    }

    fn deinit(self: *Track) void {
        self.allocator.free(self.data);
    }

    fn get(self: *Track, x: usize, y: usize) bool {
        return self.data[y * self.width + x];
    }

    fn set(self: *Track, x: usize, y: usize, value: bool) void {
        self.data[y * self.width + x] = value;
    }

    fn reset(self: *Track) void {
        @memset(self.data, false);
    }
};

fn getHeads(map: Map, allocator: mem.Allocator) ![]Position {
    var list = std.ArrayList(Position).init(allocator);
    for (0..map.yMax + 1) |y| {
        for (0..map.xMax + 1) |x| {
            if (map.get(x, y) == '0') {
                try list.append(.{ .x = x, .y = y });
            }
        }
    }
    return list.items;
}

fn getScore(map: *Map, track: *Track, x: usize, y: usize) usize {
    const current = map.uget(x, y);
    if (current == '9') {
        if (track.get(x, y)) {
            return 0;
        } else {
            track.set(x, y, true);
            return 1;
        }
    }

    const next = current + 1;
    var sum: usize = 0;
    if (y > 0 and map.uget(x, y - 1) == next) {
        sum += getScore(map, track, x, y - 1);
    }
    if (y < map.yMax and map.uget(x, y + 1) == next) {
        sum += getScore(map, track, x, y + 1);
    }
    if (x > 0 and map.uget(x - 1, y) == next) {
        sum += getScore(map, track, x - 1, y);
    }
    if (x < map.xMax and map.uget(x + 1, y) == next) {
        sum += getScore(map, track, x + 1, y);
    }
    return sum;
}

pub fn part2(this: *const @This()) !?usize {
    _ = this;
    return 0;
}

test "part 1 case 1" {
    const problem: @This() = .{
        .input =
        \\...0...
        \\...1...
        \\...2...
        \\6543456
        \\7.....7
        \\8.....8
        \\9.....9
        \\
        ,
        .allocator = std.heap.page_allocator,
    };
    try std.testing.expectEqual(2, try problem.part1());
}

test "part 1 case 2" {
    const problem: @This() = .{
        .input =
        \\..90..9
        \\...1.98
        \\...2..7
        \\6543456
        \\765.987
        \\876....
        \\987....
        \\
        ,
        .allocator = std.heap.page_allocator,
    };

    try std.testing.expectEqual(4, try problem.part1());
}

test "part 1 case 3" {
    const problem: @This() = .{
        .input =
        \\10..9..
        \\2...8..
        \\3...7..
        \\4567654
        \\...8..3
        \\...9..2
        \\.....01
        \\
        ,
        .allocator = std.heap.page_allocator,
    };

    try std.testing.expectEqual(3, try problem.part1());
}

test "test input" {
    const allocator = std.heap.page_allocator;
    const input =
        \\89010123
        \\78121874
        \\87430965
        \\96549874
        \\45678903
        \\32019012
        \\01329801
        \\10456732
        \\
    ;

    const problem: @This() = .{
        .input = input,
        .allocator = allocator,
    };

    try std.testing.expectEqual(36, try problem.part1());
    try std.testing.expectEqual(0, try problem.part2());
}
