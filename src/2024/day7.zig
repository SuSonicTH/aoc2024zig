const std = @import("std");
const mem = std.mem;
const common = @import("common.zig");

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    var lineit = std.mem.splitScalar(u8, this.input[0 .. this.input.len - 1], '\n');
    var sum: i64 = 0;
    while (lineit.next()) |line| {
        try Equation.read(line);
        sum += try Equation.calculate();
    }
    return sum;
}

pub fn part2(this: *const @This()) !?i64 {
    var lineit = std.mem.splitScalar(u8, this.input[0 .. this.input.len - 1], '\n');
    var sum: i64 = 0;
    while (lineit.next()) |line| {
        try Equation.read(line);
        sum += try Equation.calculateExtended();
    }
    return sum;
}

const Operand = enum { add, multiply, concat };

const Equation = struct {
    var operatorBuffer: [20]Operand = undefined;
    var result: i64 = 0;
    var operands: []i64 = undefined;
    var operators: []Operand = undefined;

    fn read(line: []const u8) !void {
        if (common.instr(line, 0, ':')) |pos| {
            result = try common.toNumber(line[0..pos]);
            operands = try common.split(line[pos + 2 ..], ' ');
            operators = operatorBuffer[0 .. operands.len - 1];
            for (0..operators.len) |i| {
                operators[i] = .add;
            }
        } else {
            return error.NoColonFound;
        }
    }

    fn calculate() !i64 {
        while (true) {
            if (try equals()) {
                return result;
            }
            var pos: usize = 0;
            var carry = true;
            while (carry) {
                switch (operators[pos]) {
                    .add => {
                        operators[pos] = .multiply;
                        carry = false;
                    },
                    .multiply => {
                        if (pos == operators.len - 1) {
                            return 0;
                        }
                        operators[pos] = .add;
                    },
                    .concat => return error.IllegalOperand,
                }
                pos += 1;
            }
        }
    }

    fn calculateExtended() !i64 {
        while (true) {
            if (try equals()) {
                return result;
            }
            var pos: usize = 0;
            var carry = true;
            while (carry) {
                switch (operators[pos]) {
                    .add => {
                        operators[pos] = .multiply;
                        carry = false;
                    },
                    .multiply => {
                        operators[pos] = .concat;
                        carry = false;
                    },
                    .concat => {
                        if (pos == operators.len - 1) {
                            return 0;
                        }
                        operators[pos] = .add;
                    },
                }
                pos += 1;
            }
        }
    }

    fn equals() !bool {
        var sum: i64 = operands[0];
        for (operators, 1..) |operator, i| {
            switch (operator) {
                .add => sum += operands[i],
                .multiply => sum *= operands[i],
                .concat => {
                    var buffer: [128]u8 = undefined;
                    const concat = try std.fmt.bufPrint(&buffer, "{d}{d}", .{ sum, operands[i] });
                    sum = try common.toNumber(concat);
                },
            }
        }
        return sum == result;
    }
};

test "it should do nothing" {
    const allocator = std.heap.page_allocator;
    const input =
        \\190: 10 19
        \\3267: 81 40 27
        \\83: 17 5
        \\156: 15 6
        \\7290: 6 8 6 15
        \\161011: 16 10 13
        \\192: 17 8 14
        \\21037: 9 7 18 13
        \\292: 11 6 16 20
        \\
    ;

    const problem: @This() = .{
        .input = input,
        .allocator = allocator,
    };

    try std.testing.expectEqual(3749, try problem.part1());
    try std.testing.expectEqual(11387, try problem.part2());
}
