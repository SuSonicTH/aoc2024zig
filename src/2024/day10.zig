const std = @import("std");
const mem = std.mem;
const common = @import("common.zig");

const Map = common.Grid(u8);
const Track = common.Grid(bool);

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?usize {
    return getTrailRating(this.input, this.allocator, false);
}

pub fn part2(this: *const @This()) !?usize {
    return getTrailRating(this.input, this.allocator, true);
}

fn getTrailRating(input: []const u8, allocator: mem.Allocator, duplicates: bool) !?usize {
    var map: Map = try common.readGrid(input, allocator);
    defer map.deinit();

    const heads: []Position = try getHeads(&map, allocator);
    defer allocator.free(heads);

    var track = try Track.init(map.width, map.height, allocator);
    defer track.deinit();

    var score: usize = 0;
    for (heads) |head| {
        track.reset(false);
        score += getScore(&map, &track, head.x, head.y, duplicates);
    }
    return score;
}

const Position = struct {
    x: usize,
    y: usize,
};

fn getHeads(map: *Map, allocator: mem.Allocator) ![]Position {
    var list = std.ArrayList(Position).init(allocator);
    for (0..map.width) |y| {
        for (0..map.height) |x| {
            if (map.get(x, y) == '0') {
                try list.append(.{ .x = x, .y = y });
            }
        }
    }
    return list.items;
}

fn getScore(map: *Map, track: *Track, x: usize, y: usize, duplicates: bool) usize {
    const current = map.get(x, y);
    if (current == '9') {
        if (duplicates) {
            return 1;
        } else if (track.get(x, y)) {
            return 0;
        } else {
            track.set(x, y, true);
            return 1;
        }
    }

    const next = current + 1;
    var sum: usize = 0;
    if (y > 0 and map.get(x, y - 1) == next) {
        sum += getScore(map, track, x, y - 1, duplicates);
    }
    if (y < map.height - 1 and map.get(x, y + 1) == next) {
        sum += getScore(map, track, x, y + 1, duplicates);
    }
    if (x > 0 and map.get(x - 1, y) == next) {
        sum += getScore(map, track, x - 1, y, duplicates);
    }
    if (x < map.width - 1 and map.get(x + 1, y) == next) {
        sum += getScore(map, track, x + 1, y, duplicates);
    }
    return sum;
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
    try std.testing.expectEqual(81, try problem.part2());
}
