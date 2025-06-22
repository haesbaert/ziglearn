const std = @import("std");
const stdout = std.io.getStdOut().writer();

// This is the main function I guess
// oh no emacs misses this
pub fn main() !void {
    // OMG what does this do? I have no idea
    try stdout.print("Hello {s}\n", .{"worldez"});
}
