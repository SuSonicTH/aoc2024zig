const std = @import("std");

pub fn toNumber(field: []const u8) !i64 {
    return std.fmt.parseInt(i64, field, 10);
}

var splitBuffer: [1024]i64 = undefined;

pub fn split(line: []const u8, delimiter: u8) ![]i64 {
    var columit = std.mem.splitScalar(u8, line, delimiter);
    var i: usize = 0;
    while (columit.next()) |column| {
        splitBuffer[i] = try toNumber(column);
        i += 1;
    }
    return splitBuffer[0..i];
}
