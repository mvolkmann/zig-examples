pub fn main() !void {
    var ally_state = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = ally_state.deinit();
    const ally = ally_state.allocator();

    var server = std.http.Server.init(ally, .{});
    defer server.deinit();

    try server.listen(std.net.Address.resolveIp("0.0.0.0", 8080) catch unreachable);
    
    while(server.accept(.{ .allocator = ally }) |response| {
        defer response.deinit();

        // do stuff with response
    } else |error| {
        // handle error
    }
}