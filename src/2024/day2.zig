const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    var lineit = std.mem.splitScalar(u8, this.input, '\n');
    var count: i64 = 0;
    while (lineit.next()) |line| {
        if (line.len == 0) break;

        var columit = std.mem.splitScalar(u8, line, ' ');
        var first = true;
        var unsave = false;
        var last: i64 = 0;
        var order: i64 = 0;
        while (columit.next()) |column| {
            const current = try toNumber(column);
            if (first) {
                first = false;
            } else {
                const diff = last - current;
                if (diff == 0 or diff < -3 or diff > 3) {
                    unsave = true;
                    break;
                }
                if (order == 0) {
                    order = diff;
                } else {
                    if ((order < 0 and diff > 0) or (order > 0 and diff < 0)) {
                        unsave = true;
                        break;
                    }
                }
            }
            last = current;
        }
        if (!unsave) {
            count += 1;
        }
    }
    return count;
}

pub fn part2(this: *const @This()) !?i64 {
    _ = this;
    return 0;
}

fn toNumber(field: []const u8) !i64 {
    return std.fmt.parseInt(i64, field, 10);
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
