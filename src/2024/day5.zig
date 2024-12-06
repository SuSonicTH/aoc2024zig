const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    var arena = std.heap.ArenaAllocator.init(this.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var map: std.StringArrayHashMap(std.ArrayList([]const u8)) = std.StringArrayHashMap(std.ArrayList([]const u8)).init(allocator);

    _ = try read(&map, allocator, this.input);

    std.log.err("\n97:{any}", .{map.get("97").?.items});
    return null;
}

fn read(map: *std.StringArrayHashMap(std.ArrayList([]const u8)), allocator: mem.Allocator, input: []const u8) !usize {
    var pos: usize = 0;
    while (true) {
        const startKey = pos;
        while (input[pos] != '|') {
            pos += 1;
        }
        const key = input[startKey..pos];
        pos += 1;

        const startValue = pos;
        while (input[pos] != '\n') {
            pos += 1;
        }
        const value = input[startValue..pos];

        const v = try map.getOrPut(key);
        if (!v.found_existing) {
            v.value_ptr.* = std.ArrayList([]const u8).init(allocator);
        }
        var list = v.value_ptr.*;
        try list.append(value);
        pos += 1;
        if (input[pos] == '\n') {
            return pos + 1;
        }
    }
}

pub fn part2(this: *const @This()) !?i64 {
    _ = this;
    return null;
}

test "it should do nothing" {
    const allocator = std.heap.page_allocator;
    const input =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47    
        \\
    ;

    const problem: @This() = .{
        .input = input,
        .allocator = allocator,
    };

    try std.testing.expectEqual(null, try problem.part1());
    try std.testing.expectEqual(null, try problem.part2());
}
