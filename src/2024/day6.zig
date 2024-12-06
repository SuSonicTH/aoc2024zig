const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Direction = enum {
    up,
    down,
    left,
    right,
};

const Vector = struct {
    x: i64,
    y: i64,
};

const Guard = struct {
    position: Vector,
    direction: Direction,

    fn turn(self: *Guard) void {
        switch (self.direction) {
            .up => self.direction = Direction.right,
            .right => self.direction = Direction.down,
            .down => self.direction = Direction.left,
            .left => self.direction = Direction.up,
        }
    }

    fn move(self: *Guard) void {
        switch (self.direction) {
            .up => self.position.y -= 1,
            .right => self.position.x += 1,
            .down => self.position.y += 1,
            .left => self.position.x -= 1,
        }
    }

    fn next(self: *Guard) Vector {
        switch (self.direction) {
            .up => return .{ .x = self.position.x, .y = self.position.y - 1 },
            .right => return .{ .x = self.position.x + 1, .y = self.position.y },
            .down => return .{ .x = self.position.x, .y = self.position.y + 1 },
            .left => return .{ .x = self.position.x - 1, .y = self.position.y },
        }
    }
};

const Map = struct {
    allocator: mem.Allocator,
    data: []u8,
    dimentions: Vector,

    fn init(input: []const u8, allocator: mem.Allocator) !Map {
        const dimentions = getMapDimentions(input);
        const data: []u8 = try allocator.alloc(u8, @as(usize, @intCast(dimentions.x)) * (@as(usize, @intCast(dimentions.y)) + 1));
        @memcpy(data, input[0..data.len]);

        return .{
            .allocator = allocator,
            .dimentions = dimentions,
            .data = data,
        };
    }

    fn getMapDimentions(input: []const u8) Vector {
        var pos: usize = 0;
        while (input[pos] != '\n') {
            pos += 1;
        }
        var dimentions: Vector = .{ .x = @intCast(pos), .y = 0 };
        while (pos < input.len) {
            if (input[pos] == '\n') {
                dimentions.y += 1;
            }
            pos += 1;
        }
        return dimentions;
    }

    fn getGuardPosition(self: Map) !Vector {
        for (0..@intCast(self.dimentions.x)) |x| {
            for (0..@intCast(self.dimentions.y)) |y| {
                if (self.get(@intCast(x), @intCast(y)) == '^') {
                    return .{ .x = @intCast(x), .y = @intCast(y) };
                }
            }
        }
        return error.GuardNotFound;
    }

    fn deinit(self: Map) void {
        self.allocator.free(self.data);
    }

    inline fn index(self: Map, x: i64, y: i64) usize {
        return @as(usize, @intCast(y)) * @as(usize, @intCast(self.dimentions.x)) + @as(usize, @intCast(x)) + @as(usize, @intCast(y));
    }

    inline fn get(self: Map, x: i64, y: i64) u8 {
        return self.data[self.index(x, y)];
    }

    inline fn set(self: Map, x: i64, y: i64, value: u8) void {
        self.data[self.index(x, y)] = value;
    }
};

const Game = struct {
    allocator: mem.Allocator,
    map: Map,
    guard: *Guard,
    positions: usize = 0,

    fn init(input: []const u8, allocator: mem.Allocator) !*Game {
        const game: *Game = try allocator.create(Game);
        game.allocator = allocator;
        game.map = try Map.init(input, allocator);
        game.guard = try allocator.create(Guard);
        game.guard.position = try game.map.getGuardPosition();
        game.guard.direction = Direction.up;
        game.positions = 0;
        return game;
    }

    fn deinit(self: *Game) void {
        self.allocator.destroy(self.guard);
        self.allocator.destroy(self);
    }

    fn next(self: Game) u8 {
        const n = self.guard.next();
        if (n.x < 0 or n.x >= self.map.dimentions.x or n.y < 0 or n.y >= self.map.dimentions.y) return 0;
        return self.map.get(n.x, n.y);
    }

    fn current(self: Game) u8 {
        const pos = self.guard.position;
        const dim = self.map.dimentions;
        if (pos.x < 0 or pos.x >= dim.x or pos.y < 0 or pos.y >= dim.y) return 0;
        return self.map.get(pos.x, pos.y);
    }

    fn mark(self: *Game) void {
        if (self.current() != 'X') {
            self.positions += 1;
            self.map.set(self.guard.position.x, self.guard.position.y, 'X');
        }
    }

    fn moveNext(self: *Game) void {
        self.mark();
        self.guard.move();
    }

    fn move(self: *Game) void {
        while (self.next() == '#') {
            self.guard.turn();
        }
        self.moveNext();
    }

    fn run(self: *Game) void {
        while (self.current() != 0) {
            self.move();
            //std.log.err("\n{s}", .{self.map.data});
        }
    }
};

pub fn part1(this: *const @This()) !?usize {
    const game: *Game = try Game.init(this.input, this.allocator);
    defer game.deinit();
    game.run();
    return game.positions;
}

pub fn part2(this: *const @This()) !?usize {
    _ = this;
    return null;
}

test "it should do nothing" {
    const allocator = std.heap.page_allocator;

    const input =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...    
        \\
    ;

    const problem: @This() = .{
        .input = input,
        .allocator = allocator,
    };

    try std.testing.expectEqual(41, try problem.part1());
    try std.testing.expectEqual(null, try problem.part2());
}

test "game init" {
    const allocator = std.heap.page_allocator;
    const input =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...    
        \\
    ;

    const game: *Game = try Game.init(input, allocator);
    defer game.deinit();
    try std.testing.expectEqual(10, game.map.dimentions.x);
    try std.testing.expectEqual(10, game.map.dimentions.y);
    try std.testing.expectEqual(4, game.guard.position.x);
    try std.testing.expectEqual(6, game.guard.position.y);

    try std.testing.expectEqual(game.map.get(game.guard.position.x, game.guard.position.y), '^');
}
