fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

fn maxInt(a: u32, b: u32) u32 {
    return max(u32, a, b);
}

export fn demo() u32 {
    return maxInt(19, 7);
}
