const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    var sum: i64 = 0;
    const list: List = try List.init(this.input, this.allocator);
    for (list.left.items, list.right.items) |l, r| {
        var dist = l - r;
        if (dist < 0) dist *= -1;
        sum += dist;
    }
    return sum;
}

pub fn part2(this: *const @This()) !?i64 {
    var sum: i64 = 0;
    const list: List = try List.init(this.input, this.allocator);

    for (list.left.items) |left| {
        var pos: usize = 0;
        while (pos < list.right.items.len and list.right.items[pos] < left) pos += 1;
        var count: i64 = 0;
        while (pos < list.right.items.len and list.right.items[pos] == left) {
            count += 1;
            pos += 1;
        }
        sum += left * count;
    }
    return sum;
}

const List = struct {
    left: std.ArrayList(i64),
    right: std.ArrayList(i64),

    fn init(input: []const u8, allocator: mem.Allocator) !List {
        var list: List = .{
            .left = std.ArrayList(i64).init(allocator),
            .right = std.ArrayList(i64).init(allocator),
        };

        var pos: u32 = 0;

        while (pos < input.len) {
            var start = pos;
            while (input[pos] != ' ') pos += 1;
            try list.left.append(try toNumber(input[start..pos]));

            while (input[pos] == ' ') pos += 1;

            start = pos;
            while (input[pos] != '\n') pos += 1;
            try list.right.append(try toNumber(input[start..pos]));

            pos += 1;
        }

        std.mem.sort(i64, list.left.items, {}, comptime std.sort.asc(i64));
        std.mem.sort(i64, list.right.items, {}, comptime std.sort.asc(i64));
        return list;
    }
};

fn toNumber(field: []const u8) !i64 {
    return std.fmt.parseInt(i64, field, 10);
}

test "test sample" {
    const allocator = std.heap.page_allocator;
    const input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
        \\
    ;

    const problem: @This() = .{
        .input = input,
        .allocator = allocator,
    };

    try std.testing.expectEqual(11, try problem.part1());
    try std.testing.expectEqual(31, try problem.part2());
}
