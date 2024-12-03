const std = @import("std");
const mem = std.mem;
const common = @import("common.zig");

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    return try execute(this.input, false);
}

pub fn part2(this: *const @This()) !?i64 {
    return try execute(this.input, true);
}

fn execute(input: []const u8, extended: bool) !?i64 {
    var pos: u64 = 0;
    var answer: i64 = 0;
    var mulEnabled: bool = true;

    while (pos + 8 < input.len) {
        if (std.mem.eql(u8, input[pos .. pos + 4], "mul(")) {
            pos += 4;
            if (input[pos] >= '0' and input[pos] <= '9') {
                const startFirst = pos;
                pos += 1;
                while (input[pos] >= '0' and input[pos] <= '9') {
                    pos += 1;
                }
                const first = try common.toNumber(input[startFirst..pos]);
                if (input[pos] == ',') {
                    pos += 1;
                    if (input[pos] >= '0' and input[pos] <= '9') {
                        const startSecond = pos;
                        pos += 1;
                        while (input[pos] >= '0' and input[pos] <= '9') {
                            pos += 1;
                        }
                        const second = try common.toNumber(input[startSecond..pos]);
                        if (input[pos] == ')') {
                            if (mulEnabled) {
                                answer += first * second;
                            }
                            pos += 1;
                        }
                    }
                }
            }
        } else if (extended and std.mem.eql(u8, input[pos .. pos + 7], "don't()")) {
            mulEnabled = false;
            pos += 7;
        } else if (extended and std.mem.eql(u8, input[pos .. pos + 4], "do()")) {
            mulEnabled = true;
            pos += 4;
        } else {
            pos += 1;
        }
    }
    return answer;
}

test "it should do nothing" {
    const allocator = std.heap.page_allocator;

    const problem1: @This() = .{
        .input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))",
        .allocator = allocator,
    };

    try std.testing.expectEqual(161, try problem1.part1());

    const problem2: @This() = .{
        .input = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))",
        .allocator = allocator,
    };

    try std.testing.expectEqual(48, try problem2.part2());
}
