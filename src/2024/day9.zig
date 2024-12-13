const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    var items = try readMap(this.input, this.allocator);
    var to: usize = 0;
    var from: usize = items.len - 1;

    while (true) {
        while (items[to] != -1) {
            to += 1;
        }
        while (items[from] == -1) {
            from -= 1;
        }
        if (from > to) {
            items[to] = items[from];
            items[from] = -1;
        } else {
            break;
        }
    }

    return checkSum(items);
}

pub fn part2(this: *const @This()) !?i64 {
    var items = try readMap(this.input, this.allocator);
    var to: usize = 0;
    var from: usize = items.len - 1;
    while (true) {
        const file = nextFile(items, from);
        to = 0;
        while (true) {
            if (nextSpace(items, to)) |space| {
                if (space.start > file.start) {
                    break;
                } else if (file.size <= space.size) {
                    @memcpy(items[space.start .. space.start + file.size], items[file.start .. file.end + 1]);
                    @memset(items[file.start .. file.end + 1], -1);
                    break;
                } else {
                    to = space.end + 1;
                }
            }
        }
        if (file.start == 0) {
            break;
        }
        from = file.start - 1;
    }

    return checkSum(items);
}

const File = struct {
    start: usize,
    end: usize,
    size: usize,
    id: i64,
};

fn nextFile(items: []i64, from: usize) File {
    var end = from;
    while (items[end] == -1) {
        end -= 1;
    }

    var start = end;
    while (start > 0 and items[start - 1] == items[end]) {
        start -= 1;
    }

    return .{
        .start = start,
        .end = end,
        .size = end - start + 1,
        .id = items[end],
    };
}

const Space = struct {
    start: usize,
    end: usize,
    size: usize,
};

fn nextSpace(items: []i64, from: usize) ?Space {
    var start = from;
    while (items[start] != -1 and start < items.len) {
        start += 1;
    }
    if (start >= items.len) {
        return null;
    }

    var end = start;
    while (end + 1 < items.len and items[end + 1] == -1) {
        end += 1;
    }

    return .{
        .start = start,
        .end = end,
        .size = end - start + 1,
    };
}

fn readMap(input: []const u8, allocator: mem.Allocator) ![]i64 {
    var map = std.ArrayList(i64).init(allocator);
    var block: i64 = 0;
    var isBlock = true;
    for (input) |c| {
        const val: usize = @intCast(c - '0');
        for (0..val) |_| {
            if (isBlock) {
                try map.append(block);
            } else {
                try map.append(-1);
            }
        }
        if (isBlock) {
            block += 1;
        }
        isBlock = !isBlock;
    }
    return map.items;
}

fn checkSum(items: []i64) i64 {
    var sum: i64 = 0;
    for (items, 0..) |item, pos| {
        if (item != -1) {
            sum += item * @as(i64, @intCast(pos));
        }
    }
    return sum;
}

test "it should do nothing" {
    const allocator = std.heap.page_allocator;
    const input = "2333133121414131402";

    const problem: @This() = .{
        .input = input,
        .allocator = allocator,
    };

    try std.testing.expectEqual(1928, try problem.part1());
    try std.testing.expectEqual(2858, try problem.part2());
}
