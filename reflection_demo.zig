const std = @import("std");
const print = std.debug.print;
const trait = std.meta.trait;

const Dog = struct { name: []const u8, breed: []const u8, age: u8 };

fn nextInteger(n: i32, bigger: bool) i32 {
    return if (bigger) n + 1 else n - 1;
}

pub fn main() void {
    const d = Dog{ .name = "Comet", .breed = "whippet", .age = 3 };

    // Struct reflection
    // This for loop must be inline.
    inline for (std.meta.fields(Dog)) |field| {
        const T = field.type;
        print("Dog struct has field \"{s}\" with type {s}\n", .{ field.name, @typeName(T) });

        const value = @field(d, field.name);
        // comptime is required here because the compiler needs to know the type.
        if (comptime trait.isNumber(T)) print("value is {d}\n", .{value});
        if (comptime trait.isZigString(T)) print("value is {s}\n", .{value});
        // trait methods include isConstPtr, isContainer, isExtern,
        // isFloat, isIndexable, isIntegral, isManyItemPtr, isNumber,
        // isPacked, isPtrTo, isSignedInt, isSingleItemPtr, isSlice,
        // isSliceOf, isTuple, isUnsignedInt, and isZigString.

        // To test if a struct has a field with a given name, trait.hasField(name)
        // To test if a struct has a function with a given name, trait.hasFn(name)
    }

    // Function reflection
    const T = @TypeOf(nextInteger);
    print("nextInteger type is {}\n", .{T}); // fn(i32, bool) i32
    const info = @typeInfo(T);
    if (info == .Fn) { // if T is a function type ...
        // Can compare info to any of these:
        // .AnyFrame, .Array, .Bool, .ComptimeFloat, .ComptimeInt, .Enum,
        // .EnumLiteral, .ErrorSet, .ErrorUnion, .Float, .Fn, .Frame, .Int,
        // .NoReturn, .Null, .Opaque, .Optional, .Pointer, .Struct,
        // .Undefined, .Union, .Vector, .Void
        // This for loop must be inline.
        inline for (1.., info.Fn.params) |number, param| {
            // Can't get parameter name, only type.
            print("parameter {d} type is {any}\n", .{ number, param.type });
        }
        print("return type is {any}\n", .{info.Fn.return_type});
    }
}
