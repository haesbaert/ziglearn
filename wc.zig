const std = @import("std");

const stdout = std.io.getStdOut().writer();
const warn = std.debug.print;
var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = general_purpose_allocator.allocator();

var total_line_count: u64 = 0;
var total_word_count: u64 = 0;
var total_byte_count: u64 = 0;
var print_lines = false;
var print_words = false;
var print_bytes = false;

fn printit(line_count: u64, word_count: u64, byte_count: u64, name: [:0]const u8) !void {
    if (print_lines)
        try stdout.print(" {d:7}", .{line_count});
    if (print_words)
        try stdout.print(" {d:7}", .{word_count});
    if (print_bytes)
        try stdout.print(" {d:7}", .{byte_count});
    try stdout.print(" {s}\n", .{name});
}

fn doit(filename: [:0]const u8) !void {
    var line_count: u64 = 0;
    var word_count: u64 = 0;
    var byte_count: u64 = 0;
    var file = if (filename[0] != 0) try std.fs.cwd().openFile(filename, .{}) else std.io.getStdIn();
    defer if (filename[0] != 0) file.close();
    var buffer = std.io.bufferedReader(file.reader());
    var reader = buffer.reader();
    var inword = false;

    while (reader.readByte()) |c| {
        byte_count = byte_count + 1;
        if (c == '\n')
            line_count = line_count + 1;
        if ((c >= 9 and c <= 13) or c == 32) {
            inword = false;
        } else if (!inword) {
            word_count = word_count + 1;
            inword = true;
        }
    } else |err| {
        if (err == error.EndOfStream) {
            try printit(line_count, word_count, byte_count, filename);
            total_line_count += line_count;
            total_word_count += word_count;
            total_byte_count += byte_count;
        } else
            return err;
    }
}

pub fn main() !void {
    // defer general_purpose_allocator.deinit();
    var ai = std.process.args();
    var files = std.ArrayList([:0]const u8).init(gpa);
    defer files.deinit();

    _ = ai.skip();
    while (ai.next()) |a| {
        if (std.mem.eql(u8, a, "--lines")) {
            print_lines = true;
        } else if (std.mem.eql(u8, a, "--words")) {
            print_words = true;
        } else if (std.mem.eql(u8, a, "--bytes")) {
            print_bytes = true;
        } else if (a[0] == '-') {
            for (a[1..]) |c| {
                switch (c) {
                    'l' => print_lines = true,
                    'w' => print_words = true,
                    'c' => print_bytes = true,
                    else => {},
                }
            }
        } else
            try files.append(a);
    }

    if (!print_lines and !print_words and !print_bytes) {
        print_lines = true;
        print_words = true;
        print_bytes = true;
    }
    if (files.items.len == 0)
        doit("") catch |err| { warn("{!}\n", .{err}); };
    for (files.items) |file|
        doit(file) catch |err| { warn("{s}: {!}\n", .{file, err}); };
    if (files.items.len > 1)
        try printit(total_line_count, total_word_count, total_byte_count, "total");
}
