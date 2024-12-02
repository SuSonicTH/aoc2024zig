const std = @import("std");
const mem = std.mem;
const common = @import("common.zig");

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    var lineit = std.mem.splitScalar(u8, this.input, '\n');
    var count: i64 = 0;
    while (lineit.next()) |line| {
        if (line.len == 0) break;

        const list = try common.split(line, ' ');
        if (isSave(list)) {
            count += 1;
        }
    }
    return count;
}

fn isSave(fields: []i64) bool {
    var first = true;
    var last: i64 = 0;
    var order: i64 = 0;

    for (fields) |current| {
        if (first) {
            first = false;
        } else {
            const diff = last - current;
            if (diff == 0 or diff < -3 or diff > 3) {
                return false;
            }
            if (order == 0) {
                order = diff;
            } else {
                if ((order < 0 and diff > 0) or (order > 0 and diff < 0)) {
                    return false;
                }
            }
        }
        last = current;
    }
    return true;
}

var sublist: [10]i64 = undefined;

pub fn part2(this: *const @This()) !?i64 {
    var lineit = std.mem.splitScalar(u8, this.input, '\n');
    var count: i64 = 0;
    while (lineit.next()) |line| {
        if (line.len == 0) break;

        const list = try common.split(line, ' ');

        if (isSave(list)) {
            count += 1;
        } else if (isSave(list[1..])) {
            count += 1;
        } else if (isSave(list[0 .. list.len - 1])) {
            count += 1;
        } else {
            for (1..list.len - 1) |i| {
                @memcpy(sublist[0..i], list[0..i]);
                @memcpy(sublist[i .. list.len - 1], list[i + 1 ..]);
                if (isSave(sublist[0 .. list.len - 1])) {
                    count += 1;
                    break;
                }
            }
        }
    }
    return count;
}

test "it should do nothing" {
    const allocator = std.heap.page_allocator;
    const input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
        \\
    ;

    const problem: @This() = .{
        .input = input,
        .allocator = allocator,
    };

    try std.testing.expectEqual(2, try problem.part1());
    try std.testing.expectEqual(4, try problem.part2());
}
