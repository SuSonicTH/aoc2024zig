const std = @import("std");
const fs = std.fs;
const io = std.io;
const heap = std.heap;

const Problem = @import("problem");

pub fn main() !void {
    const stdout = io.getStdOut().writer();

    var arena = heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const problem = Problem{
        .input = @embedFile("input"),
        .allocator = allocator,
    };

    if (try problem.part1()) |solution|
        try stdout.print(switch (@TypeOf(solution)) {
            []const u8 => "part1: {s}",
            else => "part1: {any}",
        } ++ "\n", .{solution});

    if (try problem.part2()) |solution|
        try stdout.print(switch (@TypeOf(solution)) {
            []const u8 => "part2: {s}",
            else => "part2: {any}",
        } ++ "\n", .{solution});
}
