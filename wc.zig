const std = @import("std");

// pub fn main() !void {
//     var inbuf = std.io.bufferedReader(std.io.getStdIn().reader());
//     var in = inbuf.reader();
//     const c = in.readByte() catch |err| switch (err) {
//         error.EndOfStream => {
//             std.log.err("{!}", .{error.EndOfStream});
//             std.debug.print("EOF!!!\n", .{});
//             return;
//         },
//         else => |e| {
//             std.log.err("{!}", .{e});
//             return e;
//         }
//     };
//     std.debug.print("Read: {c}\n", .{c});
// }

pub fn main() !void {
    var inbuf = std.io.bufferedReader(std.io.getStdIn().reader());
    var in = inbuf.reader();

    while (true) {
        if (in.readByte()) |c| {
            std.debug.print("Read: {c}\n", .{c});
        } else |err| {
            if (err == error.EndOfStream) {
                return;
            } else {
                return err;
            }
        }
    }
}
