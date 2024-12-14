const std = @import("std");
const mem = std.mem;
const common = @import("common.zig");

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    var line = try readLine(this.input, this.allocator);
    defer line.deinit();
    return try line.simulate(25);
}

pub fn part2(this: *const @This()) !?i64 {
    var line = try readLine(this.input, this.allocator);
    defer line.deinit();
    return try line.simulate(75);
}

fn readLine(input: []const u8, allocator: mem.Allocator) !Line {
    var line = Line.init(allocator);
    var it = std.mem.splitScalar(u8, input[0 .. input.len - 1], ' ');
    while (it.next()) |stone| {
        try line.add(try common.toNumber(stone));
    }
    line.flip();
    return line;
}

fn evenDigits(number: i64) !bool {
    var digits: u16 = 1;
    while (true) {
        if (@divTrunc(number, try std.math.powi(i64, 10, digits)) == 0) {
            return digits % 2 == 0;
        }
        digits += 1;
    }
}

var halves: [2]i64 = undefined;
fn splitNumber(number: i64) ![2]i64 {
    var buffer: [128]u8 = undefined;
    const string = try std.fmt.bufPrint(&buffer, "{d}", .{number});
    halves[0] = try common.toNumber(string[0 .. string.len / 2]);
    halves[1] = try common.toNumber(string[string.len / 2 ..]);
    return halves;
}

const Line = struct {
    current: *std.ArrayList(i64) = undefined,
    next: *std.ArrayList(i64) = undefined,
    index: usize = 0,

    var buffer: [2]std.ArrayList(i64) = undefined;

    fn init(allocator: mem.Allocator) Line {
        buffer[0] = std.ArrayList(i64).init(allocator);
        buffer[1] = std.ArrayList(i64).init(allocator);
        return .{
            .current = &buffer[0],
            .next = &buffer[1],
        };
    }

    fn deinit(self: *Line) void {
        self.current.deinit();
        self.next.deinit();
    }

    fn get(self: *Line) ?i64 {
        if (self.index >= self.current.items.len) {
            return null;
        }
        defer self.index += 1;
        return self.current.items[self.index];
    }

    fn add(self: *Line, value: i64) !void {
        return try self.next.append(value);
    }

    fn flip(self: *Line) void {
        const temp: *std.ArrayList(i64) = self.current;
        self.current = self.next;
        self.next = temp;

        self.index = 0;
        self.next.clearRetainingCapacity();
    }

    fn simulate(self: *Line, iterations: u8) !i64 {
        for (0..iterations) |iter| {
            std.log.err("{d}:{d}", .{ iter, self.current.items.len });
            while (self.get()) |stone| {
                if (stone == 0) {
                    try self.add(1);
                } else if (try evenDigits(stone)) {
                    const parts = try splitNumber(stone);
                    try self.add(parts[0]);
                    try self.add(parts[1]);
                } else {
                    try self.add(stone * 2024);
                }
            }
            self.flip();
        }
        return @intCast(self.current.items.len);
    }
};

test "Line" {
    var line = Line.init(std.testing.allocator);
    defer line.deinit();

    try line.add(3);
    try line.add(4);
    try line.add(2);
    try line.add(1);

    line.flip();
    try std.testing.expectEqual(3, line.get().?);
    try std.testing.expectEqual(4, line.get().?);
    try std.testing.expectEqual(2, line.get().?);
    try std.testing.expectEqual(1, line.get().?);
    try std.testing.expectEqual(null, line.get());
}

test "readLine" {
    var line = try readLine("125 17\n", std.testing.allocator);
    defer line.deinit();

    try std.testing.expectEqual(125, line.get().?);
    try std.testing.expectEqual(17, line.get().?);
    try std.testing.expectEqual(null, line.get());
}

test "evenDigits" {
    try std.testing.expectEqual(false, try evenDigits(1));
    try std.testing.expectEqual(false, try evenDigits(5));
    try std.testing.expectEqual(true, try evenDigits(12));
    try std.testing.expectEqual(false, try evenDigits(123));
    try std.testing.expectEqual(true, try evenDigits(1234));
}

test "it should do nothing" {
    const allocator = std.testing.allocator;
    const input = "125 17\n";

    const problem: @This() = .{
        .input = input,
        .allocator = allocator,
    };

    try std.testing.expectEqual(55312, try problem.part1());
    try std.testing.expectEqual(1, try problem.part2());
}
